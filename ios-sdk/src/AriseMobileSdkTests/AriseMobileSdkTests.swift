//
 
import Foundation
import Testing
@testable import AriseMobile

struct AriseMobileSdkTests {

    @Test func example() async throws {
        // Example test demonstrating test infrastructure usage
        
        // Test 1: Verify test environment configuration
        let testEnvironment = TestEnvironment.createTestEnvironmentSettings()
        #expect(testEnvironment == .uat)
        
        // Test 2: Verify DeviceFactory creates valid test data
        let testDevice = DeviceFactory.createTTPEnabledDevice()
        #expect(testDevice.deviceId == "ttp-enabled-device")
        #expect(testDevice.tapToPayEnabled)
        
    }
    
    @Test("getDeviceId returns valid UUID format")
    func testGetDeviceId() async throws {
        let sdk = try AriseMobileSdk(environment: .uat)
        
        let deviceId = sdk.getDeviceId()
        
        // Verify device ID is not empty
        #expect(!deviceId.isEmpty, "Device ID should not be empty")
        
        // Verify it's a valid UUID format (lowercase)
        // UUID format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx (36 characters with 4 hyphens)
        #expect(deviceId.count == 36, "Device ID should be 36 characters long")
        #expect(deviceId.contains("-"), "Device ID should contain hyphens")
        #expect(deviceId == deviceId.lowercased(), "Device ID should be lowercase")
    }
    
    @Test("getDeviceId returns consistent value")
    func testGetDeviceIdConsistency() async throws {
        let sdk = try AriseMobileSdk(environment: .uat)
        
        let deviceId1 = sdk.getDeviceId()
        let deviceId2 = sdk.getDeviceId()
        
        // Verify that multiple calls return the same value
        #expect(deviceId1 == deviceId2, "Device ID should be consistent across multiple calls")
    }

}
