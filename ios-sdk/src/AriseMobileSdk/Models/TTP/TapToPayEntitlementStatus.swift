import Foundation

/// Tap to Pay entitlement availability status.
public enum TapToPayEntitlementStatus: String, Sendable {
    /// Tap to Pay entitlement is available.
    case available
    
    /// Tap to Pay entitlement is unavailable.
    case unavailable
}

