import Foundation

/// Mapper for converting between SDK and OpenAPI generated types for void transaction operations
internal struct VoidTransactionMapper {
    /// Convert SDK VoidTransactionInput to OpenAPI generated input
    static func toGeneratedInput(_ transactionId: String) -> Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_Void_IsvVoidRequest {
        return Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_Void_IsvVoidRequest(
            transactionId: transactionId
        )
    }

    /// Convert OpenAPI generated response to SDK transaction result
    static func toModel(
        _ generated: Operations.PostPayApiV1TransactionsVoid.Output
    ) throws -> TransactionResponse {
        let okResponse = try generated.ok
        let responseBody = try okResponse.body.json
        return TransactionResponseMapper.toModel(responseBody)
    }
    
}

