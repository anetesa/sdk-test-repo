import Foundation

/// Location permission status.
public enum LocationPermissionStatus: String, Sendable {
    /// Location permission has been granted.
    case granted
    
    /// Location permission has been denied.
    case denied
    
    /// Location permission status is undetermined (not yet requested).
    case undetermined
}

