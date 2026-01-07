import Foundation

/// EMV fallback last chip read enumeration
///
/// Indicates the last successful chip read before fallback.
///
public enum EMVFallbackLastChipRead: Int, Equatable {
    /// Successful
    ///
    case successful = 0
    
    /// Failed
    ///
    case failed = 1
    
    /// Not A Chip Transaction
    ///
    case notAChipTransaction = 2
    
    /// Unknown
    ///
    case unknown = 3
}

