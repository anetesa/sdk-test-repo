import Foundation
import UIKit

/// Tap to Pay functionality for ARISE Mobile SDK.
///
/// Provides methods to check device compatibility with Tap to Pay on iPhone.
public class AriseMobileTTP {
    private let _ttpService: TTPServiceProtocol
    
    init(ttpService: TTPServiceProtocol) {
        self._ttpService = ttpService
    }
    
    /// Checks whether the current device can use Tap to Pay on iPhone.
    ///
    /// This method performs non-blocking checks for:
    /// - Device model (must be iPhone XS or newer)
    /// - iOS version (must be iOS 18 or newer)
    /// - Location permission status (granted/denied/undetermined)
    /// - Tap to Pay entitlement availability
    ///
    /// - Returns: `TTPCompatibilityResult` containing detailed compatibility information.
    ///   The `isCompatible` property is `true` when all prerequisites are met.
    ///
    /// - Note: This method does not trigger permission prompts. It only checks the current status.
    ///
    /// Example usage:
    /// ```swift
    /// let result = ariseSdk.ttp.checkCompatibility()
    /// if result.isCompatible {
    ///     print("Device is compatible with Tap to Pay")
    ///     print("Device: \(result.deviceModelCheck.modelIdentifier)")
    ///     print("iOS Version: \(result.iosVersionCheck.version)")
    /// } else {
    ///     print("Device is not compatible:")
    ///     for reason in result.incompatibilityReasons {
    ///         print("- \(reason)")
    ///     }
    /// }
    /// ```
    public func checkCompatibility() -> TTPCompatibilityResult {
        return _ttpService.checkCompatibility()
    }
    
    /// Retrieves the Tap to Pay activation status for the current device.
    ///
    /// This method returns the device's Tap to Pay activation status by querying
    /// the ARISE API using the persistent device identifier. The status indicates
    /// whether Tap to Pay is currently activated and ready to use on the device.
    ///
    /// - Returns: `TTPStatus` enum value:
    ///   - `.active`: Tap to Pay is activated and ready to use.
    ///   - `.inactive`: Tap to Pay is not activated.
    /// - Throws: `AriseApiError` if:
    ///   - The API request fails (network error, authentication error, etc.)
    ///   - The device identifier cannot be determined
    ///   - The device is not found in the system
    ///
    /// - Note: This method requires authentication. Call `authenticate()` before using this method.
    ///
    /// Example usage:
    /// ```swift
    /// // Get status
    /// do {
    ///     let status = try await ariseSdk.ttp.getStatus()
    ///     if status == .active {
    ///         print("Tap to Pay is active")
    ///     } else {
    ///         print("Tap to Pay is inactive - guide user through activation")
    ///     }
    /// } catch AriseApiError.apiError(let message) {
    ///     print("Failed to get status: \(message)")
    /// }
    /// ```
    public func getStatus() async throws -> TTPStatus {
        return try await _ttpService.getStatus()
    }
    
    /// Prepares Tap to Pay by initializing the Proximity Reader in the background.
    ///
    /// This method warms up the device and initializes the Proximity Reader so that
    /// Tap to Pay operations can start faster when needed. The initialization happens
    /// in the background without presenting any UI.
    ///
    /// - Throws: `TTPError` if:
    ///   - Tap to Pay status is not active (returns specific error)
    ///   - CloudCommerce SDK is not initialized
    ///   - CloudCommerce SDK configuration fails
    /// - Throws: `AriseApiError` if JWT token generation or API calls fail
    ///
    /// - Note: Safe to call multiple times; subsequent calls are fast no-ops.
    ///   Recommended to call early (e.g., post-login) for better performance.
    ///
    /// Example usage:
    /// ```swift
    /// do {
    ///     try await ariseSdk.ttp.prepare()
    ///     print("Tap to Pay is ready")
    /// } catch let error as TTPError {
    ///     print("Failed to prepare: \(error.localizedDescription)")
    /// }
    /// ```
    public func prepare() async throws {
        try await _ttpService.prepare()
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
    ///   to restore the reader to a ready state. Safe to call multiple times.
    ///
    /// Example usage:
    /// ```swift
    /// // Resume when app returns to foreground
    /// NotificationCenter.default.addObserver(
    ///     forName: UIApplication.willEnterForegroundNotification,
    ///     object: nil,
    ///     queue: .main
    /// ) { _ in
    ///     Task {
    ///         do {
    ///             try await ariseSdk.ttp.resume()
    ///             print("✅ TTP resumed successfully")
    ///         } catch let error as TTPError {
    ///             print("❌ Resume failed: \(error.localizedDescription)")
    ///             // May need to call prepare() or activate() again
    ///         }
    ///     }
    /// }
    /// ```
    public func resume() async throws {
        try await _ttpService.resume()
    }
    
    /// Shows educational information about Tap to Pay.
    ///
    /// This method presents an SDK-provided educational screen/modal with content generated by Apple.
    /// The educational content helps merchants understand setup, best practices, and device handling
    /// before accepting payments.
    ///
    /// - Parameter viewController: The view controller from which to present the educational content.
    ///   This should typically be the current view controller or the root view controller of your app.
    /// - Throws: `TTPError` if:
    ///   - Tap to Pay is not supported on this device
    ///   - iOS version is less than 18.0
    ///   - The educational content cannot be presented
    ///
    /// - Note: This method must be called from the main thread. The educational screen is presented
    ///   modally and returns control to the app when dismissed by the user. Requires iOS 18.0 or newer.
    ///
    /// Example usage:
    /// ```swift
    /// // Show educational content from current view controller
    /// if #available(iOS 18.0, *) {
    ///     do {
    ///         try await ariseSdk.ttp.showEducationalInfo(from: self)
    ///         print("Educational content was shown and dismissed")
    ///     } catch let error as TTPError {
    ///         print("Failed to show educational content: \(error.localizedDescription)")
    ///     }
    /// } else {
    ///     print("Educational content requires iOS 18.0 or newer")
    /// }
    /// ```
    @MainActor
    @available(iOS 18.0, *)
    public func showEducationalInfo(from viewController: UIViewController) async throws {
        try await _ttpService.showEducationalInfo(from: viewController)
    }
    
    /// Activates Tap to Pay on the current device.
    ///
    /// This method initiates Apple's Tap to Pay activation workflow and updates the device
    /// status in ARISE. The method is idempotent - calling it multiple times after activation
    /// is safe and returns the current status.
    ///
    /// - Throws: `TTPError` if:
    ///   - SDK is not initialized
    ///   - Activation workflow fails
    ///   - Configuration is missing or invalid
    /// - Throws: `AriseApiError` if API calls fail (network errors, authentication errors, etc.)
    ///
    /// - Note: If an automatic read/session begins unexpectedly during activation,
    ///   it will be safely aborted before completing activation. The method handles
    ///   comprehensive error mapping (Apple/MC/Network).
    ///
    /// Example usage:
    /// ```swift
    /// do {
    ///     try await ariseSdk.ttp.activate()
    /// } catch let error as TTPError {
    ///     print("❌ Activation failed: \(error.localizedDescription)")
    /// } catch let error as AriseApiError {
    ///     print("❌ API error: \(error.localizedDescription)")
    /// }
    /// ```
    public func activate() async throws {
        try await _ttpService.activate()
    }
    
    /// Performs a Tap to Pay transaction.
    ///
    /// This method presents Apple's Tap to Pay UI and guides the user through the tap flow.
    ///
    /// - Parameter request: Transaction request parameters matching CloudCommerce SDK structure.
    /// - Returns: `TTPTransactionResult` containing normalized transaction data suitable for subsequent API posting.
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
    ///
    /// Example usage:
    /// ```swift
    /// do {
    ///     let request = TTPTransactionRequest(
    ///         amount: Decimal(100.0),
    ///         currencyCode: "USD",
    ///         orderId: nil,
    ///         surchargeRate: nil
    ///     )
    ///     let result = try await ariseSdk.ttp.performTransaction(request: request)
    ///     print("Transaction ID: \(result.transactionId ?? "N/A")")
    ///     print("Status: \(result.status)")
    ///     print("Authorized Amount: \(result.authorizedAmount ?? "N/A")")
    /// } catch let error as TTPError {
    ///     print("❌ Transaction failed: \(error.localizedDescription)")
    /// } catch let error as PaymentCardReaderError {
    ///     print("❌ Card reader error: \(error.localizedDescription)")
    /// } catch let error as AriseApiError {
    ///     print("❌ API error: \(error.localizedDescription)")
    /// }
    /// ```
    @available(*, deprecated, message: "Use performTransaction(amount:) or performTransaction(calculationResult:isDebitCard:) instead")
    @MainActor
    public func performTransaction(request: TTPTransactionRequest) async throws -> TTPTransactionResult {
        return try await _ttpService.performTransaction(request: request)
    }
    
    /// Performs a Tap to Pay transaction with a simple amount.
    ///
    /// This method presents Apple's Tap to Pay UI and guides the user through the tap flow.
    /// This method is designed for merchants without Zero Cost Processing (ZCP) Surcharge enabled.
    /// If the merchant has ZCP Surcharge configured, this method will throw an error indicating
    /// that the advanced method `performTransaction(calculationResult:isDebitCard:)` should be used instead.
    ///
    /// - Parameter amount: Transaction amount as `Decimal`.
    /// - Returns: `TTPTransactionResult` containing normalized transaction data suitable for subsequent API posting.
    /// - Throws: `TTPError` if:
    ///   - SDK is not initialized
    ///   - TTP is not active
    ///   - Merchant has ZCP Surcharge enabled (use `performTransaction(calculationResult:isDebitCard:)` instead)
    ///   - Transaction fails
    /// - Throws: `PaymentCardReaderError` if the card reader encounters an error
    /// - Throws: `AriseApiError` if API calls fail (network errors, authentication errors, etc.)
    ///
    /// - Note: This method presents UI and must be called from the main thread.
    /// - Important: If your merchant account has Zero Cost Processing (ZCP) Surcharge enabled,
    ///   you must use `performTransaction(calculationResult:isDebitCard:)` instead. First call
    ///   `calculateAmount()` to get the calculation result, then pass it to the advanced transaction method.
    ///
    /// Example usage:
    /// ```swift
    /// do {
    ///     let result = try await ariseSdk.ttp.performTransaction(amount: Decimal(100.0))
    ///     print("Transaction ID: \(result.transactionId ?? "N/A")")
    ///     print("Status: \(result.status)")
    /// } catch let error as TTPError {
    ///     print("❌ Transaction failed: \(error.localizedDescription)")
    /// }
    /// ```
    @MainActor
    public func performTransaction(amount: Decimal) async throws -> TTPTransactionResult {
        return try await _ttpService.performTransaction(amount: amount)
    }
    
    /// Performs a Tap to Pay transaction with advanced amount calculation.
    ///
    /// This method presents Apple's Tap to Pay UI and guides the user through the tap flow.
    /// It uses a pre-calculated amount result from `calculateAmount()` and allows specifying
    /// whether the card being used is a debit card or credit card.
    ///
    /// - Parameters:
    ///   - calculationResult: Result from `calculateAmount()` method containing amount breakdowns for different payment types.
    ///   - isDebitCard: `true` if the card being used is a debit card, `false` for credit card.
    /// - Returns: `TTPTransactionResult` containing normalized transaction data suitable for subsequent API posting.
    /// - Throws: `TTPError` if:
    ///   - SDK is not initialized
    ///   - TTP is not active
    ///   - Transaction fails
    ///   - Required amount data is missing from calculationResult
    /// - Throws: `PaymentCardReaderError` if the card reader encounters an error
    /// - Throws: `AriseApiError` if API calls fail (network errors, authentication errors, etc.)
    ///
    /// - Note: This method presents UI and must be called from the main thread.
    /// - Important: The method selects either `debitCard` or `creditCard` AmountDto from `calculationResult`
    ///   based on the `isDebitCard` flag. All custom data (baseAmount, surchargeRate, percentageOffRate, tipRate, tipAmount)
    ///   is passed to CloudCommerce SDK in the `customData` parameter.
    ///
    /// Example usage:
    /// ```swift
    /// do {
    ///     let calculation = try await ariseSdk.calculateAmount(
    ///         request: CalculateAmountRequest(amount: 100.0)
    ///     )
    ///     let result = try await ariseSdk.ttp.performTransaction(
    ///         calculationResult: calculation,
    ///         isDebitCard: false
    ///     )
    ///     print("Transaction ID: \(result.transactionId ?? "N/A")")
    ///     print("Status: \(result.status)")
    /// } catch let error as TTPError {
    ///     print("❌ Transaction failed: \(error.localizedDescription)")
    /// }
    /// ```
    @MainActor
    public func performTransaction(calculationResult: CalculateAmountResponse, isDebitCard: Bool) async throws -> TTPTransactionResult {
        return try await _ttpService.performTransaction(calculationResult: calculationResult, isDebitCard: isDebitCard)
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
    ///
    /// Example usage:
    /// ```swift
    /// // User taps cancel button while waiting for card
    /// do {
    ///     let aborted = try await ariseSdk.ttp.abortTransaction()
    ///     if aborted {
    ///         print("Transaction was successfully aborted")
    ///         // UI is automatically dismissed
    ///     }
    /// } catch TTPError.sdkNotInitialized {
    ///     print("SDK is not initialized")
    /// } catch TTPError.cannotAbortTransaction(let reason) {
    ///     print("Cannot abort: \(reason)")
    ///     // Card reading has already begun, transaction will complete
    /// } catch {
    ///     print("Error: \(error.localizedDescription)")
    /// }
    /// ```
    @MainActor
    public func abortTransaction() async throws -> Bool {
        return try await _ttpService.abortTransaction()
    }
    
    /// Streams events from CloudCommerce SDK.
    ///
    /// This method provides access to the event stream from the Mastercard CloudCommerce SDK,
    /// which includes transaction progress events, card reader events, and other operational events.
    /// Events are automatically converted to `TTPEvent` enum which mirrors the structure of
    /// `CloudCommerce.EventStream` for easier handling. This allows the application to display
    /// progress indicators and handle real-time updates during Tap to Pay operations.
    ///
    /// - Returns: An `AsyncStream` of `TTPEvent` events from CloudCommerce SDK.
    /// - Throws: `TTPError.sdkNotInitialized` if CloudCommerce SDK is not initialized.
    ///
    /// - Note: The stream will continue until the SDK is deinitialized or the stream is cancelled.
    ///   Multiple calls to this method will return independent streams. Each stream receives
    ///   all events from the CloudCommerce SDK event manager.
    ///
    /// Example usage:
    /// ```swift
    /// Task {
    ///     do {
    ///         for await event in try ariseSdk.ttp.eventsStream() {
    ///             switch event {
    ///             case .readerEvent(let readerEvent):
    ///                 switch readerEvent {
    ///                 case .updateProgress(let progress):
    ///                     print("Reader progress: \(progress)%")
    ///                 case .cardDetected:
    ///                     print("Card detected")
    ///                 case .readCompleted:
    ///                     print("Card read completed")
    ///                 default:
    ///                     print("Reader event: \(readerEvent)")
    ///                 }
    ///             case .customEvent(let customEvent):
    ///                 switch customEvent {
    ///                 case .preparing:
    ///                     print("Preparing terminal...")
    ///                 case .ready:
    ///                     print("Terminal is ready")
    ///                 case .approved:
    ///                     print("Transaction approved!")
    ///                 case .declined:
    ///                     print("Transaction declined")
    ///                 case .readerNotReady(let reason):
    ///                     print("Reader not ready: \(reason)")
    ///                 default:
    ///                     print("Custom event: \(customEvent)")
    ///                 }
    ///             }
    ///         }
    ///     } catch TTPError.sdkNotInitialized {
    ///         print("SDK is not initialized")
    ///     }
    /// }
    /// ```
    public func eventsStream() throws -> AsyncStream<TTPEvent> {
        return try _ttpService.eventsStream()
    }
    
}

