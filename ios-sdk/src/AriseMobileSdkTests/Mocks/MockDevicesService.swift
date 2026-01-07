import Foundation
@testable import AriseMobile

/// Mock implementation of DevicesServiceProtocol for testing
final class MockDevicesService: DevicesServiceProtocol {
    // MARK: - Configuration
    
    var getDevicesResult: Result<DevicesResponse, Error> = .success(
        DevicesResponse(devices: [])
    )
    
    var deviceInfoResult: Result<DeviceInfo, Error> = .success(DeviceInfo(
        deviceId: "mock-device-id",
        deviceName: "Mock Device",
        lastLoginAt: Date(),
        tapToPayStatus: "Active",
        tapToPayStatusId: 1,
        tapToPayEnabled: true,
        userProfiles: []
    ))
    
    var ttpJwtResult: Result<(token: String, expiresAt: Date), Error> = .success((
        token: "mock-ttp-jwt-token",
        expiresAt: Date().addingTimeInterval(3600)
    ))
    
    var activateTapToPayResult: Result<Void, Error> = .success(())
    
    // MARK: - Call Tracking
    
    private(set) var getDevicesCallCount = 0
    private(set) var getDeviceInfoCallCount = 0
    private(set) var getTapToPayJwtCallCount = 0
    private(set) var activateTapToPayCallCount = 0
    
    private(set) var lastGetDeviceInfoDeviceId: String?
    private(set) var lastGetTapToPayJwtDeviceId: String?
    private(set) var lastActivateTapToPayDeviceId: String?
    
    // MARK: - Initialization
    
    init() {
        // Mock doesn't need initialization - all methods are mocked
    }
    
    // MARK: - DevicesServiceProtocol Implementation
    
    func getDevices() async throws -> DevicesResponse {
        getDevicesCallCount += 1
        
        switch getDevicesResult {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
    
    func getDeviceInfo(deviceId: String) async throws -> DeviceInfo {
        getDeviceInfoCallCount += 1
        lastGetDeviceInfoDeviceId = deviceId
        
        switch deviceInfoResult {
        case .success(let deviceInfo):
            return deviceInfo
        case .failure(let error):
            throw error
        }
    }
    
    func getTapToPayJwt(deviceId: String) async throws -> (token: String, expiresAt: Date) {
        getTapToPayJwtCallCount += 1
        lastGetTapToPayJwtDeviceId = deviceId
        
        switch ttpJwtResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
    
    func activateTapToPay(deviceId: String) async throws {
        activateTapToPayCallCount += 1
        lastActivateTapToPayDeviceId = deviceId
        
        switch activateTapToPayResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
    
    // MARK: - Reset
    
    func reset() {
        getDevicesCallCount = 0
        getDeviceInfoCallCount = 0
        getTapToPayJwtCallCount = 0
        activateTapToPayCallCount = 0
        lastGetDeviceInfoDeviceId = nil
        lastGetTapToPayJwtDeviceId = nil
        lastActivateTapToPayDeviceId = nil
    }
}

