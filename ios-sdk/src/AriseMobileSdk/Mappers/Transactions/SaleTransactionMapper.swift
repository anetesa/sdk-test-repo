import Foundation

internal struct SaleTransactionMapper {
    /// Map SDK sale request to generated OpenAPI request
    static func toGeneratedInput(_ input: AuthorizationRequest) -> Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_Sale_IsvSaleRequest {
        return Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_Sale_IsvSaleRequest(
            paymentProcessorId: input.paymentProcessorId,
            customerId: input.customerId,
            paymentMethodId: input.paymentMethodId,
            amount: input.amount,
            tipAmount: input.tipAmount,
            tipRate: input.tipRate,
            currencyId: input.currencyId,
            percentageOffRate: input.percentageOffRate,
            surchargeRate: input.surchargeRate,
            useCardPrice: input.useCardPrice,
            billingAddress: AddressDtoMapper.toGeneratedInput(input.billingAddress),
            shippingAddress: AddressDtoMapper.toGeneratedInput(input.shippingAddress),
            contactInfo: ContactInfoDtoMapper.toGeneratedInput(input.contactInfo),
            accountNumber: input.accountNumber,
            securityCode: input.securityCode,
            expirationMonth: input.expirationMonth,
            expirationYear: input.expirationYear,
            track1: input.track1,
            track2: input.track2,
            emvTags: input.emvTags,
            emvPaymentAppVersion: input.emvPaymentAppVersion,
            cardDataSource: CardDataSourceMapper.toGeneratedInput(input.cardDataSource),
            pin: input.pin,
            pinKsn: input.pinKsn,
            debit: nil,
            emvFallbackCondition: EMVFallbackConditionMapper.toGeneratedInput(input.emvFallbackCondition),
            emvFallbackLastChipRead: EMVFallbackLastChipReadMapper.toGeneratedInput(input.emvFallbackLastChipRead),
            referenceId: input.referenceId,
            l2: L2DataMapper.toGeneratedInput(input.l2),
            l3: L3DataMapper.toGeneratedInput(input.l3),
            customerInitiatedTransaction: input.customerInitiatedTransaction
        )
    }
    

    /// Map generated response to SDK result
    static func toModel(
        _ generated: Operations.PostPayApiV1TransactionsSale.Output
    ) throws -> AuthorizationResponse {
        let okResponse = try generated.ok
        let responseBody = try okResponse.body.json
        return AuthorizationTransactionMapper.toModel(responseBody)
    }
}


