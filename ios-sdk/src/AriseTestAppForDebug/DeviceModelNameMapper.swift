import Foundation

/// Maps device model identifiers to human-readable device names.
///
/// This mapper is used in the test app for display purposes only.
/// The SDK itself uses modelIdentifier directly without mapping.
struct DeviceModelNameMapper {
    /// Maps device model identifier to human-readable name.
    ///
    /// - Parameter identifier: Device model identifier (e.g., "iPhone14,2")
    /// - Returns: Human-readable device name (e.g., "iPhone 13 Pro") or the identifier if not found
    static func getDeviceName(for identifier: String) -> String {
        return deviceNames[identifier] ?? identifier
    }
    
    /// Device model identifier to name mapping.
    ///
    /// Source: Community-maintained mapping (DeviceKit, etc.)
    /// Note: This mapping needs to be updated when new devices are released.
    private static let deviceNames: [String: String] = [
        // iPhone XS series
        "iPhone11,2": "iPhone XS",
        "iPhone11,4": "iPhone XS Max",
        "iPhone11,6": "iPhone XS Max",
        "iPhone11,8": "iPhone XR",
        
        // iPhone 11 series
        "iPhone12,1": "iPhone 11",
        "iPhone12,3": "iPhone 11 Pro",
        "iPhone12,5": "iPhone 11 Pro Max",
        
        // iPhone 12 series
        "iPhone13,1": "iPhone 12 mini",
        "iPhone13,2": "iPhone 12",
        "iPhone13,3": "iPhone 12 Pro",
        "iPhone13,4": "iPhone 12 Pro Max",
        
        // iPhone 13 series
        "iPhone14,2": "iPhone 13 Pro",
        "iPhone14,3": "iPhone 13 Pro Max",
        "iPhone14,4": "iPhone 13 mini",
        "iPhone14,5": "iPhone 13",
        
        // iPhone SE (3rd generation)
        "iPhone14,6": "iPhone SE (3rd generation)",
        
        // iPhone 14 series
        "iPhone14,7": "iPhone 14",
        "iPhone14,8": "iPhone 14 Plus",
        "iPhone15,2": "iPhone 14 Pro",
        "iPhone15,3": "iPhone 14 Pro Max",
        
        // iPhone 15 series
        "iPhone15,4": "iPhone 15",
        "iPhone15,5": "iPhone 15 Plus",
        "iPhone16,1": "iPhone 15 Pro",
        "iPhone16,2": "iPhone 15 Pro Max",
        
        // iPhone 16 series
        "iPhone17,1": "iPhone 16",
        "iPhone17,2": "iPhone 16 Plus",
        "iPhone17,3": "iPhone 16 Pro",
        "iPhone17,4": "iPhone 16 Pro Max",
    ]
}


