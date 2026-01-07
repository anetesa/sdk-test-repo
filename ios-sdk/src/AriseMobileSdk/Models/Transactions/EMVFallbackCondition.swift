import Foundation

/// EMV fallback condition enumeration
///
/// Indicates the condition that caused EMV fallback to magnetic stripe.
///
public enum EMVFallbackCondition: Int, Equatable {
    /// ICC Terminal Error
    ///
    case iccTerminalError = 0
    
    /// No Candidate List
    ///
    case noCandidateList = 1
}

