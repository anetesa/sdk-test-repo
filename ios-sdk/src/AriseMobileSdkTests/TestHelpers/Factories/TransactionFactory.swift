import Foundation
@testable import AriseMobile

/// Factory for creating test transaction data
enum TransactionFactory {
    
    /// Create a test TransactionDetails with default values
    static func createTransactionDetails(
        transactionId: String? = "test-transaction-123",
        transactionDateTime: Date? = Date(),
        orderNumber: String? = "ORDER-123",
        amount: Double = 100.00,
        currency: String = "USD",
        status: String? = "Approved"
    ) -> TransactionDetails {
        return TransactionDetails(
            transactionId: transactionId,
            transactionDateTime: transactionDateTime,
            orderNumber: orderNumber,
            amount: nil,
            currencyId: 1, // USD
            currency: currency,
            baseAmount: amount,
            totalAmount: amount,
            processorId: nil,
            processor: nil,
            operationTypeId: nil,
            operationType: nil,
            transactionTypeId: nil,
            transactionType: "Sale",
            paymentMethodTypeId: nil,
            paymentMethodType: nil,
            customerId: nil,
            customerPan: nil,
            cardTokenType: nil,
            statusId: nil,
            status: status,
            merchantName: nil,
            merchantAddress: nil,
            merchantPhoneNumber: nil,
            merchantEmailAddress: nil,
            merchantWebsite: nil,
            authCode: nil,
            source: nil,
            responseCode: nil,
            responseDescription: nil,
            cardholderAuthenticationMethodId: nil,
            cardholderAuthenticationMethod: nil,
            cvmResultMsg: nil,
            cardDataSourceId: nil,
            cardDataSource: nil,
            cardProcessingDetails: nil,
            achProcessingDetails: nil,
            availableOperations: nil,
            avsResponse: nil,
            emvTags: nil,
            tsysCardDetails: nil,
            achDetails: nil
        )
    }
    
    /// Create a successful sale transaction
    static func createSuccessfulSaleTransaction(
        amount: Double = 50.00,
        transactionId: String? = "sale-123"
    ) -> TransactionDetails {
        return createTransactionDetails(
            transactionId: transactionId,
            amount: amount,
            status: TransactionStatus.approved.rawValue
        )
    }
    
    /// Create a failed transaction
    static func createFailedTransaction(
        transactionId: String? = "failed-123",
        status: TransactionStatus = .declined
    ) -> TransactionDetails {
        return createTransactionDetails(
            transactionId: transactionId,
            amount: 25.00,
            status: status.rawValue
        )
    }
    
    /// Create an AuthorizationRequest
    static func createAuthorizationRequest(
        amount: Double = 100.00,
        paymentProcessorId: String = "test-processor-id",
        currencyId: Int32 = 840,
        cardDataSource: CardDataSource = .swipe
    ) throws -> AuthorizationRequest {
        return try AuthorizationRequest(
            paymentProcessorId: paymentProcessorId,
            amount: amount,
            currencyId: currencyId,
            cardDataSource: cardDataSource
        )
    }
}

