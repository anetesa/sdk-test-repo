import Foundation
import UIKit
import CoreLocation
import CloudCommerce
#if canImport(ProximityReader)
import ProximityReader
#endif

class TTPService: TTPServiceProtocol, @unchecked Sendable {
    private let locationManager = CLLocationManager()
    private let _devicesService: DevicesServiceProtocol
    private let _settingsService: SettingsServiceProtocol
    private let _transactionsService: TransactionsServiceProtocol
    private let _environmentSettings: EnvironmentSettings
    private let _cloudCommerceSDK: CloudCommerceSDKProtocol?
    private let _tokenStorage: AriseTokenStorageProtocol
    private let _logger = AriseLogger.shared
    private var _eventObservationTask: Task<Void, Never>?

    public var countryCode: String?
    
    init(devicesService: DevicesServiceProtocol, settingsService: SettingsServiceProtocol, transactionsService: TransactionsServiceProtocol, environmentSettings: EnvironmentSettings, cloudCommerceSDK: CloudCommerceSDKProtocol?, tokenStorage: AriseTokenStorageProtocol) {
        self._devicesService = devicesService
        self._settingsService = settingsService
        self._transactionsService = transactionsService
        self._environmentSettings = environmentSettings
        self._cloudCommerceSDK = cloudCommerceSDK
        self._tokenStorage = tokenStorage
    }
    
    deinit {
        _eventObservationTask?.cancel()
    }
    
    func checkCompatibility() -> TTPCompatibilityResult {
        let deviceModelCheck = checkDeviceModel()
        let iosVersionCheck = checkIOSVersion()
        let locationPermission = checkLocationPermission()
        let tapToPayEntitlement = checkTapToPayEntitlement()
        
        // If permission is undetermined, request it now
        if locationPermission == .undetermined {
            Task { @MainActor in
                self.locationManager.requestWhenInUseAuthorization()
            }
        }
        
        var incompatibilityReasons: [String] = []
        if !deviceModelCheck.isCompatible {
            incompatibilityReasons.append("Device model is not compatible. Required: iPhone XS or newer. Current: \(deviceModelCheck.modelIdentifier)")
        }
        if !iosVersionCheck.isCompatible {
            incompatibilityReasons.append("iOS version is not compatible. Required: iOS \(iosVersionCheck.minimumRequiredVersion) or newer. Current: iOS \(iosVersionCheck.version)")
        }
        if locationPermission == .denied {
            incompatibilityReasons.append("Location permission is denied or restricted. Current status: \(locationPermission.rawValue)")
        }
        if tapToPayEntitlement != .available {
            incompatibilityReasons.append("Tap to Pay entitlement is not available")
        }
        
        return TTPCompatibilityResult(
            isCompatible: incompatibilityReasons.isEmpty,
            deviceModelCheck: deviceModelCheck,
            iosVersionCheck: iosVersionCheck,
            locationPermission: locationPermission,
            tapToPayEntitlement: tapToPayEntitlement,
            incompatibilityReasons: incompatibilityReasons
        )
    }
    
    private func checkDeviceModel() -> DeviceModelCheck {
        guard UIDevice.current.model.contains("iPhone") else {
            return DeviceModelCheck(
                isCompatible: false,
                modelIdentifier: UIDevice.current.localizedModel
            )
        }
        
        let modelIdentifier = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? {
            var systemInfo = utsname()
            uname(&systemInfo)
            return withUnsafePointer(to: &systemInfo.machine) {
                $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                    String(cString: $0)
                }
            }
        }()
        
        let isCompatible = modelIdentifier.hasPrefix("iPhone") && {
            let numericPart = String(modelIdentifier.dropFirst(6))
            guard let commaIndex = numericPart.firstIndex(of: ","),
                  let major = Int(String(numericPart[..<commaIndex])) else {
                return false
            }
            return major >= 11
        }()
        
        return DeviceModelCheck(isCompatible: isCompatible, modelIdentifier: modelIdentifier)
    }
    
    private func checkIOSVersion() -> IOSVersionCheck {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        return IOSVersionCheck(
            isCompatible: version.majorVersion >= 18,
            version: versionString,
            minimumRequiredVersion: "18.0"
        )
    }
    
    private func checkLocationPermission() -> LocationPermissionStatus {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return .granted
        case .denied, .restricted:
            return .denied
        default:
            return .undetermined
        }
    }
    
    private func checkTapToPayEntitlement() -> TapToPayEntitlementStatus {
        #if canImport(ProximityReader)
        return PaymentCardReader.isSupported ? .available : .unavailable
        #else
        return .unavailable
        #endif
    }
    
    /// Retrieves the Tap to Pay activation status for the current device.
    ///
    /// This method queries the ARISE API to get the device's Tap to Pay activation status
    /// using the persistent device identifier.
    ///
    /// - Returns: `TTPStatus` enum value indicating whether Tap to Pay is active or inactive.
    /// - Throws: `AriseApiError` if the API request fails or the device identifier cannot be determined.
    func getStatus() async throws -> TTPStatus {

        // Get device identifier
        let deviceId = DeviceIdentifier.shared.getDeviceIdentifier()
        _logger.verbose("Fetching TTP status for device: \(deviceId)")
        
        do {
            // Fetch device info from API
            let deviceInfo = try await _devicesService.getDeviceInfo(deviceId: deviceId)
            let status: TTPStatus = deviceInfo.tapToPayEnabled ? TTPStatus.active : .inactive

            return status
        } catch {
            try DecodingErrorHandler().handleError(error)
            throw error
            
        }
    }
    
    /// Retrieves a valid Tap to Pay JWT token, refreshing if necessary.
    ///
    /// This method checks Keychain for a valid token, and if not found or expired,
    /// generates a new token and saves it to Keychain.
    ///
    /// - Throws: `AriseApiError` if token generation fails
    func getToken() async throws -> String {
        // Check if we have a valid token in storage
        if let storedToken = _tokenStorage.loadTTPJwtToken() {
            _logger.verbose("Using stored TTP JWT token (expires at: \(storedToken.expiresAt))")
            return storedToken.token
        }
        
        // Generate new token
        let deviceId = DeviceIdentifier.shared.getDeviceIdentifier()
        let (token, expiresAt) = try await _devicesService.getTapToPayJwt(deviceId: deviceId)
        
        // Save token to storage
        do {
            try _tokenStorage.saveTTPJwtToken(token: token, expiresAt: expiresAt)
            _logger.info("✅ TTP JWT token generated and saved (expires at: \(expiresAt))")
        } catch {
            _logger.warning("Failed to save TTP JWT token to storage: \(error.localizedDescription)")
            // Continue - token is still returned even if save fails
        }
        
        return token
    }
    
    /// Clears the stored JWT token from storage, forcing a refresh on next request.
    func clearTokenCache() {
        _tokenStorage.clearTTPJwtToken()
        _cloudCommerceSDK?.clear()
        _logger.debug("TTP JWT token cleared from storage")
    }
    
    /// Activates Tap to Pay on the current device.
    ///
    /// This method initiates Apple's Tap to Pay activation workflow and updates the device
    /// status in ARISE. The method is idempotent - calling it multiple times after activation
    /// is safe.
    ///
    /// - Throws: `TTPError` if:
    ///   - SDK is not initialized
    ///   - Activation workflow fails
    ///   - Configuration is missing or invalid
    /// - Throws: `AriseApiError` if API calls fail (network errors, authentication errors, etc.)
    func activate() async throws {
        _logger.info("Starting TTP activation...")
        
        // Check current status for idempotency
        let currentStatus = try await getStatus()
        if currentStatus == .active {
            _logger.info("TTP is already active")
            return
        }
        
        guard let sdk = _cloudCommerceSDK else {
            throw TTPError.sdkNotInitialized
        }
        
        // Get JWT token for activation
        let tokenTtp = try await getToken()
        
        // Get payment settings for merchant info
        let settings = try await _settingsService.getPaymentSettings()
        
        guard let bannerName = settings.companyName,
              let categoryCode = settings.mccCode,
              let currencyCode = settings.currencyCode,
              var countryCode = settings.countryCode else {
            throw TTPError.configurationFailed("Missing required merchant configuration in payment settings", nil)
        }
        if(self.countryCode != nil ){
            countryCode = self.countryCode!
        }
        
        let merchant = Merchant(
            bannerName: bannerName,
            categoryCode: categoryCode,
            terminalProfileId:  _environmentSettings.terminalProfileId,
            currencyCode: currencyCode,
            countryCode: countryCode
        )
        
        // Initiate activation via CloudCommerce SDK
        do {
            _logger.verbose("Initiating activation workflow via CloudCommerce SDK...")
            
            let configureResult = try await sdk.configure(with: tokenTtp, merchant: merchant)
            _logger.verbose("CloudCommerce SDK configured: \(configureResult)")
            
            let isAccountLinked = try await sdk.isAccountLinked
            if !isAccountLinked {
                _logger.info("Apple T&C not accepted, presenting terms...")
                try await sdk.enableTapToPay()
                _logger.info("✅ Apple T&C accepted")
            }
            
            _logger.info("Activating Proximity Reader Framework...")
            try await sdk.activateReader()
            _logger.info("✅ Proximity Reader Framework activated")
            
            // Update device status in ARISE API after successful CloudCommerce SDK activation
            let deviceId = DeviceIdentifier.shared.getDeviceIdentifier()
            
            try await _devicesService.activateTapToPay(deviceId: deviceId)
            _logger.info("✅ Device Tap to Pay status updated in ARISE API")
            
        } catch let error as CloudCommerceSDKError {
            _logger.error("TTP activation failed: \(error.localizedDescription) Error code: \(error.errorCode)")
            throw TTPError.activationFailed(error.localizedDescription, error.errorCode)
        } catch let error as PaymentCardReaderError {
            _logger.error("TTP activation failed: \(error.localizedDescription) ")
            throw error
        } catch {
            _logger.error("TTP activation failed: \(error.localizedDescription)")
            throw TTPError.activationFailed(error.localizedDescription, nil)
        }
    }
    
    /// Prepares Tap to Pay by initializing the Proximity Reader.
    ///
    /// This method checks that TTP status is active, then configures CloudCommerce SDK
    /// with merchant information and JWT token. Safe to call multiple times.
    ///
    /// - Returns: `TTPPrepareResult` containing upgrade requirements and session expiration info.
    /// - Throws: `TTPError` if TTP status is not active or configuration fails
    func prepare() async throws {
        // Check TTP status is active
        let status = try await getStatus()
        guard status == .active else {
            throw TTPError.notActive("Tap To Pay is not activated. Current status: \(status.rawValue)")
        }
        
        guard let sdk = _cloudCommerceSDK else {
            throw TTPError.sdkNotInitialized
        }
               
        // Get payment settings for merchant info
        let settings = try await _settingsService.getPaymentSettings()
        
        // Create merchant configuration from settings
        guard let bannerName = settings.companyName,
              let categoryCode = settings.mccCode,
              let currencyCode = settings.currencyCode,
              var countryCode =  settings.countryCode else {
            throw TTPError.configurationFailed("Missing required merchant configuration in payment settings", nil)
        }
        if(self.countryCode != nil ){
            countryCode = self.countryCode!
        }
        

        let merchant = Merchant(
            bannerName: bannerName,
            categoryCode: categoryCode,
            terminalProfileId: _environmentSettings.terminalProfileId,
            currencyCode: currencyCode,
            countryCode: countryCode
        )
        
        // Configure CloudCommerce SDK
        do {
            // Get JWT token
            let ttpToken = try await getToken()
            
            let cloudCommerceResult = try await sdk.configure(with: ttpToken, merchant: merchant)
            _logger.verbose("CloudCommerce SDK configured for TTP: \(cloudCommerceResult)")
            
            let isAccountLinked = try await sdk.isAccountLinked
            if !isAccountLinked {
                _logger.error("Apple T&C not accepted")
                throw TTPError.notActive("Apple T&C not accepted")
            }

            _logger.info("Activating Proximity Reader Framework...")
            try await sdk.activateReader()
            _logger.info("✅ TTP prepared successfully")
                        
        } catch let error as CloudCommerceSDKError {
            _logger.error("TTP configure failed: \(error.localizedDescription) Error code: \(error.errorCode)")
            throw TTPError.activationFailed(error.localizedDescription, error.errorCode)
        } catch let error as PaymentCardReaderError {
            _logger.error("TTP configure failed: \(error.localizedDescription) ")
            throw error
        }
        catch {
            throw TTPError.activationFailed(error.localizedDescription, nil)
        }
    }
    
    /// Resumes Tap to Pay by refreshing the reader/session and token state.
    ///
    /// This method refreshes the internal JWT token and resumes the reader via CloudCommerce SDK.
    /// It is safe to call on app foreground events and before starting a transaction.
    /// Returns quickly if already in a ready state.
    ///
    /// - Throws: `TTPError` if:
    ///   - SDK is not initialized
    ///   - Token refresh fails
    ///   - Reader resume fails
    /// - Throws: `AriseApiError` if API calls fail (network errors, authentication errors, etc.)
    ///
    /// - Note: If resume fails, you may need to call `prepare()` or `activate()` again
    ///   to restore the reader to a ready state.
    func resume() async throws {
        guard let sdk = _cloudCommerceSDK else {
            throw TTPError.sdkNotInitialized
        }
        // Refresh token (getToken() automatically refreshes if needed)
        let ttpToken = try await getToken()
        
        // Resume the reader via CloudCommerce SDK
        do {
            try await sdk.resume(with: ttpToken)
            _logger.info("✅ TTP resumed successfully")
        } catch let error as CloudCommerceSDKError {
            _logger.error("TTP configure failed: \(error.localizedDescription). Error code: \(error.errorCode)")
            throw TTPError.activationFailed(error.localizedDescription, error.errorCode)
        }  catch {
            _logger.error("Failed to resume TTP: \(error.localizedDescription)")
            throw TTPError.configurationFailed("Failed to resume reader: \(error.localizedDescription)", nil)
        }
    }
    
    /// Shows educational information about Tap to Pay.
    ///
    /// This method presents an SDK-provided educational screen/modal with content generated by Apple.
    /// The educational content helps merchants understand setup, best practices, and device handling
    /// before accepting payments.
    ///
    /// - Parameter viewController: The view controller from which to present the educational content.
    /// - Throws: `TTPError` if:
    ///   - ProximityReader is not available on this device
    ///   - iOS version is less than 18.0
    ///   - The educational content cannot be presented
    @MainActor
    @available(iOS 18.0, *)
    func showEducationalInfo(from viewController: UIViewController) async throws {
        #if canImport(ProximityReader)
        guard PaymentCardReader.isSupported else {
            throw TTPError.configurationFailed("Tap to Pay is not supported on this device", nil)
        }
        
        do {
            let discovery = ProximityReaderDiscovery()
            // Get educational content for Tap to Pay
            let content = try await discovery.content(for: .payment(.howToTap))
            // Present the educational content modally
            try await discovery.presentContent(content, from: viewController)
            _logger.info("✅ Educational content presented successfully")
        } catch {
            _logger.error("Failed to show educational content: \(error.localizedDescription)")
            throw TTPError.configurationFailed("Failed to show educational content: \(error.localizedDescription)", nil)
        }
        #else
        throw TTPError.configurationFailed("ProximityReader framework is not available", nil)
        #endif
    }
    
    /// Performs a Tap to Pay transaction.
    ///
    /// This method presents Apple's Tap to Pay UI and guides the user through the tap flow.
    ///
    /// - Parameter request: Transaction request parameters matching CloudCommerce SDK structure.
    /// - Returns: `TTPTransactionResult` containing normalized transaction data.
    /// - Throws: `TTPError` if:
    ///   - SDK is not initialized
    ///   - TTP is not active
    ///   - Transaction fails
    /// - Throws: `PaymentCardReaderError` if the card reader encounters an error
    /// - Throws: `AriseApiError` if API calls fail (network errors, authentication errors, etc.)
    ///
    /// - Note: This method presents UI and must be called from the main thread.
    ///
    /// - Warning: This method is deprecated. Use `performTransaction(amount:)` or `performTransaction(calculationResult:isDebitCard:)` instead.
    @available(*, deprecated, message: "Use performTransaction(amount:) or performTransaction(calculationResult:isDebitCard:) instead")
    @MainActor
    func performTransaction(request: TTPTransactionRequest) async throws -> TTPTransactionResult {
        _logger.info("Starting TTP transaction for amount: \(request.amount)")
        
        // Check TTP status is active
        let status = try await getStatus()
        guard status == .active else {
            throw TTPError.notActive("Tap To Pay is not activated. Current status: \(status.rawValue)")
        }
        
        guard let sdk = _cloudCommerceSDK else {
            throw TTPError.sdkNotInitialized
        }
        
        // Get payment settings for currency
        let settings = try await _settingsService.getPaymentSettings()
        
        guard let currencyCode = settings.currencyCode else {
            throw TTPError.transactionFailed("Currency code not found in payment settings", nil)
        }
        
        // Perform transaction via CloudCommerce SDK
        do {
            _logger.verbose("Initiating transaction via CloudCommerce SDK...")
            
            // Build customData from surchargeRate if provided
            let customData: [String: String]?
            if let surchargeRate = request.surchargeRate, !surchargeRate.isEmpty {
                customData = ["surchargeRate": surchargeRate]
            } else {
                customData = nil
            }
            
            // Call CloudCommerce SDK performTransaction with all parameters
            let transactionResult = try await sdk.performTransaction(
                for: request.amount,
                currencyCode: currencyCode,
                tip: request.tip,
                discount: request.discount,
                salesTaxAmount: nil as String?,
                federalTaxAmount: nil as String?,
                subTotal: request.subTotal,
                orderId: request.orderId,
                customData: customData
            )
            
            // Map CloudCommerce SDK result to TTPTransactionResult
            let result = TTPTransactionMapper.toModel(transactionResult)
        
            _logger.info("✅ TTP transaction completed: \(result.status.rawValue)")
            return result
            
        } catch let error as CloudCommerceSDKError {
            _logger.error("TTP transaction failed: \(error.localizedDescription). Error code: \(error.errorCode)")
            throw TTPError.transactionFailed(error.localizedDescription, error.errorCode)
        } catch let error as PaymentCardReaderError {
            _logger.error("TTP transaction failed: \(error.localizedDescription)")
            throw error
        } catch {
            _logger.error("TTP transaction failed: \(error.localizedDescription)")
            throw TTPError.transactionFailed(error.localizedDescription, nil)
        }
    }
    
    /// Performs a Tap to Pay transaction with a simple amount.
    ///
    /// This method performs a transaction with only the amount parameter.
    /// If the merchant has configured Zero Cost Processing (ZCP) option as Surcharge,
    /// this method will throw an error indicating that the advanced method should be used.
    ///
    /// - Parameter amount: Transaction amount as `Decimal`.
    /// - Returns: `TTPTransactionResult` containing normalized transaction data.
    /// - Throws: `TTPError` if:
    ///   - SDK is not initialized
    ///   - TTP is not active
    ///   - Merchant has ZCP Surcharge enabled (use `performTransaction(calculationResult:isDebitCard:)` instead)
    ///   - Transaction fails or required data is missing
    /// - Throws: `AriseApiError` if API calls fail.
    @MainActor
    func performTransaction(amount: Decimal) async throws -> TTPTransactionResult {
        _logger.info("Starting simple TTP transaction for amount: \(amount)")
        
        // Check TTP status is active
        let status = try await getStatus()
        guard status == .active else {
            throw TTPError.notActive("Tap To Pay is not activated. Current status: \(status.rawValue)")
        }
        
        guard let sdk = _cloudCommerceSDK else {
            throw TTPError.sdkNotInitialized
        }
        
        // Get payment settings to check ZCP configuration
        let settings = try await _settingsService.getPaymentSettings()
        
        guard let currencyCode = settings.currencyCode else {
            throw TTPError.transactionFailed("Currency code not found in payment settings", nil)
        }
        
        // Check if merchant has ZCP option = Surcharge (option ID = 4)
        let isSurchargeEnabled = settings.zeroCostProcessingOptionId == 4
        
        // If Surcharge is enabled, throw error indicating advanced method should be used
        if isSurchargeEnabled {
            _logger.warning("ZCP Surcharge is enabled for this merchant. Simple transaction method cannot be used.")
            throw TTPError.transactionFailed(
                "This merchant has Zero Cost Processing (ZCP) option set to Surcharge. Please use the CalculateAmount method first, get calculation result and pass it to the advanced PerformTransaction method.",
                nil
            )
        }
        
        // Perform transaction via CloudCommerce SDK
        do {
            _logger.verbose("Initiating transaction via CloudCommerce SDK with amount: \(amount)")
            
            let transactionResult = try await sdk.performTransaction(
                for: amount,
                currencyCode: currencyCode,
                tip: nil,
                discount: nil,
                salesTaxAmount: nil,
                federalTaxAmount: nil,
                subTotal: nil,
                orderId: nil,
                customData: nil
            )
            
            // Map CloudCommerce SDK result to TTPTransactionResult
            let result = TTPTransactionMapper.toModel(transactionResult)
            
            _logger.info("✅ TTP transaction completed: \(result.status.rawValue)")
            return result
            
        } catch let error as CloudCommerceSDKError {
            _logger.error("TTP transaction failed: \(error.localizedDescription). Error code: \(error.errorCode)")
            throw TTPError.transactionFailed(error.localizedDescription, error.errorCode)
        } catch let error as PaymentCardReaderError {
            _logger.error("TTP transaction failed: \(error.localizedDescription)")
            throw error
        } catch {
            _logger.error("TTP transaction failed: \(error.localizedDescription)")
            throw TTPError.transactionFailed(error.localizedDescription, nil)
        }
    }
    
    /// Performs a Tap to Pay transaction with advanced amount calculation.
    ///
    /// Uses a pre-calculated amount result and allows specifying whether the card is debit or credit.
    /// All custom data (baseAmount, surchargeRate, percentageOffRate, tipRate, tipAmount) is passed
    /// to CloudCommerce SDK in the customData parameter.
    ///
    /// - Parameters:
    ///   - calculationResult: Result from `calculateAmount()` method.
    ///   - isDebitCard: `true` if the card is a debit card, `false` for credit card.
    /// - Returns: `TTPTransactionResult` containing normalized transaction data.
    /// - Throws: `TTPError` if transaction fails or required data is missing.
    /// - Throws: `AriseApiError` if API calls fail.
    @MainActor
    func performTransaction(calculationResult: CalculateAmountResponse, isDebitCard: Bool) async throws -> TTPTransactionResult {
        _logger.info("Starting advanced TTP transaction with calculation result, isDebitCard: \(isDebitCard)")
        
        // Check TTP status is active
        let status = try await getStatus()
        guard status == .active else {
            throw TTPError.notActive("Tap To Pay is not activated. Current status: \(status.rawValue)")
        }
        
        guard let sdk = _cloudCommerceSDK else {
            throw TTPError.sdkNotInitialized
        }
        
        // Get payment settings for currency
        let settings = try await _settingsService.getPaymentSettings()
        
        guard let currencyCode = settings.currencyCode else {
            throw TTPError.transactionFailed("Currency code not found in payment settings", nil)
        }
        
        // Select appropriate AmountDto based on card type
        let selectedAmount: AmountDto?
        if isDebitCard {
            selectedAmount = calculationResult.debitCard
            _logger.verbose("Using debit card amount from calculation result")
        } else {
            selectedAmount = calculationResult.creditCard
            _logger.verbose("Using credit card amount from calculation result")
        }
        
        guard let amountDto = selectedAmount else {
            let cardType = isDebitCard ? "debit" : "credit"
            throw TTPError.transactionFailed("\(cardType.capitalized) card amount not available in calculation result", nil)
        }
        
        // Build customData with all required fields
        var customData: [String: String] = [:]
        customData["isDebitCard"] = String(isDebitCard)
        customData["baseAmount"] = String(amountDto.baseAmount)
        // Only add surchargeRate if it's not zero
        if amountDto.surchargeRate > 0 {
            customData["surchargeRate"] = String(amountDto.surchargeRate)
        }
        customData["percentageOffRate"] = String(amountDto.percentageOffRate)
        customData["tipRate"] = String(amountDto.tipRate)
        customData["tipAmount"] = String(amountDto.tipAmount)
        
        _logger.verbose("Custom data: \(customData)")
        
        // Perform transaction via CloudCommerce SDK
        do {
            // Round amount to 2 decimal places (same as old CloudCommerce code)
            var originalAmount = Decimal(amountDto.totalAmount)
            var roundedAmount = Decimal()
            NSDecimalRound(&roundedAmount, &originalAmount, 2, .plain)
            
            _logger.verbose("Initiating transaction via CloudCommerce SDK with total amount: \(roundedAmount)")
            
            let transactionResult = try await sdk.performTransaction(
                for: roundedAmount,
                currencyCode: currencyCode,
                tip: amountDto.tipAmount > 0 ? String(format: "%.2f", amountDto.tipAmount) : nil,
                discount: nil,
                salesTaxAmount: nil,
                federalTaxAmount: nil,
                subTotal: nil,
                orderId: nil,
                customData: customData
            )
            
            // Map CloudCommerce SDK result to TTPTransactionResult
            let result = TTPTransactionMapper.toModel(transactionResult)
            
            _logger.info("✅ TTP transaction completed: \(result.status.rawValue)")
            return result
            
        } catch let error as CloudCommerceSDKError {
            _logger.error("TTP transaction failed: \(error.localizedDescription). Error code: \(error.errorCode)")
            throw TTPError.transactionFailed(error.localizedDescription, error.errorCode)
        } catch let error as PaymentCardReaderError {
            _logger.error("TTP transaction failed: \(error.localizedDescription)")
            throw error
        } catch {
            _logger.error("TTP transaction failed: \(error.localizedDescription)")
            throw TTPError.transactionFailed(error.localizedDescription, nil)
        }
    }
    
    /// Aborts an in-progress Tap to Pay transaction.
    ///
    /// This method cancels a transaction that is waiting for a card to be detected,
    /// but has not yet started reading the card. If the device has already begun
    /// reading the card, the transaction cannot be aborted.
    ///
    /// - Returns: `true` if the transaction was successfully aborted.
    /// - Throws: `TTPError` if:
    ///   - SDK is not initialized
    ///   - Transaction cannot be aborted because card reading has begun
    ///   - Any other error from CloudCommerce SDK
    ///
    /// - Note: This method only affects the current read operation and has no side effects on future reads.
    func abortTransaction() async throws -> Bool {
        _logger.info("Attempting to abort TTP transaction...")
        
        guard let sdk = _cloudCommerceSDK else {
            _logger.warning("CloudCommerce SDK not initialized")
            throw TTPError.sdkNotInitialized
        }
 
        // Call CloudCommerce SDK abortTransaction method
        do {
            let abortResult = try await sdk.abortTransaction()
            _logger.info("✅ Transaction successfully aborted")
            return abortResult
            
        } catch let error as CloudCommerceSDKError {
            _logger.error("Failed to abort transaction: \(error.localizedDescription) Error code: \(error.errorCode)")
            
            throw TTPError.failedToAbortTransaction("Failed to abort transaction: \(error.localizedDescription)", error.errorCode)
            
        } catch {
            _logger.error("Error while aborting transaction: \(error.localizedDescription)")
            
            throw TTPError.failedToAbortTransaction("Error occurred: \(error.localizedDescription)", nil)
        }
    }
        
    /// Converts a CloudCommerce SDK event to a TTPEvent.
    ///
    /// - Parameter event: The CloudCommerce.EventStream event to convert
    /// - Returns: A TTPEvent representing the SDK event
    private func convertToTTPEvent(_ event: CloudCommerce.EventStream) -> TTPEvent {
        let eventDescription = String(describing: event)
        let eventType = type(of: event)
        self._logger.verbose("📢 CloudCommerce SDK Event received: \(eventType) - \(eventDescription)")
        
        return TTPEventMapper.toTTPEvent(event)
    }
    
    /// Streams events from CloudCommerce SDK.
    ///
    /// This method provides access to the event stream from the Mastercard CloudCommerce SDK,
    /// which includes transaction progress events, card reader events, and other operational events.
    /// Events are automatically converted to `TTPEvent` enum which mirrors the structure of
    /// `CloudCommerce.EventStream` for easier handling.
    ///
    /// - Returns: An `AsyncStream` of `TTPEvent` events from CloudCommerce SDK.
    /// - Throws: `TTPError.sdkNotInitialized` if CloudCommerce SDK is not initialized.
    ///
    /// - Note: The stream will continue until the SDK is deinitialized or the stream is cancelled.
    ///   Multiple calls to this method will return independent streams.
    func eventsStream() throws -> AsyncStream<TTPEvent> {
        guard let sdk = _cloudCommerceSDK else {
            throw TTPError.sdkNotInitialized
        }
        
        return AsyncStream<TTPEvent> { continuation in
            let task = Task { [weak self] in
                guard let self = self else {
                    continuation.finish()
                    return
                }
                
                self._logger.verbose("Starting event stream for client...")
                
                for await event in sdk.eventManager.eventsStream() {
                    let ttpEvent = self.convertToTTPEvent(event)
                    continuation.yield(ttpEvent)
                }
                
                continuation.finish()
                self._logger.verbose("Event stream closed")
            }
            
            continuation.onTermination = { @Sendable (_: AsyncStream<TTPEvent>.Continuation.Termination) in
                task.cancel()
            }
        }
    }
}
