import Foundation
@testable import AriseMobile

/// Mock implementation of Keychain storage for testing
final class MockKeychain: @unchecked Sendable {
    
    // MARK: - Storage
    
    private var storage: [String: Data] = [:]
    private let queue = DispatchQueue(label: "com.arise.mobile.sdk.test.keychain", qos: .utility)
    
    // MARK: - Configuration
    
    var shouldFail = false
    var error: Error?
    
    // MARK: - Call Tracking
    
    private(set) var saveCallCount = 0
    private(set) var loadCallCount = 0
    private(set) var deleteCallCount = 0
    
    // MARK: - Reset
    
    func reset() {
        queue.sync {
            storage.removeAll()
            shouldFail = false
            error = nil
            saveCallCount = 0
            loadCallCount = 0
            deleteCallCount = 0
        }
    }
    
    // MARK: - Mock Methods
    
    func save(key: String, data: Data) throws {
        saveCallCount += 1
        
        if shouldFail {
            if let error = error {
                throw error
            } else {
                throw NSError(domain: "MockKeychain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock Keychain save failure"])
            }
        }
        
        queue.sync {
            storage[key] = data
        }
    }
    
    func load(key: String) throws -> Data? {
        loadCallCount += 1
        
        if shouldFail {
            if let error = error {
                throw error
            } else {
                throw NSError(domain: "MockKeychain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock Keychain load failure"])
            }
        }
        
        return queue.sync {
            return storage[key]
        }
    }
    
    func delete(key: String) throws {
        deleteCallCount += 1
        
        if shouldFail {
            if let error = error {
                throw error
            } else {
                throw NSError(domain: "MockKeychain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock Keychain delete failure"])
            }
        }
        
        queue.sync {
            storage.removeValue(forKey: key)
        }
    }
    
    // MARK: - Helper Methods for Token Storage
    
    func saveToken(_ token: AriseTokenStorage.StoredToken) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(token)
        try save(key: "arise_oauth_token", data: data)
    }
    
    func loadToken() throws -> AriseTokenStorage.StoredToken? {
        guard let data = try load(key: "arise_oauth_token") else {
            return nil
        }
        let decoder = JSONDecoder()
        return try decoder.decode(AriseTokenStorage.StoredToken.self, from: data)
    }
    
    func saveTTPJwtToken(token: String, expiresAt: Date) throws {
        let tokenData = TTPJwtTokenData(token: token, expiresAt: expiresAt)
        let encoder = JSONEncoder()
        let data = try encoder.encode(tokenData)
        try save(key: "arise_ttp_jwt_token", data: data)
    }
    
    func loadTTPJwtToken() throws -> TTPJwtTokenData? {
        guard let data = try load(key: "arise_ttp_jwt_token") else {
            return nil
        }
        let decoder = JSONDecoder()
        return try decoder.decode(TTPJwtTokenData.self, from: data)
    }
}

// MARK: - Helper Types

struct TTPJwtTokenData: Codable {
    let token: String
    let expiresAt: Date
}

