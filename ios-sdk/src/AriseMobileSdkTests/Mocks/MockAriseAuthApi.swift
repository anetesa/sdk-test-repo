import Foundation
@testable import AriseMobile

/// Mock implementation of AriseAuthApi for testing authentication flows
final class MockAriseAuthApi: @unchecked Sendable, AriseAuthApiProtocol {
    
    // MARK: - Configuration
    var authenticateResult: Result<AuthenticationResult, Error> = .success(
        AuthenticationResult(
            accessToken: "mock-access-token",
            refreshToken: "mock-refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
    )
    var refreshTokenResult: Result<AuthenticationResult, Error> = .success(
        AuthenticationResult(
            accessToken: "mock-refreshed-token",
            refreshToken: "mock-refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
    )
    
    // MARK: - Call Tracking
    private(set) var authenticateCallCount = 0
    private(set) var refreshTokenCallCount = 0
    
    private(set) var lastAuthenticateClientId: String?
    private(set) var lastAuthenticateClientSecret: String?
    
    // MARK: - Reset
    func reset() {
        authenticateCallCount = 0
        refreshTokenCallCount = 0
        lastAuthenticateClientId = nil
        lastAuthenticateClientSecret = nil
        authenticateResult = .success(
            AuthenticationResult(
                accessToken: "mock-access-token",
                refreshToken: "mock-refresh-token",
                expiresIn: 3600,
                tokenType: "Bearer"
            )
        )
        refreshTokenResult = .success(
            AuthenticationResult(
                accessToken: "mock-refreshed-token",
                refreshToken: "mock-refresh-token",
                expiresIn: 3600,
                tokenType: "Bearer"
            )
        )
    }
    
    // MARK: - AriseAuthApiProtocol Implementation
    
    /// Mock authenticate method
    func authenticate(
        clientId: String,
        clientSecret: String
    ) async throws -> AuthenticationResult {
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
    
    /// Mock refreshToken method
    func refreshToken() async throws -> AuthenticationResult {
        refreshTokenCallCount += 1
        
        switch refreshTokenResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
}

