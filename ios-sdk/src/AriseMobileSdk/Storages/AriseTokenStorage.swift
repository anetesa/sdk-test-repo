import Foundation
import Security

/// Secure storage for OAuth tokens used by AriseMobileSdk
internal final class AriseTokenStorage: AriseTokenStorageProtocol, @unchecked Sendable {
    private let _serviceName = "com.arise.mobile.sdk"
    private let _tokenAccount = "arise_oauth_token"
    private let _credentialsAccount = "arise_credentials"
    private let _ttpJwtAccount = "arise_ttp_jwt_token"
    private let _logger = AriseLogger.shared
    private let _queue = DispatchQueue(label: "com.arise.mobile.sdk.tokenstorage", qos: .utility)

    internal init() {}
    
    /// Errors that can occur during Keychain operations
    internal enum KeychainError: Error, LocalizedError {
        case saveFailed(OSStatus)
        case readFailed(OSStatus)
        case deleteFailed(OSStatus)
        case encodeFailed(Error)
        case decodeFailed(Error)
        case itemNotFound
        
        internal var errorDescription: String? {
            switch self {
            case .saveFailed(let status):
                return "Failed to save to Keychain (status: \(status))"
            case .readFailed(let status):
                return "Failed to read from Keychain (status: \(status))"
            case .deleteFailed(let status):
                return "Failed to delete from Keychain (status: \(status))"
            case .encodeFailed(let error):
                return "Failed to encode data for Keychain: \(error.localizedDescription)"
            case .decodeFailed(let error):
                return "Failed to decode data from Keychain: \(error.localizedDescription)"
            case .itemNotFound:
                return "Keychain item not found"
            }
        }
    }

    internal struct StoredToken: Codable {
        internal let accessToken: String
        internal let refreshToken: String?
        internal let tokenType: String
        internal let expiresAt: Date
    }

    internal struct StoredCredentials: Codable {
        internal let clientId: String
        internal let clientSecret: String
    }
    
    /// Structure for storing TTP JWT token with expiration
    internal struct StoredTTPJwtToken: Codable {
        internal let token: String
        internal let expiresAt: Date
        
        /// Checks if the token is still valid (not expired)
        /// Considers token invalid if it expires in 180 seconds (refresh proactively)
        internal var isValid: Bool {
            return expiresAt > Date().addingTimeInterval(300)
        }
    }

    /// Save authentication result securely
    /// - Parameter result: Authentication result containing tokens
    /// - Throws: KeychainError if save operation fails
    internal func save(_ result: AuthenticationResult) throws {
        // Validate expiresIn to prevent negative or zero values
        let expiresIn = max(0, result.expiresIn)
        let expiresAt = Date().addingTimeInterval(TimeInterval(expiresIn))
        let model = StoredToken(
            accessToken: result.accessToken,
            refreshToken: result.refreshToken,
            tokenType: result.tokenType,
            expiresAt: expiresAt
        )

        do {
            let data = try JSONEncoder().encode(model)
            var saveError: KeychainError?
            _queue.sync {
                if let error = self.storeInKeychain(data, account: self._tokenAccount) {
                    saveError = error
                }
            }
            
            if let error = saveError {
                _logger.error("Failed to save token to Keychain: \(error.localizedDescription)")
                throw error
            }
            
            _logger.info("Saved access token to secure storage")
        } catch let error as KeychainError {
            throw error
        } catch {
            _logger.error("Failed to encode token for storage: \(error.localizedDescription)")
            throw KeychainError.encodeFailed(error)
        }
    }

    /// Retrieve stored token if available
    /// - Returns: StoredToken if found and valid, nil otherwise
    /// - Throws: KeychainError if read operation fails (but not for itemNotFound)
    internal func load() -> StoredToken? {
        var result: StoredToken?
        var decodeError: Error?
        _queue.sync {
            guard let data = self.readFromKeychain(account: self._tokenAccount) else {
                return
            }
            do {
                result = try JSONDecoder().decode(StoredToken.self, from: data)
            } catch {
                decodeError = error
                self._logger.error("Failed to decode stored token: \(error.localizedDescription)")
            }
        }
        
        if let error = decodeError {
            _logger.error("Keychain decode error: \(error.localizedDescription)")
        }
        
        return result
    }

    /// Get valid access token string if not expired
    internal func getValidAccessToken() -> String? {
        guard let token = load() else { return nil }
        if token.expiresAt > Date() { return token.accessToken }
        _logger.warning("Stored access token is expired")
        return nil
    }

    /// Remove stored token
    internal func clear() {
        _queue.sync {
            _ = self.deleteFromKeychain(account: self._tokenAccount)
        }
        _logger.info("Cleared token from secure storage")
    }

    // MARK: - Credentials

    internal func saveCredentials(clientId: String, clientSecret: String) throws {
        let model = StoredCredentials(clientId: clientId, clientSecret: clientSecret)
        do {
            let data = try JSONEncoder().encode(model)
            var saveError: KeychainError?
            _queue.sync {
                if let error = self.storeInKeychain(data, account: self._credentialsAccount) {
                    saveError = error
                }
            }
            
            if let error = saveError {
                _logger.error("Failed to save credentials to Keychain: \(error.localizedDescription)")
                throw error
            }
            
            _logger.info("Saved client credentials to secure storage")
        } catch let error as KeychainError {
            throw error
        } catch {
            _logger.error("Failed to encode credentials for storage: \(error.localizedDescription)")
            throw KeychainError.encodeFailed(error)
        }
    }

    internal func loadCredentials() -> StoredCredentials? {
        var result: StoredCredentials?
        _queue.sync {
            guard let data = self.readFromKeychain(account: self._credentialsAccount) else { return }
            do {
                result = try JSONDecoder().decode(StoredCredentials.self, from: data)
            } catch {
                self._logger.error("Failed to decode stored credentials: \(error.localizedDescription)")
            }
        }
        return result
    }

    internal func clearCredentials() {
        _queue.sync {
            _ = self.deleteFromKeychain(account: self._credentialsAccount)
        }
        _logger.info("Cleared credentials from secure storage")
    }
    
    // MARK: - TTP JWT Token Storage
    
    /// Save TTP JWT token securely.
    ///
    /// This method saves the JWT token for Tap to Pay operations to Keychain.
    ///
    /// - Parameters:
    ///   - token: JWT token string
    ///   - expiresAt: Token expiration date
    /// - Throws: KeychainError if save operation fails
    internal func saveTTPJwtToken(token: String, expiresAt: Date) throws {
        let model = StoredTTPJwtToken(token: token, expiresAt: expiresAt)
        
        do {
            let data = try JSONEncoder().encode(model)
            var saveError: KeychainError?
            _queue.sync {
                if let error = self.storeInKeychain(data, account: self._ttpJwtAccount) {
                    saveError = error
                }
            }
            
            if let error = saveError {
                _logger.error("Failed to save TTP JWT token to Keychain: \(error.localizedDescription)")
                throw error
            }
            
            _logger.info("Saved TTP JWT token to secure storage (expires at: \(expiresAt))")
        } catch let error as KeychainError {
            throw error
        } catch {
            _logger.error("Failed to encode TTP JWT token for storage: \(error.localizedDescription)")
            throw KeychainError.encodeFailed(error)
        }
    }
    
    /// Retrieve stored TTP JWT token if available and valid.
    ///
    /// - Returns: StoredTTPJwtToken if found and valid, nil otherwise
    internal func loadTTPJwtToken() -> StoredTTPJwtToken? {
        var result: StoredTTPJwtToken?
        var decodeError: Error?
        _queue.sync {
            guard let data = self.readFromKeychain(account: self._ttpJwtAccount) else {
                return
            }
            do {
                result = try JSONDecoder().decode(StoredTTPJwtToken.self, from: data)
            } catch {
                decodeError = error
                self._logger.error("Failed to decode stored TTP JWT token: \(error.localizedDescription)")
            }
        }
        
        if let error = decodeError {
            _logger.error("Keychain decode error for TTP JWT token: \(error.localizedDescription)")
        }
        
        // Check if token is still valid
        if let token = result, !token.isValid {
            _logger.verbose("Stored TTP JWT token is expired or near expiry")
            return nil
        }
        
        return result
    }
    
    /// Remove stored TTP JWT token.
    internal func clearTTPJwtToken() {
        _queue.sync {
            _ = self.deleteFromKeychain(account: self._ttpJwtAccount)
        }
        _logger.info("Cleared TTP JWT token from secure storage")
    }

    // MARK: - Keychain Helpers

    private func keychainQuery(account: String) -> [String: Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: _serviceName,
            kSecAttrAccount as String: account,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
    }

    private func storeInKeychain(_ data: Data, account: String) -> KeychainError? {
        _ = deleteFromKeychain(account: account)
        var query = keychainQuery(account: account)
        query[kSecValueData as String] = data
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            if status == -34018 /* errSecMissingEntitlement */ {
                // Missing entitlements in test environment - log as debug, not error
                _logger.debug("Keychain save failed (missing entitlements): \(status)")
            } else {
                _logger.error("Keychain save failed: \(status)")
            }
            return .saveFailed(status)
        }
        return nil
    }

    private func readFromKeychain(account: String) -> Data? {
        var query = keychainQuery(account: account)
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess, let data = item as? Data {
            return data
        }
        if status == errSecItemNotFound || status == -34018 /* errSecMissingEntitlement */ {
            // Item not found or missing entitlements (test environment) - expected, not an error
            return nil
        }
        // Other errors should be logged
        _logger.error("Keychain read failed: \(status)")
        return nil
    }

    private func deleteFromKeychain(account: String) -> Bool {
        let status = SecItemDelete(keychainQuery(account: account) as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound && status != -34018 /* errSecMissingEntitlement */ {
            _logger.error("Keychain delete failed: \(status)")
            return false
        }
        return true
    }
}


