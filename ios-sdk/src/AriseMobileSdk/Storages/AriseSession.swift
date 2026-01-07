import Foundation

/// In-memory session for holding credentials and current token
/// Automatically restores token from persistent storage when accessed
final class AriseSession: AriseSessionProtocol, @unchecked Sendable {
    public static let shared: AriseSession = {
        let tokenStorage = AriseTokenStorage()
        return AriseSession(tokenStorage: tokenStorage)
    }()

    private let _tokenStorage: AriseTokenStorageProtocol
    private let _queue = DispatchQueue(label: "com.arise.mobile.sdk.session", attributes: .concurrent)
    private let _logger = AriseLogger.shared

    private var _clientId: String?
    private var _clientSecret: String?
    private var _token: AriseTokenStorage.StoredToken?
    private var _tokenRestored = false // Flag to prevent multiple restorations
    private var _tokenExplicitlyCleared = false // Flag to track if token was explicitly cleared (don't restore)

    init(tokenStorage: AriseTokenStorageProtocol) {
        self._tokenStorage = tokenStorage
        // Restore credentials from persistent storage on initialization
        if let credentials = tokenStorage.loadCredentials() {
            _clientId = credentials.clientId
            _clientSecret = credentials.clientSecret
            _logger.debug("Restored credentials from secure storage to session")
        }
    }

    var clientId: String? {
        get { _queue.sync { _clientId } }
        set {
            _queue.sync(flags: .barrier) { self._clientId = newValue } 
        }
    }

    var clientSecret: String? {
        get { _queue.sync { _clientSecret } }
        set {
            _queue.sync(flags: .barrier) { self._clientSecret = newValue } 
        }
    }

    /// Get token from memory or restore from persistent storage
    /// Automatically restores token from Keychain on first access if not in memory
    /// Restores expired tokens to allow refresh attempts
    /// Thread-safe: uses a single sync operation to avoid race conditions
    var token: AriseTokenStorage.StoredToken? {
        get {
            // Single sync operation to check token and restoration flag atomically
            let (existingToken, shouldRestore): (AriseTokenStorage.StoredToken?, Bool) = _queue.sync {
                // Fast path: token already in memory
                if let token = _token {
                    return (token, false)
                }
                
                // If token was explicitly cleared (after failed refresh), don't restore
                if _tokenExplicitlyCleared {
                    return (nil, false)
                }
                
                // Check if we've already tried to restore
                if _tokenRestored {
                    // Token was restored before, but might have been cleared from storage
                    // Try to restore again (allows recovery if token was cleared after failed refresh)
                    // But only if it wasn't explicitly cleared
                    return (nil, true)
                }
                
                // First access - mark as restored to prevent concurrent restoration attempts
                _tokenRestored = true
                return (nil, true)
            }
            
            // Return existing token if found
            if let token = existingToken {
                return token
            }
            
            // No token in memory - try to restore from storage
            guard shouldRestore else {
                return nil
            }
            
            // Restore from persistent storage (outside of queue to avoid deadlock)
            // AriseTokenStorage uses its own queue, so this is safe
            guard let storedToken = _tokenStorage.load() else {
                // Token not in storage - mark as explicitly cleared to avoid future checks
                _queue.async(flags: .barrier) {
                    self._tokenExplicitlyCleared = true
                    self._tokenRestored = false
                }
                return nil
            }
            
            // Token found in storage - clear the "explicitly cleared" flag
            _queue.async(flags: .barrier) {
                self._tokenExplicitlyCleared = false
            }
            
            let isValid = storedToken.expiresAt > Date()
            
            // Update in-memory token atomically using sync to ensure immediate availability
            _queue.sync(flags: .barrier) {
                self._token = storedToken
            }
            
            if isValid {
                _logger.info("✅ Restored valid token from secure storage to session (expires: \(storedToken.expiresAt))")
            } else {
                _logger.warning("⚠️ Restored expired token from secure storage (expired: \(storedToken.expiresAt)). Will attempt refresh on next API call.")
            }
            
            return storedToken
        }
        set {
            _queue.sync(flags: .barrier) {
                self._token = newValue
                // Reset flags when token is explicitly set
                if newValue == nil {
                    // Token cleared - mark as explicitly cleared and reset restoration flag
                    self._tokenExplicitlyCleared = true
                    self._tokenRestored = false
                } else {
                    // Token set - clear "explicitly cleared" flag and mark as restored
                    self._tokenExplicitlyCleared = false
                    self._tokenRestored = true
                }
            }
        }
    }

    func setCredentials(clientId: String, clientSecret: String) {
        _queue.sync(flags: .barrier) {
            self._clientId = clientId
            self._clientSecret = clientSecret
        }
    }
    
    func setToken(_ token: AriseTokenStorage.StoredToken?) {
        // Use synchronous write to ensure token is set immediately
        // This is important for tests and for immediate use after setting
        _queue.sync(flags: .barrier) {
            self._token = token
            // Reset flags when token is explicitly set
            if token == nil {
                // Token cleared - mark as explicitly cleared and reset restoration flag
                self._tokenExplicitlyCleared = true
                self._tokenRestored = false
            } else {
                // Token set - clear "explicitly cleared" flag and mark as restored
                // This prevents automatic restoration from Keychain on next access
                self._tokenExplicitlyCleared = false
                self._tokenRestored = true
            }
        }
    }

    func clear() {
        _queue.sync(flags: .barrier) {
            self._clientId = nil
            self._clientSecret = nil
            self._token = nil
            // Reset flags when clearing
            self._tokenExplicitlyCleared = true
            self._tokenRestored = false
        }
    }
    
    /// Get valid access token if available and not expired
    /// Returns access token string if token exists and is still valid
    func getValidAccessToken() -> String? {
        guard let token = token, token.expiresAt > Date() else {
            return nil
        }
        return token.accessToken
    }
}


