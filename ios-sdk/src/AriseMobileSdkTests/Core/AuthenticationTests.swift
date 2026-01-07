import Foundation
import Testing
@testable import AriseMobile

/// Tests for AriseMobileSdk authentication functionality
struct AuthenticationTests {
    
    @Test("Session stores and clears credentials")
    func testSessionStoresAndClearsCredentials() {
        // Use isolated session instance with mock storage for test isolation
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        
        // Set credentials
        let clientId = "test-client-id"
        let clientSecret = "test-client-secret"
        session.setCredentials(clientId: clientId, clientSecret: clientSecret)
        
        // Verify credentials are stored
        #expect(session.clientId == clientId)
        #expect(session.clientSecret == clientSecret)
        
        // Cleanup
        session.clear()
        
        // Verify credentials are cleared
        #expect(session.clientId == nil)
        #expect(session.clientSecret == nil)
    }
    
    
    @Test("Authentication result structure")
    func testAuthenticationResultStructure() {
        let result = AuthenticationResult(
            accessToken: "access-123",
            refreshToken: "refresh-456",
            expiresIn: 7200,
            tokenType: "Bearer"
        )
        
        #expect(result.accessToken == "access-123")
        #expect(result.refreshToken == "refresh-456")
        #expect(result.expiresIn == 7200)
        #expect(result.tokenType == "Bearer")
    }
    
    @Test("Token expiration calculation")
    func testTokenExpirationCalculation() {
        // Test token expiration calculation logic without Keychain
        let expiresIn = 3600 // 1 hour
        let authResult = AuthenticationResult(
            accessToken: "test-token",
            refreshToken: nil,
            expiresIn: expiresIn,
            tokenType: "Bearer"
        )
        
        // Calculate expiration manually (same logic as AriseTokenStorage)
        let calculatedExpiresIn = max(0, authResult.expiresIn)
        let expiresAt = Date().addingTimeInterval(TimeInterval(calculatedExpiresIn))
        
        // Create stored token model directly
        let storedToken = AriseTokenStorage.StoredToken(
            accessToken: authResult.accessToken,
            refreshToken: authResult.refreshToken,
            tokenType: authResult.tokenType,
            expiresAt: expiresAt
        )
        
        // Verify expiration is approximately correct (within 5 seconds tolerance)
        let expectedExpiration = Date().addingTimeInterval(TimeInterval(expiresIn))
        let actualExpiration = storedToken.expiresAt
        let timeDifference = abs(actualExpiration.timeIntervalSince(expectedExpiration))
        #expect(timeDifference < 5.0)
    }
    
    @Test("Authentication error types")
    func testAuthenticationErrorTypes() {
        // Test all AuthenticationError cases
        let invalidCredentials = AuthenticationError.invalidCredentials
        #expect(invalidCredentials.errorDescription != nil)
        
        let networkError = AuthenticationError.networkError("Test network error")
        #expect(networkError.errorDescription != nil)
        #expect(networkError.errorDescription?.contains("Test network error") == true)
        
        let invalidResponse = AuthenticationError.invalidResponse
        #expect(invalidResponse.errorDescription != nil)
        
        let tokenExpired = AuthenticationError.tokenExpired
        #expect(tokenExpired.errorDescription != nil)
        
        let unknown = AuthenticationError.unknown("Test unknown error")
        #expect(unknown.errorDescription != nil)
    }
    
    @Test("TokenService authenticate with mock API")
    func testTokenServiceAuthenticateWithMock() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let authResult = AuthenticationResult(
            accessToken: "mock-access-token",
            refreshToken: "mock-refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(authResult)
        
        let tokenService = TokenService(authApi: mockAuthApi, session: mockSession, tokenStorage: mockTokenStorage, environmentSettings: environment)
        
        let clientId = "test-client-id"
        let clientSecret = "test-client-secret"
        
        // Authenticate using mock
        let result = try await tokenService.authenticate(clientId: clientId, clientSecret: clientSecret)
        
        // Verify authentication result
        #expect(result.accessToken == "mock-access-token")
        #expect(result.refreshToken == "mock-refresh-token")
        #expect(result.expiresIn == 3600)
        
        // Verify credentials are saved to session
        #expect(mockSession.clientId == clientId)
        #expect(mockSession.clientSecret == clientSecret)
        
        // Verify token is saved to session
        #expect(mockSession.token != nil)
        #expect(mockSession.token?.accessToken == "mock-access-token")
        
        // Verify mock was called correctly
        #expect(mockAuthApi.authenticateCallCount == 1)
        #expect(mockAuthApi.lastAuthenticateClientId == clientId)
        #expect(mockAuthApi.lastAuthenticateClientSecret == clientSecret)
        #expect(mockSession.setCredentialsCallCount == 1)
    }
    
    @Test("TokenService authenticate handles authentication error")
    func testTokenServiceAuthenticateHandlesError() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        mockAuthApi.authenticateResult = .failure(AuthenticationError.invalidCredentials)
        
        let tokenService = TokenService(authApi: mockAuthApi, session: mockSession, tokenStorage: mockTokenStorage, environmentSettings: environment)
        
        let clientId = "test-client-id"
        let clientSecret = "test-client-secret"
        
        // Attempt authentication - should throw error
        await Test.assertThrowsError {
            _ = try await tokenService.authenticate(clientId: clientId, clientSecret: clientSecret)
        }
        
        // Verify credentials are still set in session (set before API call)
        #expect(mockSession.clientId == clientId)
        #expect(mockSession.clientSecret == clientSecret)
        
        // Verify mock was called
        #expect(mockAuthApi.authenticateCallCount == 1)
        #expect(mockSession.setCredentialsCallCount == 1)
    }
    
    @Test("TokenService refreshToken API")
    func testTokenServiceRefreshToken() async throws {
        let mockSession = MockAriseSession()
        
        // Set up session with credentials and refresh token
        mockSession.setCredentials(clientId: "test-client-id", clientSecret: "test-client-secret")
        let initialToken = AriseTokenStorage.StoredToken(
            accessToken: "old-access-token",
            refreshToken: "test-refresh-token",
            tokenType: "Bearer",
            expiresAt: Date().addingTimeInterval(-3600) // Expired
        )
        mockSession.setToken(initialToken)
        
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockAuthApi = MockAriseAuthApi()
        let refreshResult = AuthenticationResult(
            accessToken: "new-access-token",
            refreshToken: "new-refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.refreshTokenResult = .success(refreshResult)
        
        let mockTokenStorage = MockAriseTokenStorage()
        let tokenService = TokenService(authApi: mockAuthApi, session: mockSession, tokenStorage: mockTokenStorage, environmentSettings: environment)
        
        // Refresh token using mock
        let result = try await tokenService.refreshToken()
        
        // Verify refresh result
        #expect(result.accessToken == "new-access-token")
        #expect(result.refreshToken == "new-refresh-token")
        
        // Verify token is updated in session
        #expect(mockSession.token != nil)
        #expect(mockSession.token?.accessToken == "new-access-token")
        
        // Verify mock was called
        #expect(mockAuthApi.refreshTokenCallCount == 1)
    }
    
    @Test("TokenService refreshToken handles refresh error")
    func testTokenServiceRefreshTokenHandlesError() async throws {
        let mockSession = MockAriseSession()
        
        // Set up session with credentials and refresh token
        mockSession.setCredentials(clientId: "test-client-id", clientSecret: "test-client-secret")
        let initialToken = AriseTokenStorage.StoredToken(
            accessToken: "old-access-token",
            refreshToken: "test-refresh-token",
            tokenType: "Bearer",
            expiresAt: Date().addingTimeInterval(-3600) // Expired
        )
        mockSession.setToken(initialToken)
        
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let mockAuthApi = MockAriseAuthApi()
        mockAuthApi.refreshTokenResult = .failure(AuthenticationError.tokenExpired)
        
        let tokenService = TokenService(authApi: mockAuthApi, session: mockSession, tokenStorage: mockTokenStorage, environmentSettings: environment)
        
        // Attempt refresh - should throw error
        await Test.assertThrowsError {
            _ = try await tokenService.refreshToken()
        }
        
        // Verify mock was called
        #expect(mockAuthApi.refreshTokenCallCount == 1)
    }
    
    @Test("TokenService getAccessToken returns nil when no token")
    func testTokenServiceGetAccessTokenReturnsNil() async {
        let mockSession = MockAriseSession()
        let mockTokenStorage = MockAriseTokenStorage()
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let authApi = AriseAuthApi(environmentSettings: environment, session: mockSession, tokenStorage: mockTokenStorage)
        let tokenService = TokenService(authApi: authApi, session: mockSession, tokenStorage: mockTokenStorage, environmentSettings: environment)
        
        // When no token is available, getAccessToken should return nil
        let token = await tokenService.getAccessToken()
        #expect(token == nil)
    }
    
    @Test("TokenService getAccessToken returns valid token when available")
    func testTokenServiceGetAccessTokenReturnsValidToken() async {
        let mockSession = MockAriseSession()
        
        // Save a valid token directly to session (bypassing Keychain for test)
        // This simulates a token that was successfully authenticated but Keychain save failed
        let expiresAt = Date().addingTimeInterval(3600) // 1 hour from now
        let storedToken = AriseTokenStorage.StoredToken(
            accessToken: "test-valid-token",
            refreshToken: "test-refresh-token",
            tokenType: "Bearer",
            expiresAt: expiresAt
        )
        mockSession.setToken(storedToken)
        
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let authApi = AriseAuthApi(environmentSettings: environment, session: mockSession, tokenStorage: mockTokenStorage)
        let tokenService = TokenService(authApi: authApi, session: mockSession, tokenStorage: mockTokenStorage, environmentSettings: environment)
        
        // getAccessToken should return the valid token
        let token = await tokenService.getAccessToken()
        #expect(token == "test-valid-token")
    }
    
    @Test("TokenService getAccessToken auto-refreshes expired token")
    func testTokenServiceGetAccessTokenAutoRefreshesExpiredToken() async throws {
        let mockSession = MockAriseSession()
        
        // Set up expired token with refresh token and credentials
        mockSession.setCredentials(clientId: "test-client-id", clientSecret: "test-client-secret")
        let expiredToken = AriseTokenStorage.StoredToken(
            accessToken: "old-access-token",
            refreshToken: "test-refresh-token",
            tokenType: "Bearer",
            expiresAt: Date().addingTimeInterval(-3600) // Expired 1 hour ago
        )
        mockSession.setToken(expiredToken)
        
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockAuthApi = MockAriseAuthApi()
        let refreshResult = AuthenticationResult(
            accessToken: "new-access-token",
            refreshToken: "new-refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.refreshTokenResult = .success(refreshResult)
        
        let mockTokenStorage = MockAriseTokenStorage()
        let tokenService = TokenService(authApi: mockAuthApi, session: mockSession, tokenStorage: mockTokenStorage, environmentSettings: environment)
        
        // getAccessToken should automatically refresh expired token
        let token = await tokenService.getAccessToken()
        
        // Verify new token is returned
        #expect(token == "new-access-token")
        
        // Verify refresh was called
        #expect(mockAuthApi.refreshTokenCallCount == 1)
        
        // Verify token in session was updated
        #expect(mockSession.token != nil)
        #expect(mockSession.token?.accessToken == "new-access-token")
    }
    
    @Test("TokenService getAccessToken returns nil for expired token without refresh token")
    func testTokenServiceGetAccessTokenReturnsNilForExpiredTokenWithoutRefresh() async {
        let mockSession = MockAriseSession()
        
        // Set up expired token without refresh token
        let expiredToken = AriseTokenStorage.StoredToken(
            accessToken: "old-access-token",
            refreshToken: nil, // No refresh token
            tokenType: "Bearer",
            expiresAt: Date().addingTimeInterval(-3600) // Expired 1 hour ago
        )
        mockSession.setToken(expiredToken)
        
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let authApi = AriseAuthApi(environmentSettings: environment, session: mockSession, tokenStorage: mockTokenStorage)
        let tokenService = TokenService(authApi: authApi, session: mockSession, tokenStorage: mockTokenStorage, environmentSettings: environment)
        
        // getAccessToken should return nil and clear token
        let token = await tokenService.getAccessToken()
        
        // Verify nil is returned
        #expect(token == nil)
        
        // Verify token was cleared from session
        #expect(mockSession.token == nil)
    }
    
    @Test("TokenService getAccessToken handles missing credentials for refresh")
    func testTokenServiceGetAccessTokenHandlesMissingCredentials() async {
        let mockSession = MockAriseSession()
        
        // Set up expired token with refresh token but no credentials
        let expiredToken = AriseTokenStorage.StoredToken(
            accessToken: "old-access-token",
            refreshToken: "test-refresh-token",
            tokenType: "Bearer",
            expiresAt: Date().addingTimeInterval(-3600) // Expired 1 hour ago
        )
        mockSession.setToken(expiredToken)
        // No credentials set in session
        
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let authApi = AriseAuthApi(environmentSettings: environment, session: mockSession, tokenStorage: mockTokenStorage)
        let tokenService = TokenService(authApi: authApi, session: mockSession, tokenStorage: mockTokenStorage, environmentSettings: environment)
        
        // getAccessToken should return nil when credentials are missing
        // (In real scenario, it would try to restore from storage, but in test with mock session, it returns nil)
        let token = await tokenService.getAccessToken()
        
        // Verify nil is returned when credentials are missing
        #expect(token == nil)
        
        // Verify token was cleared from session
        #expect(mockSession.token == nil)
    }
    
    @Test("TokenService getAccessToken handles refresh failure")
    func testTokenServiceGetAccessTokenHandlesRefreshFailure() async {
        let mockSession = MockAriseSession()
        
        // Set up expired token with refresh token and credentials
        mockSession.setCredentials(clientId: "test-client-id", clientSecret: "test-client-secret")
        let expiredToken = AriseTokenStorage.StoredToken(
            accessToken: "old-access-token",
            refreshToken: "test-refresh-token",
            tokenType: "Bearer",
            expiresAt: Date().addingTimeInterval(-3600) // Expired 1 hour ago
        )
        mockSession.setToken(expiredToken)
        
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let mockAuthApi = MockAriseAuthApi()
        // Mock refresh to fail
        mockAuthApi.refreshTokenResult = .failure(AuthenticationError.tokenExpired)
        
        let tokenService = TokenService(authApi: mockAuthApi, session: mockSession, tokenStorage: mockTokenStorage, environmentSettings: environment)
        
        // getAccessToken should return nil when refresh fails
        let token = await tokenService.getAccessToken()
        
        // Verify nil is returned
        #expect(token == nil)
        
        // Verify refresh was attempted
        #expect(mockAuthApi.refreshTokenCallCount == 1)
        
        // Verify token was cleared from session after failed refresh
        #expect(mockSession.token == nil)
    }
}

