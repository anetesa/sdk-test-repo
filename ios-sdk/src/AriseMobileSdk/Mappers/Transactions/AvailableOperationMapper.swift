import Foundation

struct AvailableOperationMapper{
    
    /// Map available operation from OpenAPI format to SDK format
    public static func toModel(_ operation: Components.Schemas.PaymentGateway_Contracts_Transactions_GetPage_GetTransactionPageResponseDto_AvailableOperation) -> AvailableOperation {
        return AvailableOperation(
            typeId: Int(operation.typeId ?? 0),
            type: operation._type,  // Note: _type in generated code (type is reserved in Swift)
            availableAmount: operation.availableAmount,
            suggestedTips: operation.suggestedTips?.map { tip in
                SuggestedTipsDto(tipPercent: tip.tipPercent ?? 0.0, tipAmount: tip.tipAmount ?? 0.0)
            }
        )
    }
}
