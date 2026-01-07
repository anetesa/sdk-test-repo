import Foundation

/// Payment configuration settings for the merchant organization.
///
/// Contains operational settings including currencies, Zero Cost Processing (ZCP) configuration,
/// receipt preferences, and default rates/thresholds.
public struct PaymentSettingsResponse {
    // MARK: - Currency Settings
    
    /// Available currencies for transactions.
    ///
    /// List of currency options configured for the merchant.
    public let availableCurrencies: [NamedOption]
    
    // MARK: - Zero Cost Processing (ZCP) Configuration
    
    /// Zero Cost Processing option identifier.
    ///
    /// Values:
    /// - `1` = None
    /// - `2` = CashDiscount
    /// - `3` = DualPricing
    /// - `4` = Surcharge
    public let zeroCostProcessingOptionId: Int32?
    
    /// Zero Cost Processing option name.
    ///
    /// Human-readable name of the active ZCP option.
    public let zeroCostProcessingOption: String?
    
    // MARK: - Default Rates and Thresholds
    
    /// Default surcharge rate (as a percentage).
    ///
    /// Applied when Zero Cost Processing is set to Surcharge mode.
    public let defaultSurchargeRate: Double?
    
    /// Default cash discount rate (as a percentage).
    ///
    /// Applied when Zero Cost Processing is set to CashDiscount mode.
    public let defaultCashDiscountRate: Double?
    
    /// Default dual pricing rate (as a percentage).
    ///
    /// Applied when Zero Cost Processing is set to DualPricing mode.
    public let defaultDualPricingRate: Double?
    
    // MARK: - Tips Configuration
    
    /// Whether tips are enabled for transactions.
    public let isTipsEnabled: Bool
    
    /// Default tip options (as percentages).
    ///
    /// Pre-configured tip percentages available for quick selection.
    public let defaultTipsOptions: [Double]?
    
    // MARK: - Card Types and Transaction Types
    
    /// Available card types supported by the merchant.
    public let availableCardTypes: [NamedOption]
    
    /// Available transaction types supported by the merchant.
    public let availableTransactionTypes: [NamedOption]
    
    // MARK: - Payment Processors
    
    /// Available payment processors configured for the merchant.
    public let availablePaymentProcessors: [PaymentProcessor]
    
    // MARK: - Address Verification System (AVS)
    
    /// AVS configuration and settings.
    public let avs: AvsOptions?
    
    // MARK: - Receipt Preferences
    
    /// Whether the terminal can save customer's card after transaction processing.
    ///
    /// When enabled, allows storing card information for future transactions.
    public let isCustomerCardSavingByTerminalEnabled: Bool
    
    /// Merchant company name.
    public let companyName: String?
    
    /// Merchant category code (MCC) .
    public let mccCode: String?
        
    /// Default currency code.
    public let currencyCode: String?
    
    /// Default currency identifier.
    ///
    /// Numeric currency identifier (e.g., `1` for USD).
    public let currencyId: Int32?
    
    /// Country code..
    public let countryCode: String?
    
    public init(
        availableCurrencies: [NamedOption],
        zeroCostProcessingOptionId: Int32?,
        zeroCostProcessingOption: String?,
        defaultSurchargeRate: Double?,
        defaultCashDiscountRate: Double?,
        defaultDualPricingRate: Double?,
        isTipsEnabled: Bool,
        defaultTipsOptions: [Double]?,
        availableCardTypes: [NamedOption],
        availableTransactionTypes: [NamedOption],
        availablePaymentProcessors: [PaymentProcessor],
        avs: AvsOptions?,
        isCustomerCardSavingByTerminalEnabled: Bool,
        companyName: String? = nil,
        mccCode: String? = nil,
        currencyCode: String? = nil,
        currencyId: Int32? = nil,
        countryCode: String? = nil
    ) {
        self.availableCurrencies = availableCurrencies
        self.zeroCostProcessingOptionId = zeroCostProcessingOptionId
        self.zeroCostProcessingOption = zeroCostProcessingOption
        self.defaultSurchargeRate = defaultSurchargeRate
        self.defaultCashDiscountRate = defaultCashDiscountRate
        self.defaultDualPricingRate = defaultDualPricingRate
        self.isTipsEnabled = isTipsEnabled
        self.defaultTipsOptions = defaultTipsOptions
        self.availableCardTypes = availableCardTypes
        self.availableTransactionTypes = availableTransactionTypes
        self.availablePaymentProcessors = availablePaymentProcessors
        self.avs = avs
        self.isCustomerCardSavingByTerminalEnabled = isCustomerCardSavingByTerminalEnabled
        self.companyName = companyName
        self.mccCode = mccCode
        self.currencyCode = currencyCode
        self.currencyId = currencyId
        self.countryCode = countryCode
    }
}
