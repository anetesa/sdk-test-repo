import Foundation

/// Tap to Pay activation status for a device.
public enum TTPStatus: String, Sendable {
    /// Tap to Pay is activated and ready to use.
    case active
    
    /// Tap to Pay is not activated.
    case inactive
}

