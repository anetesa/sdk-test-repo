import Foundation

internal struct CalculateAmountMapper {
    static func toGeneratedInput(_ request: CalculateAmountRequest) -> Operations.GetPayApiV1TransactionsCalculateAmount.Input {
        let query = Operations.GetPayApiV1TransactionsCalculateAmount.Input.Query(
            amount: request.amount,
            percentageOffRate: request.percentageOffRate,
            surchargeRate: request.surchargeRate,
            tipAmount: request.tipAmount,
            tipRate: request.tipRate,
            currencyId: request.currencyId,
            useCardPrice: request.useCardPrice
        )

        return .init(query: query)
    }

    static func toModel(_ generated: Operations.GetPayApiV1TransactionsCalculateAmount.Output) throws -> CalculateAmountResponse {
        let okResponse = try generated.ok
        let responseBody = try okResponse.body.json

        return CalculateAmountResponse(
            currencyId: responseBody.currencyId.map { Int32($0.rawValue) },
            currency: responseBody.currency,
            zeroCostProcessingOptionId: responseBody.zeroCostProcessingOptionId.map { Int32($0.rawValue) },
            zeroCostProcessingOption: responseBody.zeroCostProcessingOption,
            useCardPrice: responseBody.useCardPrice,
            cash: responseBody.cash.map { AmountDtoMapper.toModel($0) },
            creditCard: responseBody.creditCard.map { AmountDtoMapper.toModel($0) },
            debitCard: responseBody.debitCard.map { AmountDtoMapper.toModel($0) },
            ach: responseBody.ach.map { AmountDtoMapper.toModel($0) }
        )
    }
}


