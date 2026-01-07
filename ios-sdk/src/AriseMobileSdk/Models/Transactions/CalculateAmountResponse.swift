import Foundation

/// Result of pre-calculating a transaction amount under the merchant's current pricing rules.
public struct CalculateAmountResponse {
    /// Numeric currency identifier (e.g. `1` for USD).
    public let currencyId: Int32?

    /// Human-readable currency code (e.g. `USD`).
    public let currency: String?

    /// Identifier of the active Zero Cost Processing option (see PaymentGateway enums).
    public let zeroCostProcessingOptionId: Int32?

    /// Readable name of the active Zero Cost Processing option.
    public let zeroCostProcessingOption: String?

    /// Indicates whether card pricing was applied during calculation.
    public let useCardPrice: Bool?

    /// Breakdown for cash payments, if available.
    public let cash: AmountDto?

    /// Breakdown for credit card payments, if available.
    public let creditCard: AmountDto?

    /// Breakdown for debit card payments, if available.
    public let debitCard: AmountDto?

    /// Breakdown for ACH payments, if available.
    public let ach: AmountDto?

    public init(
        currencyId: Int32?,
        currency: String?,
        zeroCostProcessingOptionId: Int32?,
        zeroCostProcessingOption: String?,
        useCardPrice: Bool?,
        cash: AmountDto?,
        creditCard: AmountDto?,
        debitCard: AmountDto?,
        ach: AmountDto?
    ) {
        self.currencyId = currencyId
        self.currency = currency
        self.zeroCostProcessingOptionId = zeroCostProcessingOptionId
        self.zeroCostProcessingOption = zeroCostProcessingOption
        self.useCardPrice = useCardPrice
        self.cash = cash
        self.creditCard = creditCard
        self.debitCard = debitCard
        self.ach = ach
    }
}


