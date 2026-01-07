import Foundation

internal struct CaptureTransactionMapper {
    static func toGeneratedInput(
        transactionId: String,
        amount: Double
    ) -> Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_Capture_IsvCaptureRequest {
        return Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_Capture_IsvCaptureRequest(
            amount: amount,
            transactionId: transactionId
        )
    }

    static func toModel(
        _ generated: Operations.PostPayApiV1TransactionsCapture.Output
    ) throws -> TransactionResponse {
        let okResponse = try generated.ok
        let responseBody = try okResponse.body.json
        return TransactionResponseMapper.toModel(responseBody)
    }
}
