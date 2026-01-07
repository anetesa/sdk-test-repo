import Foundation

struct EMVFallbackConditionMapper {
    
    /// Map SDK's EMVFallbackCondition to OpenAPI generated format
    /// - Parameter condition: SDK's EMV fallback condition enum
    /// - Returns: Generated API enum format
    static func toGeneratedInput(_ condition: EMVFallbackCondition?) -> Components.Schemas.PaymentGateway_Contracts_Enums_EMVFallbackCondition? {
        guard let condition = condition else { return nil }
        
        switch condition {
        case .iccTerminalError:
            return ._0
        case .noCandidateList:
            return ._1
        }
    }
}

