import Foundation

/// Transaction type enumeration
/// 
/// Represents the type of transaction operation.
/// These values correspond to transaction types used in the ARISE API.
/// 
/// - Note: This enum is used for SDK convenience and maps to transaction type values in the API.
public enum TransactionType: String, CaseIterable {
    /// Sale transaction
    /// 
    /// Immediate payment transaction where funds are captured immediately
    case sale = "sale"
    
    /// Authorization transaction
    /// 
    /// Transaction that reserves funds but does not capture them immediately
    case auth = "auth"
    
    /// Capture transaction
    /// 
    /// Transaction that captures previously authorized funds
    case capture = "capture"
    
    /// Void transaction
    /// 
    /// Transaction that cancels a previous transaction before settlement
    case void = "void"
    
    /// Refund transaction
    /// 
    /// Transaction that returns funds to the customer after settlement
    case refund = "refund"
    
    /// Return transaction
    /// 
    /// Transaction that returns funds to the customer (alternative to refund)
    case return_ = "return"
    
    public var displayName: String {
        switch self {
        case .sale:
            return "Sale"
        case .auth:
            return "Authorization"
        case .capture:
            return "Capture"
        case .void:
            return "Void"
        case .refund:
            return "Refund"
        case .return_:
            return "Return"
        }
    }
}

