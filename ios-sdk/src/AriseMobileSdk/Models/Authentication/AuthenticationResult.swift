import Foundation

/// Authentication result containing access token and expiration info
public struct AuthenticationResult {
    public let accessToken: String
    public let refreshToken: String?
    public let expiresIn: Int
    public let tokenType: String
    
    public init(accessToken: String, refreshToken: String?, expiresIn: Int, tokenType: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
        self.tokenType = tokenType
    }
}

