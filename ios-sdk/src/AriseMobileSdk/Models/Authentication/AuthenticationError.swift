import Foundation

/// Authentication error types
public enum AuthenticationError: Error, LocalizedError {
    case invalidCredentials
    case networkError(String)
    case invalidResponse
    case tokenExpired
    case unknown(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid client credentials"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidResponse:
            return "Invalid response from authentication server"
        case .tokenExpired:
            return "Access token has expired"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}

