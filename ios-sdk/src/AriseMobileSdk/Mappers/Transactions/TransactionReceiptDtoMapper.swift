struct TransactionReceiptDtoMapper {
    
    /// Map transaction receipt DTO from OpenAPI format to SDK format
    static func toModel(_ receipt: Components.Schemas.PaymentGateway_Contracts_Transactions_TransactionReceiptDto) -> TransactionReceiptDto {
        return TransactionReceiptDto(
            transactionId: receipt.transactionId,
            transactionDateTime: receipt.transactionDateTime,
            orderNumber: receipt.orderNumber,
            amount: receipt.amount.map { TransactionDetailMapper.mapTransactionAmountDto($0) },
            currencyId: receipt.currencyId,
            currency: receipt.currency,
            processorId: receipt.processorId,
            processor: receipt.processor,
            operationTypeId: receipt.operationTypeId,
            operationType: receipt.operationType,
            transactionTypeId: receipt.transactionTypeId,
            transactionType: receipt.transactionType,
            paymentMethodTypeId: receipt.paymentMethodTypeId,
            paymentMethodType: receipt.paymentMethodType,
            customerId: receipt.customerId,
            customerPan: receipt.customerPan,
            cardTokenType: TransactionDetailMapper.mapCardTokenType(receipt.cardTokenType),
            statusId: receipt.statusId,
            status: receipt.status,
            merchantName: receipt.merchantName,
            merchantAddress: receipt.merchantAddress,
            merchantPhoneNumber: receipt.merchantPhoneNumber,
            merchantEmailAddress: receipt.merchantEmailAddress,
            merchantWebsite: receipt.merchantWebsite,
            authCode: receipt.authCode,
            source: TransactionDetailMapper.mapSourceResponseDto(receipt.source),
            responseCode: receipt.responseCode,
            responseDescription: receipt.responseDescription,
            cardholderAuthenticationMethodId: TransactionDetailMapper.mapCardholderAuthenticationMethod(receipt.cardholderAuthenticationMethodId),
            cardholderAuthenticationMethod: receipt.cardholderAuthenticationMethod,
            cvmResultMsg: receipt.cvmResultMsg,
            cardDataSourceId: CardDataSourceMapper.toModel(receipt.cardDataSourceId),
            cardDataSource: receipt.cardDataSource,
            cardProcessingDetails: receipt.cardProcessingDetails.map { TransactionDetailMapper.mapCardDetailsDto($0) },
            achProcessingDetails: receipt.achProcessingDetails.map { TransactionDetailMapper.mapElectronicCheckDetails($0) },
            availableOperations: receipt.availableOperations?.map { TransactionDetailMapper.mapTransactionOperation($0) },
            avsResponse: receipt.avsResponse.map { AvsResponseDtoMapper.toModel($0) },
            emvTags: receipt.emvTags.map { TransactionDetailMapper.mapEmvTagsDto($0) }
        )
    }
}
