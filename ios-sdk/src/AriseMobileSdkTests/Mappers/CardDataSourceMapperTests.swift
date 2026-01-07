import Foundation
import Testing
@testable import AriseMobile

/// Tests for CardDataSourceMapper
struct CardDataSourceMapperTests {
    
    @Test("CardDataSourceMapper maps internet to _1")
    func testCardDataSourceMapperInternet() {
        let source = CardDataSource.internet
        let result = CardDataSourceMapper.toGeneratedInput(source)
        #expect(result == ._1)
    }
    
    @Test("CardDataSourceMapper maps swipe to _2")
    func testCardDataSourceMapperSwipe() {
        let source = CardDataSource.swipe
        let result = CardDataSourceMapper.toGeneratedInput(source)
        #expect(result == ._2)
    }
    
    @Test("CardDataSourceMapper maps nfc to _3")
    func testCardDataSourceMapperNfc() {
        let source = CardDataSource.nfc
        let result = CardDataSourceMapper.toGeneratedInput(source)
        #expect(result == ._3)
    }
    
    @Test("CardDataSourceMapper maps emv to _4")
    func testCardDataSourceMapperEmv() {
        let source = CardDataSource.emv
        let result = CardDataSourceMapper.toGeneratedInput(source)
        #expect(result == ._4)
    }
    
    @Test("CardDataSourceMapper maps emvContactless to _5")
    func testCardDataSourceMapperEmvContactless() {
        let source = CardDataSource.emvContactless
        let result = CardDataSourceMapper.toGeneratedInput(source)
        #expect(result == ._5)
    }
    
    @Test("CardDataSourceMapper maps fallbackSwipe to _6")
    func testCardDataSourceMapperFallbackSwipe() {
        let source = CardDataSource.fallbackSwipe
        let result = CardDataSourceMapper.toGeneratedInput(source)
        #expect(result == ._6)
    }
    
    @Test("CardDataSourceMapper maps manual to _7")
    func testCardDataSourceMapperManual() {
        let source = CardDataSource.manual
        let result = CardDataSourceMapper.toGeneratedInput(source)
        #expect(result == ._7)
    }
    
    @Test("CardDataSourceMapper toModel returns nil for nil source")
    func testCardDataSourceMapperToModelWithNilSource() {
        let result = CardDataSourceMapper.toModel(nil)
        #expect(result == nil)
    }
    
    @Test("CardDataSourceMapper toModel maps _1 to internet")
    func testCardDataSourceMapperToModelInternet() {
        let source = Components.Schemas.PaymentGateway_Contracts_Enums_CardDataSource._1
        let result = CardDataSourceMapper.toModel(source)
        
        #expect(result != nil)
        #expect(result == .internet)
    }
    
    @Test("CardDataSourceMapper toModel maps _7 to manual")
    func testCardDataSourceMapperToModelManual() {
        let source = Components.Schemas.PaymentGateway_Contracts_Enums_CardDataSource._7
        let result = CardDataSourceMapper.toModel(source)
        
        #expect(result != nil)
        #expect(result == .manual)
    }
}



