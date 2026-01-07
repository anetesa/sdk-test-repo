import Foundation
import UIKit

/// Protocol for TTPService to enable dependency injection and testing
internal protocol TTPServiceProtocol: Sendable {
    var countryCode: String? { get set }
    
    func checkCompatibility() -> TTPCompatibilityResult
    func getStatus() async throws -> TTPStatus
    func getToken() async throws -> String
    func clearTokenCache()
    func activate() async throws
    func prepare() async throws
    func resume() async throws
    @available(iOS 18.0, *)
    func showEducationalInfo(from viewController: UIViewController) async throws
    func performTransaction(request: TTPTransactionRequest) async throws -> TTPTransactionResult
    func performTransaction(amount: Decimal) async throws -> TTPTransactionResult
    func performTransaction(calculationResult: CalculateAmountResponse, isDebitCard: Bool) async throws -> TTPTransactionResult
    func abortTransaction() async throws -> Bool
    func eventsStream() throws -> AsyncStream<TTPEvent>
}

