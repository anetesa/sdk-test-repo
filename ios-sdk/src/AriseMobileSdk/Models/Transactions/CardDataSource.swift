import Foundation

/// Card data source used when capturing payment details.
///
public enum CardDataSource: Int, Equatable, CaseIterable {
    /// Virtual terminal or ISV API (card-not-present).
    case internet = 1
    /// Swiped magnetic stripe data (track 1 or track 2).
    case swipe = 2
    /// Near-field communication (contactless).
    case nfc = 3
    /// EMV chip transaction.
    case emv = 4
    /// EMV contactless transaction.
    case emvContactless = 5
    /// Fallback swipe after EMV failure.
    case fallbackSwipe = 6
    /// Manual card entry (card-present keyed transaction).
    case manual = 7
}
