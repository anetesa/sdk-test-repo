import Foundation

/// Available operation information
/// 
/// Information about an operation that can be performed on a transaction.
/// 
public struct AvailableOperation {
    /// Operation type identifier
    /// 
    /// Numeric identifier for the operation type
    /// 
    public let typeId: Int
    
    /// Operation type name
    /// 
    /// Human-readable operation type name
    /// 
    public let type: String?
    
    /// Available amount for this operation
    /// 
    /// Maximum amount that can be processed for this operation
    /// 
    public let availableAmount: Double?
    
    /// Suggested tip amounts
    /// 
    /// List of suggested tip amounts and percentages
    /// 
    /// - SeeAlso: `SuggestedTipsDto` for structure details
    public let suggestedTips: Array<SuggestedTipsDto>?
}
