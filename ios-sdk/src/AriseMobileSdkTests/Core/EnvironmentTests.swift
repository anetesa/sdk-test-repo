import Foundation
import Testing
@testable import AriseMobile

/// Tests for Environment enum
struct EnvironmentTests {
    
    @Test("Environment has production case")
    func testEnvironmentHasProductionCase() {
        let env = Environment.production
        #expect(env == .production)
    }
    
    @Test("Environment has uat case")
    func testEnvironmentHasUatCase() {
        let env = Environment.uat
        #expect(env == .uat)
    }
    
    @Test("Environment cases are distinct")
    func testEnvironmentCasesAreDistinct() {
        let production = Environment.production
        let uat = Environment.uat
        #expect(production != uat)
    }
    
    @Test("Environment can be used in switch statement")
    func testEnvironmentSwitchStatement() {
        let env: Environment = .production
        var result: String = ""
        
        switch env {
        case .production:
            result = "prod"
        case .uat:
            result = "uat"
        }
        
        #expect(result == "prod")
    }
}



