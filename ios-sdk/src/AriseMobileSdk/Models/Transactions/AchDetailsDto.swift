import Foundation

/// ACH transaction details returned by the ARISE API.
///
/// Mirrors the ACH-specific payload described in the OpenAPI schema.
public struct AchDetailsDto: Equatable {
    /// Account number used for the ACH transaction.
    ///
    public let customerAccountNumber: String?

    /// Routing number associated with the account.
    ///
    public let customerRoutingNumber: String?

    /// Human-readable account holder type (e.g., Business, Personal).
    ///
    public let accountHolderType: String?

    /// Numeric account holder type identifier.
    ///
    public let accountHolderTypeId: Int32?

    /// Human-readable account type (e.g., Checking, Savings).
    ///
    public let accountType: String?

    /// Numeric account type identifier.
    public let accountTypeId: Int32?

    /// Tax identifier associated with the account.
    public let taxId: String?

    public init(
        customerAccountNumber: String? = nil,
        customerRoutingNumber: String? = nil,
        accountHolderType: String? = nil,
        accountHolderTypeId: Int32? = nil,
        accountType: String? = nil,
        accountTypeId: Int32? = nil,
        taxId: String? = nil
    ) {
        self.customerAccountNumber = customerAccountNumber
        self.customerRoutingNumber = customerRoutingNumber
        self.accountHolderType = accountHolderType
        self.accountHolderTypeId = accountHolderTypeId
        self.accountType = accountType
        self.accountTypeId = accountTypeId
        self.taxId = taxId
    }
}
