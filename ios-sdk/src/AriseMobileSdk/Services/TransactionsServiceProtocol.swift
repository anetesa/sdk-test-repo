import Foundation

/// Protocol for TransactionsService to enable dependency injection and testing
internal protocol TransactionsServiceProtocol: Sendable {
    func getTransactions(filters: TransactionFilters?) async throws -> TransactionsResponse?
    func getTransactionDetails(id: String) async throws -> TransactionDetails?
    func submitAuthTransaction(request: AuthorizationRequest) async throws -> AuthorizationResponse
    func submitSaleTransaction(request: AuthorizationRequest) async throws -> AuthorizationResponse
    func calculateAmount(request: CalculateAmountRequest) async throws -> CalculateAmountResponse
    func voidTransaction(transactionId: String) async throws -> TransactionResponse
    func captureTransaction(transactionId: String, amount: Double) async throws -> TransactionResponse
    func refundTransaction(request: RefundRequest) async throws -> TransactionResponse
}

