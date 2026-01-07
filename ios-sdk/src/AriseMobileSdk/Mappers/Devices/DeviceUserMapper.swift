import Foundation

struct DeviceUserMapper {
    static func toModel(
        _ profile: Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_Get_DeviceUserResponse
    ) -> DeviceUser {
        DeviceUser(
            id: profile.id,
            firstName: profile.firstName,
            lastName: profile.lastName,
            email: profile.email
        )
    }
}


