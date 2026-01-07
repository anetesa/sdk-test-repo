import Foundation

/// Amount information for a transaction
/// 
/// Contains all amount-related fields including base amount, surcharges, tips, discounts, and total amount.
/// 
/// - Important: All amounts are in the currency specified by parent `currencyCode`
/// - Warning: Percentages are stored as decimal values (e.g., 5% = 0.05)
public struct TransactionReceiptAmountDto {
    /// Base transaction amount before any fees, surcharges, or tips
    /// 
    /// This is the original transaction amount entered by the merchant
    /// 
    public let baseAmount: Double?
    
    /// Percentage off amount
    /// 
    /// Discount amount calculated from percentage off rate
    /// 
    public let percentageOffAmount: Double?
    
    /// Percentage off rate
    /// 
    /// Discount rate as decimal (e.g., 0.10 for 10%)
    /// 
    public let percentageOffRate: Double?
    
    /// Cash discount amount
    /// 
    /// Discount amount for cash payments
    /// 
    public let cashDiscountAmount: Double?
    
    /// Cash discount rate
    /// 
    /// Discount rate for cash payments as decimal (e.g., 0.05 for 5%)
    /// 
    public let cashDiscountRate: Double?
    
    /// Surcharge amount added to the base amount
    /// 
    /// Additional fee charged to the customer, typically calculated from surcharge rate
    /// 
    public let surchargeAmount: Double?
    
    /// Surcharge rate
    /// 
    /// Surcharge rate as decimal (e.g., 0.03 for 3%)
    /// 
    public let surchargeRate: Double?
    
    /// Tip amount
    /// 
    /// Gratuity amount added by the customer
    /// 
    public let tipAmount: Double?
    
    /// Tip rate
    /// 
    /// Tip rate as decimal (e.g., 0.15 for 15%)
    /// 
    public let tipRate: Double?
    
    /// Total transaction amount
    /// 
    /// Final amount including base amount, surcharges, tips, and discounts.
    /// This is the amount that will be charged to the customer.
    /// 
    /// - Important: This field is required and must be >= 0
    public let totalAmount: Double?
    
    public init(
        baseAmount: Double?,
        percentageOffAmount: Double?,
        percentageOffRate: Double?,
        cashDiscountAmount: Double?,
        cashDiscountRate: Double?,
        surchargeAmount: Double?,
        surchargeRate: Double?,
        tipAmount: Double?,
        tipRate: Double?,
        totalAmount: Double?
    ) {
        self.baseAmount = baseAmount
        self.percentageOffAmount = percentageOffAmount
        self.percentageOffRate = percentageOffRate
        self.cashDiscountAmount = cashDiscountAmount
        self.cashDiscountRate = cashDiscountRate
        self.surchargeAmount = surchargeAmount
        self.surchargeRate = surchargeRate
        self.tipAmount = tipAmount
        self.tipRate = tipRate
        self.totalAmount = totalAmount
    }
}
