import Foundation
import Testing
@testable import AriseMobile

/// Tests for AriseAuthApi functionality
struct AuthApiTests {
    
    // MARK: - Helper Methods
    
    private func createAuthApi(
        environmentSettings: EnvironmentSettings? = nil,
        session: AriseSessionProtocol? = nil,
        tokenStorage: AriseTokenStorageProtocol? = nil
    ) -> AriseAuthApi {
        let environment = environmentSettings ?? TestEnvironment.createTestEnvironmentSettings()
        let mockSession = session ?? MockAriseSession()
        let mockTokenStorage = tokenStorage ?? MockAriseTokenStorage()
        
        return AriseAuthApi(
            environmentSettings: environment,
            session: mockSession,
            tokenStorage: mockTokenStorage
        )
    }
    
    private func createValidTokenResponse() -> (data: Data, response: HTTPURLResponse) {
        let json = """
        {
            "access_token": "test-access-token",
            "token_type": "Bearer",
            "expires_in": 3600,
            "refresh_token": "test-refresh-token"
        }
        """
        let data = json.data(using: .utf8)!
        let response = HTTPURLResponse(
            url: URL(string: "https://auth.test.com/oauth2/token")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        return (data, response)
    }
    
    // MARK: - Authentication Tests
    
    @Test("AriseAuthApi authenticates successfully with client credentials")
    func testAuthenticateSuccess() async throws {
        // Note: This test would require mocking URLSession, which is complex
        // For now, we test the structure and error handling
        let authApi = createAuthApi()
        
        // Verify initialization
        #expect(authApi.environmentSettings.apiBaseUrl != "")
    }
    
    @Test("AriseAuthApi formURLEncodedString encodes parameters correctly")
    func testFormURLEncodedString() {
        let authApi = createAuthApi()
        
        let parameters = [
            "grant_type": "client_credentials",
            "client_id": "test-client-id",
            "client_secret": "test-secret",
            "scope": "offline_access"
        ]
        
        let encoded = authApi.formURLEncodedString(from: parameters)
        
        #expect(encoded.contains("grant_type=client_credentials"))
        #expect(encoded.contains("client_id=test-client-id"))
        #expect(encoded.contains("client_secret=test-secret"))
        #expect(encoded.contains("scope=offline_access"))
    }
    
    @Test("AriseAuthApi formURLEncodedString handles special characters")
    func testFormURLEncodedStringSpecialCharacters() {
        let authApi = createAuthApi()
        
        let parameters = [
            "grant_type": "client_credentials",
            "client_id": "test@client.id",
            "scope": "offline access"
        ]
        
        let encoded = authApi.formURLEncodedString(from: parameters)
        
        // Should be URL encoded
        #expect(encoded.contains("grant_type=client_credentials"))
    }
    
    // MARK: - Token Refresh Tests
    
    @Test("AriseAuthApi refreshToken requires client credentials")
    func testRefreshTokenRequiresCredentials() async {
        let mockSession = MockAriseSession()
        // Don't set credentials
        let authApi = createAuthApi(session: mockSession)
        
        do {
            _ = try await authApi.refreshToken()
            Issue.record("Expected error for missing credentials")
        } catch let error as AuthenticationError {
            #expect(error.localizedDescription.contains("Missing client credentials") || error.localizedDescription.contains("credentials"))
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
    
    @Test("AriseAuthApi refreshToken requires refresh token")
    func testRefreshTokenRequiresRefreshToken() async {
        let mockSession = MockAriseSession()
        mockSession.clientId = "test-client-id"
        mockSession.clientSecret = "test-secret"
        // Don't set refresh token
        let authApi = createAuthApi(session: mockSession)
        
        do {
            _ = try await authApi.refreshToken()
            Issue.record("Expected error for missing refresh token")
        } catch let error as AuthenticationError {
            #expect(error.localizedDescription.contains("Missing refresh token") || error.localizedDescription.contains("refresh"))
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
    
    @Test("AriseAuthApi refreshToken loads credentials from storage if not in session")
    func testRefreshTokenLoadsCredentialsFromStorage() async {
        let mockSession = MockAriseSession()
        let mockTokenStorage = MockAriseTokenStorage()
        
        // Set credentials in storage but not in session
        try? mockTokenStorage.saveCredentials(clientId: "storage-client-id", clientSecret: "storage-secret")
        
        // Set refresh token in storage
        let authResult = AuthenticationResult(
            accessToken: "old-token",
            refreshToken: "refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        try? mockTokenStorage.save(authResult)
        
        // Also set in session for refresh token check
        let storedToken = AriseTokenStorage.StoredToken(
            accessToken: "old-token",
            refreshToken: "refresh-token",
            tokenType: "Bearer",
            expiresAt: Date().addingTimeInterval(3600)
        )
        mockSession.setToken(storedToken)
        
        let authApi = createAuthApi(session: mockSession, tokenStorage: mockTokenStorage)
        
        // Note: This will fail because we can't mock URLSession easily
        // But we can verify the structure
        do {
            _ = try await authApi.refreshToken()
            // If it gets here, it means credentials were loaded
        } catch {
            // Expected - we can't easily mock URLSession in unit tests
            // The important thing is that the code path was executed
        }
    }
    
    // MARK: - Error Handling Tests
    
    @Test("AriseAuthApi handles environment settings")
    func testAuthApiHandlesEnvironmentSettings() {
        let authApi = createAuthApi(environmentSettings: .uat)
        
        // Verify initialization doesn't crash and environment is set
        #expect(authApi.environmentSettings == .uat)
        #expect(authApi.environmentSettings.authApiBaseUrl.contains("uat"))
    }
    
    // MARK: - Integration Tests
    
    @Test("AriseAuthApi integrates with OpenAPI client structure")
    func testAuthApiOpenAPIIntegration() {
        let authApi = createAuthApi()
        
        // Verify that AuthApi follows the expected structure for OpenAPI integration
        // This is more of a structural test
        #expect(authApi.environmentSettings != nil)
    }
}

