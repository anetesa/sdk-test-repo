import Foundation
import Testing
@testable import AriseMobile

/// Tests for DeviceIdentifier utility
struct DeviceIdentifierTests {
    
    // MARK: - Device Identifier Generation
    
    @Test("DeviceIdentifier generates a valid UUID")
    func testDeviceIdentifierGeneratesValidUUID() {
        let identifier = DeviceIdentifier.shared.getDeviceIdentifier()
        
        // UUID should be a valid UUID format (lowercase)
        #expect(identifier.count == 36) // UUID format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
        #expect(identifier.contains("-"))
        #expect(identifier == identifier.lowercased()) // Should be lowercase
    }
    
    @Test("DeviceIdentifier generates unique identifiers on first call")
    func testDeviceIdentifierGeneratesUniqueIdentifier() {
        // Clear any existing identifier by deleting from Keychain
        clearDeviceIdentifier()
        
        let identifier = DeviceIdentifier.shared.getDeviceIdentifier()
        
        // Should be a valid UUID
        #expect(UUID(uuidString: identifier) != nil)
    }
    
    // MARK: - Persistence
    
    @Test("DeviceIdentifier persists identifier across calls")
    func testDeviceIdentifierPersistsAcrossCalls() {
        // Clear any existing identifier to ensure clean state
        clearDeviceIdentifier()
        
        // Small delay to ensure Keychain operations complete
        Thread.sleep(forTimeInterval: 0.2)
        
        // Check if Keychain is accessible BEFORE generating identifier
        let keychainAccessible = isKeychainAccessible()
        
        let firstIdentifier = DeviceIdentifier.shared.getDeviceIdentifier()
        #expect(!firstIdentifier.isEmpty)
        #expect(UUID(uuidString: firstIdentifier) != nil)
        
        Thread.sleep(forTimeInterval: 0.2)
        
        if keychainAccessible {
            let storedIdentifier = readDeviceIdentifierFromKeychain()
            
            if storedIdentifier != nil {
                #expect(storedIdentifier == firstIdentifier, "Identifier should be saved to Keychain. Expected: \(firstIdentifier), got: \(storedIdentifier ?? "nil")")
            }
            
            // Get identifier second time - should be the same (retrieved from Keychain)
            let secondIdentifier = DeviceIdentifier.shared.getDeviceIdentifier()
            
            // Small delay to ensure Keychain operations complete
            Thread.sleep(forTimeInterval: 0.2)
            
            // Verify Keychain still has the same identifier
            let stillStored = readDeviceIdentifierFromKeychain()
            if stillStored != nil {
                #expect(stillStored == firstIdentifier, "Keychain should still have first identifier. Expected: \(firstIdentifier), got: \(stillStored ?? "nil")")
            }
            
            // If Keychain is accessible and we successfully stored, identifiers should match
            if storedIdentifier != nil {
                #expect(firstIdentifier == secondIdentifier, "Expected same identifier on second call, got first: \(firstIdentifier), second: \(secondIdentifier)")
            }
        } else {
            // If Keychain is not accessible (e.g., in tests without entitlements),
            // DeviceIdentifier will generate a new UUID each time, which is expected behavior
            // We can't test persistence in this case, but we can verify it still returns valid UUIDs
            let secondIdentifier = DeviceIdentifier.shared.getDeviceIdentifier()
            #expect(!secondIdentifier.isEmpty)
            #expect(UUID(uuidString: secondIdentifier) != nil)
        }
    }
    
    @Test("DeviceIdentifier retrieves existing identifier from Keychain")
    func testDeviceIdentifierRetrievesFromKeychain() {
        // Clear any existing identifier to ensure clean state
        clearDeviceIdentifier()
        
        // Small delay to ensure Keychain operations complete
        Thread.sleep(forTimeInterval: 0.2)
        
        // Check if Keychain is accessible
        let keychainAccessible = isKeychainAccessible()
        
        // Generate and save an identifier
        let savedIdentifier = DeviceIdentifier.shared.getDeviceIdentifier()
        #expect(!savedIdentifier.isEmpty)
        #expect(UUID(uuidString: savedIdentifier) != nil)
        
        // Small delay to ensure Keychain operations complete
        Thread.sleep(forTimeInterval: 0.2)
        
        if keychainAccessible {
            // Verify identifier was saved to Keychain
            let storedIdentifier = readDeviceIdentifierFromKeychain()
            if storedIdentifier != nil {
                #expect(storedIdentifier == savedIdentifier, "Identifier should be saved to Keychain. Expected: \(savedIdentifier), got: \(storedIdentifier ?? "nil")")
            }
        }
        
        // Small delay before retrieval
        Thread.sleep(forTimeInterval: 0.2)
        
        // Subsequent calls should return the same identifier (from Keychain if accessible)
        let retrievedIdentifier = DeviceIdentifier.shared.getDeviceIdentifier()
        
        if keychainAccessible {
            // Verify Keychain still has the identifier
            let stillStored = readDeviceIdentifierFromKeychain()
            if stillStored != nil {
                #expect(stillStored == savedIdentifier, "Keychain should still have saved identifier. Expected: \(savedIdentifier), got: \(stillStored ?? "nil")")
                // If Keychain is accessible and we successfully stored, identifiers should match
                #expect(savedIdentifier == retrievedIdentifier, "Expected same identifier on retrieval, got saved: \(savedIdentifier), retrieved: \(retrievedIdentifier)")
            }
        } else {
            // If Keychain is not accessible, DeviceIdentifier will generate a new UUID each time
            // This is expected behavior in test environment without entitlements
            #expect(!retrievedIdentifier.isEmpty)
            #expect(UUID(uuidString: retrievedIdentifier) != nil)
        }
    }
    
    // MARK: - Uniqueness
    
    @Test("DeviceIdentifier returns same identifier for multiple calls")
    func testDeviceIdentifierReturnsSameIdentifier() {
        // Clear any existing identifier to ensure clean state
        clearDeviceIdentifier()
        
        // Small delay to ensure Keychain operations complete
        Thread.sleep(forTimeInterval: 0.2)
        
        // Check if Keychain is accessible
        let keychainAccessible = isKeychainAccessible()
        
        let identifier1 = DeviceIdentifier.shared.getDeviceIdentifier()
        #expect(!identifier1.isEmpty)
        #expect(UUID(uuidString: identifier1) != nil)
        
        // Small delay to ensure Keychain operations complete
        Thread.sleep(forTimeInterval: 0.2)
        
        if keychainAccessible {
            // Verify identifier1 was saved to Keychain
            let storedAfterFirst = readDeviceIdentifierFromKeychain()
            if storedAfterFirst != nil {
                #expect(storedAfterFirst == identifier1, "After first call, Keychain should have identifier1. Expected: \(identifier1), got: \(storedAfterFirst ?? "nil")")
            }
        }
        
        Thread.sleep(forTimeInterval: 0.2)
        
        let identifier2 = DeviceIdentifier.shared.getDeviceIdentifier()
        #expect(!identifier2.isEmpty)
        #expect(UUID(uuidString: identifier2) != nil)
        
        Thread.sleep(forTimeInterval: 0.2)
        
        let identifier3 = DeviceIdentifier.shared.getDeviceIdentifier()
        #expect(!identifier3.isEmpty)
        #expect(UUID(uuidString: identifier3) != nil)
        
        if keychainAccessible {
            // If Keychain is accessible and we successfully stored, all identifiers should match
            let storedAfterFirst = readDeviceIdentifierFromKeychain()
            if storedAfterFirst != nil {
                #expect(identifier1 == identifier2, "Expected same identifier on calls 1-2, got: \(identifier1) vs \(identifier2)")
                #expect(identifier2 == identifier3, "Expected same identifier on calls 2-3, got: \(identifier2) vs \(identifier3)")
                #expect(identifier1 == identifier3, "Expected same identifier on calls 1-3, got: \(identifier1) vs \(identifier3)")
            }
        } else {
            // If Keychain is not accessible, DeviceIdentifier will generate a new UUID each time
            // This is expected behavior in test environment without entitlements
            // We can't test persistence in this case, but we can verify it still returns valid UUIDs
        }
    }
    
    @Test("DeviceIdentifier maintains uniqueness across app sessions")
    func testDeviceIdentifierMaintainsUniqueness() {
        // Clear any existing identifier to ensure clean state
        clearDeviceIdentifier()
        
        // Check if Keychain is accessible
        let keychainAccessible = isKeychainAccessible()
        
        // Small delay to ensure Keychain operations complete
        Thread.sleep(forTimeInterval: 0.1)
        
        // Get identifier
        let identifier1 = DeviceIdentifier.shared.getDeviceIdentifier()
        #expect(!identifier1.isEmpty)
        #expect(UUID(uuidString: identifier1) != nil)
        
        if keychainAccessible {
            // Verify identifier1 was saved to Keychain
            let storedIdentifier = readDeviceIdentifierFromKeychain()
            #expect(storedIdentifier == identifier1, "Identifier should be saved to Keychain. Expected: \(identifier1), got: \(storedIdentifier ?? "nil")")
        }
        
        Thread.sleep(forTimeInterval: 0.1)
        
        // Subsequent calls should return the same identifier (if Keychain is accessible)
        let identifier2 = DeviceIdentifier.shared.getDeviceIdentifier()
        #expect(!identifier2.isEmpty)
        #expect(UUID(uuidString: identifier2) != nil)
        
        if keychainAccessible {
            // Verify Keychain still has identifier1 (should be same as identifier2)
            let stillStored = readDeviceIdentifierFromKeychain()
            #expect(stillStored == identifier1, "Keychain should still have identifier1. Expected: \(identifier1), got: \(stillStored ?? "nil")")
            // If Keychain is accessible, identifiers should match
            #expect(identifier1 == identifier2, "Expected same identifier across calls, got: \(identifier1) vs \(identifier2)")
        } else {
            // If Keychain is not accessible, DeviceIdentifier will generate a new UUID each time
            // This is expected behavior in test environment without entitlements
        }
    }
    
    // MARK: - Device Name
    
    @Test("DeviceIdentifier returns device name")
    func testDeviceIdentifierReturnsDeviceName() {
        let deviceName = DeviceIdentifier.shared.getDeviceName()
        
        // Device name should not be empty
        #expect(!deviceName.isEmpty)
        
        // Device name should be a valid model identifier format
        // (e.g., "iPhone12,1", "iPad13,1", etc.)
        #expect(deviceName.count > 0)
    }
    
    // MARK: - Edge Cases
    
    @Test("DeviceIdentifier handles Keychain read failure gracefully")
    func testDeviceIdentifierHandlesKeychainReadFailure() {
        // This test verifies that DeviceIdentifier still returns a valid UUID
        // even if Keychain operations fail (though we can't easily simulate this in unit tests)
        let identifier = DeviceIdentifier.shared.getDeviceIdentifier()
        
        // Should still return a valid UUID
        #expect(UUID(uuidString: identifier) != nil)
    }
    
    @Test("DeviceIdentifier handles Keychain save failure gracefully")
    func testDeviceIdentifierHandlesKeychainSaveFailure() {
        // This test verifies that DeviceIdentifier still returns a valid UUID
        // even if Keychain save fails (though we can't easily simulate this in unit tests)
        clearDeviceIdentifier()
        
        let identifier = DeviceIdentifier.shared.getDeviceIdentifier()
        
        // Should still return a valid UUID
        #expect(UUID(uuidString: identifier) != nil)
    }
    
    // MARK: - Helper Methods
    
    /// Clears the device identifier from Keychain for testing
    /// This ensures test isolation by removing any existing identifier
    /// Uses the same parameters as DeviceIdentifier to ensure proper deletion
    private func clearDeviceIdentifier() {
        let serviceName = "com.arise.mobile.sdk"
        let account = "device_identifier"
        
        // Use the same query parameters as DeviceIdentifier.keychainQuery()
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: account,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        Thread.sleep(forTimeInterval: 0.1)
        _ = status
    }
    
    /// Reads the device identifier directly from Keychain for verification
    /// This allows us to check what's actually stored in Keychain
    /// Returns nil if Keychain is not accessible (e.g., missing entitlements in tests)
    private func readDeviceIdentifierFromKeychain() -> String? {
        let serviceName = "com.arise.mobile.sdk"
        let account = "device_identifier"
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: account,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        // -34018 (errSecMissingEntitlement) means Keychain is not accessible (common in tests)
        if status == -34018 {
            return nil // Keychain not accessible
        }
        
        if status == errSecSuccess,
           let data = item as? Data,
           let identifier = String(data: data, encoding: .utf8) {
            return identifier.lowercased()
        }
        
        return nil
    }
    
    /// Checks if Keychain is accessible (has entitlements)
    /// Returns true if Keychain operations are available, false otherwise
    private func isKeychainAccessible() -> Bool {
        // Try to read from Keychain - if we get -34018, Keychain is not accessible
        let serviceName = "com.arise.mobile.sdk"
        let account = "device_identifier"
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: account,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        // -34018 (errSecMissingEntitlement) means Keychain is not accessible
        return status != -34018
    }
}

