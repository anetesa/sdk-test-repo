import Foundation
import Testing
@testable import AriseMobile

/// Tests for AriseTokenStorage functionality
struct AriseTokenStorageTests {
    
    // MARK: - Helper Methods
    
    private func createAuthResult(
        accessToken: String = "test-access-token",
        refreshToken: String? = "test-refresh-token",
        expiresIn: Int = 3600,
        tokenType: String = "Bearer"
    ) -> AuthenticationResult {
        return AuthenticationResult(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: expiresIn,
            tokenType: tokenType
        )
    }
    
    // MARK: - OAuth Token Save/Load Tests
    
    @Test("AriseTokenStorage saves authentication result")
    func testSaveAuthenticationResult() throws {
        let storage = MockAriseTokenStorage()
        let authResult = createAuthResult()
        
        try storage.save(authResult)
        
        #expect(storage.saveCallCount == 1)
        #expect(storage.lastSavedResult?.accessToken == "test-access-token")
        #expect(storage.lastSavedResult?.refreshToken == "test-refresh-token")
    }
    
    @Test("AriseTokenStorage loads saved token")
    func testLoadSavedToken() throws {
        let storage = MockAriseTokenStorage()
        let authResult = createAuthResult()
        
        try storage.save(authResult)
        let loadedToken = storage.load()
        
        #expect(loadedToken?.accessToken == "test-access-token")
        #expect(loadedToken?.refreshToken == "test-refresh-token")
        #expect(loadedToken?.tokenType == "Bearer")
    }
    
    @Test("AriseTokenStorage load returns nil when no token stored")
    func testLoadReturnsNilWhenEmpty() {
        let storage = MockAriseTokenStorage()
        
        let token = storage.load()
        
        #expect(token == nil)
    }
    
    @Test("AriseTokenStorage saves token with expiration")
    func testSaveTokenWithExpiration() throws {
        let storage = MockAriseTokenStorage()
        let authResult = createAuthResult(expiresIn: 3600)
        
        let beforeSave = Date()
        try storage.save(authResult)
        let afterSave = Date()
        
        let loadedToken = storage.load()
        let expiresAt = loadedToken?.expiresAt ?? Date()
        
        // Token should expire approximately 3600 seconds from now
        let expectedExpiry = beforeSave.addingTimeInterval(3600)
        #expect(expiresAt >= expectedExpiry)
        #expect(expiresAt <= afterSave.addingTimeInterval(3600))
    }
    
    @Test("AriseTokenStorage handles negative expiresIn")
    func testHandlesNegativeExpiresIn() throws {
        let storage = MockAriseTokenStorage()
        let authResult = createAuthResult(expiresIn: -100)
        
        try storage.save(authResult)
        let loadedToken = storage.load()
        
        // Should handle negative expiry gracefully (set to current time)
        #expect(loadedToken != nil)
        #expect(loadedToken?.expiresAt ?? Date.distantFuture <= Date())
    }
    
    @Test("AriseTokenStorage clear removes token")
    func testClearRemovesToken() throws {
        let storage = MockAriseTokenStorage()
        let authResult = createAuthResult()
        
        try storage.save(authResult)
        storage.clear()
        
        let token = storage.load()
        #expect(token == nil)
        #expect(storage.clearCallCount == 1)
    }
    
    // MARK: - Credentials Save/Load Tests
    
    @Test("AriseTokenStorage saves credentials")
    func testSaveCredentials() throws {
        let storage = MockAriseTokenStorage()
        
        try storage.saveCredentials(clientId: "client-123", clientSecret: "secret-456")
        
        #expect(storage.saveCredentialsCallCount == 1)
        #expect(storage.lastSavedCredentials?.clientId == "client-123")
        #expect(storage.lastSavedCredentials?.clientSecret == "secret-456")
    }
    
    @Test("AriseTokenStorage loads saved credentials")
    func testLoadSavedCredentials() throws {
        let storage = MockAriseTokenStorage()
        
        try storage.saveCredentials(clientId: "client-123", clientSecret: "secret-456")
        let credentials = storage.loadCredentials()
        
        #expect(credentials?.clientId == "client-123")
        #expect(credentials?.clientSecret == "secret-456")
    }
    
    @Test("AriseTokenStorage loadCredentials returns nil when empty")
    func testLoadCredentialsReturnsNilWhenEmpty() {
        let storage = MockAriseTokenStorage()
        
        let credentials = storage.loadCredentials()
        
        #expect(credentials == nil)
    }
    
    // MARK: - TTP JWT Token Tests
    
    @Test("AriseTokenStorage saves TTP JWT token")
    func testSaveTTPJwtToken() throws {
        let storage = MockAriseTokenStorage()
        let expiresAt = Date().addingTimeInterval(3600)
        
        try storage.saveTTPJwtToken(token: "ttp-jwt-token-123", expiresAt: expiresAt)
        
        #expect(storage.saveTTPJwtTokenCallCount == 1)
        #expect(storage.lastSavedTTPJwtToken?.token == "ttp-jwt-token-123")
        #expect(storage.lastSavedTTPJwtToken?.expiresAt == expiresAt)
    }
    
    @Test("AriseTokenStorage loads valid TTP JWT token")
    func testLoadValidTTPJwtToken() throws {
        let storage = MockAriseTokenStorage()
        let expiresAt = Date().addingTimeInterval(3600)
        
        try storage.saveTTPJwtToken(token: "ttp-jwt-token-123", expiresAt: expiresAt)
        let loadedToken = storage.loadTTPJwtToken()
        
        #expect(loadedToken?.token == "ttp-jwt-token-123")
        #expect(loadedToken?.expiresAt == expiresAt)
    }
    
    @Test("AriseTokenStorage loadTTPJwtToken returns nil when empty")
    func testLoadTTPJwtTokenReturnsNilWhenEmpty() {
        let storage = MockAriseTokenStorage()
        
        let token = storage.loadTTPJwtToken()
        
        #expect(token == nil)
    }
    
    @Test("AriseTokenStorage loadTTPJwtToken returns nil for expired token")
    func testLoadTTPJwtTokenReturnsNilForExpired() throws {
        let storage = MockAriseTokenStorage()
        let expiresAt = Date().addingTimeInterval(-3600) // Expired 1 hour ago
        
        try storage.saveTTPJwtToken(token: "expired-token", expiresAt: expiresAt)
        let loadedToken = storage.loadTTPJwtToken()
        
        #expect(loadedToken == nil)
    }
    
    @Test("AriseTokenStorage loadTTPJwtToken returns nil for near-expiry token")
    func testLoadTTPJwtTokenReturnsNilForNearExpiry() throws {
        let storage = MockAriseTokenStorage()
        // Token expires in 2 minutes (less than 5 minute threshold)
        let expiresAt = Date().addingTimeInterval(120)
        
        try storage.saveTTPJwtToken(token: "near-expiry-token", expiresAt: expiresAt)
        let loadedToken = storage.loadTTPJwtToken()
        
        // Should return nil because token is near expiry (< 5 minutes)
        #expect(loadedToken == nil)
    }
    
    @Test("AriseTokenStorage clearTTPJwtToken removes token")
    func testClearTTPJwtTokenRemovesToken() throws {
        let storage = MockAriseTokenStorage()
        let expiresAt = Date().addingTimeInterval(3600)
        
        try storage.saveTTPJwtToken(token: "ttp-jwt-token", expiresAt: expiresAt)
        storage.clearTTPJwtToken()
        
        let token = storage.loadTTPJwtToken()
        #expect(token == nil)
        #expect(storage.clearTTPJwtTokenCallCount == 1)
    }
    
    @Test("AriseTokenStorage TTP token isValid property works correctly")
    func testTTPTokenIsValidProperty() throws {
        let storage = MockAriseTokenStorage()
        
        // Valid token (expires in 10 minutes, more than 5 minute threshold)
        let validExpiresAt = Date().addingTimeInterval(600)
        try storage.saveTTPJwtToken(token: "valid-token", expiresAt: validExpiresAt)
        let validToken = storage.loadTTPJwtToken()
        #expect(validToken?.isValid == true)
        
        storage.clearTTPJwtToken()
        
        // Near-expiry token (expires in 2 minutes, less than 5 minute threshold)
        let nearExpiryExpiresAt = Date().addingTimeInterval(120)
        try storage.saveTTPJwtToken(token: "near-expiry-token", expiresAt: nearExpiryExpiresAt)
        let nearExpiryToken = storage.loadTTPJwtToken()
        #expect(nearExpiryToken == nil) // Mock returns nil for invalid tokens
        
        storage.clearTTPJwtToken()
        
        // Expired token
        let expiredExpiresAt = Date().addingTimeInterval(-600)
        try storage.saveTTPJwtToken(token: "expired-token", expiresAt: expiredExpiresAt)
        let expiredToken = storage.loadTTPJwtToken()
        #expect(expiredToken == nil) // Mock returns nil for invalid tokens
    }
    
    // MARK: - Error Handling Tests
    
    @Test("AriseTokenStorage throws error on save failure")
    func testThrowsErrorOnSaveFailure() {
        let storage = MockAriseTokenStorage()
        storage.shouldFailSave = true
        
        let authResult = createAuthResult()
        
        #expect(throws: AriseTokenStorage.KeychainError.self) {
            try storage.save(authResult)
        }
    }
    
    @Test("AriseTokenStorage throws error on credentials save failure")
    func testThrowsErrorOnCredentialsSaveFailure() {
        let storage = MockAriseTokenStorage()
        storage.shouldFailSave = true
        
        #expect(throws: AriseTokenStorage.KeychainError.self) {
            try storage.saveCredentials(clientId: "client", clientSecret: "secret")
        }
    }
    
    @Test("AriseTokenStorage throws error on TTP JWT save failure")
    func testThrowsErrorOnTTPJwtSaveFailure() {
        let storage = MockAriseTokenStorage()
        storage.shouldFailSave = true
        
        let expiresAt = Date().addingTimeInterval(3600)
        
        #expect(throws: AriseTokenStorage.KeychainError.self) {
            try storage.saveTTPJwtToken(token: "token", expiresAt: expiresAt)
        }
    }
    
    @Test("AriseTokenStorage handles load failure gracefully")
    func testHandlesLoadFailureGracefully() {
        let storage = MockAriseTokenStorage()
        storage.shouldFailLoad = true
        
        let token = storage.load()
        
        #expect(token == nil)
    }
    
    // MARK: - Multiple Operations Tests
    
    @Test("AriseTokenStorage handles multiple save/load cycles")
    func testMultipleSaveLoadCycles() throws {
        let storage = MockAriseTokenStorage()
        
        // First cycle
        let authResult1 = createAuthResult(accessToken: "token-1")
        try storage.save(authResult1)
        let token1 = storage.load()
        #expect(token1?.accessToken == "token-1")
        
        // Second cycle
        let authResult2 = createAuthResult(accessToken: "token-2")
        try storage.save(authResult2)
        let token2 = storage.load()
        #expect(token2?.accessToken == "token-2")
        
        // Third cycle
        let authResult3 = createAuthResult(accessToken: "token-3")
        try storage.save(authResult3)
        let token3 = storage.load()
        #expect(token3?.accessToken == "token-3")
    }
    
    @Test("AriseTokenStorage maintains separate storage for OAuth and TTP tokens")
    func testSeparateStorageForOAuthAndTTP() throws {
        let storage = MockAriseTokenStorage()
        
        // Save OAuth token
        let authResult = createAuthResult(accessToken: "oauth-token")
        try storage.save(authResult)
        
        // Save TTP JWT token
        let ttpExpiresAt = Date().addingTimeInterval(3600)
        try storage.saveTTPJwtToken(token: "ttp-jwt-token", expiresAt: ttpExpiresAt)
        
        // Both should be retrievable
        let oauthToken = storage.load()
        let ttpToken = storage.loadTTPJwtToken()
        
        #expect(oauthToken?.accessToken == "oauth-token")
        #expect(ttpToken?.token == "ttp-jwt-token")
        
        // Clearing OAuth token should not affect TTP token
        storage.clear()
        let oauthTokenAfterClear = storage.load()
        let ttpTokenAfterClear = storage.loadTTPJwtToken()
        
        #expect(oauthTokenAfterClear == nil)
        #expect(ttpTokenAfterClear?.token == "ttp-jwt-token")
    }
    
    // MARK: - Edge Cases Tests
    
    @Test("AriseTokenStorage handles empty access token")
    func testHandlesEmptyAccessToken() throws {
        let storage = MockAriseTokenStorage()
        let authResult = createAuthResult(accessToken: "")
        
        try storage.save(authResult)
        let token = storage.load()
        
        #expect(token?.accessToken == "")
    }
    
    @Test("AriseTokenStorage handles nil refresh token")
    func testHandlesNilRefreshToken() throws {
        let storage = MockAriseTokenStorage()
        let authResult = createAuthResult(refreshToken: nil)
        
        try storage.save(authResult)
        let token = storage.load()
        
        #expect(token?.accessToken == "test-access-token")
        #expect(token?.refreshToken == nil)
    }
    
    @Test("AriseTokenStorage handles zero expiresIn")
    func testHandlesZeroExpiresIn() throws {
        let storage = MockAriseTokenStorage()
        let authResult = createAuthResult(expiresIn: 0)
        
        try storage.save(authResult)
        let token = storage.load()
        
        #expect(token != nil)
        // Token should be immediately expired
        #expect(token?.expiresAt ?? Date.distantFuture <= Date())
    }
    
    @Test("AriseTokenStorage handles very large expiresIn")
    func testHandlesVeryLargeExpiresIn() throws {
        let storage = MockAriseTokenStorage()
        let authResult = createAuthResult(expiresIn: 86400 * 365) // 1 year
        
        try storage.save(authResult)
        let token = storage.load()
        
        #expect(token != nil)
        let oneYearFromNow = Date().addingTimeInterval(TimeInterval(86400 * 365))
        #expect(token?.expiresAt ?? Date() >= oneYearFromNow.addingTimeInterval(-10))
    }
    
    @Test("AriseTokenStorage handles empty TTP JWT token")
    func testHandlesEmptyTTPJwtToken() throws {
        let storage = MockAriseTokenStorage()
        let expiresAt = Date().addingTimeInterval(3600)
        
        try storage.saveTTPJwtToken(token: "", expiresAt: expiresAt)
        let token = storage.loadTTPJwtToken()
        
        #expect(token?.token == "")
    }
}






