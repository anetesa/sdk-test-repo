import Foundation

struct ContactInfoDtoMapper {
    
    /// Map SDK's ContactInfoDto to OpenAPI generated format
    /// - Parameter contactInfo: SDK's contact info DTO
    /// - Returns: Generated API request format
    static func toGeneratedInput(_ contactInfo: ContactInfoDto?) -> Components.Schemas.PaymentGateway_Contracts_Transactions_ContactInfoDto? {
        guard let contactInfo = contactInfo else { return nil }
        
        return Components.Schemas.PaymentGateway_Contracts_Transactions_ContactInfoDto(
            firstName: contactInfo.firstName,
            lastName: contactInfo.lastName,
            companyName: contactInfo.companyName,
            email: contactInfo.email,
            mobileNumber: contactInfo.mobileNumber,
            smsNotification: contactInfo.smsNotification
        )
    }
}

