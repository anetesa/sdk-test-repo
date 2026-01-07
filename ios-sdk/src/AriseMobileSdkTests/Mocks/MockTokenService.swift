import Foundation
@testable import AriseMobile

/// Mock implementation of TokenServiceProtocol for testing
final class MockTokenService: TokenServiceProtocol, @unchecked Sendable {
    // MARK: - Configuration
    
    var currentAccessTokenValue: String? = "mock-access-token"
    var refreshTokenResult: Result<AuthenticationResult, Error> = .success(
        AuthenticationResult(
            accessToken: "refreshed-access-token",
            refreshToken: "refreshed-refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
    )
    var getAccessTokenResult: String? = "mock-access-token"
    var authenticateResult: Result<AuthenticationResult, Error> = .success(
        AuthenticationResult(
            accessToken: "new-access-token",
            refreshToken: "new-refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
    )
    
    // MARK: - Call Tracking
    
    private(set) var refreshTokenCallCount = 0
    private(set) var getAccessTokenCallCount = 0
    private(set) var authenticateCallCount = 0
    private(set) var clearStoredTokenCallCount = 0
    
    private(set) var lastAuthenticateClientId: String?
    private(set) var lastAuthenticateClientSecret: String?
    
    // MARK: - TokenServiceProtocol Implementation
    
    var currentAccessToken: String? {
        return currentAccessTokenValue
    }
    
    func refreshToken() async throws -> AuthenticationResult {
        refreshTokenCallCount += 1
        
        switch refreshTokenResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
    
    func getAccessToken() async -> String? {
        getAccessTokenCallCount += 1
        return getAccessTokenResult
    }
    
    func authenticate(clientId: String, clientSecret: String) async throws -> AuthenticationResult {
        authenticateCallCount += 1
        lastAuthenticateClientId = clientId
        lastAuthenticateClientSecret = clientSecret
        
        switch authenticateResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
    
    func clearStoredToken() {
        clearStoredTokenCallCount += 1
        currentAccessTokenValue = nil
        getAccessTokenResult = nil
    }
    
    // MARK: - Reset
    
    func reset() {
        refreshTokenCallCount = 0
        getAccessTokenCallCount = 0
        authenticateCallCount = 0
        clearStoredTokenCallCount = 0
        lastAuthenticateClientId = nil
        lastAuthenticateClientSecret = nil
        currentAccessTokenValue = "mock-access-token"
        getAccessTokenResult = "mock-access-token"
    }
}

