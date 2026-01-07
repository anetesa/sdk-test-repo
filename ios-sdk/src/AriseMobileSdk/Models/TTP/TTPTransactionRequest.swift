import Foundation

/// Request parameters for performing a Tap to Pay transaction.
///
/// This structure mirrors the parameters accepted by CloudCommerce SDK's performTransaction method.
public struct TTPTransactionRequest {
    /// Transaction amount.
    public let amount: Decimal
    
    /// Tip amount as string (optional).
    public let tip: String?
    
    /// Discount amount as string (optional).
    public let discount: String?
    
    /// Subtotal amount as string (optional).
    public let subTotal: String
    
    /// Order identifier (optional).
    public let orderId: String?
    
    /// Surcharge rate as string (optional).
    public let surchargeRate: String?
    
    public init(
        amount: Decimal,
        currencyCode: String,
        tip: String? = nil,
        discount: String? = nil,
        salesTaxAmount: String? = nil,
        federalTaxAmount: String? = nil,
        subTotal: String,
        orderId: String? = nil,
        surchargeRate: String? = nil
    ) {
        self.amount = amount
        self.tip = tip
        self.discount = discount
        self.subTotal = subTotal
        self.orderId = orderId
        self.surchargeRate = surchargeRate
    }
}

