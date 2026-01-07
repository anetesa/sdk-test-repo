struct TransactionResponseDetailsDtoMapper {
    
    /// Map transaction response details DTO from OpenAPI format to SDK format
    static func toModel(_ details: Components.Schemas.PaymentGateway_Contracts_Transactions_TransactionResponseDetailsDto) -> TransactionResponseDetailsDto {
        return TransactionResponseDetailsDto(
            hostResponseCode: details.hostResponseCode,
            hostResponseMessage: details.hostResponseMessage,
            hostResponseDefinition: details.hostResponseDefinition,
            code: details.code,
            message: details.message,
            processorResponseCode: details.processorResponseCode,
            authCode: details.authCode,
            maskedPan: details.maskedPan
        )
    }
}
