import Foundation

/// Level 2 transaction data.
///
/// Level 2 data provides enhanced transaction information for commercial card processing,
/// typically including tax information.
public struct L2Data {
    /// Sales tax rate.
    ///
    /// Decimal Number. Max length=4. Allowed characters: 0-9 .(dot)
    /// Allowed range: 0.01 - 100
    public let salesTaxRate: Double?
    
    /// Creates a new `L2Data`.
    ///
    /// - Parameter salesTaxRate: Sales tax rate (0.01 - 100)
    public init(salesTaxRate: Double? = nil) {
        self.salesTaxRate = salesTaxRate
    }
}
