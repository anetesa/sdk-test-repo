import Foundation
import Testing
@testable import AriseMobile

/// Tests for AvailableOperationMapper
struct AvailableOperationMapperTests {
    
    @Test("AvailableOperationMapper maps operation with all fields")
    func testAvailableOperationMapperWithAllFields() {
        let suggestedTip = Components.Schemas.PaymentGateway_Contracts_Amounts_SuggestedTipsDto(
            tipPercent: 15.0,
            tipAmount: 10.0
        )
        
        let operation = Components.Schemas.PaymentGateway_Contracts_Transactions_GetPage_GetTransactionPageResponseDto_AvailableOperation(
            typeId: 1,
            _type: "void",
            availableAmount: 100.0,
            suggestedTips: [suggestedTip]
        )
        
        let result = AvailableOperationMapper.toModel(operation)
        
        #expect(result.typeId == 1)
        #expect(result.type == "void")
        #expect(result.availableAmount == 100.0)
        #expect(result.suggestedTips?.count == 1)
        #expect(result.suggestedTips?.first?.tipPercent == 15.0)
        #expect(result.suggestedTips?.first?.tipAmount == 10.0)
    }
    
    @Test("AvailableOperationMapper maps operation with nil typeId")
    func testAvailableOperationMapperWithNilTypeId() {
        let operation = Components.Schemas.PaymentGateway_Contracts_Transactions_GetPage_GetTransactionPageResponseDto_AvailableOperation(
            typeId: nil,
            _type: "refund",
            availableAmount: 50.0,
            suggestedTips: nil
        )
        
        let result = AvailableOperationMapper.toModel(operation)
        
        #expect(result.typeId == 0) // Should default to 0
        #expect(result.type == "refund")
        #expect(result.availableAmount == 50.0)
        #expect(result.suggestedTips == nil)
    }
    
    @Test("AvailableOperationMapper maps operation with nil suggestedTips")
    func testAvailableOperationMapperWithNilSuggestedTips() {
        let operation = Components.Schemas.PaymentGateway_Contracts_Transactions_GetPage_GetTransactionPageResponseDto_AvailableOperation(
            typeId: 2,
            _type: "capture",
            availableAmount: 75.0,
            suggestedTips: nil
        )
        
        let result = AvailableOperationMapper.toModel(operation)
        
        #expect(result.typeId == 2)
        #expect(result.type == "capture")
        #expect(result.availableAmount == 75.0)
        #expect(result.suggestedTips == nil)
    }
    
    @Test("AvailableOperationMapper maps operation with multiple suggested tips")
    func testAvailableOperationMapperWithMultipleSuggestedTips() {
        let tip1 = Components.Schemas.PaymentGateway_Contracts_Amounts_SuggestedTipsDto(
            tipPercent: 10.0,
            tipAmount: 5.0
        )
        let tip2 = Components.Schemas.PaymentGateway_Contracts_Amounts_SuggestedTipsDto(
            tipPercent: 15.0,
            tipAmount: 7.5
        )
        let tip3 = Components.Schemas.PaymentGateway_Contracts_Amounts_SuggestedTipsDto(
            tipPercent: 20.0,
            tipAmount: 10.0
        )
        
        let operation = Components.Schemas.PaymentGateway_Contracts_Transactions_GetPage_GetTransactionPageResponseDto_AvailableOperation(
            typeId: 3,
            _type: "tip",
            availableAmount: 50.0,
            suggestedTips: [tip1, tip2, tip3]
        )
        
        let result = AvailableOperationMapper.toModel(operation)
        
        #expect(result.suggestedTips?.count == 3)
        #expect(result.suggestedTips?[0].tipPercent == 10.0)
        #expect(result.suggestedTips?[1].tipPercent == 15.0)
        #expect(result.suggestedTips?[2].tipPercent == 20.0)
    }
    
    @Test("AvailableOperationMapper maps operation with nil tipPercent and tipAmount")
    func testAvailableOperationMapperWithNilTipValues() {
        let suggestedTip = Components.Schemas.PaymentGateway_Contracts_Amounts_SuggestedTipsDto(
            tipPercent: nil as Double?,
            tipAmount: nil as Double?
        )
        
        let operation = Components.Schemas.PaymentGateway_Contracts_Transactions_GetPage_GetTransactionPageResponseDto_AvailableOperation(
            typeId: 4,
            _type: "void",
            availableAmount: 100.0,
            suggestedTips: [suggestedTip]
        )
        
        let result = AvailableOperationMapper.toModel(operation)
        
        #expect(result.suggestedTips?.count == 1)
        #expect(result.suggestedTips?.first?.tipPercent == 0.0) // Should default to 0.0
        #expect(result.suggestedTips?.first?.tipAmount == 0.0) // Should default to 0.0
    }
}


