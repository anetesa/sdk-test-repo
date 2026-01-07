import Foundation

/// Suggested tip information
/// 
/// Represents a suggested tip amount and percentage.
/// 
public struct SuggestedTipsDto {
    /// Tip percentage
    /// 
    /// Suggested tip percentage (e.g., 15.0 for 15%)
    /// 
    public let tipPercent: Double
    
    /// Tip amount
    /// 
    /// Suggested tip amount in currency
    /// 
    public let tipAmount: Double
}
