import Foundation
import Testing
@testable import AriseMobile

/// Tests for EMVFallbackLastChipReadMapper
struct EMVFallbackLastChipReadMapperTests {
    
    @Test("EMVFallbackLastChipReadMapper maps successful")
    func testEMVFallbackLastChipReadMapperSuccessful() {
        let lastChipRead = EMVFallbackLastChipRead.successful
        let result = EMVFallbackLastChipReadMapper.toGeneratedInput(lastChipRead)
        
        #expect(result != nil)
        #expect(result == ._0)
    }
    
    @Test("EMVFallbackLastChipReadMapper maps failed")
    func testEMVFallbackLastChipReadMapperFailed() {
        let lastChipRead = EMVFallbackLastChipRead.failed
        let result = EMVFallbackLastChipReadMapper.toGeneratedInput(lastChipRead)
        
        #expect(result != nil)
        #expect(result == ._1)
    }
    
    @Test("EMVFallbackLastChipReadMapper maps notAChipTransaction")
    func testEMVFallbackLastChipReadMapperNotAChipTransaction() {
        let lastChipRead = EMVFallbackLastChipRead.notAChipTransaction
        let result = EMVFallbackLastChipReadMapper.toGeneratedInput(lastChipRead)
        
        #expect(result != nil)
        #expect(result == ._2)
    }
    
    @Test("EMVFallbackLastChipReadMapper maps unknown")
    func testEMVFallbackLastChipReadMapperUnknown() {
        let lastChipRead = EMVFallbackLastChipRead.unknown
        let result = EMVFallbackLastChipReadMapper.toGeneratedInput(lastChipRead)
        
        #expect(result != nil)
        #expect(result == ._3)
    }
    
    @Test("EMVFallbackLastChipReadMapper returns nil for nil lastChipRead")
    func testEMVFallbackLastChipReadMapperWithNilLastChipRead() {
        let result = EMVFallbackLastChipReadMapper.toGeneratedInput(nil)
        #expect(result == nil)
    }
}



