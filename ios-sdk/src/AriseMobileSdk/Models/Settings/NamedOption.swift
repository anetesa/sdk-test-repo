import Foundation

/// Named option with identifier and name.
///
/// Generic structure for representing enumerated options with an identifier and optional name.
/// Used for currencies, card types, transaction types, and other enumerated options.
///
/// - Note: Conforms to `Identifiable` for SwiftUI compatibility.
public struct NamedOption: Identifiable {
    /// Numeric identifier.
    public let id: Int32
    
    /// Option  name.
    public let name: String?
    
    public init(id: Int32, name: String?) {
        self.id = id
        self.name = name
    }
}

