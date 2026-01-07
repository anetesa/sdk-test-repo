import Foundation

/// Cardholder Verification Method (CVM) data.
///
/// Represents CVM information from a Tap to Pay transaction.
/// This structure corresponds to CloudCommerce.CVMData.
public struct TTPCVMData: Codable, Equatable {
    /// CVM tag identifier.
    public let tag: String?
    
    /// CVM tag value.
    public let value: String?
    
    public init(
        tag: String? = nil,
        value: String? = nil
    ) {
        self.tag = tag
        self.value = value
    }
}
