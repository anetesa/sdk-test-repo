import Foundation
import CloudCommerce
/// Entry point for the ARISE Mobile SDK for iOS.
///
/// Provides authenticated access to ARISE APIs, handles credential storage, and exposes high-level
/// helper methods for transaction processing, configuration, and session management.
public class AriseMobileSdk {

    private let _logger = AriseLogger.shared
    private let _tokenStorage: AriseTokenStorageProtocol
    private let _session: AriseSessionProtocol
    private let _authApi: AriseAuthApiProtocol
    private let _cloudCommerceSDK: CloudCommerceSDKProtocol?
    private let _transactionsService: TransactionsServiceProtocol
    private let _settingsService: SettingsServiceProtocol
    private let _devicesService: DevicesServiceProtocol
    private let _environmentSettings: EnvironmentSettings
    private let _tokenService: TokenServiceProtocol
    private let _ttpService: TTPServiceProtocol
    
    /// Tap to Pay functionality.
    ///
    /// Provides methods to check device compatibility with Tap to Pay on iPhone.
    public let ttp: AriseMobileTTP
    
    // TODO: remove countryCode after testing
    /// Creates a configured instance of the ARISE Mobile SDK for the desired environment.
    ///
    /// - Parameters:
    ///   - environment: Target ARISE backend (`.production` or `.uat`).
    ///   - countryCode: Optional country code to use for regional settings.
    /// - Throws:`NSError` An error if the SDK  fails to initialize.
    ///
    /// Example usage:
    /// ```swift
    /// let ariseSdk = try AriseMobileSdk(environment: .uat)
    /// ```
    public convenience init(environment: Environment, countryCode: String? = "USA") throws {
        // Try to create CloudCommerce SDK, but allow nil in test environment
        var cloudCommerceSDK: CloudCommerceSDKProtocol?
        
        do {
            // Map Arise Environment to CloudCommerce Environment
            // Note: Currently mapping all environments to sandbox for compatibility
            // This should be updated when proper environment mapping is determined
            let cloudCommerceEnvironment: CloudCommerce.TargetEnvironment = .sandbox
            let sdk = try CloudCommerceSDK(environment: cloudCommerceEnvironment)
            cloudCommerceSDK = CloudCommerceSDKWrapper(sdk)
            AriseLogger.shared.debug("Initialized CloudCommerce SDK with environment: \(cloudCommerceEnvironment), version: \(sdk.version)")
        } catch {
            AriseLogger.shared.error("Failed to initialize CloudCommerce SDK: \(error.localizedDescription)")
            // In test environment, allow SDK to continue without CloudCommerce SDK
            // This allows unit tests to run and test other functionality
            // Check multiple ways to detect test environment
            let isTestEnvironment = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
                || ProcessInfo.processInfo.environment["XCTestBundlePath"] != nil
                || NSClassFromString("XCTestCase") != nil
                || Bundle.main.bundlePath.contains("xctest")
            
            if isTestEnvironment {
                // Running in test environment - allow SDK to continue without CloudCommerce SDK
                AriseLogger.shared.warning("CloudCommerce SDK initialization failed in test environment - continuing without it")
            } else {
                throw NSError(domain: "AriseMobileSdk", code: -1, userInfo: [NSLocalizedDescriptionKey: "CloudCommerce SDK not initialized"])
            }
        }
        
        try self.init(environment: environment, countryCode: countryCode, cloudCommerceSDK: cloudCommerceSDK)
    }
    
    /// Internal initializer with dependency injection support for testing
    ///
    /// - Parameters:
    ///   - environment: Target ARISE backend (`.production` or `.uat`).
    ///   - countryCode: Optional country code to use for regional settings.
    ///   - tokenStorage: Token storage instance (for dependency injection in tests).
    ///   - session: Session instance (for dependency injection in tests).
    ///   - authApi: Authentication API instance (for dependency injection in tests).
    ///   - tokenService: Token service instance (for dependency injection in tests).
    ///   - transactionsService: Transactions service instance (for dependency injection in tests).
    ///   - settingsService: Settings service instance (for dependency injection in tests).
    ///   - devicesService: Devices service instance (for dependency injection in tests).
    ///   - ttpService: TTP service instance (for dependency injection in tests).
    ///   - cloudCommerceSDK: Optional CloudCommerce SDK instance (for dependency injection in tests).
    /// - Throws:`NSError` An error if the SDK  fails to initialize.
    internal init(
        environment: Environment,
        countryCode: String? = "USA",
        tokenStorage: AriseTokenStorageProtocol? = nil,
        session: AriseSessionProtocol? = nil,
        authApi: AriseAuthApiProtocol? = nil,
        tokenService: TokenServiceProtocol? = nil,
        transactionsService: TransactionsServiceProtocol? = nil,
        settingsService: SettingsServiceProtocol? = nil,
        devicesService: DevicesServiceProtocol? = nil,
        ttpService: TTPServiceProtocol? = nil,
        cloudCommerceSDK: CloudCommerceSDKProtocol? = nil
    ) throws {
        _environmentSettings = environment == .production ? .production : .uat
        
        // Use injected dependencies or create defaults
        let tokenStorageInstance = tokenStorage ?? AriseTokenStorage()
        let sessionInstance = session ?? AriseSession(tokenStorage: tokenStorageInstance)
        let authApiInstance = authApi ?? AriseAuthApi(environmentSettings: _environmentSettings, session: sessionInstance, tokenStorage: tokenStorageInstance)
        
        // TokenService needs concrete types, so we need to ensure we have them
        let tokenServiceInstance: TokenServiceProtocol
        if let injected = tokenService {
            tokenServiceInstance = injected
        } else {
            tokenServiceInstance = TokenService(authApi: authApiInstance, session: sessionInstance, tokenStorage: tokenStorageInstance, environmentSettings: _environmentSettings)
        }
        
        // Store references
        _tokenStorage = tokenStorageInstance
        _session = sessionInstance
        _authApi = authApiInstance
        _tokenService = tokenServiceInstance
        _cloudCommerceSDK = cloudCommerceSDK
        
        // Initialize services with shared TokenService (or use injected)
        // Note: These services require concrete TokenService type, so we need to cast
        if let transactionsServiceInstance = transactionsService {
            _transactionsService = transactionsServiceInstance
        } else if let concreteTokenService = tokenServiceInstance as? TokenService {
            _transactionsService = TransactionsService(tokenService: concreteTokenService, environmentSettings: _environmentSettings)
        } else {
            throw NSError(domain: "AriseMobileSdk", code: -1, userInfo: [NSLocalizedDescriptionKey: "TokenService must be concrete type when creating TransactionsService"])
        }
        
        if let settingsServiceInstance = settingsService {
            _settingsService = settingsServiceInstance
        } else if let concreteTokenService = tokenServiceInstance as? TokenService {
            _settingsService = SettingsService(tokenService: concreteTokenService, environmentSettings: _environmentSettings)
        } else {
            throw NSError(domain: "AriseMobileSdk", code: -1, userInfo: [NSLocalizedDescriptionKey: "TokenService must be concrete type when creating SettingsService"])
        }
        
        if let devicesServiceInstance = devicesService {
            _devicesService = devicesServiceInstance
        } else if let concreteTokenService = tokenServiceInstance as? TokenService {
            _devicesService = DevicesService(tokenService: concreteTokenService, environmentSettings: _environmentSettings)
        } else {
            throw NSError(domain: "AriseMobileSdk", code: -1, userInfo: [NSLocalizedDescriptionKey: "TokenService must be concrete type when creating DevicesService"])
        }
        
        // Use injected TTPService or create default
        if let ttpServiceInstance = ttpService {
            _ttpService = ttpServiceInstance
        } else {
            // TTPService requires concrete types
            guard let concreteDevicesService = _devicesService as? DevicesService,
                  let concreteSettingsService = _settingsService as? SettingsService,
                  let concreteTransactionsService = _transactionsService as? TransactionsService else {
                throw NSError(domain: "AriseMobileSdk", code: -1, userInfo: [NSLocalizedDescriptionKey: "Services must be concrete types when creating TTPService"])
            }
            let ttpServiceInstance = TTPService(devicesService: concreteDevicesService, settingsService: concreteSettingsService, transactionsService: concreteTransactionsService, environmentSettings: _environmentSettings, cloudCommerceSDK: cloudCommerceSDK, tokenStorage: tokenStorageInstance)
            ttpServiceInstance.countryCode = countryCode
            _ttpService = ttpServiceInstance
        }
        
        ttp = AriseMobileTTP(ttpService: _ttpService)
    }
    
    /// Configures how verbose the ARISE Mobile SDK for iOS logging should be.
    ///
    /// - Parameters:
    ///   - level: Minimum log level that will be written to the console.
    ///
    /// Example usage:
    /// ```swift
    /// ariseSdk.setLogLevel(.info)
    /// ```
    public func setLogLevel(_ level: LogLevel) {
        _logger.setLogLevel(level)
        // Enable CloudCommerce SDK performance logs for debug/verbose levels
        if level == .debug || level == .verbose {
            if let sdk = _cloudCommerceSDK {
                sdk.enablePerformanceLogging(true)
                _logger.debug("CloudCommerce SDK performance logs enabled")
            }
        }
    }
    
    /// Returns the current logging level used by the ARISE Mobile SDK for iOS.
    ///
    /// - Returns: The active `LogLevel` value.
    ///
    /// Example usage:
    /// ```swift
    /// let currentLevel = ariseSdk.getLogLevel()
    /// ```
    public func getLogLevel() -> LogLevel {
        return _logger.getLogLevel()
    }
    
    /// Authenticates the merchant application against the ARISE API using client credentials.
    ///
    /// - Parameters:
    ///   - clientId: Client identifier issued in the ARISE merchant portal.
    ///   - clientSecret: Client secret paired with the client identifier.
    /// - Returns: `AuthenticationResult` containing access token, refresh token, and expiration metadata.
    /// - Throws: `AuthenticationError` when ARISE rejects the credentials or the network request fails.
    ///
    /// Example usage:
    /// ```swift
    /// let auth = try await ariseSdk.authenticate(clientId: "merchant-id", clientSecret: "secret")
    /// print("Access token expires at \(auth.expirationDate)")
    /// ```
    public func authenticate(clientId: String, clientSecret: String) async throws -> AuthenticationResult {
       
        return try await _tokenService.authenticate(clientId: clientId, clientSecret: clientSecret)
    }
    
    /// Returns the version of the embedded CloudCommerce SDK binary.
    ///
    /// - Returns: Version string reported by CloudCommerce.
    /// - Throws: `NSError` if the underlying CloudCommerce SDK was not initialized successfully.
    ///
    /// Example usage:
    /// ```swift
    /// let cloudVersion = try ariseSdk.getCloudCommerceVersion()
    /// print("Using CloudCommerce SDK \(cloudVersion)")
    /// ```
    public func getCloudCommerceVersion() throws -> String {
        _logger.debug("Getting CloudCommerce SDK version")
        guard let sdk = _cloudCommerceSDK else {
            _logger.error("Failed to get CloudCommerce SDK version: not initialized")
            throw NSError(domain: "AriseMobileSdk", code: -1, userInfo: [NSLocalizedDescriptionKey: "CloudCommerce SDK not initialized"])
        }
        let version = sdk.version
        _logger.info("CloudCommerce SDK version: \(version)")
        
        return version
    }
    
    /// Returns the version of the ARISE Mobile SDK for iOS that is embedded in your application.
    ///
    /// - Returns: Version string from the framework bundle.
    ///
    /// Example usage:
    /// ```swift
    /// let sdkVersion = ariseSdk.getVersion()
    /// print("ARISE SDK version \(sdkVersion)")
    /// ```
    public func getVersion() -> String {
        let bundle = Bundle(for: type(of: self))
        let shortVersion = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        
        return shortVersion
    }
    
    /// Returns the persistent device identifier stored in Keychain.
    ///
    /// Example usage:
    /// ```swift
    /// let deviceId = ariseSdk.getDeviceId()
    /// print("Device ID: \(deviceId)")
    /// ```
    public func getDeviceId() -> String {
        return DeviceIdentifier.shared.getDeviceIdentifier()
    }

    /// Retrieves a stored ARISE access token when one is still valid.
    ///
    /// The method first checks the in-memory session cache and falls back to secure storage if needed.
    ///
    /// - Returns: A valid bearer token string or `nil` when no active session exists.
    ///
    /// Example usage:
    /// ```swift
    /// if let token = await ariseSdk.getAccessToken() {
    ///     print("Existing token: \(token)")
    /// }
    /// ```
    public func getAccessToken() async -> String? {
        
        return await _tokenService.getAccessToken()
    }

    /// Removes any stored ARISE authentication tokens from the device.
    ///
    /// Example usage:
    /// ```swift
    /// ariseSdk.clearStoredToken()
    /// ```
    public func clearStoredToken() {
      
        _tokenService.clearStoredToken()
        _ttpService.clearTokenCache()
        // Ensure in-memory session is also cleared
        _session.clear()
    }

    /// Exchanges the refresh token for a new ARISE access token.
    ///
    /// - Returns: Updated `AuthenticationResult` containing fresh tokens.
    /// - Throws: `AuthenticationError` if the refresh token is missing, expired, or invalid.
    ///
    /// Example usage:
    /// ```swift
    /// let refreshed = try await ariseSdk.refreshAccessToken()
    /// print("New access token: \(refreshed.accessToken)")
    /// ```
    public func refreshAccessToken() async throws -> AuthenticationResult {
        
        return try await _tokenService.refreshToken()
    }
    
    /// Retrieves a paginated list of transactions from the ARISE API.
    ///
    /// Use filters to scope the response by pagination, date ranges, or batch identifiers.
    ///
    /// - Parameters:
    ///   - filters: Optional filters for transactions (pagination, sorting, batch filters, etc.)
    /// - Returns:`TransactionsResponse` containing the transaction list and pagination metadata.
    /// - Throws: `AriseApiError` if ARISE rejects the request or the response cannot be decoded.
    /// 
    /// Example usage:
    /// ```swift
    /// let filters = try TransactionFilters(
    ///     page: 0,
    ///     pageSize: 20,
    ///     asc: true,
    ///     orderBy: "date",
    ///     batchId: "d6fdd754-c287-4c61-84ff-55d8bc5ad5fb"
    /// )
    /// let result = try await ariseSdk.getTransactions(filters: filters)
    /// print("Found \(result.items.count) transactions")
    /// ```
    public func getTransactions(filters: TransactionFilters? = nil) async throws -> TransactionsResponse? {
        return try await _transactionsService.getTransactions(filters: filters)
    }
    
    /// Get transaction receipt (detailed transaction information).
    ///
    /// Retrieves complete details for a specific transaction by IDs identifier.
    ///
    /// - Parameters:
    ///   - id: Transaction unique identifier (UUID format)
    /// - Returns: `TransactionDetails` describing the transaction, or `nil` when the transaction cannot be found.
    /// - Throws: `AriseApiError` if the ARISE API rejects the request.
    /// 
    /// 
    /// Example usage:
    /// ```swift
    /// let transactionId = "123e4567-e89b-12d3-a456-426614174000"
    /// if let details = try await ariseSdk.getTransactionDetails(id: transactionId) {
    ///     print("Transaction ID: \(details.transactionId ?? "N/A")")
    ///     print("Amount: \(details.amount?.totalAmount ?? 0)")
    ///     print("Status: \(details.status ?? "N/A")")
    /// }
    /// ```
    public func getTransactionDetails(id: String) async throws -> TransactionDetails? {
        return try await _transactionsService.getTransactionDetails(id: id)
    }
    
    /// Submits an authorization transaction through the ARISE payment API.
    ///
    /// Authorizes a payment without immediately capturing funds so that you can confirm availability before fulfillment.
    ///
    /// - Parameters:
    ///   - input: Authorization transaction request payload.
    /// - Returns: `AuthorizationResponse` describing the transaction status, identifiers, receipt, and auth codes.
    /// - Throws: `AriseApiError` if validation fails or the ARISE API returns an error.
    ///
    ///
    /// Example usage:
    /// ```swift
    /// let input = try AuthorizationRequest(
    ///     paymentProcessorId: "197c05e0-f99a-49bb-905c-d3da9d1e7200",
    ///     amount: 123.45,
    ///     currencyId: 1,
    ///     cardDataSource: .manual,
    ///     accountNumber: "4111111111111111",
    ///     expirationMonth: 12,
    ///     expirationYear: 24,
    ///     securityCode: "123"
    /// )
    /// let result = try await ariseSdk.submitAuthTransaction(input: input)
    /// print("Transaction ID: \(result.transactionId ?? "N/A")")
    /// print("Status: \(result.status ?? "N/A")")
    /// print("Auth Code: \(result.authorizationCode ?? "N/A")")
    /// ```
    public func submitAuthTransaction(input: AuthorizationRequest) async throws -> AuthorizationResponse {
        return try await _transactionsService.submitAuthTransaction(request: input)
    }
    
    /// Submits a sale transaction (authorize + capture in one step) through the ARISE payment API.
    ///
    /// - Parameters:
    ///   - input: Sale transaction request payload.
    /// - Returns: `AuthorizationResponse` containing the transaction status, identifiers, receipt, and settlement indicators.
    /// - Throws: `AriseApiError` if validation fails or the ARISE API returns an error.
    ///
    /// Example usage:
    /// ```swift
    /// let input = try AuthorizationRequest(
    ///     paymentProcessorId: "197c05e0-f99a-49bb-905c-d3da9d1e7200",
    ///     amount: 54.99,
    ///     currencyId: 1,
    ///     cardDataSource: .manual,
    ///     accountNumber: "4111111111111111",
    ///     expirationMonth: 12,
    ///     expirationYear: 24,
    ///     securityCode: "123",
    ///     tipAmount: 5.00,
    ///     useCardPrice: true
    /// )
    /// let result = try await ariseSdk.submitSaleTransaction(input: input)
    /// print("Status: \(result.status ?? "N/A")")
    /// print("Total: \(result.transactionReceipt?.amount?.totalAmount ?? 0)")
    /// ```
    public func submitSaleTransaction(input: AuthorizationRequest) async throws -> AuthorizationResponse {
        return try await _transactionsService.submitSaleTransaction(request: input)
    }
    
    /// Calculates the final customer-facing amount based on the merchant's settings.
    ///
    /// - Parameters:
    ///   - request:`CalculateAmountRequest` including base amount, optional discounts, and pricing mode.
    /// - Returns: `CalculateAmountResponse` containing currency metadata and per-tender breakdown (cash, credit, debit, ACH).
    /// - Throws: `AriseApiError` if the calculation request is rejected or cannot be processed.
    ///
    /// Example usage:
    /// ```swift
    /// let calculation = try await ariseSdk.calculateAmount(
    ///     request: CalculateAmountRequest(
    ///         amount: 100.0,
    ///         percentageOffRate: 5.0,
    ///         surchargeRate: 3.0,
    ///         tipAmount: 10.0,
    ///         useCardPrice: true
    ///     )
    /// )
    /// print("Card total: \(calculation.creditCard?.totalAmount ?? 0)")
    /// print("Cash total: \(calculation.cash?.totalAmount ?? 0)")
    /// ```
    public func calculateAmount(request: CalculateAmountRequest) async throws -> CalculateAmountResponse {
        return try await _transactionsService.calculateAmount(request: request)
    }
    
    /// Voids an in-flight or same-day authorization or sale transaction in ARISE.
    ///
    /// - Parameters:
    ///   - transactionId: Unique transaction identifier (UUID) to void.
    /// - Returns: `TransactionResponse` containing updated transaction details.
    /// - Throws: `AriseApiError` if the transaction cannot be voided or the ARISE API returns an error.
    ///
    /// Example usage:
    /// ```swift
    /// let transactionId = "123e4567-e89b-12d3-a456-426614174000"
    /// do {
    ///     let result = try await ariseSdk.voidTransaction(transactionId: transactionId)
    ///     print("Transaction voided successfully")
    ///     print("New status: \(result.status ?? "N/A")")
    ///     print("Response Code: \(result.authorisationResponseCode ?? "N/A")")
    /// } catch AriseApiError.apiError(let message) {
    ///     print("Cannot void transaction: \(message)")
    /// }
    /// ```
    public func voidTransaction(transactionId: String) async throws -> TransactionResponse {
        
        return try await _transactionsService.voidTransaction(transactionId: transactionId)
    }
    
    /// Captures funds for a previously authorized transaction.
    ///
    /// - Parameters:
    ///   - transactionId: Identifier of the authorization to capture.
    ///   - amount: Amount to capture (must not exceed the remaining authorized amount).
    /// - Returns: `TransactionResponse` containing updated transaction details.
    /// - Throws: `AriseApiError` if validation fails or the ARISE API returns an error.
    ///
    /// Example usage:
    /// ```swift
    /// let details = try await ariseSdk.getTransactionDetails(id: transactionId)
    /// let amountToCapture = details?.amount?.totalAmount ?? 0
    /// let result = try await ariseSdk.captureTransaction(
    ///     transactionId: transactionId,
    ///     amount: amountToCapture
    /// )
    /// print("Status: \(result.status ?? "N/A")")
    /// ```
    public func captureTransaction(transactionId: String, amount: Double) async throws -> TransactionResponse {
        return try await _transactionsService.captureTransaction(
            transactionId: transactionId,
            amount: amount
        )
    }

    /// Processes a full or partial refund for a settled transaction.
    ///
    /// - Parameters:
    ///   - request: `RefundRequest` containing the transaction ID, optional amount, and card-present metadata.
    /// - Returns: `TransactionResponse` containing updated transaction details.
    /// - Throws: `AriseApiError` if validation fails or the ARISE API rejects the refund.
    ///
    /// Example usage:
    /// ```swift
    /// // Partial refund
    /// let partialResult = try await ariseSdk.refundTransaction(
    ///     RefundRequest(
    ///         transactionId: transactionId,
    ///         amount: 25.00,
    ///         cardDataSource: .manual
    ///     )
    /// )
    /// print("Partial refund approved: \(partialResult.transactionReceipt?.amount?.totalAmount ?? 0)")
    ///
    /// // Full remaining refund
    /// let fullResult = try await ariseSdk.refundTransaction(
    ///     RefundRequest(
    ///         transactionId: transactionId,
    ///         cardDataSource: .manual
    ///     )
    /// )
    /// print("Remaining amount refunded. New status: \(fullResult.status ?? "N/A")")
    /// ```
    public func refundTransaction(request: RefundRequest) async throws -> TransactionResponse {
        return try await _transactionsService.refundTransaction(request: request)
    }
    
    /// Retrieves payment configuration settings for the merchant organization.
    ///
    /// - Returns: `PaymentSettings` containing normalized configuration data.
    /// - Throws: `AriseApiError` if the ARISE API rejects the request or the response cannot be decoded.
    ///
    /// Example usage:
    /// ```swift
    /// let settings = try await ariseSdk.getPaymentSettings()
    /// print("Available currencies: \(settings.availableCurrencies.map { $0.name ?? "" })")
    /// print("ZCP mode: \(settings.zeroCostProcessingOption ?? "None")")
    /// print("Tips enabled: \(settings.isTipsEnabled)")
    /// print("Default surcharge rate: \(settings.defaultSurchargeRate ?? 0)%")
    /// ```
    public func getPaymentSettings() async throws -> PaymentSettingsResponse {
        return try await _settingsService.getPaymentSettings()
    }

    /// Retrieves Tap to Pay capable devices linked to the authenticated merchant.
    ///
    /// - Returns: `DevicesResponse` containing device metadata straight from the merchant devices API (identifier, device name, Tap to Pay status text/id, last login timestamp, associated profiles).
    /// - Throws: `AriseApiError` when the API returns an error or the response cannot be decoded.
    ///
    /// Example usage:
    /// ```swift
    /// let devices = try await ariseSdk.getDevices()
    /// devices.devices.forEach { device in
    ///     print("\(device.deviceName) -> \(device.tapToPayStatus ?? "Unknown")")
    /// }
    /// ```
    public func getDevices() async throws -> DevicesResponse {
        return try await _devicesService.getDevices()
    }
    
    /// Retrieves detailed information for a specific device by its identifier.
    ///
    /// - Parameters:
    ///   - deviceId: Unique device identifier in UUID format (e.g., "123e4567-e89b-12d3-a456-426614174000").
    /// - Returns: `DeviceInfo` containing device details.
    /// - Throws: `AriseApiError`  when the API returns an error or the response cannot be decoded.
    ///
    /// Example usage:
    /// ```swift
    /// let deviceId = "123e4567-e89b-12d3-a456-426614174000"
    /// do {
    ///     let deviceInfo = try await ariseSdk.getDeviceInfo(deviceId: deviceId)
    ///     print("Device: \(deviceInfo.deviceName ?? "Unknown")")
    ///     print("TTP Status: \(deviceInfo.tapToPayStatus ?? "Unknown")")
    ///     print("TTP Enabled: \(deviceInfo.tapToPayEnabled)")
    ///     print("Last Login: \(deviceInfo.lastLoginAt?.description ?? "Never")")
    /// } catch AriseApiError.apiError(let message) {
    ///     print("Error retrieving device: \(message)")
    /// }
    /// ```
    public func getDeviceInfo(deviceId: String) async throws -> DeviceInfo {
        return try await _devicesService.getDeviceInfo(deviceId: deviceId)
    }
    
}
