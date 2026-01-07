import Foundation

/// Protocol for ARISE token storage
/// Allows dependency injection for testing
internal protocol AriseTokenStorageProtocol: Sendable {
    /// Save authentication result securely
    /// - Parameter result: Authentication result containing tokens
    /// - Throws: KeychainError if save operation fails
    func save(_ result: AuthenticationResult) throws
    
    /// Retrieve stored token if available
    /// - Returns: StoredToken if found and valid, nil otherwise
    func load() -> AriseTokenStorage.StoredToken?
    
    /// Remove stored token
    func clear()
    
    /// Load stored credentials
    /// - Returns: StoredCredentials if found, nil otherwise
    func loadCredentials() -> AriseTokenStorage.StoredCredentials?
    
    /// Save credentials securely
    /// - Parameters:
    ///   - clientId: Client ID
    ///   - clientSecret: Client Secret
    /// - Throws: KeychainError if save operation fails
    func saveCredentials(clientId: String, clientSecret: String) throws
    
    /// Save TTP JWT token securely
    /// - Parameters:
    ///   - token: JWT token string
    ///   - expiresAt: Token expiration date
    /// - Throws: KeychainError if save operation fails
    func saveTTPJwtToken(token: String, expiresAt: Date) throws
    
    /// Retrieve stored TTP JWT token if available and valid
    /// - Returns: StoredTTPJwtToken if found and valid, nil otherwise
    func loadTTPJwtToken() -> AriseTokenStorage.StoredTTPJwtToken?
    
    /// Remove stored TTP JWT token
    func clearTTPJwtToken()
}

