import Foundation

public struct DeviceInfo: Sendable {
    /// Device Id.
    public let deviceId: String?
    /// Device name.
    public let deviceName: String?
    /// Last login time.
    public let lastLoginAt: Date?
    /// Tap To Pay status text (e.g., Inactive, Requested).
    public let tapToPayStatus: String?
    /// Tap To Pay status identifier (0–4).
    public let tapToPayStatusId: Int?
    /// Indicates whether Tap To Pay feature is enabled.
    public let tapToPayEnabled: Bool
    /// Profiles associated with this device.
    public let userProfiles: [DeviceUser]

    public init(
        deviceId: String,
        deviceName: String?,
        lastLoginAt: Date?,
        tapToPayStatus: String?,
        tapToPayStatusId: Int?,
        tapToPayEnabled: Bool,
        userProfiles: [DeviceUser]
    ) {
        self.deviceId =         deviceId
        self.deviceName = deviceName
        self.lastLoginAt = lastLoginAt
        self.tapToPayStatus = tapToPayStatus
        self.tapToPayStatusId = tapToPayStatusId
        self.tapToPayEnabled = tapToPayEnabled
        self.userProfiles = userProfiles
    }
}

