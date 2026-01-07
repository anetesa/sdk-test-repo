import Foundation
import Security
import UIKit

/// Utility for retrieving a persistent device identifier that survives app reinstallation.
///
/// The identifier is stored in Keychain and will persist even after the app is deleted and reinstalled,
/// as long as the device is not wiped or restored from backup.
final class DeviceIdentifier {
    static let shared = DeviceIdentifier()
    
    private let _serviceName = "com.arise.mobile.sdk"
    private let _account = "device_identifier"
    private let _logger = AriseLogger.shared
    private let _queue = DispatchQueue(label: "com.arise.mobile.sdk.deviceidentifier", qos: .utility)
    
    // In-memory cache for device identifier (used when Keychain is unavailable, e.g., in tests)
    private var _cachedIdentifier: String?
    
    private init() {}
    
    /// Retrieves a persistent device identifier.
    ///
    /// - Returns: A UUID string that remains constant across app reinstalls.
    ///   If an identifier exists in Keychain, it is returned. Otherwise, a new UUID is generated,
    ///   stored in Keychain, and returned.
    func getDeviceIdentifier() -> String {
        var identifier: String?
        
        _queue.sync {
            // First, check in-memory cache (for test environments where Keychain doesn't work)
            if let cached = _cachedIdentifier {
                identifier = cached
                _logger.debug("Retrieved device identifier from memory cache")
                return
            }
            
            // Try to read from Keychain
            if let existingId = readFromKeychain() {
                identifier = existingId
                _cachedIdentifier = existingId
                _logger.debug("Retrieved existing device identifier from Keychain")
                return
            }
            
            // Generate new identifier
            let newId = UUID().uuidString.lowercased()
            _logger.debug("Generated new device identifier: \(newId)")
            
            let saveResult = saveToKeychain(newId)
            
            if saveResult {
                identifier = newId
                _cachedIdentifier = newId
                _logger.info("Saved new device identifier to Keychain")
            } else {
                // Keychain failed, but cache in memory for consistency within this app session
                identifier = newId
                _cachedIdentifier = newId
                _logger.warning("Failed to save device identifier to Keychain, using generated ID (cached in memory)")
            }
        }
        
        return identifier ?? UUID().uuidString
    }
    
    // MARK: - Keychain Helpers
    
    private func keychainQuery() -> [String: Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: _serviceName,
            kSecAttrAccount as String: _account,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
    }
    
    private func readFromKeychain() -> String? {
        var query = keychainQuery()
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess,
           let data = item as? Data,
           let identifier = String(data: data, encoding: .utf8) {
            return identifier.lowercased()
        }
        
        if status != errSecItemNotFound && status != -34018 {
            _logger.error("Keychain read failed for device identifier: \(status)")
        }
        
        return nil
    }
    
    private func saveToKeychain(_ identifier: String) -> Bool {
        guard let data = identifier.data(using: .utf8) else {
            _logger.error("Failed to encode device identifier")
            return false
        }
        
        _ = deleteFromKeychain()
        
        var query = keychainQuery()
        query[kSecValueData as String] = data
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            return true
        }
        
        if status == -34018 {
            _logger.debug("Keychain save skipped (missing entitlements, likely in test environment): \(status)")
            return false
        }
        
        _logger.error("Keychain save failed for device identifier: \(status)")
        return false
    }
    
    private func deleteFromKeychain() -> Bool {
        let status = SecItemDelete(keychainQuery() as CFDictionary)
        
        if status == errSecSuccess || status == errSecItemNotFound || status == -34018 {
            return true
        }
        
        _logger.error("Keychain delete failed for device identifier: \(status)")
        return false
    }
    

    func getDeviceName() -> String {
        return getModelIdentifier()
    }
    
    /// Gets the device model identifier (e.g., "iPhone12,1").
    ///
    /// - Returns: Model identifier string
    private func getModelIdentifier() -> String {
        // Check simulator environment variable first
        if let simulatorModel = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return simulatorModel
        }
        
        // Get actual device model identifier
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }
    }
    
}

