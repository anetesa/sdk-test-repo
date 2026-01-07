import Foundation
import Testing
@testable import AriseMobile

/// Tests for TransactionProductMapper
struct TransactionProductMapperTests {
    
    @Test("TransactionProductMapper maps product with all fields")
    func testTransactionProductMapperWithAllFields() {
        let product = TransactionProduct(
            name: "Test Product",
            code: "PROD-001",
            unitPrice: 10.50,
            measurementUnit: "piece",
            quantity: 2,
            taxAmount: 2.10,
            discountRate: 5.0,
            description: "Test product description",
            measurementUnitId: 1
        )
        
        let result = TransactionProductMapper.toGeneratedInput(product)
        
        #expect(result.name == "Test Product")
        #expect(result.code == "PROD-001")
        #expect(result.unitPrice == 10.50)
        #expect(result.measurementUnit == "piece")
        #expect(result.quantity == 2)
        #expect(result.taxAmount == 2.10)
        #expect(result.discountRate == 5.0)
        #expect(result.description == "Test product description")
        #expect(result.measurementUnitId == 1)
    }
    
    @Test("TransactionProductMapper maps product with minimal fields")
    func testTransactionProductMapperWithMinimalFields() {
        let product = TransactionProduct(
            name: "Minimal Product",
            code: nil,
            unitPrice: 5.0,
            measurementUnit: nil,
            quantity: 1,
            taxAmount: nil,
            discountRate: nil,
            description: nil,
            measurementUnitId: nil
        )
        
        let result = TransactionProductMapper.toGeneratedInput(product)
        
        #expect(result.name == "Minimal Product")
        #expect(result.code == nil)
        #expect(result.unitPrice == 5.0)
        #expect(result.measurementUnit == nil)
        #expect(result.quantity == 1)
        #expect(result.taxAmount == nil)
        #expect(result.discountRate == nil)
        #expect(result.description == nil)
        #expect(result.measurementUnitId == nil)
    }
    
    @Test("TransactionProductMapper maps product with zero values")
    func testTransactionProductMapperWithZeroValues() {
        let product = TransactionProduct(
            name: "Zero Product",
            code: "ZERO",
            unitPrice: 0.0,
            measurementUnit: "unit",
            quantity: 0,
            taxAmount: 0.0,
            discountRate: 0.0,
            description: "",
            measurementUnitId: 0
        )
        
        let result = TransactionProductMapper.toGeneratedInput(product)
        
        #expect(result.name == "Zero Product")
        #expect(result.unitPrice == 0.0)
        #expect(result.quantity == 0)
        #expect(result.taxAmount == 0.0)
        #expect(result.discountRate == 0.0)
    }
}



