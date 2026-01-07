import Foundation

/// Service for handling token refresh operations
/// Centralizes all token refresh logic
/// Thread-safe: protects against concurrent refresh attempts
internal final class TokenService: TokenServiceProtocol, @unchecked Sendable {
    private let _authApi: AriseAuthApiProtocol
    private let _session: AriseSessionProtocol
    private let _tokenStorage: AriseTokenStorageProtocol
    private let _environmentSettings: EnvironmentSettings
    private let _logger = AriseLogger.shared
    
    // Lock to prevent concurrent token refresh attempts
    // Multiple requests getting 401 should share the same refresh operation
    private let _refreshLock = NSLock()
    private var _refreshTask: Task<AuthenticationResult, Error>?
    private var _isRefreshing = false
    
    /// Initialize TokenService with injected dependencies
    /// - Parameters:
    ///   - authApi: Authentication API client (can be real or mock for testing)
    ///   - session: Session manager (can be real or mock for testing)
    ///   - tokenStorage: Token storage (can be real or mock for testing)
    ///   - environmentSettings: Environment configuration
    init(authApi: AriseAuthApiProtocol, session: AriseSessionProtocol, tokenStorage: AriseTokenStorageProtocol, environmentSettings: EnvironmentSettings) {
        self._environmentSettings = environmentSettings
        self._authApi = authApi
        self._session = session
        self._tokenStorage = tokenStorage
    }
    
    /// Get current access token synchronously from session
    /// Used by BaseApiClient to configure client
    var currentAccessToken: String? {
        return _session.token?.accessToken
    }
    
    /// Perform token refresh and save to storage/session
    /// Thread-safe: multiple concurrent calls will share the same refresh operation
    /// - Returns: AuthenticationResult with new tokens
    /// - Throws: Error if refresh fails
    func refreshToken() async throws -> AuthenticationResult {
        // Check if refresh is already in progress
        _refreshLock.lock()
        let existingTask = _refreshTask
        let alreadyRefreshing = _isRefreshing
        _refreshLock.unlock()
        
        // If there's an ongoing refresh task, wait for it
        if let existingTask = existingTask, alreadyRefreshing {
            _logger.verbose("🔄 Token refresh already in progress, waiting for completion...")
            do {
                return try await existingTask.value
            } catch {
                // If existing task failed, clear it and allow new refresh
                _refreshLock.lock()
                if _isRefreshing {
                    _refreshTask = nil
                    _isRefreshing = false
                }
                _refreshLock.unlock()
                throw error
            }
        }
        
        // Create new refresh task
        let task: Task<AuthenticationResult, Error>
        _refreshLock.lock()
        // Double-check after acquiring lock
        if let existingTask = _refreshTask, _isRefreshing {
            _refreshLock.unlock()
            _logger.verbose("🔄 Token refresh already in progress (double-check), waiting for completion...")
            return try await existingTask.value
        }
        
        _isRefreshing = true
        task = Task<AuthenticationResult, Error> {
            defer {
                // Clear task reference and flag after completion (success or failure)
                _refreshLock.lock()
                _refreshTask = nil
                _isRefreshing = false
                _refreshLock.unlock()
            }
            
            // Note: refreshToken() in AriseAuthApi already checks for token and credentials
            // No need to duplicate the check here
            let refreshResult = try await _authApi.refreshToken()
            
            // Validate expiresIn before saving
            let expiresIn = max(0, refreshResult.expiresIn)
            let expiresAt = Date().addingTimeInterval(TimeInterval(expiresIn))
            
            // Create stored token model
            let storedToken = AriseTokenStorage.StoredToken(
                accessToken: refreshResult.accessToken,
                refreshToken: refreshResult.refreshToken,
                tokenType: refreshResult.tokenType,
                expiresAt: expiresAt
            )
            
            // Set token in session immediately (even if Keychain save fails)
            _session.setToken(storedToken)
            
            // Save new token to storage
            do {
                try _tokenStorage.save(refreshResult)
            } catch let error as AriseTokenStorage.KeychainError {
                // -34018 (errSecMissingEntitlement) is expected in test environment
                if case .saveFailed(let status) = error, status == -34018 {
                    _logger.debug("  ⚠️ Failed to save refreshed token to storage (expected in test environment): \(error.localizedDescription)")
                } else {
                    _logger.error("  ⚠️ Failed to save refreshed token to storage: \(error.localizedDescription)")
                }
                // Continue anyway - token is in session
            } catch {
                _logger.error("  ⚠️ Failed to save refreshed token to storage: \(error.localizedDescription)")
                // Continue anyway - token is in session
            }
            
            _logger.info("✅ Token refreshed successfully")
            _logger.verbose("  ✓ Token prefix: \(String(refreshResult.accessToken.prefix(10)))...")
            
            return refreshResult
        }
        
        _refreshTask = task
        _refreshLock.unlock()
        
        // Wait for refresh to complete
        return try await task.value
    }
    
    /// Get current access token, refreshing if needed
    /// - Returns: Current access token string, or nil if unavailable
    func getAccessToken() async -> String? {
        _logger.verbose("🔑 Getting access token...")
        
        // Access token property will automatically restore from storage if not in memory
        guard let token = _session.token else {
            _logger.verbose("  ✗ No token available in session or storage")
            return nil
        }
        
        // Check if token is still valid
        if token.expiresAt > Date() {
            let prefix = String(token.accessToken.prefix(10))
            _logger.verbose("  ✓ Token found in session (expires: \(token.expiresAt))")
            _logger.verbose("  ✓ Token prefix: \(prefix)...")
            return token.accessToken
        }
        
        // Token expired, try to refresh if refresh token is available
        _logger.verbose("  ⚠️ Token expired, attempting refresh...")
        guard token.refreshToken != nil else {
            _logger.verbose("  ✗ No refresh token available")
            // Clear expired token and reset restoration flag to allow re-authentication
            _tokenStorage.clear()
            _session.setToken(nil)
            return nil
        }
        
        // Ensure credentials are available for refresh
        if _session.clientId == nil || _session.clientSecret == nil {
            // Try to restore credentials from storage
            if let credentials = _tokenStorage.loadCredentials() {
                _session.setCredentials(clientId: credentials.clientId, clientSecret: credentials.clientSecret)
                _logger.verbose("  ✓ Restored credentials for token refresh")
            } else {
                _logger.error("  ✗ No credentials available for token refresh")
                // Clear expired token
                _tokenStorage.clear()
                _session.setToken(nil)
                return nil
            }
        }
        
        // Refresh token
        do {
            let refreshResult = try await refreshToken()
            return refreshResult.accessToken
        } catch {
            _logger.error("  ✗ Failed to refresh token: \(error.localizedDescription)")
            // Clear invalid token
            _tokenStorage.clear()
            _session.setToken(nil)
            return nil
        }
    }
    
    public func authenticate(clientId: String, clientSecret: String) async throws -> AuthenticationResult {
        
        _session.setCredentials(clientId: clientId, clientSecret: clientSecret)
        let result = try await _authApi.authenticate(
            clientId: clientId,
            clientSecret: clientSecret
        )
        
        // Calculate expiration and create stored token model
        let expiresIn = max(0, result.expiresIn)
        let expiresAt = Date().addingTimeInterval(TimeInterval(expiresIn))
        let storedToken = AriseTokenStorage.StoredToken(
            accessToken: result.accessToken,
            refreshToken: result.refreshToken,
            tokenType: result.tokenType,
            expiresAt: expiresAt
        )
        
        // Set token in session immediately (even if Keychain save fails)
        // This must be done before attempting Keychain save to ensure token is available
        _session.setToken(storedToken)
        
        // Save token and credentials to persistent storage
        // Storage failures are logged but don't fail authentication since token is in memory
        // Note: _tokenStorage.save() also sets token in session, but we've already set it above
        // In test environment, Keychain operations may fail, but token remains in session
        do {
            try _tokenStorage.save(result)
        } catch let error as AriseTokenStorage.KeychainError {
            // -34018 (errSecMissingEntitlement) is expected in test environment
            if case .saveFailed(let status) = error, status == -34018 {
                _logger.debug("Failed to save authentication result to storage (expected in test environment): \(error.localizedDescription)")
            } else {
                _logger.error("Failed to save authentication result to storage: \(error.localizedDescription)")
            }
            // Continue - token is already in session memory, authentication succeeded
        } catch {
            _logger.error("Failed to save authentication result to storage: \(error.localizedDescription)")
            // Continue - token is already in session memory, authentication succeeded
        }
        
        do {
            try _tokenStorage.saveCredentials(clientId: clientId, clientSecret: clientSecret)
        } catch let error as AriseTokenStorage.KeychainError {
            // -34018 (errSecMissingEntitlement) is expected in test environment
            if case .saveFailed(let status) = error, status == -34018 {
                _logger.debug("Failed to save credentials to storage (expected in test environment): \(error.localizedDescription)")
            } else {
                _logger.error("Failed to save credentials to storage: \(error.localizedDescription)")
            }
            // Continue - credentials are in session memory, authentication succeeded
        } catch {
            _logger.error("Failed to save credentials to storage: \(error.localizedDescription)")
            // Continue - credentials are in session memory, authentication succeeded
        }
        
        // Register device after successful authentication
        // Create DevicesService with the same TokenService instance to avoid duplicates
        Task {
            do {
                let devicesService = DevicesService(tokenService: self, environmentSettings: _environmentSettings)
                try await devicesService.registerDevice()
            } catch {
                _logger.warning("Device registration failed (non-critical): \(error.localizedDescription)")
                // Don't throw - device registration is non-critical
            }
        }
        
        return result
    }
    
    public func clearStoredToken() {
        _tokenStorage.clear()
        _session.setToken(nil)
        // Optionally clear stored credentials as well (kept for future decision)
        // Note: clearCredentials() is not in protocol, would need to be added if needed
    }
}

