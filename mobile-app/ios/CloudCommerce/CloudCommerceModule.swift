import Foundation
import CloudCommerce
import CoreLocation
import React
import DeviceCheck
import ProximityReader

/// Provides a React Native bridge to the Mastercard CloudCommerce SDK for
/// secure payment processing using Tap to Pay for iPhone technology.
@objc(CloudCommerceModule)
@MainActor
class CloudCommerceModule: RCTEventEmitter, CLLocationManagerDelegate {
  // MARK: - Event Emitter
  
  override func supportedEvents() -> [String]! {
    return ["CloudCommerceEvent"]
  }
  
  /// CloudCommerce SDK instance - manages the entire payment lifecycle
  /// Should be initialized once per session and reused for all operations
  private var cloudCommerceSDK: CloudCommerceSDK?
  
  /// Core Location manager for GPS positioning required by Mastercard for fraud prevention
  /// Accurate location is mandatory for transaction processing per CloudCommerce requirements
  private let locationManager = CLLocationManager()
  
  /// Continuation for async location retrieval - handles GPS timeout scenarios
  private var locationContinuation: CheckedContinuation<CLLocation, Error>?
  
  /// Continuation for async location authorization - handles permission requests
  private var authorizationContinuation: CheckedContinuation<Void, Error>?
  
  override init() {
    super.init()
    locationManager.delegate = self
  }
  
  // MARK: - Accurate Location Retrieval
  
  /**
   * Retrieves accurate GPS location for transaction validation
   *
   * Per CloudCommerce SDK Integration Guide:
   * - GPS coordinates are required for all transactions for fraud prevention
   * - Horizontal accuracy must be ≤10 meters for optimal security
   * - Vertical accuracy must be ≤10 meters when available
   * - Location timestamp must be recent (within 10 seconds)
   *
   * @param timeoutSeconds Maximum time to wait for accurate GPS fix (default: 15s)
   * @returns CLLocation with accurate coordinates
   * @throws GPS timeout error if accurate location cannot be obtained
   */
  private func getAccurateLocation(timeoutSeconds: TimeInterval = 15) async throws -> CLLocation {
    try await withCheckedThrowingContinuation { continuation in
      self.locationContinuation = continuation
      self.locationManager.startUpdatingLocation()
      
      // Timeout handler to prevent indefinite waiting
      // CloudCommerce recommends 15-30 second timeout for GPS acquisition
      DispatchQueue.main.asyncAfter(deadline: .now() + timeoutSeconds) { [weak self] in // Ensure closure runs on MainActor
        guard let self = self else { return }
        if let continuation = self.locationContinuation {
          self.locationManager.stopUpdatingLocation()
          continuation.resume(throwing: NSError(domain: "GPS", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "Timed out waiting for accurate GPS fix"
          ]))
          self.locationContinuation = nil
        }
      }
    }
  }
  
  /**
   * CLLocationManagerDelegate - Location update handler
   *
   * Validates location accuracy per CloudCommerce requirements:
   * - Horizontal accuracy ≤10m (critical for fraud prevention)
   * - Vertical accuracy ≤10m (when available)
   * - Recent timestamp (within 10 seconds)
   */
  nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    // Delegate methods can be called from different threads.
    // Ensure state modification and continuation resumption happens on the MainActor.
    Task { @MainActor in
      guard let location = locations.last else { return }
      
      // CloudCommerce accuracy requirements for transaction validation
      if location.horizontalAccuracy <= 10,
         location.verticalAccuracy <= 10,
         abs(location.timestamp.timeIntervalSinceNow) < 10 {
        self.locationManager.stopUpdatingLocation() // self is MainActor isolated
        self.locationContinuation?.resume(returning: location)
        self.locationContinuation = nil
      }
    }
  }
  
  /**
   * CLLocationManagerDelegate - Location error handler
   * Propagates location errors to the calling context
   */
  // This delegate method might not be called on the main thread.
  // Explicitly hop to the MainActor if accessing MainActor-isolated state.
  nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    Task { @MainActor in
      self.locationContinuation?.resume(throwing: error) // self is MainActor isolated
      self.locationContinuation = nil
    }
  }
  
  /**
   * CLLocationManagerDelegate - Authorization status change handler
   * Handles location permission grants/denials for the first-time setup
   */
  nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    Task { @MainActor in
      switch status {
      case .authorizedWhenInUse, .authorizedAlways:
        // Permission granted - resume the prepare flow
        self.authorizationContinuation?.resume()
        self.authorizationContinuation = nil
      case .denied, .restricted:
        // Permission denied - fail the prepare flow
        let error = NSError(domain: "LocationPermission", code: 1, userInfo: [
          NSLocalizedDescriptionKey: "Location permission is required for payment processing"
        ])
        self.authorizationContinuation?.resume(throwing: error)
        self.authorizationContinuation = nil
      case .notDetermined:
        // Still waiting for user response - do nothing
        break
      @unknown default:
        // Unknown status - treat as error
        let error = NSError(domain: "LocationPermission", code: 2, userInfo: [
          NSLocalizedDescriptionKey: "Unknown location authorization status"
        ])
        self.authorizationContinuation?.resume(throwing: error)
        self.authorizationContinuation = nil
      }
    }
  }
  
  // MARK: - Location Permission Helper
  
  /**
   * Requests location permission and waits for the user response
   * 
   * This method handles the first-time location permission request flow:
   * 1. Checks current authorization status
   * 2. If already authorized, returns immediately
   * 3. If not determined, requests permission and waits for user response
   * 4. If denied, throws an error
   * 
   * @param timeoutSeconds Maximum time to wait for user response (default: 30s)
   * @throws Authorization error if permission is denied or times out
   */
  private func requestLocationPermissionIfNeeded(timeoutSeconds: TimeInterval = 30) async throws {
    let status = locationManager.authorizationStatus
    
    // If already authorized, no need to request again
    switch status {
    case .authorizedWhenInUse, .authorizedAlways:
      return
    case .denied, .restricted:
      throw NSError(domain: "LocationPermission", code: 1, userInfo: [
        NSLocalizedDescriptionKey: "Location permission is required for payment processing"
      ])
    case .notDetermined:
      // Need to request permission and wait for response
      break
    @unknown default:
      throw NSError(domain: "LocationPermission", code: 2, userInfo: [
        NSLocalizedDescriptionKey: "Unknown location authorization status"
      ])
    }
    
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      self.authorizationContinuation = continuation
      self.locationManager.requestWhenInUseAuthorization()
      
      // Timeout handler to prevent indefinite waiting for user response
      DispatchQueue.main.asyncAfter(deadline: .now() + timeoutSeconds) { [weak self] in
        guard let self = self else { return }
        if let continuation = self.authorizationContinuation {
          let error = NSError(domain: "LocationPermission", code: 3, userInfo: [
            NSLocalizedDescriptionKey: "Timed out waiting for location permission response"
          ])
          continuation.resume(throwing: error)
          self.authorizationContinuation = nil
        }
      }
    }
  }

  // MARK: - React Native Event Enum
  
  /// Enum representing structured events to be sent to React Native.
  /// Each case corresponds to a specific type of event with associated data.
  enum ReactNativeCloudCommerceEvent: Encodable {
    // General Status Updates (e.g., from prepare/resume)
    case generalStatus(message: String)

    // Reader-specific events from ProximityReader.PaymentCardReader.Event
    case readerProgress(progress: Int)
    case readerState(state: String, message: String) // For various reader states like "Ready for tap", "Card detected"

    // Transaction-specific events from CloudCommerce.CloudCommerceEvents
    case transactionState(state: String, message: String) // For "Preparing", "Authorizing", "In progress"
    case transactionApproved
    case transactionDeclined
    case transactionError(message: String) // For "Reader not ready", "Card read failure", "Error occurred"
    case unknownEvent(description: String) // Fallback for unhandled events

    // Custom CodingKeys to map enum cases to a consistent JSON structure for React Native
    enum CodingKeys: String, CodingKey {
      case type
      case message
      case code // For errors
      case progress // For reader progress
      case state // For reader and transaction states
      case success // For transaction result (approved/declined)
      case description // For unknown events
    }

    func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      switch self {
      case .generalStatus(let message):
        try container.encode("StatusUpdate", forKey: .type)
        try container.encode(message, forKey: .message)
      case .readerProgress(let progress):
        try container.encode("ReaderProgress", forKey: .type)
        try container.encode("Updating reader firmware...", forKey: .message)
        try container.encode(progress, forKey: .progress)
      case .readerState(let state, let message):
        try container.encode("ReaderState", forKey: .type)
        try container.encode(message, forKey: .message)
        try container.encode(state, forKey: .state)
      case .transactionState(let state, let message):
        try container.encode("TransactionState", forKey: .type)
        try container.encode(message, forKey: .message)
        try container.encode(state, forKey: .state)
      case .transactionApproved:
        try container.encode("TransactionResult", forKey: .type)
        try container.encode("Transaction Approved", forKey: .message)
        try container.encode(true, forKey: .success)
      case .transactionDeclined:
        try container.encode("TransactionResult", forKey: .type)
        try container.encode("Transaction Declined", forKey: .message)
        try container.encode(false, forKey: .success)
      case .transactionError(let message):
        try container.encode("Error", forKey: .type)
        try container.encode(message, forKey: .message)
        try container.encode("TRANSACTION_ERROR", forKey: .code)
      case .unknownEvent(let description):
        try container.encode("UnknownEvent", forKey: .type)
        try container.encode("An unknown event occurred: \(description)", forKey: .message)
        try container.encode(description, forKey: .description)
      }
    }
  }

  // MARK: - Event Handling
  
  /**
   * Starts a background task to observe events from the CloudCommerceSDK's event manager.
   * This should be called once the SDK is initialized.
   */
  private func startObservingEvents() {
    guard let sdk = cloudCommerceSDK else {
      print("Cannot start observing events, SDK is not initialized.")
      return
    }
    
    Task { [weak self] in
      // The for-await loop runs asynchronously and will gracefully terminate
      // when the `sdk` instance is deallocated (e.g., during `clear()`).
      for await event in sdk.eventManager.eventsStream() {
        // Ensure the module instance still exists before handling the event.
        guard let self = self else {
          print("CloudCommerceModule instance deallocated, stopping event observation.")
          break
        }
        self.handleSDKEvent(event)
      }
      print("CloudCommerce event stream closed.")
    }
  }

  /**
   * Parses an event from the SDK and sends it to React Native.
   * @param event The `CloudCommerce.EventStream` event to handle.
   */
  private func handleSDKEvent(_ event: CloudCommerce.EventStream) {
    let rnEvent: ReactNativeCloudCommerceEvent
    
    switch event {
    case .readerEvent(let readerEvent):
      // Low-level events from the card reader (ProximityReader.PaymentCardReader.Event)
      switch readerEvent {
      case .updateProgress(let progress):
        rnEvent = .readerProgress(progress: progress)
      case .notReady:
        rnEvent = .readerState(state: "notReady", message: "Reader not ready.")
      case .readyForTap:
        rnEvent = .readerState(state: "readyForTap", message: "Ready for card tap.")
      case .cardDetected:
        rnEvent = .readerState(state: "cardDetected", message: "Card detected. Hold steady.")
      case .removeCard:
        rnEvent = .readerState(state: "removeCard", message: "Remove card.")
      case .readCompleted:
        rnEvent = .readerState(state: "readCompleted", message: "Card read completed.")
      case .readRetry:
        rnEvent = .readerState(state: "readRetry", message: "Card read failed. Please retry.")
      case .readCancelled:
        rnEvent = .readerState(state: "readCancelled", message: "Card read cancelled.")
      case .pinEntryRequested:
        rnEvent = .readerState(state: "pinEntryRequested", message: "PIN entry requested on reader.")
      case .pinEntryCompleted:
        rnEvent = .readerState(state: "pinEntryCompleted", message: "PIN entry completed.")
      case .userInterfaceDismissed:
        rnEvent = .readerState(state: "userInterfaceDismissed", message: "Reader interface dismissed.")
      case .readNotCompleted:
        rnEvent = .readerState(state: "readNotCompleted", message: "Reader interface not c  ompleted.")
      @unknown default:
        rnEvent = .unknownEvent(description: "Unknown reader event: \(readerEvent)")
      }
      
    case .customEvent(let customEvent):
      // High-level business logic events from the SDK
      switch customEvent {
      case .preparing: rnEvent = .transactionState(state: "preparing", message: "Preparing terminal...")
      case .ready: rnEvent = .transactionState(state: "ready", message: "Terminal is ready.")
      case .readerNotReady(let reason): rnEvent = .transactionError(message: "Reader not ready: \(reason)")
      case .cardDetected: rnEvent = .transactionState(state: "cardDetected", message: "Card detected.")
      case .cardReadSuccess: rnEvent = .transactionState(state: "cardReadSuccess", message: "Card read successfully.")
      case .cardReadFailure: rnEvent = .transactionError(message: "Failed to read card.")
      case .authorizing: rnEvent = .transactionState(state: "authorizing", message: "Authorizing payment...")
      case .approved: rnEvent = .transactionApproved
      case .declined: rnEvent = .transactionDeclined
      case .errorOccurred: rnEvent = .transactionError(message: "An error occurred during the transaction.")
      case .inProgress: rnEvent = .transactionState(state: "inProgress", message: "Transaction in progress...")
      case .updateReaderProgress(let progress): rnEvent = .readerProgress(progress: progress)
      case .unknownEvent(let description): rnEvent = .unknownEvent(description: description)
      @unknown default: rnEvent = .unknownEvent(description: "Unknown custom event: \(customEvent)")
      }
    }
    
    do {
      let encoder = JSONEncoder()
      let data = try encoder.encode(rnEvent)
      if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
        self.sendEvent(withName: "CloudCommerceEvent", body: jsonObject)
      } else {
        self.sendEvent(withName: "CloudCommerceEvent", body: ["type": "Error", "message": "Failed to serialize native event."])
      }
    } catch {
      self.sendEvent(withName: "CloudCommerceEvent", body: ["type": "Error", "message": "Failed to encode event: \(error.localizedDescription)"])
    }
  }

  // MARK: - Error Code Extraction Helper
  
  /**
   * Extracts the actual errorCode from CloudCommerceSDKError
   * According to CloudCommerce SDK documentation, errors have this structure:
   * CloudCommerceSDKError(errorCode: "GPS005", localizedDescription: "...", ...)
   */
  private func extractCloudCommerceErrorCode(from error: Error) -> String {
    let nsError = error as NSError
    
   // DEBUG: Print everything about this error
   // print("=== ERROR DEBUG START ===")
   // print("Error type: \(type(of: error))")
   // print("Error description: \(error.localizedDescription)")
   // print("NSError domain: \(nsError.domain)")
   // print("NSError code: \(nsError.code)")
   // print("NSError userInfo: \(nsError.userInfo)")
    
    // ✅ PRIMARY METHOD: Use Mirror reflection to access CloudCommerceSDKError properties
    let mirror = Mirror(reflecting: error)
    for (label, value) in mirror.children {
      
      // Extract errorCode if found
      if label == "errorCode", let errorCodeValue = value as? String {
        return errorCodeValue
      }
    }
    
    // FALLBACK: Try userInfo for errorCode
    if let errorCode = nsError.userInfo["errorCode"] as? String {
      return errorCode
    }
    
    // Check for specific error messages that map to known codes
    let description = error.localizedDescription
    if description.contains("Merchant is not allowed to operate in the current country") {
      return "GPS004"
    }
    
    // Check if this is a ProximityReader error (Apple's error, not CloudCommerce)
    if nsError.domain == "ProximityReader.PaymentCardReaderError" {
      let readerCode = "READER\(String(format: "%03d", nsError.code))"
      return readerCode
    }
    
    // Default fallback
    let fallbackCode: String
    if nsError.domain.contains("CloudCommerce") {
      fallbackCode = "CLOUD_COMMERCE_ERROR"
    } else if nsError.domain == "NSURLErrorDomain" {
      fallbackCode = "NETWORK_ERROR"
    } else {
      fallbackCode = "UNKNOWN_ERROR"
    }
    
    return fallbackCode
  }

  // MARK: - React Native Exposed Methods
  
  /**
   * Prepare the CloudCommerce SDK for payment processing
   *
   * This is the first method that must be called to initialize the SDK session.
   * Per CloudCommerce Integration Guide, this method:
   * 1. Requests location permissions (required for all transactions)
   * 2. Obtains accurate GPS coordinates for fraud prevention
   * 3. Initializes the CloudCommerce SDK with environment settings
   * 4. Validates merchant credentials and configuration
   * 5. Returns upgrade requirements if SDK version is outdated
   *
   * @param token Authentication token from Arise backend
   * @param merchantDict Merchant configuration including:
   *   - bannerName: Display name for the merchant
   *   - categoryCode: Merchant category code (MCC)
   *   - terminalProfileId: Terminal identifier for transaction routing
   *   - currencyCode: ISO currency code (e.g., "USD")
   *   - countryCode: ISO country code (e.g., "USA")
   * @param isProd Boolean flag to set the environment. `true` for production, `false` for sandbox.
   *
   * @returns UpgradeResult containing:
   *   - forceUpgrade: boolean indicating if SDK update is mandatory
   *   - recommendedUpgrade: boolean indicating if update is recommended
   */
  @objc func prepare(_ token: String, merchantDict: NSDictionary, isProd: Bool, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
    Task {
      do {
        // STEP 1: Request and wait for location permission before proceeding
        // This prevents the "device could not be located" error on first install
        try await requestLocationPermissionIfNeeded()
        
        // STEP 2: Initialize the CloudCommerce SDK
        // Determine the target environment based on the isProd flag from React Native.
        // Use .prod if isProd is true, otherwise use .sandbox.
//        let targetEnvironment: TargetEnvironment = isProd ? .prod : .sandbox
        let sdkInstance = try CloudCommerceSDK(environment: .sandbox)
        sdkInstance.clear()
        self.cloudCommerceSDK = sdkInstance
        
        // STEP 3: Start observing SDK events
        startObservingEvents()
        
        guard let sdk = self.cloudCommerceSDK else {
          throw NSError(domain: "CloudCommerce", code: 99, userInfo: [NSLocalizedDescriptionKey: "SDK init failed"])
        }
        
        print("CloudCommerce SDK version: \(sdk.version)")

        // STEP 4: Prepare the SDK with merchant details
        let decoded: Arise.Merchant = try merchantDict.decoded() // Or your specific Merchant type
        let merchant = CloudCommerce.Merchant(from: decoded)
        
        let upgrade = try await sdk.prepare(with: token, merchant: merchant)
        
        let result: [String: Any] = [
          "forceUpgrade": upgrade.forceUpgrade,
          "recommendedUpgrade": upgrade.recommendedUpgrade
        ]
        
        resolver(result)
      } catch {
        let specificErrorCode = extractCloudCommerceErrorCode(from: error)
        rejecter(specificErrorCode, error.localizedDescription, error)
      }
    }
  }
  
  /**
   * Checks for App Attest support and generates/attests a key.
   *
   * This function is converted to async throws to fit the async/await flow.
   * Note: The clientDataHash should ideally be a hash of data your server can verify.
   */
  private func checkSupport() async throws {
    let service = DCAppAttestService.shared
    
    guard service.isSupported else {
      print("Device does not support App Attest")
      // Depending on requirements, you might throw an error here if App Attest is mandatory.
      // For now, we'll just return if not supported, matching the original logic's intent.
      return
    }
    
    let keyId: String = try await withCheckedThrowingContinuation { continuation in
      service.generateKey { keyId, error in
        if let error = error {
          print("Error generating key: \(error.localizedDescription)")
          continuation.resume(throwing: error)
        } else if let keyId = keyId {
          continuation.resume(returning: keyId)
        } else {
          continuation.resume(throwing: NSError(domain: "AppAttestService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Key ID generation failed without explicit error."]))
        }
      }
    }
    
    UserDefaults.standard.set(keyId, forKey: "appAttestKeyId")
    
    let attestation: Data = try await withCheckedThrowingContinuation { continuation in
      // Note: clientDataHash should ideally be a hash of some data your server can verify.
      // Using an empty Data() might be acceptable for some use cases or for testing.
      service.attestKey(keyId, clientDataHash: Data()) { attestation, error in
        if let attestation = attestation {
          continuation.resume(returning: attestation)
        } else if let error = error {
          continuation.resume(throwing: error)
        } else {
          continuation.resume(throwing: NSError(domain: "AppAttestService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Key attestation failed without explicit error."]))
        }
      }
    }
  }
  
  /**
   * Resume a previously prepared CloudCommerce SDK session
   *
   * Used to restore SDK state after app backgrounding or session interruption.
   * Per CloudCommerce Integration Guide:
   * - Should be called when resuming from background
   * - Validates that the session is still active
   * - Re-establishes secure connections if needed
   *
   * @param token Authentication token to validate session
   * @returns Success message when session is restored
   */
  @objc func resume(_ token: String, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
    Task {
      do {
        guard let sdk = cloudCommerceSDK else {
          throw NSError(domain: "CloudCommerce", code: 1, userInfo: [NSLocalizedDescriptionKey: "SDK not initialized"])
        }
        
        //  DEBUG: Print resume attempt
        print("=== RESUME DEBUG START ===")
        print("Attempting to resume CloudCommerce SDK with token")
        print("SDK state before resume: \(sdk)")
        
        try await sdk.resume(with: token)
        print("✅ Resume successful")
        print(" === RESUME DEBUG END ===")
        resolver("resumed")
      } catch {
        print("❌ Resume failed with error:")
        let specificErrorCode = extractCloudCommerceErrorCode(from: error)
        rejecter(specificErrorCode, error.localizedDescription, error)
      }
    }
  }
  
  /**
   * Perform a payment transaction using Tap to Pay for iPhone
   *
   * This is the core method for processing payments through the CloudCommerce SDK.
   * Per CloudCommerce Integration Guide:
   * 1. Validates transaction details and amounts
   * 2. Initiates secure NFC communication with payment cards
   * 3. Processes cryptographic operations for secure payment
   * 4. Returns transaction result with card details and authorization
   *
   * Transaction Flow:
   * - Customer presents contactless card or mobile wallet to iPhone
   * - iOS Proximity Reader framework detects payment instrument       
   * - CloudCommerce SDK handles EMV processing and authorization
   * - Result includes transaction ID, authorization code, and card details
   *
   * @param detailsDict Transaction details including:
   *   - amount: Transaction amount in decimal format (e.g., 10.00)
   *   - currencyCode: ISO currency code (e.g., "USD")
   *   - countryCode: ISO country code (e.g., "USA")
   *   - tip: Optional tip amount as string
   *   - discount: Optional discount amount as string
   *   - salesTaxAmount: Optional sales tax as string
   *   - federalTaxAmount: Optional federal tax as string
   *   - subTotal: Optional subtotal as string
   *   - customData: Optional custom data as string
   *   - orderId: Unique order identifier for tracking
   *
   * @returns Transaction object containing:
   *   - transactionId: Unique transaction identifier
   *   - authorizationCode: Payment authorization code
   *   - maskedCardNumber: Masked card number for receipts
   *   - cardBrandName: Card brand (Visa, Mastercard, etc.)
   *   - authorizedAmount: Final authorized amount
   */
  @objc(performTransaction:resolver:rejecter:) // This Task will run on the MainActor
  func performTransaction(detailsDict: NSDictionary, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
    Task {
      do {
        guard let sdk = cloudCommerceSDK else {
          throw NSError(domain: "CloudCommerce", code: 2, userInfo: [NSLocalizedDescriptionKey: "SDK not initialized"])
        }
        
        // Convert React Native transaction details to the Swift model.
        let details: TransactionDetails = try detailsDict.decoded()

        // Round amount to 2 decimal places for currency.
        var originalAmount = details.amount
        var roundedAmount = Decimal()
        NSDecimalRound(&roundedAmount, &originalAmount, 2, .plain)
        
        let result = try await sdk.performTransaction(
            for: roundedAmount,          // Amount in decimal format
            currencyCode: details.currencyCode,  // ISO currency code
            tip: details.tip,             // Optional tip amount
            discount: details.discount,   // Optional discount
            salesTaxAmount: details.salesTaxAmount,    // Optional sales tax
            federalTaxAmount: details.federalTaxAmount, // Optional federal tax
            subTotal: details.subTotal,   // Optional subtotal
            orderId: details.orderId,      // Unique order identifier
            customData: details.customData, // Optional custom data
          )
        
        // Convert Transaction object to Dictionary for React Native
        var transactionDict: [String: Any] = [:]
        
        // Use Mirror to safely extract all properties
        let mirror = Mirror(reflecting: result)
        for (label, value) in mirror.children {
          if let label = label {
            // Handle Optional values properly
            if case Optional<Any>.some(let unwrappedValue) = value {
              transactionDict[label] = unwrappedValue
            } else if case Optional<Any>.none = value {
              transactionDict[label] = NSNull()
            } else {
              transactionDict[label] = value
            }
          }
        }
        
        resolver(transactionDict)
      } catch {
        // print("Transaction failed: \(error.localizedDescription)")
        let specificErrorCode = extractCloudCommerceErrorCode(from: error)
        rejecter(specificErrorCode, error.localizedDescription, error)
      }
    }
  }
  
  /**
   * Clears the current CloudCommerce SDK session and releases resources.
   *
   * This method should be called when the user logs out or the payment flow is
   * definitively finished. It clears any stored session data, tokens, and resets
   * the SDK instance.
   */
  @objc func clear(_ resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
    // This operation is synchronous and should be safe to call from any thread,
    Task { @MainActor in
      cloudCommerceSDK?.clear()
      cloudCommerceSDK = nil
      resolver(true)
    }
  }

  /**
   * Retrieves all available SDK details in a single call.
   * This is more efficient than multiple bridge calls and avoids potential
   * synchronization issues where individual getter methods might not be found by JS.
   * @param resolver Promise resolver.
   * @param rejecter Promise rejecter.
   */
  @objc func getSdkDetails(_ resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
    Task { @MainActor in
      guard let sdk = self.cloudCommerceSDK else {
        rejecter("SDK_NOT_INITIALIZED", "CloudCommerceSDK is not initialized.", nil)
        return
      }

      var details: [String: Any] = [:]

      details["posIdentifier"] = sdk.posIdentifier ?? NSNull()
      details["deviceIdentifier"] = sdk.deviceIdentifier
      details["version"] = sdk.version
      details["sessionExpiryTime"] = sdk.sessionExpiryTime ?? NSNull()

      if let merchantDetails = sdk.merchantDetails {
        do {
          let encoder = JSONEncoder()
          let data = try encoder.encode(merchantDetails)
          if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            details["merchantDetails"] = jsonObject
          }
        } catch {
          details["merchantDetails"] = NSNull()
        }
      }

        details["information"] = sdk.information


      resolver(details)
    }
  }
  
  // MARK: - Tap to Pay Education
  
  /**
   * Shows the Tap to Pay educational screens provided by Apple SDK
   *
   * This method displays Apple's built-in educational content that teaches users
   * how to use Tap to Pay for iPhone. The educational screens are automatically
   * generated by Apple SDK for iOS 18 or newer.
   *
   * Per Apple's ProximityReader documentation:
   * - Educational content is displayed in a modal presentation
   * - Content is localized automatically based on device settings
   * - Covers topics like how to tap cards, proper positioning, etc.
   *
   * @returns Promise that resolves when educational content is dismissed
   * @throws Error if content cannot be displayed or if ProximityReader is not available
   */
  @objc func showTapToPayEducationScreens(_ resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
    Task {
      do {
        // Create ProximityReaderDiscovery instance
        let proximityReaderDiscovery = ProximityReaderDiscovery()
        
        // Fetch the educational content for the "how to tap" topic
        let content = try await proximityReaderDiscovery.content(for: ProximityReaderDiscovery.Topic.payment(.howToTap))
        
        // Get the top-most view controller to present from
        guard let controller = UIApplication.shared.topMostViewController() else {
          throw NSError(domain: "TapToPayEducation", code: 2, userInfo: [
            NSLocalizedDescriptionKey: "Could not find top view controller to present from"
          ])
        }
        
        // Present the educational content
        try await proximityReaderDiscovery.presentContent(content, from: controller)
        
        // Resolve after content is dismissed
        resolver(["success": true])
      } catch {
        rejecter("TTP_EDUCATION_ERROR", error.localizedDescription, error)
      }
    }
  }
}

// MARK: - UIApplication Extension

/// Extension to find the top-most view controller in the view hierarchy
extension UIApplication {
  func topMostViewController(base: UIViewController? = nil) -> UIViewController? {
    let base = base ?? UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }?
      .rootViewController
    
    if let nav = base as? UINavigationController {
      return topMostViewController(base: nav.visibleViewController)
    }
    
    if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
      return topMostViewController(base: selected)
    }
    
    if let presented = base?.presentedViewController {
      return topMostViewController(base: presented)
    }
    
    return base
  }
}
