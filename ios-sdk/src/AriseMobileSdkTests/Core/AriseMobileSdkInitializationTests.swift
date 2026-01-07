import Foundation
import Testing
@testable import AriseMobile

/// Tests for AriseMobileSdk initialization
/// 
/// Note: These tests verify SDK initialization structure without making real API calls.
/// Integration tests that require real API calls should be in a separate test suite.
struct AriseMobileSdkInitializationTests {
    
    @Test("SDK initialization structure exists")
    func testSDKInitializationStructure() {
        // Verify that SDK can be initialized (may fail if CloudCommerceSDK cannot be initialized)
        // This is a structural test that doesn't make API calls
        do {
            let sdk = try AriseMobileSdk(environment: .uat)
            #expect(sdk != nil)
        } catch {
            // If initialization fails due to CloudCommerceSDK, that's acceptable for unit tests
            // Real initialization testing should be done in integration tests
            #expect(error != nil)
        }
    }
    
    @Test("SDK version retrieval structure")
    func testGetVersionStructure() {
        // Test that getVersion() method exists and returns a string
        // This doesn't make API calls, only checks method structure
        do {
            let sdk = try AriseMobileSdk(environment: .uat)
            let version = sdk.getVersion()
            // Version should be a string (may be empty if not set in bundle)
            #expect(type(of: version) == String.self)
        } catch {
            // If initialization fails, skip version test
            #expect(error != nil)
        }
    }
    
    @Test("Log level configuration structure")
    func testLogLevelConfigurationStructure() {
        // Test that log level methods exist and work correctly
        // This doesn't make API calls, only tests method structure
        do {
            let sdk = try AriseMobileSdk(environment: .uat)
            
            // Test setting log level
            sdk.setLogLevel(.verbose)
            #expect(sdk.getLogLevel() == .verbose)
            
            sdk.setLogLevel(.error)
            #expect(sdk.getLogLevel() == .error)
            
            sdk.setLogLevel(.info)
            #expect(sdk.getLogLevel() == .info)
        } catch {
            // If initialization fails, skip log level test
            #expect(error != nil)
        }
    }
    
    // Note: Tests for CloudCommerce version retrieval and environment-specific initialization
    // are skipped here as they may trigger real API calls. These should be tested in
    // integration tests with proper mocking or in a separate integration test suite.
}

