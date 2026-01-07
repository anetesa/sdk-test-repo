import Foundation

struct AddressDtoMapper {
    
    /// Map SDK's AddressDto to OpenAPI generated format
    /// - Parameter address: SDK's address DTO
    /// - Returns: Generated API request format
    static func toGeneratedInput(_ address: AddressDto?) -> Components.Schemas.PaymentGateway_Contracts_Transactions_AddressDto? {
        guard let address = address else { return nil }
        
        return Components.Schemas.PaymentGateway_Contracts_Transactions_AddressDto(
            city: address.city,
            countryId: address.countryId,
            line1: address.line1,
            line2: address.line2,
            postalCode: address.postalCode,
            stateName: address.stateName,
            stateId: address.stateId
        )
    }
}

