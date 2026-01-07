import Foundation

internal struct L3DataMapper {
    /// Map SDK's L3Data to OpenAPI generated IsvL3Data
    static func toGeneratedInput(_ input: L3Data?) -> Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_IsvL3Data? {
        guard let input = input else { return nil }
        
        let products = input.products?.map { TransactionProductMapper.toGeneratedInput($0) }
        
        return Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_IsvL3Data(
            invoiceNumber: input.invoiceNumber,
            purchaseOrder: input.purchaseOrder,
            shippingCharges: input.shippingCharges,
            dutyCharges: input.dutyCharges,
            products: products
        )
    }
}
