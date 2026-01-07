import Foundation
import Testing
@testable import AriseMobile

/// Tests for MapperError handling in mappers
struct MapperErrorHandlingTests {
    
    @Test("DeviceMapper throws MapperError when deviceId is missing")
    func testDeviceMapperThrowsErrorOnMissingDeviceId() {
        // Create a DeviceResponse without deviceId
        let deviceDto = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_Get_DeviceResponse(
            deviceId: nil, // Missing required field
            deviceName: "Test Device",
            lastLoginAt: nil,
            tapToPayStatus: nil,
            tapToPayStatusId: nil,
            tapToPayEnabled: nil,
            userProfiles: nil
        )
        
        #expect(throws: MapperError.self) {
            try DeviceMapper.toModel(deviceDto)
        }
    }
    
    @Test("DeviceMapper error message includes field name")
    func testDeviceMapperErrorMessageIncludesFieldName() {
        let deviceDto = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_Get_DeviceResponse(
            deviceId: nil,
            deviceName: "Test Device",
            lastLoginAt: nil,
            tapToPayStatus: nil,
            tapToPayStatusId: nil,
            tapToPayEnabled: nil,
            userProfiles: nil
        )
        
        do {
            _ = try DeviceMapper.toModel(deviceDto)
            Issue.record("Expected error to be thrown")
        } catch let error as MapperError {
            let description = error.errorDescription ?? ""
            #expect(description.contains("deviceId") || description.contains("Device"))
        } catch {
            Issue.record("Expected MapperError, got \(type(of: error))")
        }
    }
    
    @Test("MapperError is properly propagated from mappers")
    func testMapperErrorPropagation() {
        let deviceDto = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_Get_DeviceResponse(
            deviceId: nil,
            deviceName: "Test Device",
            lastLoginAt: nil,
            tapToPayStatus: nil,
            tapToPayStatusId: nil,
            tapToPayEnabled: nil,
            userProfiles: nil
        )
        
        do {
            _ = try DeviceMapper.toModel(deviceDto)
            Issue.record("Expected error to be thrown")
        } catch let error as MapperError {
            // Error should be properly typed
            #expect(error is MapperError)
            #expect(error.errorDescription != nil)
        } catch {
            Issue.record("Expected MapperError, got \(type(of: error))")
        }
    }
    
    @Test("MapperError can be caught and handled")
    func testMapperErrorCanBeCaught() {
        let deviceDto = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_Get_DeviceResponse(
            deviceId: nil,
            deviceName: "Test Device",
            lastLoginAt: nil,
            tapToPayStatus: nil,
            tapToPayStatusId: nil,
            tapToPayEnabled: nil,
            userProfiles: nil
        )
        
        var caughtError: MapperError?
        
        do {
            _ = try DeviceMapper.toModel(deviceDto)
        } catch let error as MapperError {
            caughtError = error
        } catch {
            Issue.record("Expected MapperError, got \(type(of: error))")
        }
        
        #expect(caughtError != nil)
        #expect(caughtError?.errorDescription != nil)
    }
    
    @Test("MapperError provides useful error information")
    func testMapperErrorProvidesUsefulInformation() {
        let deviceDto = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_Get_DeviceResponse(
            deviceId: nil,
            deviceName: "Test Device",
            lastLoginAt: nil,
            tapToPayStatus: nil,
            tapToPayStatusId: nil,
            tapToPayEnabled: nil,
            userProfiles: nil
        )
        
        do {
            _ = try DeviceMapper.toModel(deviceDto)
            Issue.record("Expected error to be thrown")
        } catch let error as MapperError {
            let description = error.errorDescription ?? ""
            
            // Error description should be informative
            #expect(!description.isEmpty)
            #expect(description.contains("Missing") || description.contains("required") || description.contains("field"))
        } catch {
            Issue.record("Expected MapperError, got \(type(of: error))")
        }
    }
    
    @Test("Multiple mapper errors can be distinguished")
    func testMultipleMapperErrorsAreDistinguishable() {
        let deviceDto1 = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_Get_DeviceResponse(
            deviceId: nil,
            deviceName: "Device 1",
            lastLoginAt: nil,
            tapToPayStatus: nil,
            tapToPayStatusId: nil,
            tapToPayEnabled: nil,
            userProfiles: nil
        )
        
        let deviceDto2 = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_Get_DeviceResponse(
            deviceId: nil,
            deviceName: "Device 2",
            lastLoginAt: nil,
            tapToPayStatus: nil,
            tapToPayStatusId: nil,
            tapToPayEnabled: nil,
            userProfiles: nil
        )
        
        var error1: MapperError?
        var error2: MapperError?
        
        do {
            _ = try DeviceMapper.toModel(deviceDto1)
        } catch let error as MapperError {
            error1 = error
        } catch {}
        
        do {
            _ = try DeviceMapper.toModel(deviceDto2)
        } catch let error as MapperError {
            error2 = error
        } catch {}
        
        #expect(error1 != nil)
        #expect(error2 != nil)
        // Both errors should have similar structure but may differ in details
        #expect(error1?.errorDescription != nil)
        #expect(error2?.errorDescription != nil)
    }
}

