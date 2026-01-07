import Foundation

/// Level 3 transaction data.
///
/// Level 3 data provides detailed line-item information for commercial card transactions,
/// including invoice numbers, purchase orders, shipping charges, duty charges, and product details.
public struct L3Data {
    /// The Value Added Tax (VAT) invoice number associated with the transaction.
    ///
    /// Max length=15. Allowed characters: a-z A-Z 0-9 Space
    public let invoiceNumber: String?
    
    /// The value used by the customer to identify an order.
    ///
    /// Issued by the buyer to the seller. Max length=25. Allowed characters: a-z A-Z 0-9 Space
    public let purchaseOrder: String?
    
    /// The dollar amount for shipping or freight charges applied to a product or transaction.
    ///
    /// Numeric. Max length=12. Allowed characters: 0-9 .(dot)
    public let shippingCharges: Double?
    
    /// Indicates the total charges for any import or export duties included in the order.
    ///
    /// Numeric. Max length=12. Allowed characters: 0-9 .(dot)
    public let dutyCharges: Double?
    
    /// List of products in the transaction.
    ///
    /// You can send multiple products in a request.
    public let products: [TransactionProduct]?
    
    /// Creates a new `L3Data`.
    ///
    /// - Parameters:
    ///   - invoiceNumber: The Value Added Tax (VAT) invoice number
    ///   - purchaseOrder: The value used by the customer to identify an order
    ///   - shippingCharges: The dollar amount for shipping or freight charges
    ///   - dutyCharges: The total charges for any import or export duties
    ///   - products: List of products in the transaction
    public init(
        invoiceNumber: String? = nil,
        purchaseOrder: String? = nil,
        shippingCharges: Double? = nil,
        dutyCharges: Double? = nil,
        products: [TransactionProduct]? = nil
    ) {
        self.invoiceNumber = invoiceNumber
        self.purchaseOrder = purchaseOrder
        self.shippingCharges = shippingCharges
        self.dutyCharges = dutyCharges
        self.products = products
    }
}
