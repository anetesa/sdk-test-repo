import Foundation
@testable import AriseMobile

/// Mock implementation of AriseTokenStorageProtocol for testing
final class MockAriseTokenStorage: AriseTokenStorageProtocol {
    // MARK: - Storage
    
    private var _storedToken: AriseTokenStorage.StoredToken?
    private var _storedCredentials: AriseTokenStorage.StoredCredentials?
    private var _storedTTPJwtToken: AriseTokenStorage.StoredTTPJwtToken?
    
    // MARK: - Configuration
    
    var shouldFailSave = false
    var shouldFailLoad = false
    var saveError: Error?
    var loadError: Error?
    
    // MARK: - Call Tracking
    
    private(set) var saveCallCount = 0
    private(set) var loadCallCount = 0
    private(set) var clearCallCount = 0
    private(set) var saveCredentialsCallCount = 0
    private(set) var loadCredentialsCallCount = 0
    private(set) var saveTTPJwtTokenCallCount = 0
    private(set) var loadTTPJwtTokenCallCount = 0
    private(set) var clearTTPJwtTokenCallCount = 0
    
    private(set) var lastSavedResult: AuthenticationResult?
    private(set) var lastSavedCredentials: (clientId: String, clientSecret: String)?
    private(set) var lastSavedTTPJwtToken: (token: String, expiresAt: Date)?
    
    // MARK: - Reset
    
    func reset() {
        _storedToken = nil
        _storedCredentials = nil
        _storedTTPJwtToken = nil
        shouldFailSave = false
        shouldFailLoad = false
        saveError = nil
        loadError = nil
        saveCallCount = 0
        loadCallCount = 0
        clearCallCount = 0
        saveCredentialsCallCount = 0
        loadCredentialsCallCount = 0
        saveTTPJwtTokenCallCount = 0
        loadTTPJwtTokenCallCount = 0
        clearTTPJwtTokenCallCount = 0
        lastSavedResult = nil
        lastSavedCredentials = nil
        lastSavedTTPJwtToken = nil
    }
    
    // MARK: - AriseTokenStorageProtocol Implementation
    
    func save(_ result: AuthenticationResult) throws {
        saveCallCount += 1
        lastSavedResult = result
        
        if shouldFailSave {
            if let error = saveError {
                throw error
            } else {
                throw AriseTokenStorage.KeychainError.saveFailed(-1)
            }
        }
        
        let expiresIn = max(0, result.expiresIn)
        let expiresAt = Date().addingTimeInterval(TimeInterval(expiresIn))
        _storedToken = AriseTokenStorage.StoredToken(
            accessToken: result.accessToken,
            refreshToken: result.refreshToken,
            tokenType: result.tokenType,
            expiresAt: expiresAt
        )
    }
    
    func load() -> AriseTokenStorage.StoredToken? {
        loadCallCount += 1
        
        if shouldFailLoad {
            return nil
        }
        
        return _storedToken
    }
    
    func clear() {
        clearCallCount += 1
        _storedToken = nil
    }
    
    func loadCredentials() -> AriseTokenStorage.StoredCredentials? {
        loadCredentialsCallCount += 1
        
        if shouldFailLoad {
            return nil
        }
        
        return _storedCredentials
    }
    
    func saveCredentials(clientId: String, clientSecret: String) throws {
        saveCredentialsCallCount += 1
        lastSavedCredentials = (clientId: clientId, clientSecret: clientSecret)
        
        if shouldFailSave {
            if let error = saveError {
                throw error
            } else {
                throw AriseTokenStorage.KeychainError.saveFailed(-1)
            }
        }
        
        _storedCredentials = AriseTokenStorage.StoredCredentials(
            clientId: clientId,
            clientSecret: clientSecret
        )
    }
    
    func saveTTPJwtToken(token: String, expiresAt: Date) throws {
        saveTTPJwtTokenCallCount += 1
        lastSavedTTPJwtToken = (token: token, expiresAt: expiresAt)
        
        if shouldFailSave {
            if let error = saveError {
                throw error
            } else {
                throw AriseTokenStorage.KeychainError.saveFailed(-1)
            }
        }
        
        _storedTTPJwtToken = AriseTokenStorage.StoredTTPJwtToken(
            token: token,
            expiresAt: expiresAt
        )
    }
    
    func loadTTPJwtToken() -> AriseTokenStorage.StoredTTPJwtToken? {
        loadTTPJwtTokenCallCount += 1
        
        if shouldFailLoad {
            return nil
        }
        
        // Check if token is still valid
        if let token = _storedTTPJwtToken, token.isValid {
            return token
        }
        
        return nil
    }
    
    func clearTTPJwtToken() {
        clearTTPJwtTokenCallCount += 1
        _storedTTPJwtToken = nil
    }
}

