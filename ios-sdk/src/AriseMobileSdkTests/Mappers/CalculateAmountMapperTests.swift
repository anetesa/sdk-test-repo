import Foundation
import Testing
@testable import AriseMobile

/// Tests for CalculateAmountMapper
struct CalculateAmountMapperTests {
    
    @Test("CalculateAmountMapper maps request to generated input")
    func testCalculateAmountMapperToGeneratedInput() {
        let request = CalculateAmountRequest(
            amount: 100.0,
            percentageOffRate: 10.0,
            surchargeRate: 3.0,
            tipAmount: 15.0,
            tipRate: 15.0,
            currencyId: 1,
            useCardPrice: true
        )
        
        let result = CalculateAmountMapper.toGeneratedInput(request)
        
        #expect(result.query.amount == 100.0)
        #expect(result.query.percentageOffRate == 10.0)
        #expect(result.query.surchargeRate == 3.0)
        #expect(result.query.tipAmount == 15.0)
        #expect(result.query.tipRate == 15.0)
        #expect(result.query.currencyId == 1)
        #expect(result.query.useCardPrice == true)
    }
    
    @Test("CalculateAmountMapper maps request with nil optional fields")
    func testCalculateAmountMapperWithNilFields() {
        let request = CalculateAmountRequest(
            amount: 50.0,
            percentageOffRate: nil,
            surchargeRate: nil,
            tipAmount: nil,
            tipRate: nil,
            currencyId: nil,
            useCardPrice: false
        )
        
        let result = CalculateAmountMapper.toGeneratedInput(request)
        
        #expect(result.query.amount == 50.0)
        #expect(result.query.percentageOffRate == nil)
        #expect(result.query.surchargeRate == nil)
        #expect(result.query.tipAmount == nil)
        #expect(result.query.tipRate == nil)
        #expect(result.query.currencyId == nil)
        #expect(result.query.useCardPrice == false)
    }
    
    @Test("CalculateAmountMapper maps response to model with all fields")
    func testCalculateAmountMapperToModelWithAllFields() throws {
        let cashAmount = Components.Schemas.PaymentGateway_Contracts_Amounts_AmountDto(
            baseAmount: 100.0,
            percentageOffAmount: nil,
            percentageOffRate: nil,
            cashDiscountAmount: nil,
            cashDiscountRate: nil,
            surchargeAmount: nil,
            surchargeRate: nil,
            tipAmount: nil,
            tipRate: nil,
            taxAmount: nil,
            taxRate: nil,
            totalAmount: 100.0
        )
        
        let creditCardAmount = Components.Schemas.PaymentGateway_Contracts_Amounts_AmountDto(
            baseAmount: 100.0,
            percentageOffAmount: nil,
            percentageOffRate: nil,
            cashDiscountAmount: nil,
            cashDiscountRate: nil,
            surchargeAmount: 3.0,
            surchargeRate: 3.0,
            tipAmount: 15.0,
            tipRate: 15.0,
            taxAmount: nil,
            taxRate: nil,
            totalAmount: 118.0
        )
        
        let debitCardAmount = Components.Schemas.PaymentGateway_Contracts_Amounts_AmountDto(
            baseAmount: 100.0,
            percentageOffAmount: nil,
            percentageOffRate: nil,
            cashDiscountAmount: nil,
            cashDiscountRate: nil,
            surchargeAmount: 2.0,
            surchargeRate: 2.0,
            tipAmount: nil,
            tipRate: nil,
            taxAmount: nil,
            taxRate: nil,
            totalAmount: 102.0
        )
        
        let achAmount = Components.Schemas.PaymentGateway_Contracts_Amounts_AmountDto(
            baseAmount: 100.0,
            percentageOffAmount: nil,
            percentageOffRate: nil,
            cashDiscountAmount: nil,
            cashDiscountRate: nil,
            surchargeAmount: nil,
            surchargeRate: nil,
            tipAmount: nil,
            tipRate: nil,
            taxAmount: nil,
            taxRate: nil,
            totalAmount: 100.0
        )
        
        let responseBody = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Amounts_IsvAmountsResponse(
            currencyId: Components.Schemas.PaymentGateway_Contracts_Enums_Currency._1,
            currency: "USD",
            zeroCostProcessingOptionId: Components.Schemas.PaymentGateway_Contracts_Enums_ZeroCostProcessingOption._1,
            zeroCostProcessingOption: "Option 1",
            useCardPrice: true,
            cash: cashAmount,
            creditCard: creditCardAmount,
            debitCard: debitCardAmount,
            ach: achAmount
        )
        
        let okBody = Operations.GetPayApiV1TransactionsCalculateAmount.Output.Ok.Body.json(responseBody)
        let okResponse = Operations.GetPayApiV1TransactionsCalculateAmount.Output.Ok(body: okBody)
        let output = Operations.GetPayApiV1TransactionsCalculateAmount.Output.ok(okResponse)
        
        let result = try CalculateAmountMapper.toModel(output)
        
        #expect(result.currencyId == 1)
        #expect(result.currency == "USD")
        #expect(result.zeroCostProcessingOptionId == 1)
        #expect(result.zeroCostProcessingOption == "Option 1")
        #expect(result.useCardPrice == true)
        #expect(result.cash != nil)
        #expect(result.cash?.baseAmount == 100.0)
        #expect(result.creditCard != nil)
        #expect(result.creditCard?.totalAmount == 118.0)
        #expect(result.debitCard != nil)
        #expect(result.debitCard?.totalAmount == 102.0)
        #expect(result.ach != nil)
        #expect(result.ach?.totalAmount == 100.0)
    }
    
    @Test("CalculateAmountMapper maps response with nil optional fields")
    func testCalculateAmountMapperToModelWithNilFields() throws {
        let responseBody = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Amounts_IsvAmountsResponse(
            currencyId: nil,
            currency: nil,
            zeroCostProcessingOptionId: nil,
            zeroCostProcessingOption: nil,
            useCardPrice: false,
            cash: nil,
            creditCard: nil,
            debitCard: nil,
            ach: nil
        )
        
        let okBody = Operations.GetPayApiV1TransactionsCalculateAmount.Output.Ok.Body.json(responseBody)
        let okResponse = Operations.GetPayApiV1TransactionsCalculateAmount.Output.Ok(body: okBody)
        let output = Operations.GetPayApiV1TransactionsCalculateAmount.Output.ok(okResponse)
        
        let result = try CalculateAmountMapper.toModel(output)
        
        #expect(result.currencyId == nil)
        #expect(result.currency == nil)
        #expect(result.zeroCostProcessingOptionId == nil)
        #expect(result.zeroCostProcessingOption == nil)
        #expect(result.useCardPrice == false)
        #expect(result.cash == nil)
        #expect(result.creditCard == nil)
        #expect(result.debitCard == nil)
        #expect(result.ach == nil)
    }
    
    @Test("CalculateAmountMapper maps response with partial amounts")
    func testCalculateAmountMapperToModelWithPartialAmounts() throws {
        let creditCardAmount = Components.Schemas.PaymentGateway_Contracts_Amounts_AmountDto(
            baseAmount: 50.0,
            percentageOffAmount: nil,
            percentageOffRate: nil,
            cashDiscountAmount: nil,
            cashDiscountRate: nil,
            surchargeAmount: 1.5,
            surchargeRate: 3.0,
            tipAmount: 7.5,
            tipRate: 15.0,
            taxAmount: nil,
            taxRate: nil,
            totalAmount: 59.0
        )
        
        let responseBody = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Amounts_IsvAmountsResponse(
            currencyId: Components.Schemas.PaymentGateway_Contracts_Enums_Currency._1,
            currency: "USD",
            zeroCostProcessingOptionId: nil,
            zeroCostProcessingOption: nil,
            useCardPrice: true,
            cash: nil,
            creditCard: creditCardAmount,
            debitCard: nil,
            ach: nil
        )
        
        let okBody = Operations.GetPayApiV1TransactionsCalculateAmount.Output.Ok.Body.json(responseBody)
        let okResponse = Operations.GetPayApiV1TransactionsCalculateAmount.Output.Ok(body: okBody)
        let output = Operations.GetPayApiV1TransactionsCalculateAmount.Output.ok(okResponse)
        
        let result = try CalculateAmountMapper.toModel(output)
        
        #expect(result.currencyId == 1)
        #expect(result.currency == "USD")
        #expect(result.cash == nil)
        #expect(result.creditCard != nil)
        #expect(result.creditCard?.baseAmount == 50.0)
        #expect(result.creditCard?.surchargeAmount == 1.5)
        #expect(result.creditCard?.tipAmount == 7.5)
        #expect(result.creditCard?.totalAmount == 59.0)
        #expect(result.debitCard == nil)
        #expect(result.ach == nil)
    }
}

