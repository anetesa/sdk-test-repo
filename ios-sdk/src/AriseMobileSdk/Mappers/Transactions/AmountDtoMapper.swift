import Foundation

struct AmountDtoMapper {
    
    /// Map amount DTO from OpenAPI format to SDK format
    public static func toModel(_ amount: Components.Schemas.PaymentGateway_Contracts_Amounts_AmountDto?) -> AmountDto {
        return AmountDto(
            baseAmount: amount?.baseAmount ?? 0.0,
            percentageOffAmount: amount?.percentageOffAmount ?? 0.0,
            percentageOffRate: amount?.percentageOffRate ?? 0.0,
            cashDiscountAmount: amount?.cashDiscountAmount ?? 0.0,
            cashDiscountRate: amount?.cashDiscountRate ?? 0.0,
            surchargeAmount: amount?.surchargeAmount ?? 0.0,
            surchargeRate: amount?.surchargeRate ?? 0.0,
            tipAmount: amount?.tipAmount ?? 0.0,
            tipRate: amount?.tipRate ?? 0.0,
            taxAmount: amount?.taxAmount ?? 0.0,
            taxRate: amount?.taxRate ?? 0.0,
            totalAmount: amount?.totalAmount ?? 0.0
        )
    }
    
}
