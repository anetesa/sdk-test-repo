import Foundation
@testable import AriseMobile

/// Factory for creating test device data
enum DeviceFactory {
    
    /// Create a test DeviceInfo with default values
    static func createDeviceInfo(
        deviceId: String = "test-device-id-123",
        deviceName: String? = "Test iPhone",
        lastLoginAt: Date? = Date(),
        tapToPayStatus: String? = "Active",
        tapToPayStatusId: Int? = 1,
        tapToPayEnabled: Bool = true,
        userProfiles: [DeviceUser] = []
    ) -> DeviceInfo {
        return DeviceInfo(
            deviceId: deviceId, // deviceId is not optional in init
            deviceName: deviceName,
            lastLoginAt: lastLoginAt,
            tapToPayStatus: tapToPayStatus,
            tapToPayStatusId: tapToPayStatusId,
            tapToPayEnabled: tapToPayEnabled,
            userProfiles: userProfiles
        )
    }
    
    /// Create a device with Tap to Pay enabled
    static func createTTPEnabledDevice(deviceId: String = "ttp-enabled-device") -> DeviceInfo {
        return createDeviceInfo(
            deviceId: deviceId,
            tapToPayStatus: "Active",
            tapToPayStatusId: 1,
            tapToPayEnabled: true
        )
    }
    
    /// Create a device with Tap to Pay disabled
    static func createTTPDisabledDevice(deviceId: String = "ttp-disabled-device") -> DeviceInfo {
        return createDeviceInfo(
            deviceId: deviceId,
            tapToPayStatus: "Inactive",
            tapToPayStatusId: 0,
            tapToPayEnabled: false
        )
    }
    
    /// Create a test DeviceUser
    static func createDeviceUser(
        id: String? = "test-user-id",
        firstName: String? = "Test",
        lastName: String? = "User",
        email: String? = "test@example.com"
    ) -> DeviceUser {
        return DeviceUser(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email
        )
    }
    
    /// Create DevicesResponse with multiple devices
    static func createDevicesResponse(
        devices: [DeviceInfo] = [createTTPEnabledDevice(), createTTPDisabledDevice()]
    ) -> DevicesResponse {
        return DevicesResponse(devices: devices)
    }
}

