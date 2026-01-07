/// Card processing details returned by the ARISE API.
///
/// Mirrors card-specific metadata provided in transaction receipts.
public struct CardDetailsDto: Equatable {
    /// Authorization code assigned by the host processor.
    public let authCode: String?

    /// Merchant identifier (MID) assigned to the merchant account.
    public let mid: String?

    /// Terminal identifier used to submit the transaction.
    public let tid: String?

    /// Numeric identifier describing whether the card is credit or debit.
    public let cardCreditDebitTypeId: Int32?

    /// Textual description for credit/debit classification.
    public let cardCreditDebitType: String?

    /// Numeric identifier describing whether the processing flow is credit or debit.
    public let processCreditDebitTypeId: Int32?

    /// Textual description for the processing credit/debit classification.
    public let processCreditDebitType: String?

    /// Retrieval reference number assigned to the transaction.
    public let rrn: String?

    /// Numeric identifier for the card brand/type.
    public let cardTypeId: Int32?

    /// Textual description of the card brand/type (e.g., Visa, MasterCard).
    public let cardType: String?

    public init(
        authCode: String? = nil,
        mid: String? = nil,
        tid: String? = nil,
        cardCreditDebitTypeId: Int32? = nil,
        cardCreditDebitType: String? = nil,
        processCreditDebitTypeId: Int32? = nil,
        processCreditDebitType: String? = nil,
        rrn: String? = nil,
        cardTypeId: Int32? = nil,
        cardType: String? = nil
    ) {
        self.authCode = authCode
        self.mid = mid
        self.tid = tid
        self.cardCreditDebitTypeId = cardCreditDebitTypeId
        self.cardCreditDebitType = cardCreditDebitType
        self.processCreditDebitTypeId = processCreditDebitTypeId
        self.processCreditDebitType = processCreditDebitType
        self.rrn = rrn
        self.cardTypeId = cardTypeId
        self.cardType = cardType
    }
}
