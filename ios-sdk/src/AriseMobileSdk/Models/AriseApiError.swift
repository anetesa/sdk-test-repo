import Foundation

/// Errors that can occur during API operations
/// Centralized error handling for all Arise API clients
public enum AriseApiError: Error, LocalizedError {
    case badRequest(String, ErrorInfo?)
    case unauthorized(String)
    case forbidden(String, ErrorInfo?)
    case notFound(String, ErrorInfo?)
    case serverError(String, ErrorInfo?)
    case unknown(String, ErrorInfo?)
    case invalidResponse(String)
    case networkError(String)
    
    public var errorDescription: String? {
        switch self {
        case .badRequest(let message, _):
            return "BadRequest Error: \(message)"
        case .unauthorized(let message):
            return "Authentication Required: \(message)"
        case .forbidden(let message, _):
            return "Forbidden Required:  \(message)"
        case .notFound(let message, _):
            return "NotFound Error:  \(message)"
        case .serverError(let message, _):
            return "Server Error: \(message)"
        case .unknown(let message, _):
            return "Unknown Error: \(message)"
        case .invalidResponse(let message):
            return "Invalid Response: \(message)"
        case .networkError(let message):
            return "Network Error: \(message)"
        }
    }
    
    public var errorInfo: ErrorInfo? {
        switch self {
        case .badRequest(_, let errorInfo):
            return errorInfo
        case .unauthorized(_):
            return nil
        case .forbidden(_, let errorInfo):
            return errorInfo
        case .notFound(_, let errorInfo):
            return errorInfo
        case .serverError(_, let errorInfo):
            return errorInfo
        case .unknown(_, let errorInfo):
            return errorInfo
        case .invalidResponse(_):
            return nil
        case .networkError(_):
            return nil
        
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .badRequest:
            return "Please verify the request parameters and try again."
        case .unauthorized:
            return "Please call `authenticate()` method to obtain a valid access token."
        case .forbidden(_, _):
            return "You do not have permission to perform this action. Please check your access rights."
        case .notFound(_, _):
            return "You are trying to access a resource that does not exist. Please verify the resource identifier."
        case .serverError:
            return "The server encountered an error. Please try again after a short delay."
        case .unknown:
            return "An unexpected error occurred. Please try again or contact support if the issue persists."
        case .invalidResponse:
            return "The server returned an unexpected response. This may indicate an API change or a temporary server issue."
        case .networkError:
            return "Check your internet connection and try again."
        }
    }
}

