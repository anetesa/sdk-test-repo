import Foundation
import Testing
@testable import AriseMobile

/// Tests for AriseSession functionality
struct AriseSessionTests {
    
    // MARK: - Helper Methods
    
    private func createSession(tokenStorage: AriseTokenStorageProtocol? = nil) -> AriseSession {
        let storage = tokenStorage ?? MockAriseTokenStorage()
        return AriseSession(tokenStorage: storage)
    }
    
    private func createStoredToken(
        accessToken: String = "test-access-token",
        refreshToken: String? = "test-refresh-token",
        expiresIn: TimeInterval = 3600
    ) -> AriseTokenStorage.StoredToken {
        return AriseTokenStorage.StoredToken(
            accessToken: accessToken,
            refreshToken: refreshToken,
            tokenType: "Bearer",
            expiresAt: Date().addingTimeInterval(expiresIn)
        )
    }
    
    // MARK: - Initialization Tests
    
    @Test("AriseSession initializes with empty state")
    func testInitializationEmpty() {
        let session = createSession()
        
        #expect(session.clientId == nil)
        #expect(session.clientSecret == nil)
        #expect(session.token == nil)
    }
    
    @Test("AriseSession restores credentials from storage on initialization")
    func testInitializationRestoresCredentials() throws {
        let mockStorage = MockAriseTokenStorage()
        try mockStorage.saveCredentials(clientId: "test-client-id", clientSecret: "test-secret")
        
        let session = createSession(tokenStorage: mockStorage)
        
        #expect(session.clientId == "test-client-id")
        #expect(session.clientSecret == "test-secret")
    }
    
    // MARK: - Credentials Tests
    
    @Test("AriseSession setCredentials stores credentials")
    func testSetCredentials() {
        let session = createSession()
        
        session.setCredentials(clientId: "client-id-123", clientSecret: "secret-456")
        
        #expect(session.clientId == "client-id-123")
        #expect(session.clientSecret == "secret-456")
    }
    
    @Test("AriseSession setCredentials overwrites existing credentials")
    func testSetCredentialsOverwrites() {
        let session = createSession()
        
        session.setCredentials(clientId: "old-id", clientSecret: "old-secret")
        session.setCredentials(clientId: "new-id", clientSecret: "new-secret")
        
        #expect(session.clientId == "new-id")
        #expect(session.clientSecret == "new-secret")
    }
    
    // MARK: - Token Storage Tests
    
    @Test("AriseSession setToken stores token in memory")
    func testSetTokenStoresInMemory() {
        let session = createSession()
        let token = createStoredToken()
        
        session.setToken(token)
        
        #expect(session.token?.accessToken == "test-access-token")
        #expect(session.token?.refreshToken == "test-refresh-token")
    }
    
    @Test("AriseSession restores token from storage on first access")
    func testTokenRestorationOnFirstAccess() {
        let mockStorage = MockAriseTokenStorage()
        let authResult = AuthenticationResult(
            accessToken: "stored-token",
            refreshToken: "stored-refresh",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        try? mockStorage.save(authResult)
        
        let session = createSession(tokenStorage: mockStorage)
        
        // First access should restore from storage
        let token = session.token
        
        #expect(token?.accessToken == "stored-token")
        #expect(token?.refreshToken == "stored-refresh")
        #expect(mockStorage.loadCallCount == 1)
    }
    
    @Test("AriseSession does not restore token multiple times")
    func testTokenNotRestoredMultipleTimes() {
        let mockStorage = MockAriseTokenStorage()
        let authResult = AuthenticationResult(
            accessToken: "stored-token",
            refreshToken: "stored-refresh",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        try? mockStorage.save(authResult)
        
        let session = createSession(tokenStorage: mockStorage)
        
        // Access token multiple times
        _ = session.token
        _ = session.token
        _ = session.token
        
        // Should only load once
        #expect(mockStorage.loadCallCount == 1)
    }
    
    @Test("AriseSession restores expired token")
    func testRestoresExpiredToken() {
        let mockStorage = MockAriseTokenStorage()
        let authResult = AuthenticationResult(
            accessToken: "expired-token",
            refreshToken: "refresh-token",
            expiresIn: -3600, // Expired 1 hour ago
            tokenType: "Bearer"
        )
        try? mockStorage.save(authResult)
        
        let session = createSession(tokenStorage: mockStorage)
        
        let token = session.token
        
        // Expired token should still be restored (to allow refresh)
        #expect(token?.accessToken == "expired-token")
        #expect(token?.expiresAt ?? Date() < Date())
    }
    
    @Test("AriseSession getValidAccessToken returns token if valid")
    func testGetValidAccessTokenReturnsValid() {
        let session = createSession()
        let token = createStoredToken(expiresIn: 3600)
        
        session.setToken(token)
        
        let validToken = session.getValidAccessToken()
        #expect(validToken == "test-access-token")
    }
    
    @Test("AriseSession getValidAccessToken returns nil if expired")
    func testGetValidAccessTokenReturnsNilIfExpired() {
        let session = createSession()
        let token = createStoredToken(expiresIn: -3600) // Expired
        
        session.setToken(token)
        
        let validToken = session.getValidAccessToken()
        #expect(validToken == nil)
    }
    
    @Test("AriseSession getValidAccessToken returns nil if no token")
    func testGetValidAccessTokenReturnsNilIfNoToken() {
        let session = createSession()
        
        let validToken = session.getValidAccessToken()
        #expect(validToken == nil)
    }
    
    // MARK: - Clear Tests
    
    @Test("AriseSession clear removes all data")
    func testClearRemovesAllData() {
        let session = createSession()
        let token = createStoredToken()
        
        session.setCredentials(clientId: "client-id", clientSecret: "secret")
        session.setToken(token)
        
        session.clear()
        
        #expect(session.clientId == nil)
        #expect(session.clientSecret == nil)
        #expect(session.token == nil)
    }
    
    @Test("AriseSession does not restore token after explicit clear")
    func testNoRestorationAfterClear() {
        let mockStorage = MockAriseTokenStorage()
        let authResult = AuthenticationResult(
            accessToken: "stored-token",
            refreshToken: "stored-refresh",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        try? mockStorage.save(authResult)
        
        let session = createSession(tokenStorage: mockStorage)
        
        // Clear session
        session.clear()
        
        // Accessing token should not restore from storage
        let token = session.token
        #expect(token == nil)
    }
    
    // MARK: - Thread Safety Tests
    
    @Test("AriseSession handles concurrent access safely")
    func testConcurrentAccess() async {
        let session = createSession()
        let token = createStoredToken()
        
        // Perform concurrent operations
        await withTaskGroup(of: Void.self) { group in
            // Set credentials concurrently
            for i in 0..<10 {
                group.addTask {
                    session.setCredentials(clientId: "client-\(i)", clientSecret: "secret-\(i)")
                }
            }
            
            // Set token concurrently
            for _ in 0..<10 {
                group.addTask {
                    session.setToken(token)
                }
            }
            
            // Read concurrently
            for _ in 0..<10 {
                group.addTask {
                    _ = session.clientId
                    _ = session.token
                }
            }
        }
        
        // Should complete without crashing
        #expect(session.clientId != nil)
    }
    
    // MARK: - Edge Cases Tests
    
    @Test("AriseSession handles nil refresh token")
    func testHandlesNilRefreshToken() {
        let session = createSession()
        let token = createStoredToken(refreshToken: nil)
        
        session.setToken(token)
        
        #expect(session.token?.accessToken == "test-access-token")
        #expect(session.token?.refreshToken == nil)
    }
    
    @Test("AriseSession handles setting nil token")
    func testHandlesSettingNilToken() {
        let session = createSession()
        let token = createStoredToken()
        
        session.setToken(token)
        #expect(session.token != nil)
        
        session.setToken(nil)
        #expect(session.token == nil)
    }
    
    @Test("AriseSession handles empty credentials")
    func testHandlesEmptyCredentials() {
        let session = createSession()
        
        session.setCredentials(clientId: "", clientSecret: "")
        
        #expect(session.clientId == "")
        #expect(session.clientSecret == "")
    }
}






