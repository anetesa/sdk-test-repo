import Foundation

/// Aggregated response containing merchant devices.
public struct DevicesResponse: Sendable {
    /// Flattened list of devices.
    public let devices: [DeviceInfo]

    public init(devices: [DeviceInfo]) {
        self.devices = devices
    }
}

