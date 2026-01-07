import Foundation

/// Protocol for ARISE session management
/// Allows dependency injection for testing
internal protocol AriseSessionProtocol: Sendable {
    var clientId: String? { get }
    var clientSecret: String? { get }
    var token: AriseTokenStorage.StoredToken? { get }
    
    func setCredentials(clientId: String, clientSecret: String)
    func setToken(_ token: AriseTokenStorage.StoredToken?)
    func clear()
    func getValidAccessToken() -> String?
}

