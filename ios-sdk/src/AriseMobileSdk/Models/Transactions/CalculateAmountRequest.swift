import Foundation

/// Request parameters for calculating a transaction amount prior to submission.
///
/// Supply the base amount and any optional modifiers to obtain the final totals that will be
/// presented to the customer under the current Zero Cost Processing configuration.
public struct CalculateAmountRequest {
    /// Base transaction amount before any discounts or surcharges.
    public let amount: Double

    /// Percentage-off or discount rate (e.g. `5.0` for a 5% discount).
    public let percentageOffRate: Double?

    /// Surcharge rate to apply (e.g. `3.0` for a 3% surcharge).
    public let surchargeRate: Double?

    /// Absolute tip amount to add on top of the base amount.
    public let tipAmount: Double?

    /// Tip rate expressed as percentage (e.g. `10.0` for a 10% gratuity).
    public let tipRate: Double?

    /// Currency identifier (matches PaymentGateway currency identifiers such as `1` for USD).
    public let currencyId: Int32?

    /// Indicates whether the provided `amount` represents the card price (`true`) or cash price (`false`) in Dual Pricing mode.
    public let useCardPrice: Bool?

    public init(
        amount: Double,
        percentageOffRate: Double? = nil,
        surchargeRate: Double? = nil,
        tipAmount: Double? = nil,
        tipRate: Double? = nil,
        currencyId: Int32? = nil,
        useCardPrice: Bool? = nil
    ) {
        self.amount = amount
        self.percentageOffRate = percentageOffRate
        self.surchargeRate = surchargeRate
        self.tipAmount = tipAmount
        self.tipRate = tipRate
        self.currencyId = currencyId
        self.useCardPrice = useCardPrice
    }
}


