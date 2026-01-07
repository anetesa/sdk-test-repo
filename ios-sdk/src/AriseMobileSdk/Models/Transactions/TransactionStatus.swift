import Foundation

/// Transaction status enumeration
/// 
/// Represents the current status of a transaction.
/// These values correspond to transaction status values in the ARISE API.
/// 
/// - Note: This enum is used for SDK convenience and maps to transaction status values in the API.
public enum TransactionStatus: String, CaseIterable {
    /// Transaction is pending
    /// 
    /// Transaction has been initiated but not yet processed
    case pending = "pending"
    
    /// Transaction is processing
    /// 
    /// Transaction is currently being processed by the payment processor
    case processing = "processing"
    
    /// Transaction is approved
    /// 
    /// Transaction has been approved by the payment processor
    case approved = "approved"
    
    /// Transaction is completed
    /// 
    /// Transaction has been successfully completed
    case completed = "completed"
    
    /// Transaction is settled
    /// 
    /// Transaction has been settled and funds have been transferred
    case settled = "settled"
    
    /// Transaction is declined
    /// 
    /// Transaction was declined by the payment processor
    case declined = "declined"
    
    /// Transaction failed
    /// 
    /// Transaction failed due to an error
    case failed = "failed"
    
    /// Transaction is rejected
    /// 
    /// Transaction was rejected (e.g., due to validation failure)
    case rejected = "rejected"
    
    /// Transaction is cancelled
    /// 
    /// Transaction was cancelled before completion
    case cancelled = "cancelled"
    
    /// Transaction is voided
    /// 
    /// Transaction was voided (cancelled after authorization but before settlement)
    case voided = "voided"
    
    public var displayName: String {
        switch self {
        case .pending:
            return "Pending"
        case .processing:
            return "Processing"
        case .approved:
            return "Approved"
        case .completed:
            return "Completed"
        case .settled:
            return "Settled"
        case .declined:
            return "Declined"
        case .failed:
            return "Failed"
        case .rejected:
            return "Rejected"
        case .cancelled:
            return "Cancelled"
        case .voided:
            return "Voided"
        }
    }
}

