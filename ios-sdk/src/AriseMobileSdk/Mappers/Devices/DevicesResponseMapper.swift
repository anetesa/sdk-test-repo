import Foundation

struct DevicesResponseMapper {
    static func toModel(_ generated: Operations.GetPayApiV1Devices.Output) throws -> DevicesResponse {
        let okResponse = try generated.ok
        let getDevicesResponse = try okResponse.body.json
        
        let devices = try (getDevicesResponse.devices ?? []).map { try DeviceMapper.toModel($0) }

        return DevicesResponse(
            devices: devices
        )
    }
}


