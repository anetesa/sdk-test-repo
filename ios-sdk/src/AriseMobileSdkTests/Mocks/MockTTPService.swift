import Foundation
import UIKit
@testable import AriseMobile

/// Mock implementation of TTPServiceProtocol for testing
final class MockTTPService: TTPServiceProtocol, @unchecked Sendable {
    // MARK: - Configuration
    
    var countryCodeValue: String? = "USA"
    
    var checkCompatibilityResult: TTPCompatibilityResult = TTPCompatibilityResult(
        isCompatible: true,
        deviceModelCheck: DeviceModelCheck(isCompatible: true, modelIdentifier: "iPhone15,2"),
        iosVersionCheck: IOSVersionCheck(isCompatible: true, version: "18.0", minimumRequiredVersion: "18.0"),
        locationPermission: .granted,
        tapToPayEntitlement: .available,
        incompatibilityReasons: []
    )
    
    var getStatusResult: Result<TTPStatus, Error> = .success(.active)
    var getTokenResult: Result<String, Error> = .success("mock-ttp-jwt-token")
    var activateResult: Result<Void, Error> = .success(())
    var prepareResult: Result<Void, Error> = .success(())
    var resumeResult: Result<Void, Error> = .success(())
    var showEducationalInfoResult: Result<Void, Error> = .success(())
    var performTransactionResult: Result<TTPTransactionResult, Error> = .success(
        TTPTransactionResult(
            transactionId: "mock-ttp-transaction-id",
            transactionOutcome: "APPROVED",
            status: .approved,
            orderId: nil,
            authorizedAmount: "100.00",
            authorizationCode: nil,
            authorisationResponseCode: nil,
            authorizedDate: nil,
            authorizedDateFormat: nil,
            cardBrandName: nil,
            maskedCardNumber: nil,
            externalReferenceID: nil,
            applicationIdentifier: nil,
            applicationPreferredName: nil,
            applicationCryptogram: nil,
            applicationTransactionCounter: nil,
            terminalVerificationResults: nil,
            issuerApplicationData: nil,
            applicationPANSequenceNumber: nil,
            partnerDataMap: nil,
            cvmTags: nil,
            cvmAction: nil
        )
    )
    var abortTransactionResult: Result<Bool, Error> = .success(true)
    var eventsStreamResult: Result<AsyncStream<TTPEvent>, Error> = .success(
        AsyncStream { continuation in
            continuation.finish()
        }
    )
    
    // MARK: - Call Tracking
    
    private(set) var checkCompatibilityCallCount = 0
    private(set) var getStatusCallCount = 0
    private(set) var getTokenCallCount = 0
    private(set) var clearTokenCacheCallCount = 0
    private(set) var activateCallCount = 0
    private(set) var prepareCallCount = 0
    private(set) var resumeCallCount = 0
    private(set) var showEducationalInfoCallCount = 0
    private(set) var performTransactionCallCount = 0
    private(set) var abortTransactionCallCount = 0
    private(set) var eventsStreamCallCount = 0
    
    private(set) var lastShowEducationalInfoViewController: UIViewController?
    private(set) var lastPerformTransactionRequest: TTPTransactionRequest?
    
    // MARK: - TTPServiceProtocol Implementation
    
    var countryCode: String? {
        get { countryCodeValue }
        set { countryCodeValue = newValue }
    }
    
    func checkCompatibility() -> TTPCompatibilityResult {
        checkCompatibilityCallCount += 1
        return checkCompatibilityResult
    }
    
    func getStatus() async throws -> TTPStatus {
        getStatusCallCount += 1
        
        switch getStatusResult {
        case .success(let status):
            return status
        case .failure(let error):
            throw error
        }
    }
    
    func getToken() async throws -> String {
        getTokenCallCount += 1
        
        switch getTokenResult {
        case .success(let token):
            return token
        case .failure(let error):
            throw error
        }
    }
    
    func clearTokenCache() {
        clearTokenCacheCallCount += 1
    }
    
    func activate() async throws {
        activateCallCount += 1
        
        switch activateResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
    
    func prepare() async throws {
        prepareCallCount += 1
        
        switch prepareResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
    
    func resume() async throws {
        resumeCallCount += 1
        
        switch resumeResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
    
    @available(iOS 18.0, *)
    func showEducationalInfo(from viewController: UIViewController) async throws {
        showEducationalInfoCallCount += 1
        lastShowEducationalInfoViewController = viewController
        
        switch showEducationalInfoResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
    
    func performTransaction(request: TTPTransactionRequest) async throws -> TTPTransactionResult {
        performTransactionCallCount += 1
        lastPerformTransactionRequest = request
        
        switch performTransactionResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
    
    func performTransaction(amount: Decimal) async throws -> TTPTransactionResult {
        performTransactionCallCount += 1
        
        switch performTransactionResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
    
    func performTransaction(calculationResult: CalculateAmountResponse, isDebitCard: Bool) async throws -> TTPTransactionResult {
        performTransactionCallCount += 1
        
        switch performTransactionResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
    
    func abortTransaction() async throws -> Bool {
        abortTransactionCallCount += 1
        
        switch abortTransactionResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
    
    func eventsStream() throws -> AsyncStream<TTPEvent> {
        eventsStreamCallCount += 1
        
        switch eventsStreamResult {
        case .success(let stream):
            return stream
        case .failure(let error):
            throw error
        }
    }
    
    // MARK: - Reset
    
    func reset() {
        checkCompatibilityCallCount = 0
        getStatusCallCount = 0
        getTokenCallCount = 0
        clearTokenCacheCallCount = 0
        activateCallCount = 0
        prepareCallCount = 0
        resumeCallCount = 0
        showEducationalInfoCallCount = 0
        performTransactionCallCount = 0
        abortTransactionCallCount = 0
        eventsStreamCallCount = 0
        
        lastShowEducationalInfoViewController = nil
        lastPerformTransactionRequest = nil
    }
}

