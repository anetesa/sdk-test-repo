import Foundation

struct EMVFallbackLastChipReadMapper {
    
    /// Map SDK's EMVFallbackLastChipRead to OpenAPI generated format
    /// - Parameter lastChipRead: SDK's EMV fallback last chip read enum
    /// - Returns: Generated API enum format
    static func toGeneratedInput(_ lastChipRead: EMVFallbackLastChipRead?) -> Components.Schemas.PaymentGateway_Contracts_Enums_EMVFallbackLastChipRead? {
        guard let lastChipRead = lastChipRead else { return nil }
        
        switch lastChipRead {
        case .successful:
            return ._0
        case .failed:
            return ._1
        case .notAChipTransaction:
            return ._2
        case .unknown:
            return ._3
        }
    }
}

