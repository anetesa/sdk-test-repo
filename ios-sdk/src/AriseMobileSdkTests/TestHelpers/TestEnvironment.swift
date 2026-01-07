import Foundation
@testable import AriseMobile

/// Test environment configuration
enum TestEnvironment {
    
    /// Create a test EnvironmentSettings (uses UAT by default for testing)
    static func createTestEnvironmentSettings() -> EnvironmentSettings {
        return .uat
    }
    
    /// Create a UAT EnvironmentSettings
    static func createUATEnvironmentSettings() -> EnvironmentSettings {
        return .uat
    }
    
    /// Create a production EnvironmentSettings (use with caution in tests)
    static func createProductionEnvironmentSettings() -> EnvironmentSettings {
        return .production
    }
    
    /// Reset test environment (clear any global state if needed)
    static func reset() {
        // Clear any global test state
        // This can be extended as needed
    }
}

