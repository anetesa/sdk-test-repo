import Foundation

/// Transaction status for Tap to Pay transactions.
public enum TTPTransactionStatus: String {
    /// Transaction was approved by the payment processor.
    case approved
    
    /// Transaction was declined by the payment processor.
    case declined
    
    /// Transaction was cancelled by the user or system.
    case cancelled
    
    /// Transaction failed due to an error.
    case failed
}
