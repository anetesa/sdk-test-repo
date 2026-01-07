import Foundation

/// Protocol for DevicesService to enable dependency injection and testing
internal protocol DevicesServiceProtocol {
    func getDevices() async throws -> DevicesResponse
    func getDeviceInfo(deviceId: String) async throws -> DeviceInfo
    func getTapToPayJwt(deviceId: String) async throws -> (token: String, expiresAt: Date)
    func activateTapToPay(deviceId: String) async throws
}

