import Foundation

/// Transaction source information
/// 
/// Information about the source of the transaction (e.g., POS terminal, online, mobile).
/// 
public struct SourceResponseDto {
    /// Source type identifier
    /// 
    /// Numeric identifier for the source type
    /// 
    public let typeId: Int?
    
    /// Source type name
    /// 
    /// Human-readable source type name
    /// 
    public let type: String?
    
    /// Source identifier
    /// 
    /// Unique identifier for the source
    /// 
    public let id: String?
    
    /// Source name
    /// 
    /// Human-readable source name
    /// 
    public let name: String
}
