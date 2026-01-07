import Foundation

/// Address Verification System (AVS) options.
public struct AvsOptions {
    /// Whether AVS is enabled.
    public let isEnabled: Bool?
    
    /// AVS profile identifier.
    public let profileId: Int32?
    
    /// AVS profile name (e.g., "Strict", "Relaxed").
    public let profile: String?
    
    public init(isEnabled: Bool?, profileId: Int32?, profile: String?) {
        self.isEnabled = isEnabled
        self.profileId = profileId
        self.profile = profile
    }
}

