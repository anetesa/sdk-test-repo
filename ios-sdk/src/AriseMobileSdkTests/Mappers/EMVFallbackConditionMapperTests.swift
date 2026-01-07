import Foundation
import Testing
@testable import AriseMobile

/// Tests for EMVFallbackConditionMapper
struct EMVFallbackConditionMapperTests {
    
    @Test("EMVFallbackConditionMapper maps iccTerminalError")
    func testEMVFallbackConditionMapperIccTerminalError() {
        let condition = EMVFallbackCondition.iccTerminalError
        let result = EMVFallbackConditionMapper.toGeneratedInput(condition)
        
        #expect(result != nil)
        #expect(result == ._0)
    }
    
    @Test("EMVFallbackConditionMapper maps noCandidateList")
    func testEMVFallbackConditionMapperNoCandidateList() {
        let condition = EMVFallbackCondition.noCandidateList
        let result = EMVFallbackConditionMapper.toGeneratedInput(condition)
        
        #expect(result != nil)
        #expect(result == ._1)
    }
    
    @Test("EMVFallbackConditionMapper returns nil for nil condition")
    func testEMVFallbackConditionMapperWithNilCondition() {
        let result = EMVFallbackConditionMapper.toGeneratedInput(nil)
        #expect(result == nil)
    }
}



