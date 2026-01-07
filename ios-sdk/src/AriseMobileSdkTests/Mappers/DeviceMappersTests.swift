import Foundation
import Testing
@testable import AriseMobile

/// Tests for Device Mappers functionality
struct DeviceMappersTests {
    
    // MARK: - DeviceMapper Tests
    
    @Test("DeviceMapper converts generated response to model")
    func testDeviceMapperToModel() throws {
        let generatedResponse = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_Get_DeviceResponse(
            deviceId: "test-device-id",
            deviceName: "Test Device",
            lastLoginAt: Date(),
            tapToPayStatus: "active",
            tapToPayStatusId: 1,
            tapToPayEnabled: true,
            userProfiles: []
        )
        
        let result = try DeviceMapper.toModel(generatedResponse)
        
        #expect(result.deviceId == "test-device-id")
        #expect(result.deviceName == "Test Device")
        #expect(result.tapToPayStatus == "active")
        #expect(result.tapToPayStatusId == 1)
        #expect(result.tapToPayEnabled == true)
    }
    
    @Test("DeviceMapper throws error when deviceId is missing")
    func testDeviceMapperMissingDeviceId() {
        let generatedResponse = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_Get_DeviceResponse(
            deviceId: nil,
            deviceName: "Test Device",
            lastLoginAt: nil,
            tapToPayStatus: nil,
            tapToPayStatusId: nil,
            tapToPayEnabled: nil,
            userProfiles: nil
        )
        
        #expect(throws: MapperError.self) {
            try DeviceMapper.toModel(generatedResponse)
        }
    }
    
    @Test("DeviceMapper throws error when deviceId is empty")
    func testDeviceMapperEmptyDeviceId() {
        let generatedResponse = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_Get_DeviceResponse(
            deviceId: "",
            deviceName: "Test Device",
            lastLoginAt: nil,
            tapToPayStatus: nil,
            tapToPayStatusId: nil,
            tapToPayEnabled: nil,
            userProfiles: nil
        )
        
        #expect(throws: MapperError.self) {
            try DeviceMapper.toModel(generatedResponse)
        }
    }
    
    // MARK: - DevicesResponseMapper Tests
    
    @Test("DevicesResponseMapper converts generated output to model")
    func testDevicesResponseMapperToModel() throws {
        let deviceResponse1 = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_Get_DeviceResponse(
            deviceId: "device-1",
            deviceName: "Device 1",
            lastLoginAt: Date(),
            tapToPayStatus: "active",
            tapToPayStatusId: 1,
            tapToPayEnabled: true,
            userProfiles: []
        )
        
        let deviceResponse2 = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_Get_DeviceResponse(
            deviceId: "device-2",
            deviceName: "Device 2",
            lastLoginAt: nil,
            tapToPayStatus: "inactive",
            tapToPayStatusId: 0,
            tapToPayEnabled: false,
            userProfiles: nil
        )
        
        let getDevicesResponse = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_Get_GetDevicesResponse(
            devices: [deviceResponse1, deviceResponse2]
        )
        
        let okBody = Operations.GetPayApiV1Devices.Output.Ok.Body.json(getDevicesResponse)
        let okResponse = Operations.GetPayApiV1Devices.Output.Ok(body: okBody)
        let output = Operations.GetPayApiV1Devices.Output.ok(okResponse)
        
        let result = try DevicesResponseMapper.toModel(output)
        
        #expect(result.devices.count == 2)
        #expect(result.devices[0].deviceId == "device-1")
        #expect(result.devices[0].deviceName == "Device 1")
        #expect(result.devices[0].tapToPayStatus == "active")
        #expect(result.devices[0].tapToPayEnabled == true)
        #expect(result.devices[1].deviceId == "device-2")
        #expect(result.devices[1].deviceName == "Device 2")
        #expect(result.devices[1].tapToPayStatus == "inactive")
        #expect(result.devices[1].tapToPayEnabled == false)
    }
    
    @Test("DevicesResponseMapper converts empty devices list to model")
    func testDevicesResponseMapperEmptyDevices() throws {
        let getDevicesResponse = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_Get_GetDevicesResponse(
            devices: []
        )
        
        let okBody = Operations.GetPayApiV1Devices.Output.Ok.Body.json(getDevicesResponse)
        let okResponse = Operations.GetPayApiV1Devices.Output.Ok(body: okBody)
        let output = Operations.GetPayApiV1Devices.Output.ok(okResponse)
        
        let result = try DevicesResponseMapper.toModel(output)
        
        #expect(result.devices.count == 0)
    }
    
    // MARK: - DeviceUserMapper Tests
    
    @Test("DeviceUserMapper converts generated user to model")
    func testDeviceUserMapperToModel() {
        let generatedUser = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_Get_DeviceUserResponse(
            id: "test-user-id",
            firstName: "John",
            lastName: "Doe",
            email: "test@example.com"
        )
        
        let result = DeviceUserMapper.toModel(generatedUser)
        
        #expect(result.id == "test-user-id")
        #expect(result.firstName == "John")
        #expect(result.lastName == "Doe")
        #expect(result.email == "test@example.com")
    }
    
    // MARK: - Edge Cases and Additional Tests
    
    @Test("DeviceMapper handles nil optional fields")
    func testDeviceMapperWithNilFields() throws {
        let generatedResponse = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_Get_DeviceResponse(
            deviceId: "test-device-id",
            deviceName: nil,
            lastLoginAt: nil,
            tapToPayStatus: nil,
            tapToPayStatusId: nil,
            tapToPayEnabled: nil,
            userProfiles: nil
        )
        
        let result = try DeviceMapper.toModel(generatedResponse)
        
        #expect(result.deviceId == "test-device-id")
        #expect(result.deviceName == nil)
        #expect(result.lastLoginAt == nil)
        #expect(result.tapToPayStatus == nil)
        #expect(result.tapToPayStatusId == nil)
        #expect(result.tapToPayEnabled == false) // nil is converted to false by mapper
    }
    
    @Test("DeviceMapper handles user profiles")
    func testDeviceMapperWithUserProfiles() throws {
        let userProfile = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_Get_DeviceUserResponse(
            id: "user-1",
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com"
        )
        
        let generatedResponse = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_Get_DeviceResponse(
            deviceId: "test-device-id",
            deviceName: "Test Device",
            lastLoginAt: Date(),
            tapToPayStatus: "active",
            tapToPayStatusId: 1,
            tapToPayEnabled: true,
            userProfiles: [userProfile]
        )
        
        let result = try DeviceMapper.toModel(generatedResponse)
        
        #expect(result.userProfiles.count == 1)
        #expect(result.userProfiles.first?.id == "user-1")
        #expect(result.userProfiles.first?.firstName == "John")
    }
    
    @Test("DeviceMapper handles empty user profiles")
    func testDeviceMapperWithEmptyUserProfiles() throws {
        let generatedResponse = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_Get_DeviceResponse(
            deviceId: "test-device-id",
            deviceName: "Test Device",
            lastLoginAt: nil,
            tapToPayStatus: "active",
            tapToPayStatusId: 1,
            tapToPayEnabled: true,
            userProfiles: []
        )
        
        let result = try DeviceMapper.toModel(generatedResponse)
        
        #expect(result.userProfiles.count == 0)
    }
    
    @Test("DevicesResponseMapper handles devices with different statuses")
    func testDevicesResponseMapperDifferentStatuses() throws {
        let activeDevice = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_Get_DeviceResponse(
            deviceId: "device-active",
            deviceName: "Active Device",
            lastLoginAt: Date(),
            tapToPayStatus: "active",
            tapToPayStatusId: 1,
            tapToPayEnabled: true,
            userProfiles: []
        )
        
        let inactiveDevice = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_Get_DeviceResponse(
            deviceId: "device-inactive",
            deviceName: "Inactive Device",
            lastLoginAt: nil,
            tapToPayStatus: "inactive",
            tapToPayStatusId: 0,
            tapToPayEnabled: false,
            userProfiles: nil
        )
        
        let getDevicesResponse = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_Get_GetDevicesResponse(
            devices: [activeDevice, inactiveDevice]
        )
        
        let okBody = Operations.GetPayApiV1Devices.Output.Ok.Body.json(getDevicesResponse)
        let okResponse = Operations.GetPayApiV1Devices.Output.Ok(body: okBody)
        let output = Operations.GetPayApiV1Devices.Output.ok(okResponse)
        
        let result = try DevicesResponseMapper.toModel(output)
        
        #expect(result.devices.count == 2)
        #expect(result.devices[0].tapToPayStatus == "active")
        #expect(result.devices[0].tapToPayEnabled == true)
        #expect(result.devices[1].tapToPayStatus == "inactive")
        #expect(result.devices[1].tapToPayEnabled == false)
    }
    
    @Test("DeviceUserMapper handles nil optional fields")
    func testDeviceUserMapperWithNilFields() {
        let generatedUser = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_Get_DeviceUserResponse(
            id: "test-user-id",
            firstName: nil,
            lastName: nil,
            email: nil
        )
        
        let result = DeviceUserMapper.toModel(generatedUser)
        
        #expect(result.id == "test-user-id")
        #expect(result.firstName == nil)
        #expect(result.lastName == nil)
        #expect(result.email == nil)
    }
}

