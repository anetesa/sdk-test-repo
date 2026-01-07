import Foundation
import CloudCommerce

/// Protocol for CloudCommerceSDK to enable dependency injection and testing
internal protocol CloudCommerceSDKProtocol {
    var version: String { get }
    var isAccountLinked: Bool { get async throws }
    var eventManager: CloudCommerceEventManagerProtocol { get }
    
    func configure(with token: String, merchant: CloudCommerce.Merchant?) async throws -> CloudCommerce.SdkUpgradeResponse
    func enableTapToPay() async throws
    func activateReader() async throws
    func resume(with token: String) async throws
    func performTransaction(
        for amount: Decimal,
        currencyCode: String,
        tip: String?,
        discount: String?,
        salesTaxAmount: String?,
        federalTaxAmount: String?,
        subTotal: String?,
        orderId: String?,
        customData: [String: String]?
    ) async throws -> CloudCommerce.Transaction
    func abortTransaction() async throws -> Bool
    func enablePerformanceLogging(_ enabled: Bool)
    func clear()
}

/// Protocol for CloudCommerceEventManager to enable dependency injection and testing
internal protocol CloudCommerceEventManagerProtocol {
    func eventsStream() -> AsyncStream<CloudCommerce.EventStream>
}

// MARK: - CloudCommerceSDK Wrapper for Protocol Conformance

/// Wrapper to make CloudCommerceSDK conform to CloudCommerceSDKProtocol
internal final class CloudCommerceSDKWrapper: CloudCommerceSDKProtocol, @unchecked Sendable {
    internal let _sdk: CloudCommerceSDK
    
    init(_ sdk: CloudCommerceSDK) {
        self._sdk = sdk
    }
    
    var version: String {
        _sdk.version
    }
    
    var isAccountLinked: Bool {
        get async throws {
            try await _sdk.isAccountLinked
        }
    }
    
    var eventManager: CloudCommerceEventManagerProtocol {
        CloudCommerceEventManagerWrapper(_sdk.eventManager)
    }
    
    func configure(with token: String, merchant: CloudCommerce.Merchant?) async throws -> CloudCommerce.SdkUpgradeResponse {
        try await _sdk.configure(with: token, merchant: merchant)
    }
    
    func enableTapToPay() async throws {
        try await _sdk.enableTapToPay()
    }
    
    func activateReader() async throws {
        try await _sdk.activateReader()
    }
    
    func resume(with token: String) async throws {
        try await _sdk.resume(with: token)
    }
    
    func performTransaction(
        for amount: Decimal,
        currencyCode: String,
        tip: String?,
        discount: String?,
        salesTaxAmount: String?,
        federalTaxAmount: String?,
        subTotal: String?,
        orderId: String?,
        customData: [String: String]?
    ) async throws -> CloudCommerce.Transaction {
        try await _sdk.performTransaction(
            for: amount,
            currencyCode: currencyCode,
            tip: tip,
            discount: discount,
            salesTaxAmount: salesTaxAmount,
            federalTaxAmount: federalTaxAmount,
            subTotal: subTotal,
            orderId: orderId,
            customData: customData
        )
    }
    
    func abortTransaction() async throws -> Bool {
        try await _sdk.abortTransaction()
    }
    
    func enablePerformanceLogging(_ enabled: Bool) {
        _sdk.enablePerformanceLogging(enabled)
    }
    
    func clear() {
        _sdk.clear()
    }
}

// MARK: - CloudCommerceEventManager Wrapper for Protocol Conformance

/// Wrapper to make CloudCommerceEventManager conform to CloudCommerceEventManagerProtocol
internal final class CloudCommerceEventManagerWrapper: CloudCommerceEventManagerProtocol, @unchecked Sendable {
    private let _eventManager: CloudCommerceEventManager
    
    init(_ eventManager: CloudCommerceEventManager) {
        self._eventManager = eventManager
    }
    
    func eventsStream() -> AsyncStream<CloudCommerce.EventStream> {
        _eventManager.eventsStream()
    }
}

