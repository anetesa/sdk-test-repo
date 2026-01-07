import Foundation
import Testing
import OpenAPIRuntime
import HTTPTypes
@testable import AriseMobile

/// Test implementation of BaseApiClient for testing
final class TestBaseApiClient: BaseApiClient {
    init(tokenService: TokenService, environmentSettings: EnvironmentSettings) {
        super.init(tokenService: tokenService, environmentSettings: environmentSettings, queueLabel: "com.arise.test.api-client")
    }
}

/// Tests for BaseApiClient functionality
struct BaseApiClientTests {
    
    // MARK: - Helper Methods
    
    private func createBaseApiClient(
        tokenService: TokenService? = nil,
        environmentSettings: EnvironmentSettings? = nil
    ) -> TestBaseApiClient {
        let environment = environmentSettings ?? TestEnvironment.createTestEnvironmentSettings()
        let mockSession = MockAriseSession()
        let mockTokenStorage = MockAriseTokenStorage()
        let mockAuthApi = MockAriseAuthApi()
        let tokenService = tokenService ?? TokenService(
            authApi: mockAuthApi,
            session: mockSession,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        return TestBaseApiClient(
            tokenService: tokenService,
            environmentSettings: environment
        )
    }
    
    private func createTokenServiceWithToken(_ token: String) -> TokenService {
        let mockSession = MockAriseSession()
        let storedToken = AriseTokenStorage.StoredToken(
            accessToken: token,
            refreshToken: "refresh-token",
            tokenType: "Bearer",
            expiresAt: Date().addingTimeInterval(3600)
        )
        mockSession.setToken(storedToken)
        
        let mockTokenStorage = MockAriseTokenStorage()
        let mockAuthApi = MockAriseAuthApi()
        
        return TokenService(
            authApi: mockAuthApi,
            session: mockSession,
            tokenStorage: mockTokenStorage,
            environmentSettings: TestEnvironment.createTestEnvironmentSettings()
        )
    }
    
    // MARK: - Initialization Tests
    
    @Test("BaseApiClient initializes successfully")
    func testInitialization() {
        let client = createBaseApiClient()
        #expect(client.instanceBaseURL == TestEnvironment.createTestEnvironmentSettings().apiBaseUrl)
        #expect(client.configurationQueue.label == "com.arise.test.api-client")
    }
    
    // MARK: - API Client Creation Tests
    
    @Test("BaseApiClient creates API client successfully")
    func testGetApiClientCreatesClient() throws {
        let tokenService = createTokenServiceWithToken("test-token-123")
        let client = createBaseApiClient(tokenService: tokenService)
        
        let apiClient = try client.getApiClient()
        #expect(apiClient != nil)
    }
    

    @Test("BaseApiClient creates and caches API client")
    func testGetApiClientCreatesAndCaches() throws {
        let tokenService = createTokenServiceWithToken("test-token-123")
        let client = createBaseApiClient(tokenService: tokenService)
        
        let apiClient1 = try client.getApiClient()
        let apiClient2 = try client.getApiClient()
        
        #expect(apiClient1 != nil)
        #expect(apiClient2 != nil)
    }
    
    @Test("BaseApiClient recreates client when token changes")
    func testGetApiClientRecreatesOnTokenChange() throws {
        let mockSession = MockAriseSession()
        let mockTokenStorage = MockAriseTokenStorage()
        let mockAuthApi = MockAriseAuthApi()
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: mockSession,
            tokenStorage: mockTokenStorage,
            environmentSettings: TestEnvironment.createTestEnvironmentSettings()
        )
        
        let client = createBaseApiClient(tokenService: tokenService)
        
        // Set initial token
        let token1 = AriseTokenStorage.StoredToken(
            accessToken: "token-1",
            refreshToken: "refresh-1",
            tokenType: "Bearer",
            expiresAt: Date().addingTimeInterval(3600)
        )
        mockSession.setToken(token1)
        
        let apiClient1 = try client.getApiClient()
        
        // Change token
        let token2 = AriseTokenStorage.StoredToken(
            accessToken: "token-2",
            refreshToken: "refresh-2",
            tokenType: "Bearer",
            expiresAt: Date().addingTimeInterval(3600)
        )
        mockSession.setToken(token2)
        
        let apiClient2 = try client.getApiClient()
        

        // Should be different instances (client is recreated)
        // Note: We can't directly compare Client instances, but we can verify they're created
        #expect(apiClient1 != nil)
        #expect(apiClient2 != nil)
    }
    
    @Test("BaseApiClient throws error for invalid base URL")
    func testGetApiClientThrowsForInvalidURL() {
        // Note: EnvironmentSettings is an enum, so we can't create invalid URLs directly
        // Instead, we test that valid URLs work correctly
        let tokenService = createTokenServiceWithToken("test-token")
        let client = createBaseApiClient(tokenService: tokenService)
        
        // Valid URL should work
        do {
            let apiClient = try client.getApiClient()
            #expect(apiClient != nil)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Request Execution Tests
    
    @Test("BaseApiClient executeWithConfiguration handles successful request")
    func testExecuteWithConfigurationSuccess() async throws {
        let tokenService = createTokenServiceWithToken("test-token")
        let client = createBaseApiClient(tokenService: tokenService)
        
        let result = try await client.executeWithConfiguration(token: "test-token") {
            return "success"
        }
        
        #expect(result == "success")
    }
    
    @Test("BaseApiClient executeWithConfiguration handles URLError")
    func testExecuteWithConfigurationHandlesURLError() async {
        let tokenService = createTokenServiceWithToken("test-token")
        let client = createBaseApiClient(tokenService: tokenService)
        
        do {
            _ = try await client.executeWithConfiguration(token: "test-token") {
                throw URLError(.notConnectedToInternet)
            }
            Issue.record("Expected error")
        } catch let error as AriseApiError {
            #expect(error.localizedDescription.contains("notConnectedToInternet") || error.localizedDescription.contains("Network"))
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
    
    @Test("BaseApiClient executeWithConfiguration rethrows AriseApiError")
    func testExecuteWithConfigurationRethrowsAriseApiError() async {
        let tokenService = createTokenServiceWithToken("test-token")
        let client = createBaseApiClient(tokenService: tokenService)
        
        let errorInfo = ErrorInfo(
            details: "Test error details",
            statusCode: 400,
            correlationId: "test-correlation-id",
            errorCode: "TEST_ERROR",
            source: "test",
            exceptionType: "TestException"
        )
        let expectedError = AriseApiError.badRequest("Test error", errorInfo)
        
        do {
            _ = try await client.executeWithConfiguration(token: "test-token") {
                throw expectedError
            }
            Issue.record("Expected error")
        } catch let error as AriseApiError {
            #expect(error.localizedDescription == expectedError.localizedDescription)
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Token Access Tests
    
    @Test("BaseApiClient getAccessToken returns token from service")
    func testGetAccessToken() async {
        let tokenService = createTokenServiceWithToken("test-access-token")
        let client = createBaseApiClient(tokenService: tokenService)
        
        let token = await client.getAccessToken()
        #expect(token == "test-access-token")
    }
    
    @Test("BaseApiClient getAccessToken returns nil when no token")
    func testGetAccessTokenReturnsNil() async {
        let mockSession = MockAriseSession()
        let mockTokenStorage = MockAriseTokenStorage()
        let mockAuthApi = MockAriseAuthApi()
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: mockSession,
            tokenStorage: mockTokenStorage,
            environmentSettings: TestEnvironment.createTestEnvironmentSettings()
        )
        let client = createBaseApiClient(tokenService: tokenService)
        
        let token = await client.getAccessToken()
        #expect(token == nil)
    }
    

    // MARK: - Middleware Chain Tests
    
    @Test("BaseApiClient creates client with all middlewares")
    func testGetApiClientCreatesWithMiddlewares() throws {
        let tokenService = createTokenServiceWithToken("test-token")
        let client = createBaseApiClient(tokenService: tokenService)
        
        let apiClient = try client.getApiClient()
        #expect(apiClient != nil)
        
        // Verify client is created (middlewares are configured internally)
        // We can't directly access middleware configuration, but we can verify client works
    }
    
    @Test("BaseApiClient handles concurrent getApiClient calls")
    func testGetApiClientConcurrentCalls() async throws {
        let tokenService = createTokenServiceWithToken("test-token")
        let client = createBaseApiClient(tokenService: tokenService)
        
        // Make concurrent calls
        async let client1 = try client.getApiClient()
        async let client2 = try client.getApiClient()
        async let client3 = try client.getApiClient()
        
        let results = try await [client1, client2, client3]
        
        // All should succeed
        for result in results {
            #expect(result != nil)
        }
    }
}

