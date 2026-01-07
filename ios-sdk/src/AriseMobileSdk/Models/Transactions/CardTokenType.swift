import Foundation

/// Card token type enumeration
/// 
/// Indicates whether the card is stored locally or on the network.
/// 
public enum CardTokenType: Int {
    /// Card stored locally in merchant's system
    case local = 1
    
    /// Card stored on payment network (tokenized)
    case network = 2
}
