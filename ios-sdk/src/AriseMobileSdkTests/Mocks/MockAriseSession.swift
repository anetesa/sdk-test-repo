import Foundation
@testable import AriseMobile

/// Mock implementation of AriseSessionProtocol for testing
final class MockAriseSession: AriseSessionProtocol {
    var clientId: String?
    var clientSecret: String?
    private(set) var token: AriseTokenStorage.StoredToken?
    
    var setCredentialsCallCount = 0
    var lastSetCredentialsClientId: String?
    var lastSetCredentialsClientSecret: String?
    
    var setTokenCallCount = 0
    var lastSetTokenValue: AriseTokenStorage.StoredToken?
    
    var clearCallCount = 0
    
    func setCredentials(clientId: String, clientSecret: String) {
        setCredentialsCallCount += 1
        lastSetCredentialsClientId = clientId
        lastSetCredentialsClientSecret = clientSecret
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
    
    func setToken(_ token: AriseTokenStorage.StoredToken?) {
        setTokenCallCount += 1
        lastSetTokenValue = token
        self.token = token
    }
    
    func clear() {
        clearCallCount += 1
        clientId = nil
        clientSecret = nil
        token = nil
    }
    
    func getValidAccessToken() -> String? {
        guard let token = token, token.expiresAt > Date() else {
            return nil
        }
        return token.accessToken
    }
}

