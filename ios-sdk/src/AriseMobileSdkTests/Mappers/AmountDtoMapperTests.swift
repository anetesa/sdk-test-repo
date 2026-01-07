import Foundation
import Testing
@testable import AriseMobile

/// Tests for AmountDtoMapper
struct AmountDtoMapperTests {
    
    @Test("AmountDtoMapper maps amount with all fields")
    func testAmountDtoMapperWithAllFields() {
        let amount = Components.Schemas.PaymentGateway_Contracts_Amounts_AmountDto(
            baseAmount: 100.0,
            percentageOffAmount: 10.0,
            percentageOffRate: 10.0,
            cashDiscountAmount: 5.0,
            cashDiscountRate: 5.0,
            surchargeAmount: 3.0,
            surchargeRate: 3.0,
            tipAmount: 15.0,
            tipRate: 15.0,
            taxAmount: 8.0,
            taxRate: 8.0,
            totalAmount: 113.0
        )
        
        let result = AmountDtoMapper.toModel(amount)
        
        #expect(result.baseAmount == 100.0)
        #expect(result.percentageOffAmount == 10.0)
        #expect(result.percentageOffRate == 10.0)
        #expect(result.cashDiscountAmount == 5.0)
        #expect(result.cashDiscountRate == 5.0)
        #expect(result.surchargeAmount == 3.0)
        #expect(result.surchargeRate == 3.0)
        #expect(result.tipAmount == 15.0)
        #expect(result.tipRate == 15.0)
        #expect(result.taxAmount == 8.0)
        #expect(result.taxRate == 8.0)
        #expect(result.totalAmount == 113.0)
    }
    
    @Test("AmountDtoMapper maps nil amount to defaults")
    func testAmountDtoMapperWithNilAmount() {
        let result = AmountDtoMapper.toModel(nil)
        
        #expect(result.baseAmount == 0.0)
        #expect(result.percentageOffAmount == 0.0)
        #expect(result.percentageOffRate == 0.0)
        #expect(result.cashDiscountAmount == 0.0)
        #expect(result.cashDiscountRate == 0.0)
        #expect(result.surchargeAmount == 0.0)
        #expect(result.surchargeRate == 0.0)
        #expect(result.tipAmount == 0.0)
        #expect(result.tipRate == 0.0)
        #expect(result.taxAmount == 0.0)
        #expect(result.taxRate == 0.0)
        #expect(result.totalAmount == 0.0)
    }
    
    @Test("AmountDtoMapper maps amount with partial fields")
    func testAmountDtoMapperWithPartialFields() {
        let amount = Components.Schemas.PaymentGateway_Contracts_Amounts_AmountDto(
            baseAmount: 50.0,
            percentageOffAmount: nil,
            percentageOffRate: nil,
            cashDiscountAmount: nil,
            cashDiscountRate: nil,
            surchargeAmount: 2.0,
            surchargeRate: nil,
            tipAmount: nil,
            tipRate: nil,
            taxAmount: 4.0,
            taxRate: nil,
            totalAmount: 56.0
        )
        
        let result = AmountDtoMapper.toModel(amount)
        
        #expect(result.baseAmount == 50.0)
        #expect(result.percentageOffAmount == 0.0)
        #expect(result.percentageOffRate == 0.0)
        #expect(result.cashDiscountAmount == 0.0)
        #expect(result.cashDiscountRate == 0.0)
        #expect(result.surchargeAmount == 2.0)
        #expect(result.surchargeRate == 0.0)
        #expect(result.tipAmount == 0.0)
        #expect(result.tipRate == 0.0)
        #expect(result.taxAmount == 4.0)
        #expect(result.taxRate == 0.0)
        #expect(result.totalAmount == 56.0)
    }
    
    @Test("AmountDtoMapper maps amount with zero values")
    func testAmountDtoMapperWithZeroValues() {
        let amount = Components.Schemas.PaymentGateway_Contracts_Amounts_AmountDto(
            baseAmount: 0.0,
            percentageOffAmount: 0.0,
            percentageOffRate: 0.0,
            cashDiscountAmount: 0.0,
            cashDiscountRate: 0.0,
            surchargeAmount: 0.0,
            surchargeRate: 0.0,
            tipAmount: 0.0,
            tipRate: 0.0,
            taxAmount: 0.0,
            taxRate: 0.0,
            totalAmount: 0.0
        )
        
        let result = AmountDtoMapper.toModel(amount)
        
        #expect(result.baseAmount == 0.0)
        #expect(result.totalAmount == 0.0)
    }
    
    @Test("AmountDtoMapper maps amount with negative values")
    func testAmountDtoMapperWithNegativeValues() {
        let amount = Components.Schemas.PaymentGateway_Contracts_Amounts_AmountDto(
            baseAmount: -10.0,
            percentageOffAmount: -5.0,
            percentageOffRate: nil,
            cashDiscountAmount: nil,
            cashDiscountRate: nil,
            surchargeAmount: nil,
            surchargeRate: nil,
            tipAmount: nil,
            tipRate: nil,
            taxAmount: nil,
            taxRate: nil,
            totalAmount: -15.0
        )
        
        let result = AmountDtoMapper.toModel(amount)
        
        #expect(result.baseAmount == -10.0)
        #expect(result.percentageOffAmount == -5.0)
        #expect(result.totalAmount == -15.0)
    }
}



