import Foundation

/// TSYS-specific card details returned by the ARISE API.
///
/// Provides identifiers that TSYS includes in transaction responses.
public struct TsysCardDetailsDto: Equatable {
    /// Authorization code returned by TSYS.
    public let authCode: String?

    /// Merchant identifier assigned by TSYS (MID).
    public let mid: String?

    /// Terminal identifier assigned by TSYS (TID).
    public let tid: String?

    public init(
        authCode: String? = nil,
        mid: String? = nil,
        tid: String? = nil
    ) {
        self.authCode = authCode
        self.mid = mid
        self.tid = tid
    }
}
