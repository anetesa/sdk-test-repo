import Foundation
@testable import AriseMobile

/// Mock implementation of TransactionsServiceProtocol for testing
final class MockTransactionsService: TransactionsServiceProtocol, @unchecked Sendable {
    // MARK: - Thread Safety
    
    private let lock = NSLock()
    
    // MARK: - Configuration (Thread-safe accessors)
    
    private var _getTransactionsResult: Result<TransactionsResponse?, Error> = .success(nil)
    var getTransactionsResult: Result<TransactionsResponse?, Error> {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _getTransactionsResult
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _getTransactionsResult = newValue
        }
    }
    
    private var _getTransactionDetailsResult: Result<TransactionDetails?, Error> = .success(nil)
    var getTransactionDetailsResult: Result<TransactionDetails?, Error> {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _getTransactionDetailsResult
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _getTransactionDetailsResult = newValue
        }
    }
    
    private var _submitAuthTransactionResult: Result<AuthorizationResponse, Error> = .success(
        AuthorizationResponse(
            transactionId: "mock-transaction-id",
            transactionDateTime: Date(),
            typeId: 1,
            type: "Authorization",
            statusId: 1,
            status: "Authorized",
            processedAmount: 100.0,
            details: nil,
            transactionReceipt: nil,
            avsResponse: nil
        )
    )
    private var _submitSaleTransactionResult: Result<AuthorizationResponse, Error> = .success(
        AuthorizationResponse(
            transactionId: "mock-sale-transaction-id",
            transactionDateTime: Date(),
            typeId: 2,
            type: "Sale",
            statusId: 2,
            status: "Completed",
            processedAmount: 100.0,
            details: nil,
            transactionReceipt: nil,
            avsResponse: nil
        )
    )
    private var _calculateAmountResult: Result<CalculateAmountResponse, Error> = .success(
        CalculateAmountResponse(
            currencyId: nil,
            currency: nil,
            zeroCostProcessingOptionId: nil,
            zeroCostProcessingOption: nil,
            useCardPrice: nil,
            cash: nil,
            creditCard: nil,
            debitCard: nil,
            ach: nil
        )
    )
    private var _voidTransactionResult: Result<TransactionResponse, Error> = .success(
        TransactionResponse(
            transactionId: "mock-void-transaction-id",
            transactionDateTime: Date(),
            typeId: 3,
            type: "Void",
            statusId: 3,
            status: "Voided",
            details: nil,
            transactionReceipt: nil
        )
    )
    private var _captureTransactionResult: Result<TransactionResponse, Error> = .success(
        TransactionResponse(
            transactionId: "mock-capture-transaction-id",
            transactionDateTime: Date(),
            typeId: 4,
            type: "Capture",
            statusId: 4,
            status: "Captured",
            details: nil,
            transactionReceipt: nil
        )
    )
    private var _refundTransactionResult: Result<TransactionResponse, Error> = .success(
        TransactionResponse(
            transactionId: "mock-refund-transaction-id",
            transactionDateTime: Date(),
            typeId: 5,
            type: "Refund",
            statusId: 5,
            status: "Refunded",
            details: nil,
            transactionReceipt: nil
        )
    )
    
    // Thread-safe accessors for result properties
    var submitAuthTransactionResult: Result<AuthorizationResponse, Error> {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _submitAuthTransactionResult
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _submitAuthTransactionResult = newValue
        }
    }
    
    var submitSaleTransactionResult: Result<AuthorizationResponse, Error> {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _submitSaleTransactionResult
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _submitSaleTransactionResult = newValue
        }
    }
    
    var calculateAmountResult: Result<CalculateAmountResponse, Error> {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _calculateAmountResult
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _calculateAmountResult = newValue
        }
    }
    
    var voidTransactionResult: Result<TransactionResponse, Error> {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _voidTransactionResult
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _voidTransactionResult = newValue
        }
    }
    
    var captureTransactionResult: Result<TransactionResponse, Error> {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _captureTransactionResult
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _captureTransactionResult = newValue
        }
    }
    
    var refundTransactionResult: Result<TransactionResponse, Error> {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _refundTransactionResult
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _refundTransactionResult = newValue
        }
    }
    
    // MARK: - Call Tracking
    
    private var _getTransactionsCallCount = 0
    private var _getTransactionDetailsCallCount = 0
    private var _submitAuthTransactionCallCount = 0
    private var _submitSaleTransactionCallCount = 0
    private var _calculateAmountCallCount = 0
    private var _voidTransactionCallCount = 0
    private var _captureTransactionCallCount = 0
    private var _refundTransactionCallCount = 0
    
    private var _lastGetTransactionsFilters: TransactionFilters?
    private var _lastGetTransactionDetailsId: String?
    private var _lastSubmitAuthTransactionRequest: AuthorizationRequest?
    private var _lastSubmitSaleTransactionRequest: AuthorizationRequest?
    private var _lastCalculateAmountRequest: CalculateAmountRequest?
    private var _lastVoidTransactionId: String?
    private var _lastCaptureTransactionId: String?
    private var _lastCaptureTransactionAmount: Double?
    private var _lastRefundTransactionRequest: RefundRequest?
    
    // Thread-safe accessors
    var getTransactionsCallCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _getTransactionsCallCount
    }
    var getTransactionDetailsCallCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _getTransactionDetailsCallCount
    }
    var submitAuthTransactionCallCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _submitAuthTransactionCallCount
    }
    var submitSaleTransactionCallCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _submitSaleTransactionCallCount
    }
    var calculateAmountCallCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _calculateAmountCallCount
    }
    var voidTransactionCallCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _voidTransactionCallCount
    }
    var captureTransactionCallCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _captureTransactionCallCount
    }
    var refundTransactionCallCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _refundTransactionCallCount
    }
    
    var lastGetTransactionsFilters: TransactionFilters? {
        lock.lock()
        defer { lock.unlock() }
        return _lastGetTransactionsFilters
    }
    var lastGetTransactionDetailsId: String? {
        lock.lock()
        defer { lock.unlock() }
        return _lastGetTransactionDetailsId
    }
    var lastSubmitAuthTransactionRequest: AuthorizationRequest? {
        lock.lock()
        defer { lock.unlock() }
        return _lastSubmitAuthTransactionRequest
    }
    var lastSubmitSaleTransactionRequest: AuthorizationRequest? {
        lock.lock()
        defer { lock.unlock() }
        return _lastSubmitSaleTransactionRequest
    }
    var lastCalculateAmountRequest: CalculateAmountRequest? {
        lock.lock()
        defer { lock.unlock() }
        return _lastCalculateAmountRequest
    }
    var lastVoidTransactionId: String? {
        lock.lock()
        defer { lock.unlock() }
        return _lastVoidTransactionId
    }
    var lastCaptureTransactionId: String? {
        lock.lock()
        defer { lock.unlock() }
        return _lastCaptureTransactionId
    }
    var lastCaptureTransactionAmount: Double? {
        lock.lock()
        defer { lock.unlock() }
        return _lastCaptureTransactionAmount
    }
    var lastRefundTransactionRequest: RefundRequest? {
        lock.lock()
        defer { lock.unlock() }
        return _lastRefundTransactionRequest
    }
    
    // MARK: - TransactionsServiceProtocol Implementation
    
    func getTransactions(filters: TransactionFilters?) async throws -> TransactionsResponse? {
        let result: Result<TransactionsResponse?, Error>
        lock.lock()
        defer { lock.unlock() }
        
        _getTransactionsCallCount += 1
        _lastGetTransactionsFilters = filters
        result = _getTransactionsResult
        
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
    
    func getTransactionDetails(id: String) async throws -> TransactionDetails? {
        let result: Result<TransactionDetails?, Error>
        lock.lock()
        defer { lock.unlock() }
        
        _getTransactionDetailsCallCount += 1
        _lastGetTransactionDetailsId = id
        result = _getTransactionDetailsResult
        
        switch result {
        case .success(let details):
            return details
        case .failure(let error):
            throw error
        }
    }
    
    func submitAuthTransaction(request: AuthorizationRequest) async throws -> AuthorizationResponse {
        let result: Result<AuthorizationResponse, Error>
        lock.lock()
        defer { lock.unlock() }
        
        _submitAuthTransactionCallCount += 1
        _lastSubmitAuthTransactionRequest = request
        result = _submitAuthTransactionResult
        
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
    
    func submitSaleTransaction(request: AuthorizationRequest) async throws -> AuthorizationResponse {
        let result: Result<AuthorizationResponse, Error>
        lock.lock()
        defer { lock.unlock() }
        
        _submitSaleTransactionCallCount += 1
        _lastSubmitSaleTransactionRequest = request
        result = _submitSaleTransactionResult
        
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
    
    func calculateAmount(request: CalculateAmountRequest) async throws -> CalculateAmountResponse {
        let result: Result<CalculateAmountResponse, Error>
        lock.lock()
        defer { lock.unlock() }
        
        _calculateAmountCallCount += 1
        _lastCalculateAmountRequest = request
        result = _calculateAmountResult
        
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
    
    func voidTransaction(transactionId: String) async throws -> TransactionResponse {
        let result: Result<TransactionResponse, Error>
        lock.lock()
        defer { lock.unlock() }
        
        _voidTransactionCallCount += 1
        _lastVoidTransactionId = transactionId
        result = _voidTransactionResult
        
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
    
    func captureTransaction(transactionId: String, amount: Double) async throws -> TransactionResponse {
        let result: Result<TransactionResponse, Error>
        lock.lock()
        defer { lock.unlock() }
        
        _captureTransactionCallCount += 1
        _lastCaptureTransactionId = transactionId
        _lastCaptureTransactionAmount = amount
        result = _captureTransactionResult
        
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
    
    func refundTransaction(request: RefundRequest) async throws -> TransactionResponse {
        let result: Result<TransactionResponse, Error>
        lock.lock()
        defer { lock.unlock() }
        
        _refundTransactionCallCount += 1
        _lastRefundTransactionRequest = request
        result = _refundTransactionResult
        
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
    
    // MARK: - Reset
    
    func reset() {
        lock.lock()
        defer { lock.unlock() }
        
        _getTransactionsCallCount = 0
        _getTransactionDetailsCallCount = 0
        _submitAuthTransactionCallCount = 0
        _submitSaleTransactionCallCount = 0
        _calculateAmountCallCount = 0
        _voidTransactionCallCount = 0
        _captureTransactionCallCount = 0
        _refundTransactionCallCount = 0
        
        _lastGetTransactionsFilters = nil
        _lastGetTransactionDetailsId = nil
        _lastSubmitAuthTransactionRequest = nil
        _lastSubmitSaleTransactionRequest = nil
        _lastCalculateAmountRequest = nil
        _lastVoidTransactionId = nil
        _lastCaptureTransactionId = nil
        _lastCaptureTransactionAmount = nil
        _lastRefundTransactionRequest = nil
    }
}

