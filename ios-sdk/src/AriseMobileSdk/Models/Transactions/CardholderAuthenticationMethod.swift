import Foundation

/// Cardholder authentication method used during transaction processing.
///
public enum CardholderAuthenticationMethod: Int, Equatable, CaseIterable {
    /// No authentication was performed.
    case notAuthenticated = 0
    /// Cardholder entered a PIN.
    case pin = 1
    /// Electronic signature analysis was used.
    case electronicSignatureAnalysis = 2
    /// Manual signature verification was performed.
    case manualSignature = 3
    /// Manual authentication (other).
    case manualOther = 4
    /// Authentication method unknown.
    case unknown = 5
    /// Systematic authentication method (other).
    case systematicOther = 6
    /// Electronic ticketing environment (Amex).
    case eTicketEnvAmex = 7
    /// Offline PIN verification.
    case offlinePin = 8
}
