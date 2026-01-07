import Foundation

/// Protocol for ARISE authentication API client
/// Allows dependency injection for testing
internal protocol AriseAuthApiProtocol: Sendable {
    /// Perform OAuth 2.0 Client Credentials authentication.
    /// - Parameters:
    ///   - clientId: Client ID from ARISE merchant portal
    ///   - clientSecret: Client Secret from ARISE merchant portal
    /// - Returns: AuthenticationResult containing access token and metadata
    /// - Throws: AuthenticationError if authentication fails
    func authenticate(
        clientId: String,
        clientSecret: String
    ) async throws -> AuthenticationResult
    
    /// Refresh access token using stored client credentials and refresh token.
    /// - Returns: AuthenticationResult containing access token and metadata
    /// - Throws: AuthenticationError if required data is missing or refresh fails
    func refreshToken() async throws -> AuthenticationResult
}

