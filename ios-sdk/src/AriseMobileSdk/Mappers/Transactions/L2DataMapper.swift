import Foundation

internal struct L2DataMapper {
    /// Map SDK's L2Data to OpenAPI generated IsvL2Data
    static func toGeneratedInput(_ input: L2Data?) -> Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_IsvL2Data? {
        guard let input = input else { return nil }
        return Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_IsvL2Data(
            salesTaxRate: input.salesTaxRate
        )
    }
}
