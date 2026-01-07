import Foundation

/// Errors that can occur during Tap to Pay operations
public enum TTPError: Error, LocalizedError {
    case notActive(String)
    case sdkNotInitialized
    case configurationFailed(String, String?)
    case activationFailed(String, String?)
    case transactionFailed(String, String?)
    case failedToAbortTransaction(String, String?)
    case unknown(String, String?)
    
    public var errorDescription: String? {
        switch self {
        case .notActive(let message):
            return "Tap to Pay is not active: \(message)"
        case .sdkNotInitialized:
            return "CloudCommerce SDK not initialized"
        case .configurationFailed(let message, let errorCode):
            return "Configuration failed: \(message) \(errorCode != nil ? " (Code: \(errorCode!))" : "")"
        case .activationFailed(let message, let errorCode):
            return "Activation failed: \(message) \(errorCode != nil ? " (Code: \(errorCode!))" : "")"
        case .transactionFailed(let message, let errorCode):
            return "Transaction failed: \(message) \(errorCode != nil ? " (Code: \(errorCode!))" : "")"
        case .failedToAbortTransaction(let message, let errorCode):
            return "Cannot abort transaction:  \(message) \(errorCode != nil ? " (Code: \(errorCode!))" : "")"
        case .unknown(let message, let errorCode):
            return "Unknown error: \(message) \(errorCode != nil ? " (Code: \(errorCode!))" : "")"
        }
    }
    
    public var errorCode: String? {
        switch self {
        case .notActive(_):
            return nil
        case .sdkNotInitialized:
            return nil
        case .configurationFailed(_, let errorCode):
            return errorCode
        case .activationFailed(_, let errorCode):
            return errorCode
        case .transactionFailed(_, let errorCode):
            return errorCode
        case .failedToAbortTransaction(_, let errorCode):
            return errorCode
        case .unknown(_, let errorCode):
            return errorCode
        }
    }
}

