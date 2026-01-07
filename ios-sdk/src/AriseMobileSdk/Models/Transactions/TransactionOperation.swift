/// Transaction operation information
///
/// Information about available operations that can be performed on a transaction.
///
public struct TransactionOperation {
    /// Operation type identifier
    ///
    /// Numeric identifier for the operation type (e.g., Void, Refund, Capture)
    ///
    public let typeId: Int?
    
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
    public let suggestedTips: [SuggestedTipsDto]?
    
    public init(
        typeId: Int?,
        type: String?,
        availableAmount: Double?,
        suggestedTips: [SuggestedTipsDto]?
    ) {
        self.typeId = typeId
        self.type = type
        self.availableAmount = availableAmount
        self.suggestedTips = suggestedTips
    }
}
