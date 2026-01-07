import Foundation

/// Represents a product in a Level 3 transaction.
///
/// Level 3 data includes detailed line-item information for commercial card transactions.
public struct TransactionProduct {
    /// The name of the product.
    ///
    /// Alphanumeric and Special Characters. Min Length=1, max length=50.
    /// Allowed special characters: Space, Slash /, Hyphen -, Comma
    public let name: String?
    
    /// The merchant's assigned unique product identification code.
    ///
    /// Alphanumeric and Special Characters. Min length=1, max length=20.
    /// Allowed special characters: Space, Slash /
    public let code: String?
    
    /// The product amount.
    ///
    /// Numeric. Max length=12. Allowed characters: 0-9 .(dot)
    public let unitPrice: Double?
    
    /// The unit of measurement for the product.
    ///
    /// Alphanumeric and special character Space. Max length=20
    public let measurementUnit: String?
    
    /// The quantity of a product.
    ///
    /// Decimal number. Max length=12
    public let quantity: Double?
    
    /// The tax amount established on a product.
    ///
    /// Numeric. Max length=12. Allowed characters: 0-9 .(dot)
    public let taxAmount: Double?
    
    /// The discount percentage applied to a product.
    ///
    /// Corresponds with productDiscountName. This does not impact transaction functionality.
    /// It is used for reporting purposes. Numeric. Max Length=4. Allowed range: 0.01 to 100
    public let discountRate: Double?
    
    /// The description of the product.
    ///
    /// Alphanumeric and Special Characters. Min length=1, max length=200.
    public let description: String?
    
    /// Measurement unit identifier.
    public let measurementUnitId: Int32?
    
    /// Creates a new `TransactionProduct`.
    ///
    /// - Parameters:
    ///   - name: The name of the product
    ///   - code: The merchant's assigned unique product identification code
    ///   - unitPrice: The product amount
    ///   - measurementUnit: The unit of measurement for the product
    ///   - quantity: The quantity of a product
    ///   - taxAmount: The tax amount established on a product
    ///   - discountRate: The discount percentage applied to a product
    ///   - description: The description of the product
    ///   - measurementUnitId: Measurement unit identifier
    public init(
        name: String? = nil,
        code: String? = nil,
        unitPrice: Double? = nil,
        measurementUnit: String? = nil,
        quantity: Double? = nil,
        taxAmount: Double? = nil,
        discountRate: Double? = nil,
        description: String? = nil,
        measurementUnitId: Int32? = nil
    ) {
        self.name = name
        self.code = code
        self.unitPrice = unitPrice
        self.measurementUnit = measurementUnit
        self.quantity = quantity
        self.taxAmount = taxAmount
        self.discountRate = discountRate
        self.description = description
        self.measurementUnitId = measurementUnitId
    }
}
