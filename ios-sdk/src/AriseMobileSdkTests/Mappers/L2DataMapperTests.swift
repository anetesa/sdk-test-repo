import Foundation
import Testing
@testable import AriseMobile

/// Tests for L2DataMapper
struct L2DataMapperTests {
    
    @Test("L2DataMapper maps L2Data with salesTaxRate")
    func testL2DataMapperWithSalesTaxRate() {
        let l2Data = L2Data(salesTaxRate: 8.5)
        let result = L2DataMapper.toGeneratedInput(l2Data)
        
        #expect(result != nil)
        #expect(result?.salesTaxRate == 8.5)
    }
    
    @Test("L2DataMapper maps L2Data with zero salesTaxRate")
    func testL2DataMapperWithZeroSalesTaxRate() {
        let l2Data = L2Data(salesTaxRate: 0.0)
        let result = L2DataMapper.toGeneratedInput(l2Data)
        
        #expect(result != nil)
        #expect(result?.salesTaxRate == 0.0)
    }
    
    @Test("L2DataMapper returns nil for nil L2Data")
    func testL2DataMapperWithNilL2Data() {
        let result = L2DataMapper.toGeneratedInput(nil)
        #expect(result == nil)
    }
    
    @Test("L2DataMapper maps L2Data with negative salesTaxRate")
    func testL2DataMapperWithNegativeSalesTaxRate() {
        let l2Data = L2Data(salesTaxRate: -5.0)
        let result = L2DataMapper.toGeneratedInput(l2Data)
        
        #expect(result != nil)
        #expect(result?.salesTaxRate == -5.0)
    }
}



