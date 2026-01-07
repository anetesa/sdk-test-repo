import Foundation

/// Protocol for TokenService to enable dependency injection and testing
internal protocol TokenServiceProtocol: Sendable {
    /// Get current access token synchronously from session
    var currentAccessToken: String? { get }
    
    /// Perform token refresh and save to storage/session
    func refreshToken() async throws -> AuthenticationResult
    
    /// Get current access token, refreshing if needed
    func getAccessToken() async -> String?
    
    /// Authenticate with client credentials
    func authenticate(clientId: String, clientSecret: String) async throws -> AuthenticationResult
    
    /// Clear stored tokens
    func clearStoredToken()
}

