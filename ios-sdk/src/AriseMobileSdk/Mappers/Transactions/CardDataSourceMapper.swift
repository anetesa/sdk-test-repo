import Foundation

struct CardDataSourceMapper {
    
    /// Map SDK's CardDataSource to OpenAPI generated format
    /// - Parameter cardDataSource: SDK's card data source enum
    /// - Returns: Generated API enum format
    static func toGeneratedInput(_ cardDataSource: CardDataSource) -> Components.Schemas.PaymentGateway_Contracts_Enums_CardDataSource {
        switch cardDataSource {
        case .internet:
            return ._1
        case .swipe:
            return ._2
        case .nfc:
            return ._3
        case .emv:
            return ._4
        case .emvContactless:
            return ._5
        case .fallbackSwipe:
            return ._6
        case .manual:
            return ._7
        }
    }
    
    /// Map card data source enum
    public static func toModel(_ source: Components.Schemas.PaymentGateway_Contracts_Enums_CardDataSource?) -> CardDataSource? {
        guard let source = source else { return nil }
        return CardDataSource(rawValue: Int(source.rawValue))
    }
}

