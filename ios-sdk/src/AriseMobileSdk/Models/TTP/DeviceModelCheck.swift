import Foundation

/// Device model compatibility check result.
public struct DeviceModelCheck: Sendable {
    /// Whether the device model is compatible (iPhone XS or newer).
    public let isCompatible: Bool
    
    /// Device model identifier (e.g., "iPhone14,2").
    public let modelIdentifier: String
    
    public init(isCompatible: Bool, modelIdentifier: String) {
        self.isCompatible = isCompatible
        self.modelIdentifier = modelIdentifier
    }
}

