import Foundation

internal struct AvsOptionsMapper {
    static func toModel(_ dto: Components.Schemas.PaymentGateway_Contracts_Configurations_Payments_GetPaymentConfigurationsResponseDto_AvsOptions) -> AvsOptions {
        return AvsOptions(
            isEnabled: dto.isEnabled,
            profileId: dto.profileId,
            profile: dto.profile
        )
    }
}

