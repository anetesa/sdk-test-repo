import Foundation

/// Result of Tap to Pay compatibility check.
///
/// Contains detailed information about device compatibility with Tap to Pay on iPhone,
/// including device model, iOS version, location permissions, and Tap to Pay entitlement status.
public struct TTPCompatibilityResult: Sendable {
    /// Overall compatibility status.
    ///
    /// `true` when all prerequisites are met (device model, iOS version, location permission, and Tap to Pay entitlement).
    public let isCompatible: Bool
    
    /// Device model compatibility check result.
    public let deviceModelCheck: DeviceModelCheck
    
    /// iOS version compatibility check result.
    public let iosVersionCheck: IOSVersionCheck
    
    /// Location permission status.
    public let locationPermission: LocationPermissionStatus
    
    /// Tap to Pay entitlement availability status.
    public let tapToPayEntitlement: TapToPayEntitlementStatus
    
    /// List of reasons why the device is not compatible (empty if `compatible` is `true`).
    public let incompatibilityReasons: [String]
    
    public init(
        isCompatible: Bool,
        deviceModelCheck: DeviceModelCheck,
        iosVersionCheck: IOSVersionCheck,
        locationPermission: LocationPermissionStatus,
        tapToPayEntitlement: TapToPayEntitlementStatus,
        incompatibilityReasons: [String]
    ) {
        self.isCompatible = isCompatible
        self.deviceModelCheck = deviceModelCheck
        self.iosVersionCheck = iosVersionCheck
        self.locationPermission = locationPermission
        self.tapToPayEntitlement = tapToPayEntitlement
        self.incompatibilityReasons = incompatibilityReasons
    }
}

