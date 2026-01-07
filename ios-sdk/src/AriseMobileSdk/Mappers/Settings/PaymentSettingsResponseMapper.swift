import Foundation

internal struct PaymentSettingsResponseMapper {
    static func toModel(_ generated: Operations.GetPayApiV1ConfigurationsPayments.Output) throws -> PaymentSettingsResponse {
        let okResponse = try generated.ok
        let responseBody = try okResponse.body.json
        
        // Map currencies
        let currencies = (responseBody.availableCurrencies ?? []).map { dto in
            NamedOption(
                id: dto.id ?? 0,
                name: dto.name
            )
        }
        
        // Map card types
        let cardTypes = (responseBody.availableCardTypes ?? []).map { dto in
            NamedOption(
                id: dto.id ?? 0,
                name: dto.name
            )
        }
        
        // Map transaction types
        let transactionTypes = (responseBody.availableTransactionTypes ?? []).map { dto in
            NamedOption(
                id: dto.id ?? 0,
                name: dto.name
            )
        }
        
        // Map payment processors
        let processors = (responseBody.availablePaymentProcessors ?? []).map { dto in
            PaymentProcessorMapper.toModel(dto)
        }
        
        // Map AVS options
        let avsOptions = responseBody.avs.map { avs in
            AvsOptionsMapper.toModel(avs)
        }

        
//      TODO: remove mock value
        let countryCode = "USA"
        
        return PaymentSettingsResponse(
            availableCurrencies: currencies,
            zeroCostProcessingOptionId: responseBody.zeroCostProcessingOptionId,
            zeroCostProcessingOption: responseBody.zeroCostProcessingOption,
            defaultSurchargeRate: responseBody.defaultSurchargeRate,
            defaultCashDiscountRate: responseBody.defaultCashDiscountRate,
            defaultDualPricingRate: responseBody.defaultDualPricingRate,
            isTipsEnabled: responseBody.isTipsEnabled ?? false,
            defaultTipsOptions: responseBody.defaultTipsOptions,
            availableCardTypes: cardTypes,
            availableTransactionTypes: transactionTypes,
            availablePaymentProcessors: processors,
            avs: avsOptions,
            isCustomerCardSavingByTerminalEnabled: responseBody.isCustomerCardSavingByTerminalEnabled ?? false,
            companyName: responseBody.companyName,
            mccCode: responseBody.mccCode,
            currencyCode: responseBody.currencyIsoCode,
            currencyId: responseBody.currencyId,
            countryCode: countryCode
        )
    }
}

