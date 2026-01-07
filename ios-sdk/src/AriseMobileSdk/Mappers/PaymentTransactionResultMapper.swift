//
//  PaymentTransactionResultMapper.swift
//  AriseMobileSdk
//
//  Created by Alexandr on 10.11.2025.
//

import Foundation

typealias GeneratedIsvAuthorizationResponse = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_Authorization_IsvAuthorizationResponse
typealias IsvAuthorizationResult = AuthorizationResponse

internal struct IsvAuthorizationResultMapper {
    /// Convert shared authorization/sale response body into SDK model.
    static func toModel(_ response: GeneratedIsvAuthorizationResponse) -> IsvAuthorizationResult {
        return IsvAuthorizationResult(
            transactionId: response.transactionId,
            transactionDateTime: response.transactionDateTime,
            typeId: response.typeId,
            type: response._type,
            statusId: response.statusId,
            status: response.status,
            processedAmount: response.processedAmount,
            details: response.details.map { TransactionResponseDetailsDtoMapper.toModel($0) },
            transactionReceipt: response.transactionReceipt.map { TransactionReceiptDtoMapper.toModel($0) },
            avsResponse: response.avsResponse.map { AvsResponseDtoMapper.toModel($0) }
        )
    }

}


