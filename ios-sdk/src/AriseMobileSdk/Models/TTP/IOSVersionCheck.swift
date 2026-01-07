import Foundation

/// iOS version compatibility check result.
public struct IOSVersionCheck: Sendable {
    /// Whether the iOS version is compatible (iOS 18 or newer).
    public let isCompatible: Bool
    
    /// Current iOS version string (e.g., "18.0").
    public let version: String
    
    /// Required minimum iOS version (e.g., "18.0").
    public let minimumRequiredVersion: String
    
    public init(            isCompatible: Bool, version: String, minimumRequiredVersion: String) {
        self.isCompatible =             isCompatible
        self.version = version
        self.minimumRequiredVersion = minimumRequiredVersion
    }
}

