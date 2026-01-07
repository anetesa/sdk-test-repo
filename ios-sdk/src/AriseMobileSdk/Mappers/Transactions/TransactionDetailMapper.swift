import Foundation

struct TransactionDetailMapper {
    
    /// Map OpenAPI generated output to SDK's Transaction model
    /// - Parameter generated: Generated API response from OpenAPI client
    /// - Returns: Transaction in SDK format
    /// - Throws: Error if response is not successful
    static func toModel(_ generated: Operations.GetPayApiV1TransactionsId.Output) throws -> TransactionDetails {
        let okResponse = try generated.ok
        let responseBody = try okResponse.body.json
        
        return TransactionDetails(
            transactionId: responseBody.transactionId,
            transactionDateTime: responseBody.transactionDateTime,
            orderNumber: responseBody.orderNumber,
            amount: responseBody.amount.map { mapTransactionAmountDto($0) },
            currencyId: responseBody.currencyId,
            currency: responseBody.currency,
            baseAmount: responseBody.baseAmount,
            totalAmount: responseBody.totalAmount,
            processorId: responseBody.processorId,
            processor: responseBody.processor,
            operationTypeId: responseBody.operationTypeId,
            operationType: responseBody.operationType,
            transactionTypeId: responseBody.transactionTypeId,
            transactionType: responseBody.transactionType,
            paymentMethodTypeId: responseBody.paymentMethodTypeId,
            paymentMethodType: responseBody.paymentMethodType,
            customerId: responseBody.customerId,
            customerPan: responseBody.customerPan,
            cardTokenType: mapCardTokenType(responseBody.cardTokenType),
            statusId: responseBody.statusId,
            status: responseBody.status,
            merchantName: responseBody.merchantName,
            merchantAddress: responseBody.merchantAddress,
            merchantPhoneNumber: responseBody.merchantPhoneNumber,
            merchantEmailAddress: responseBody.merchantEmailAddress,
            merchantWebsite: responseBody.merchantWebsite,
            authCode: responseBody.authCode,
            source: mapSourceResponseDto(responseBody.source),
            responseCode: responseBody.responseCode,
            responseDescription: responseBody.responseDescription,
            cardholderAuthenticationMethodId: mapCardholderAuthenticationMethod(responseBody.cardholderAuthenticationMethodId),
            cardholderAuthenticationMethod: responseBody.cardholderAuthenticationMethod,
            cvmResultMsg: responseBody.cvmResultMsg,
            cardDataSourceId: CardDataSourceMapper.toModel(responseBody.cardDataSourceId),
            cardDataSource: responseBody.cardDataSource,
            cardProcessingDetails: responseBody.cardProcessingDetails.map { mapCardDetailsDto($0) },
            achProcessingDetails: responseBody.achProcessingDetails.map { mapElectronicCheckDetails($0) },
            availableOperations: responseBody.availableOperations?.map { mapTransactionOperation($0) },
            avsResponse: responseBody.avsResponse.map { AvsResponseDtoMapper.toModel($0) },
            emvTags: responseBody.emvTags.map { mapEmvTagsDto($0) },
            tsysCardDetails: responseBody.tsysCardDetails.map { mapTsysCardDetailsDto($0) },
            achDetails: responseBody.achDetails.map { mapAchDetailsDto($0) }
        )
    }
    
    // MARK: - Helper Mapping Functions
    
    /// Map transaction amount DTO from OpenAPI format to SDK format
    public static func mapTransactionAmountDto(_ amount: Components.Schemas.PaymentGateway_Contracts_Transactions_TransactionReceiptDto_AmountDto) -> TransactionReceiptAmountDto {
        return TransactionReceiptAmountDto(
            baseAmount: amount.baseAmount,
            percentageOffAmount: amount.percentageOffAmount,
            percentageOffRate: amount.percentageOffRate,
            cashDiscountAmount: amount.cashDiscountAmount,
            cashDiscountRate: amount.cashDiscountRate,
            surchargeAmount: amount.surchargeAmount,
            surchargeRate: amount.surchargeRate,
            tipAmount: amount.tipAmount,
            tipRate: amount.tipRate,
            totalAmount: amount.totalAmount
        )
    }
    
    /// Map source response DTO from OpenAPI format to SDK format
    public static func mapSourceResponseDto(_ source: Components.Schemas.PaymentGateway_Contracts_SourceResponseDto?) -> SourceResponseDto? {
        guard let source = source else { return nil }
        return SourceResponseDto(
            typeId: source.typeId.map { Int($0) },
            type: source._type,
            id: source.id,
            name: source.name ?? ""
        )
    }
    
    /// Map card token type enum from OpenAPI format to SDK format
    public static func mapCardTokenType(_ tokenType: Components.Schemas.PaymentGateway_Contracts_Enums_TokenType?) -> CardTokenType? {
        guard let tokenType = tokenType else { return nil }
        switch tokenType {
        case ._1:
            return .local
        case ._2:
            return .network
        @unknown default:
            return nil
        }
    }
    
    /// Map cardholder authentication method enum
    public static func mapCardholderAuthenticationMethod(_ method: Components.Schemas.PaymentGateway_Contracts_Enums_CardholderAuthenticationMethod?) -> CardholderAuthenticationMethod? {
        guard let method = method else { return nil }
        return CardholderAuthenticationMethod(rawValue: Int(method.rawValue))
    }
        
    /// Map card details DTO from OpenAPI format to SDK format
    public static func mapCardDetailsDto(_ cardDetails: Components.Schemas.PaymentGateway_Contracts_Transactions_TransactionReceiptDto_CardDetailsDto) -> CardDetailsDto {
        return CardDetailsDto(
            authCode: cardDetails.authCode,
            mid: cardDetails.mid,
            tid: cardDetails.tid,
            cardCreditDebitTypeId: cardDetails.cardCreditDebitTypeId,
            cardCreditDebitType: cardDetails.cardCreditDebitType,
            processCreditDebitTypeId: cardDetails.processCreditDebitTypeId,
            processCreditDebitType: cardDetails.processCreditDebitType,
            rrn: cardDetails.rrn,
            cardTypeId: cardDetails.cardTypeId,
            cardType: cardDetails.cardType
        )
    }
    
    /// Map electronic check details from OpenAPI format to SDK format
    public static func mapElectronicCheckDetails(_ details: Components.Schemas.PaymentGateway_Contracts_Transactions_TransactionReceiptDto_ElectronicCheckDetails) -> ElectronicCheckDetails {
        return ElectronicCheckDetails(
            customerAccountNumber: details.customerAccountNumber,
            customerRoutingNumber: details.customerRoutingNumber,
            accountHolderType: details.accountHolderType,
            accountHolderTypeId: details.accountHolderTypeId,
            accountType: details.accountType,
            accountTypeId: details.accountTypeId,
            taxId: details.taxId
        )
    }
    
    /// Map transaction operation from OpenAPI format to SDK format
    static func mapTransactionOperation(_ operation: Components.Schemas.PaymentGateway_Contracts_Enums_TransactionOperation) -> TransactionOperation {
        return TransactionOperation(
            typeId: operation.typeId?.rawValue,
            type: operation._type,
            availableAmount: operation.availableAmount,
            suggestedTips: operation.suggestedTips?.compactMap { tipDto -> SuggestedTipsDto? in
                guard let tipPercent = tipDto.tipPercent, let tipAmount = tipDto.tipAmount else {
                    return nil
                }
                return SuggestedTipsDto(tipPercent: tipPercent, tipAmount: tipAmount)
            }
        )
    }
    
    
    /// Map EMV tags DTO from OpenAPI format to SDK format
    static func mapEmvTagsDto(_ emvTags: Components.Schemas.PaymentGateway_Contracts_Transactions_TransactionReceiptDto_EmvTagsDto) -> EmvTagsDto {
        let rawTags = emvTags.rawTags?.compactMap { pair -> EmvTagsDto.RawTag? in
            guard let key = pair.key else { return nil }
            return EmvTagsDto.RawTag(tag: key, value: pair.value)
        }
        
        return EmvTagsDto(
            ac: emvTags.ac,
            tvr: emvTags.tvr,
            tsi: emvTags.tsi,
            aid: emvTags.aid,
            applicationLabel: emvTags.applicationLabel,
            rawTags: rawTags
        )
    }
    
    /// Map TSYS card details DTO from OpenAPI format to SDK format
    private static func mapTsysCardDetailsDto(_ tsysDetails: Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_Get_GetIsvTransactionResponse_TsysCardDetailsDto) -> TsysCardDetailsDto {
        return TsysCardDetailsDto(
            authCode: tsysDetails.authCode,
            mid: tsysDetails.mid,
            tid: tsysDetails.tid
        )
    }
    
    /// Map ACH details DTO from OpenAPI format to SDK format
    private static func mapAchDetailsDto(_ achDetails: Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_Get_GetIsvTransactionResponse_AchDetailsDto) -> AchDetailsDto {
        return AchDetailsDto(
            customerAccountNumber: achDetails.customerAccountNumber,
            customerRoutingNumber: achDetails.customerRoutingNumber,
            accountHolderType: achDetails.accountHolderType,
            accountHolderTypeId: achDetails.accountHolderTypeId,
            accountType: achDetails.accountType,
            accountTypeId: achDetails.accountTypeId,
            taxId: achDetails.taxId
        )
    }
}

