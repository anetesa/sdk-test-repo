import Foundation
import CloudCommerce
@testable import AriseMobile

/// Helper function to create default SdkUpgradeResponse for testing
private func createDefaultSdkUpgradeResponse() -> Result<CloudCommerce.SdkUpgradeResponse, Error> {
    let json = """
    {
        "forceUpgrade": false,
        "recommendedUpgrade": false,
        "sessionExpiryTime": null,
        "clearDataRequired": false
    }
    """.data(using: .utf8)!
    let decoder = JSONDecoder()
    do {
        let response = try decoder.decode(CloudCommerce.SdkUpgradeResponse.self, from: json)
        return .success(response)
    } catch {
        // Return error if decoding fails
        return .failure(error)
    }
}

/// Mock implementation of CloudCommerceSDK for testing TTP functionality
/// Matches the real CloudCommerceSDK API structure
final class MockCloudCommerceSDK: CloudCommerceSDKProtocol, @unchecked Sendable {
    
    // MARK: - Thread Safety
    
    private let lock = NSLock()
    
    // MARK: - Configuration
    var prepareResult: Result<CloudCommerce.SdkUpgradeResponse, Error> = createDefaultSdkUpgradeResponse()
    var resumeError: Error?
    var performTransactionResult: Result<CloudCommerce.Transaction, Error>?
    var abortTransactionResult: Result<Bool, Error> = .success(true)
    var events: [CloudCommerce.EventStream] = []
    var version: String = "1.0.0-mock"
    var environment: CloudCommerce.TargetEnvironment = .sandbox
    var sessionId: String? = "mock-session-id"
    var merchantDetails: CloudCommerce.MerchantDetails? = nil
    var posIdentifier: String? = "mock-pos-identifier"
    var deviceIdentifier: String = "mock-device-identifier"
    var sessionExpiryTime: String? = nil
    var isAccountLinkedValue: Bool = false
    var configureResult: Result<CloudCommerce.SdkUpgradeResponse, Error> = createDefaultSdkUpgradeResponse()
    var enableTapToPayError: Error?
    var activateReaderError: Error?
    var enablePerformanceLoggingCalled = false
    var enablePerformanceLoggingValue: Bool?
    
    // MARK: - Call Tracking
    
    private var _configureCallCount = 0
    private var _enableTapToPayCallCount = 0
    private var _activateReaderCallCount = 0
    private var _resumeCallCount = 0
    private var _performTransactionCallCount = 0
    private var _abortTransactionCallCount = 0
    private var _clearCallCount = 0
    
    // Thread-safe accessors
    var configureCallCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _configureCallCount
    }
    var enableTapToPayCallCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _enableTapToPayCallCount
    }
    var activateReaderCallCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _activateReaderCallCount
    }
    var resumeCallCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _resumeCallCount
    }
    var performTransactionCallCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _performTransactionCallCount
    }
    var abortTransactionCallCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _abortTransactionCallCount
    }
    var clearCallCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _clearCallCount
    }
    
    private(set) var lastConfigureToken: String?
    private(set) var lastConfigureMerchant: CloudCommerce.Merchant?
    private(set) var lastResumeToken: String?
    private(set) var lastPerformTransactionAmount: Decimal?
    private(set) var lastPerformTransactionCurrencyCode: String?
    private(set) var lastPerformTransactionTip: String?
    private(set) var lastPerformTransactionDiscount: String?
    private(set) var lastPerformTransactionSubTotal: String?
    private(set) var lastPerformTransactionOrderId: String?
    private(set) var lastPerformTransactionCustomData: [String: String]?
    
    // MARK: - Event Manager
    
    var eventManager: CloudCommerceEventManagerProtocol {
        MockEventManager(events: events)
    }
    
    // MARK: - Reset
    
    func reset() {
        lock.lock()
        defer { lock.unlock() }
        
        _configureCallCount = 0
        _enableTapToPayCallCount = 0
        _activateReaderCallCount = 0
        _resumeCallCount = 0
        _performTransactionCallCount = 0
        _abortTransactionCallCount = 0
        _clearCallCount = 0
        lastConfigureToken = nil
        lastConfigureMerchant = nil
        lastResumeToken = nil
        lastPerformTransactionAmount = nil
        lastPerformTransactionCurrencyCode = nil
        lastPerformTransactionTip = nil
        lastPerformTransactionDiscount = nil
        lastPerformTransactionSubTotal = nil
        lastPerformTransactionOrderId = nil
        lastPerformTransactionCustomData = nil
        events = []
        configureResult = createDefaultSdkUpgradeResponse()
        enableTapToPayError = nil
        activateReaderError = nil
        resumeError = nil
        performTransactionResult = nil
        abortTransactionResult = .success(true)
        enablePerformanceLoggingCalled = false
        enablePerformanceLoggingValue = nil
    }
}

// MARK: - CloudCommerceSDKProtocol Implementation

extension MockCloudCommerceSDK {
    
    var isAccountLinked: Bool {
        get async throws {
            isAccountLinkedValue
        }
    }
    
    /// Mock configure method (matches CloudCommerceSDK.configure)
    func configure(with token: String, merchant: CloudCommerce.Merchant?) async throws -> CloudCommerce.SdkUpgradeResponse {
        lock.lock()
        defer { lock.unlock() }
        
        _configureCallCount += 1
        lastConfigureToken = token
        lastConfigureMerchant = merchant
        
        switch configureResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
    
    /// Mock enableTapToPay method (matches CloudCommerceSDK.enableTapToPay)
    func enableTapToPay() async throws {
        lock.lock()
        defer { lock.unlock() }
        
        _enableTapToPayCallCount += 1
        
        if let error = enableTapToPayError {
            throw error
        }
    }
    
    /// Mock activateReader method (matches CloudCommerceSDK.activateReader)
    func activateReader() async throws {
        lock.lock()
        defer { lock.unlock() }
        
        _activateReaderCallCount += 1
        
        if let error = activateReaderError {
            throw error
        }
    }
    
    /// Mock resume method (matches CloudCommerceSDK.resume)
    func resume(with token: String) async throws {
        lock.lock()
        defer { lock.unlock() }
        
        _resumeCallCount += 1
        lastResumeToken = token
        
        if let error = resumeError {
            throw error
        }
    }
    
    /// Mock enablePerformanceLogging method (matches CloudCommerceSDK.enablePerformanceLogging)
    func enablePerformanceLogging(_ enabled: Bool) {
        enablePerformanceLoggingCalled = true
        enablePerformanceLoggingValue = enabled
    }
    
    /// Mock performTransaction method (matches CloudCommerceSDK.performTransaction)
    /// Note: tip, discount, salesTaxAmount, federalTaxAmount, subTotal are String? in the real API
    func performTransaction(
        for amount: Decimal,
        currencyCode: String,
        tip: String? = nil,
        discount: String? = nil,
        salesTaxAmount: String? = nil,
        federalTaxAmount: String? = nil,
        subTotal: String? = nil,
        orderId: String? = nil,
        customData: [String: String]? = nil
    ) async throws -> CloudCommerce.Transaction {
        lock.lock()
        defer { lock.unlock() }
        
        _performTransactionCallCount += 1
        lastPerformTransactionAmount = amount
        lastPerformTransactionCurrencyCode = currencyCode
        lastPerformTransactionTip = tip
        lastPerformTransactionDiscount = discount
        lastPerformTransactionSubTotal = subTotal
        lastPerformTransactionOrderId = orderId
        lastPerformTransactionCustomData = customData
        
        guard let result = performTransactionResult else {
            throw NSError(
                domain: "MockCloudCommerceSDK",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "performTransactionResult not set"]
            )
        }
        
        switch result {
        case .success(let transaction):
            return transaction
        case .failure(let error):
            throw error
        }
    }
    
    /// Mock abortTransaction method (matches CloudCommerceSDK.abortTransaction)
    func abortTransaction() async throws -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        _abortTransactionCallCount += 1
        
        switch abortTransactionResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
    
    /// Mock clear method (matches CloudCommerceSDK.clear)
    func clear() {
        lock.lock()
        defer { lock.unlock() }
        
        _clearCallCount += 1
    }
}

// MARK: - Mock Event Manager

/// Mock implementation of CloudCommerceEventManager
/// Matches the real CloudCommerceEventManager API
final class MockEventManager: CloudCommerceEventManagerProtocol, @unchecked Sendable {
    private let events: [CloudCommerce.EventStream]
    
    init(events: [CloudCommerce.EventStream] = []) {
        self.events = events
    }
    
    /// Mock eventsStream method (matches CloudCommerceEventManager.eventsStream)
    /// Immediately finishes the stream to prevent hanging in tests
    func eventsStream() -> AsyncStream<CloudCommerce.EventStream> {
        AsyncStream { continuation in
            // Yield all events immediately, then finish
            // This prevents the stream from hanging in tests
            for event in events {
                continuation.yield(event)
            }
            // Always finish the stream immediately to prevent hanging
            continuation.finish()
        }
    }
}

