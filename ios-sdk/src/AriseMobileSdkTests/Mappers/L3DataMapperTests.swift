import Foundation
import Testing
@testable import AriseMobile

/// Tests for L3DataMapper
struct L3DataMapperTests {
    
    @Test("L3DataMapper maps L3Data with all fields")
    func testL3DataMapperWithAllFields() {
        let product1 = TransactionProduct(
            name: "Product 1",
            code: "PROD-1",
            unitPrice: 10.0,
            measurementUnit: "piece",
            quantity: 2,
            taxAmount: 2.0,
            discountRate: 5.0,
            description: "Description 1",
            measurementUnitId: 1
        )
        
        let product2 = TransactionProduct(
            name: "Product 2",
            code: "PROD-2",
            unitPrice: 20.0,
            measurementUnit: "kg",
            quantity: 1,
            taxAmount: 4.0,
            discountRate: nil,
            description: nil,
            measurementUnitId: nil
        )
        
        let l3Data = L3Data(
            invoiceNumber: "INV-123",
            purchaseOrder: "PO-456",
            shippingCharges: 5.0,
            dutyCharges: 2.5,
            products: [product1, product2]
        )
        
        let result = L3DataMapper.toGeneratedInput(l3Data)
        
        #expect(result != nil)
        #expect(result?.invoiceNumber == "INV-123")
        #expect(result?.purchaseOrder == "PO-456")
        #expect(result?.shippingCharges == 5.0)
        #expect(result?.dutyCharges == 2.5)
        #expect(result?.products?.count == 2)
        #expect(result?.products?[0].name == "Product 1")
        #expect(result?.products?[1].name == "Product 2")
    }
    
    @Test("L3DataMapper maps L3Data with nil optional fields")
    func testL3DataMapperWithNilOptionalFields() {
        let l3Data = L3Data(
            invoiceNumber: nil,
            purchaseOrder: nil,
            shippingCharges: nil,
            dutyCharges: nil,
            products: nil
        )
        
        let result = L3DataMapper.toGeneratedInput(l3Data)
        
        #expect(result != nil)
        #expect(result?.invoiceNumber == nil)
        #expect(result?.purchaseOrder == nil)
        #expect(result?.shippingCharges == nil)
        #expect(result?.dutyCharges == nil)
        #expect(result?.products == nil)
    }
    
    @Test("L3DataMapper returns nil for nil L3Data")
    func testL3DataMapperWithNilL3Data() {
        let result = L3DataMapper.toGeneratedInput(nil)
        #expect(result == nil)
    }
    
    @Test("L3DataMapper maps L3Data with empty products array")
    func testL3DataMapperWithEmptyProducts() {
        let l3Data = L3Data(
            invoiceNumber: "INV-789",
            purchaseOrder: nil,
            shippingCharges: nil,
            dutyCharges: nil,
            products: []
        )
        
        let result = L3DataMapper.toGeneratedInput(l3Data)
        
        #expect(result != nil)
        #expect(result?.invoiceNumber == "INV-789")
        #expect(result?.products?.count == 0)
    }
}



