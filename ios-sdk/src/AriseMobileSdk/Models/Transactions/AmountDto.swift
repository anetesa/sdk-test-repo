import Foundation

/// Amount information
/// 
/// Contains all amount-related fields including base amount, surcharges, tips, discounts, and total amount.
/// 
/// - Important: All amounts are in the currency specified by parent `currencyCode`
/// - Warning: Percentages are stored as decimal values (e.g., 5% = 0.05)
public struct AmountDto {
    /// Base transaction amount
    /// 
    public var baseAmount: Double
    
    /// Percentage off amount
    /// 
    public var percentageOffAmount: Double
    
    /// Percentage off rate
    /// 
    public var percentageOffRate: Double
    
    /// Cash discount amount
    /// 
    public var cashDiscountAmount: Double
    
    /// Cash discount rate
    /// 
    public var cashDiscountRate: Double
    
    /// Surcharge amount
    /// 
    public var surchargeAmount: Double
    
    /// Surcharge rate
    /// 
    public var surchargeRate: Double
    
    /// Tip amount
    /// 
    public var tipAmount: Double
    
    /// Tip rate
    /// 
    public var tipRate: Double
    
    /// Tax amount
    /// 
    public var taxAmount: Double
    
    /// Tax rate
    /// 
    public var taxRate: Double
    
    /// Total transaction amount
    /// 
    public var totalAmount: Double
    
    /// Public initializer for AmountDto
    public init(
        baseAmount: Double,
        percentageOffAmount: Double,
        percentageOffRate: Double,
        cashDiscountAmount: Double,
        cashDiscountRate: Double,
        surchargeAmount: Double,
        surchargeRate: Double,
        tipAmount: Double,
        tipRate: Double,
        taxAmount: Double,
        taxRate: Double,
        totalAmount: Double
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
        self.taxAmount = taxAmount
        self.taxRate = taxRate
        self.totalAmount = totalAmount
    }
}
