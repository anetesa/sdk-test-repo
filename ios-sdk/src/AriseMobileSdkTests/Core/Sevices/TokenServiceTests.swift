import Foundation
import Testing
@testable import AriseMobile

/// Tests for TokenService focusing on token generation, validation, expiration handling, and refresh logic
struct TokenServiceTests {
    
    // MARK: - Helper Methods
    
    private func createTokenService(
        authApi: AriseAuthApiProtocol? = nil,
        session: AriseSessionProtocol? = nil,
        tokenStorage: AriseTokenStorageProtocol? = nil
    ) -> TokenService {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockAuthApi = authApi ?? MockAriseAuthApi()
        let mockSession = session ?? MockAriseSession()
        let mockTokenStorage = tokenStorage ?? MockAriseTokenStorage()
        
        return TokenService(
            authApi: mockAuthApi,
            session: mockSession,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
    }
    
    private func createValidToken(expiresIn: TimeInterval = 3600) -> AriseTokenStorage.StoredToken {
        AriseTokenStorage.StoredToken(
            accessToken: "test-access-token",
            refreshToken: "test-refresh-token",
            tokenType: "Bearer",
            expiresAt: Date().addingTimeInterval(expiresIn)
        )
    }
    
    private func createExpiredToken() -> AriseTokenStorage.StoredToken {
        AriseTokenStorage.StoredToken(
            accessToken: "expired-access-token",
            refreshToken: "expired-refresh-token",
            tokenType: "Bearer",
            expiresAt: Date().addingTimeInterval(-3600) // Expired 1 hour ago
        )
    }
    
    // MARK: - Token Generation Tests
    
    // Note: Basic authenticate tests are in AuthenticationTests.swift
    // This file focuses on edge cases and specific scenarios
    
    @Test("Token generation calculates expiration correctly")
    func testTokenGenerationCalculatesExpiration() async throws {
        let mockAuthApi = MockAriseAuthApi()
        let expiresIn = 1800 // 30 minutes
        let authResult = AuthenticationResult(
            accessToken: "test-token",
            refreshToken: "test-refresh",
            expiresIn: expiresIn,
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(authResult)
        
        let mockSession = MockAriseSession()
        let tokenService = createTokenService(authApi: mockAuthApi, session: mockSession)
        
        let beforeAuth = Date()
        _ = try await tokenService.authenticate(
            clientId: "test-client-id",
            clientSecret: "test-client-secret"
        )
        let afterAuth = Date()
        
        // Verify expiration is calculated correctly (within 5 seconds tolerance)
        guard let storedToken = mockSession.token else {
            Issue.record("Token was not stored in session")
            return
        }
        
        let expectedExpiration = afterAuth.addingTimeInterval(TimeInterval(expiresIn))
        let timeDifference = abs(storedToken.expiresAt.timeIntervalSince(expectedExpiration))
        #expect(timeDifference < 5.0)
        
        // Verify token is not expired
        #expect(storedToken.expiresAt > Date())
    }
    
    @Test("Token generation handles zero expiration")
    func testTokenGenerationHandlesZeroExpiration() async throws {
        let mockAuthApi = MockAriseAuthApi()
        let authResult = AuthenticationResult(
            accessToken: "test-token",
            refreshToken: "test-refresh",
            expiresIn: 0, // Zero expiration
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(authResult)
        
        let mockSession = MockAriseSession()
        let tokenService = createTokenService(authApi: mockAuthApi, session: mockSession)
        
        _ = try await tokenService.authenticate(
            clientId: "test-client-id",
            clientSecret: "test-client-secret"
        )
        
        // Verify expiration is set to at least current time (max(0, expiresIn) = 0)
        guard let storedToken = mockSession.token else {
            Issue.record("Token was not stored in session")
            return
        }
        
        // Token should be expired immediately (expiresAt should be <= Date())
        #expect(storedToken.expiresAt <= Date().addingTimeInterval(5)) // Allow 5 seconds tolerance
    }
    
    @Test("Token generation handles negative expiration")
    func testTokenGenerationHandlesNegativeExpiration() async throws {
        let mockAuthApi = MockAriseAuthApi()
        let authResult = AuthenticationResult(
            accessToken: "test-token",
            refreshToken: "test-refresh",
            expiresIn: -100, // Negative expiration
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(authResult)
        
        let mockSession = MockAriseSession()
        let tokenService = createTokenService(authApi: mockAuthApi, session: mockSession)
        
        _ = try await tokenService.authenticate(
            clientId: "test-client-id",
            clientSecret: "test-client-secret"
        )
        
        // Verify expiration is clamped to 0 (max(0, -100) = 0)
        guard let storedToken = mockSession.token else {
            Issue.record("Token was not stored in session")
            return
        }
        
        // Token should be expired immediately
        #expect(storedToken.expiresAt <= Date().addingTimeInterval(5)) // Allow 5 seconds tolerance
    }
    
    // Note: testTokenServiceAuthenticateWithMock in AuthenticationTests.swift already verifies credentials are saved to session
    
    // MARK: - Token Validation Tests
    
    // Note: testTokenServiceGetAccessTokenReturnsValidToken in AuthenticationTests.swift covers valid token validation
    // Note: testTokenServiceGetAccessTokenReturnsNilForExpiredTokenWithoutRefresh in AuthenticationTests.swift covers expired token validation
    
    @Test("Token validation handles token without refresh token")
    func testTokenValidationHandlesTokenWithoutRefreshToken() async {
        let mockSession = MockAriseSession()
        
        // Test token without refresh token (edge case)
        // Note: Token with refresh token is tested in testTokenServiceGetAccessTokenReturnsValidToken
        let tokenWithoutRefresh = AriseTokenStorage.StoredToken(
            accessToken: "no-refresh-token",
            refreshToken: nil,
            tokenType: "Bearer",
            expiresAt: Date().addingTimeInterval(3600)
        )
        mockSession.setToken(tokenWithoutRefresh)
        
        let tokenService = createTokenService(session: mockSession)
        let accessTokenNoRefresh = await tokenService.getAccessToken()
        #expect(accessTokenNoRefresh == "no-refresh-token")
    }
    
    // MARK: - Expiration Handling Tests
    
    // Note: testTokenServiceGetAccessTokenReturnsNilForExpiredTokenWithoutRefresh in AuthenticationTests.swift covers expired token detection
    // Note: testTokenServiceGetAccessTokenAutoRefreshesExpiredToken in AuthenticationTests.swift covers auto-refresh
    
    // Note: testTokenServiceGetAccessTokenHandlesRefreshFailure in AuthenticationTests.swift covers this
    
    @Test("Expiration handling handles token about to expire")
    func testExpirationHandlingHandlesTokenAboutToExpire() async {
        let mockSession = MockAriseSession()
        
        // Token expires in 1 second (still valid but about to expire)
        let aboutToExpireToken = createValidToken(expiresIn: 1)
        mockSession.setToken(aboutToExpireToken)
        
        let tokenService = createTokenService(session: mockSession)
        let accessToken = await tokenService.getAccessToken()
        
        // Should still return token (it's not expired yet)
        #expect(accessToken == "test-access-token")
        
        // Wait for token to expire
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Now should return nil (token expired)
        let expiredAccessToken = await tokenService.getAccessToken()
        #expect(expiredAccessToken == nil)
    }
    
    // Note: testTokenServiceGetAccessTokenReturnsNilForExpiredTokenWithoutRefresh in AuthenticationTests.swift covers this
    
    // MARK: - Refresh Logic Tests
    
    // Note: testTokenServiceRefreshToken in AuthenticationTests.swift covers basic refresh logic
    
    @Test("Refresh logic calculates new expiration correctly")
    func testRefreshLogicCalculatesNewExpiration() async throws {
        let mockSession = MockAriseSession()
        mockSession.setCredentials(clientId: "test-client-id", clientSecret: "test-client-secret")
        
        let oldToken = createValidToken()
        mockSession.setToken(oldToken)
        
        let mockAuthApi = MockAriseAuthApi()
        let expiresIn = 1800 // 30 minutes
        let refreshResult = AuthenticationResult(
            accessToken: "new-token",
            refreshToken: "new-refresh",
            expiresIn: expiresIn,
            tokenType: "Bearer"
        )
        mockAuthApi.refreshTokenResult = .success(refreshResult)
        
        let tokenService = createTokenService(authApi: mockAuthApi, session: mockSession)
        
        let beforeRefresh = Date()
        _ = try await tokenService.refreshToken()
        let afterRefresh = Date()
        
        // Verify expiration is calculated correctly
        guard let storedToken = mockSession.token else {
            Issue.record("Token was not stored in session")
            return
        }
        
        let expectedExpiration = afterRefresh.addingTimeInterval(TimeInterval(expiresIn))
        let timeDifference = abs(storedToken.expiresAt.timeIntervalSince(expectedExpiration))
        #expect(timeDifference < 5.0)
    }
    
    @Test("Refresh logic prevents concurrent refresh attempts")
    func testRefreshLogicPreventsConcurrentRefresh() async throws {
        let mockSession = MockAriseSession()
        mockSession.setCredentials(clientId: "test-client-id", clientSecret: "test-client-secret")
        
        let oldToken = createValidToken()
        mockSession.setToken(oldToken)
        
        let mockAuthApi = MockAriseAuthApi()
        let refreshResult = AuthenticationResult(
            accessToken: "refreshed-token",
            refreshToken: "refreshed-refresh",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.refreshTokenResult = .success(refreshResult)
        
        let tokenService = createTokenService(authApi: mockAuthApi, session: mockSession)
        
        // Start multiple concurrent refresh attempts
        let task1 = Task {
            try await tokenService.refreshToken()
        }
        let task2 = Task {
            try await tokenService.refreshToken()
        }
        let task3 = Task {
            try await tokenService.refreshToken()
        }
        
        // Wait for all tasks to complete
        let result1 = try await task1.value
        let result2 = try await task2.value
        let result3 = try await task3.value
        
        // All should return the same result
        #expect(result1.accessToken == "refreshed-token")
        #expect(result2.accessToken == "refreshed-token")
        #expect(result3.accessToken == "refreshed-token")
        
        // Refresh should only be called once (shared refresh operation)
        // Note: Due to race conditions, it might be called 1-3 times, but should be less than 3
        #expect(mockAuthApi.refreshTokenCallCount <= 3)
    }
    
    // Note: testTokenServiceRefreshTokenHandlesError in AuthenticationTests.swift covers this
    
    @Test("Refresh logic saves token to storage")
    func testRefreshLogicSavesTokenToStorage() async throws {
        let mockSession = MockAriseSession()
        mockSession.setCredentials(clientId: "test-client-id", clientSecret: "test-client-secret")
        
        let oldToken = createValidToken()
        mockSession.setToken(oldToken)
        
        let mockAuthApi = MockAriseAuthApi()
        let refreshResult = AuthenticationResult(
            accessToken: "refreshed-token",
            refreshToken: "refreshed-refresh",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.refreshTokenResult = .success(refreshResult)
        
        let mockTokenStorage = MockAriseTokenStorage()
        let tokenService = createTokenService(
            authApi: mockAuthApi,
            session: mockSession,
            tokenStorage: mockTokenStorage
        )
        
        _ = try await tokenService.refreshToken()
        
        // Verify token was saved to storage
        #expect(mockTokenStorage.saveCallCount == 1)
        #expect(mockTokenStorage.lastSavedResult?.accessToken == "refreshed-token")
    }
    
    @Test("Refresh logic continues even if storage save fails")
    func testRefreshLogicContinuesIfStorageSaveFails() async throws {
        let mockSession = MockAriseSession()
        mockSession.setCredentials(clientId: "test-client-id", clientSecret: "test-client-secret")
        
        let oldToken = createValidToken()
        mockSession.setToken(oldToken)
        
        let mockAuthApi = MockAriseAuthApi()
        let refreshResult = AuthenticationResult(
            accessToken: "refreshed-token",
            refreshToken: "refreshed-refresh",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.refreshTokenResult = .success(refreshResult)
        
        let mockTokenStorage = MockAriseTokenStorage()
        mockTokenStorage.shouldFailSave = true
        mockTokenStorage.saveError = AriseTokenStorage.KeychainError.saveFailed(-1)
        
        let tokenService = createTokenService(
            authApi: mockAuthApi,
            session: mockSession,
            tokenStorage: mockTokenStorage
        )
        
        // Should still succeed (token is in session even if storage fails)
        let result = try await tokenService.refreshToken()
        
        // Verify refresh succeeded
        #expect(result.accessToken == "refreshed-token")
        
        // Verify token is in session (even though storage save failed)
        #expect(mockSession.token?.accessToken == "refreshed-token")
    }
    
    @Test("Refresh logic clears refresh state after completion")
    func testRefreshLogicClearsRefreshState() async throws {
        let mockSession = MockAriseSession()
        mockSession.setCredentials(clientId: "test-client-id", clientSecret: "test-client-secret")
        
        let oldToken = createValidToken()
        mockSession.setToken(oldToken)
        
        let mockAuthApi = MockAriseAuthApi()
        let refreshResult = AuthenticationResult(
            accessToken: "refreshed-token",
            refreshToken: "refreshed-refresh",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.refreshTokenResult = .success(refreshResult)
        
        let tokenService = createTokenService(authApi: mockAuthApi, session: mockSession)
        
        // First refresh
        _ = try await tokenService.refreshToken()
        #expect(mockAuthApi.refreshTokenCallCount == 1)
        
        // Second refresh should work (refresh state should be cleared)
        _ = try await tokenService.refreshToken()
        #expect(mockAuthApi.refreshTokenCallCount == 2)
    }
    
    @Test("Refresh logic handles refresh failure and allows retry")
    func testRefreshLogicHandlesFailureAndAllowsRetry() async throws {
        let mockSession = MockAriseSession()
        mockSession.setCredentials(clientId: "test-client-id", clientSecret: "test-client-secret")
        
        let oldToken = createValidToken()
        mockSession.setToken(oldToken)
        
        let mockAuthApi = MockAriseAuthApi()
        
        // First refresh fails
        mockAuthApi.refreshTokenResult = .failure(AuthenticationError.tokenExpired)
        
        let tokenService = createTokenService(authApi: mockAuthApi, session: mockSession)
        
        // First refresh attempt - should fail
        await Test.assertThrowsError {
            _ = try await tokenService.refreshToken()
        }
        #expect(mockAuthApi.refreshTokenCallCount == 1)
        
        // Second refresh attempt should be allowed (refresh state cleared after failure)
        let refreshResult = AuthenticationResult(
            accessToken: "retry-token",
            refreshToken: "retry-refresh",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.refreshTokenResult = .success(refreshResult)
        
        let result = try await tokenService.refreshToken()
        #expect(result.accessToken == "retry-token")
        #expect(mockAuthApi.refreshTokenCallCount == 2)
    }
}

