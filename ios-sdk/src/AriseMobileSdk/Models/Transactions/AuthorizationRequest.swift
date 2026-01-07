import Foundation

/// Input parameters for submitting an authorization transaction
///
/// Represents the required and optional parameters for authorizing a payment without immediate capture.
///
public struct AuthorizationRequest {
    
    // MARK: - Required Fields
    
    /// Payment processor identifier
    ///
    /// Unique identifier of the payment processor to use for this transaction.
    /// This is required to identify which payment gateway/processor should handle the transaction.
    ///
    public let paymentProcessorId: String
    
    /// Transaction amount
    ///
    /// The amount of the transaction in the specified currency.
    /// Must be greater than 0.
    ///
    /// - Validation: Must be > 0
    public let amount: Double
    
    /// Currency identifier
    ///
    /// Numeric currency code (ISO 4217).
    /// Example: 1 = USD, 2 = EUR, etc.
    ///
    public let currencyId: Int32
    
    /// Card data source
    ///
    /// Indicates how the card data was obtained (e.g., Manual Entry, Swipe, Chip, Contactless).
    /// This is required to determine the appropriate processing method.
    ///
    /// - SeeAlso: `CardDataSource` enum for available values
    public let cardDataSource: CardDataSource
    
    // MARK: - Payment Method (Card Details or Token)
    
    /// Customer payment method ID
    ///
    /// Unique identifier of a stored payment method (token).
    /// Use this when processing a transaction with a previously stored card.
    /// Either `paymentMethodId` or card details (`accountNumber` with `expirationMonth`/`expirationYear`) must be provided.
    ///
    /// - Note: If provided, card details (accountNumber, expirationMonth, expirationYear) are not required
    public let paymentMethodId: String?
    
    /// Account number (card number)
    ///
    /// The 13-19 digit card number used for the transaction.
    /// This field may contain a token issued against a card number. This is de-tokenized by TransIT to process the transaction.
    /// Either `paymentMethodId` or `accountNumber` with expiration must be provided.
    ///
    /// - Note: Required if `paymentMethodId` is not provided
    public let accountNumber: String?
    
    /// Security code (CVV/CVC)
    ///
    /// The three or four digit security code on the credit card.
    /// Required for card-not-present transactions when using `accountNumber`.
    ///
    public let securityCode: String?
    
    /// Expiration month
    ///
    /// The expiration month of the card (1-12).
    /// Required when using `accountNumber`.
    ///
    public let expirationMonth: Int32?
    
    /// Expiration year
    ///
    /// The expiration year of the card (2-digit or 4-digit format).
    /// Required when using `accountNumber`.
    ///
    public let expirationYear: Int32?
    
    // MARK: - Track Data (for Swipe/Contactless)
    
    /// Track 1 data
    ///
    /// The card data from track 1 of the magnetic stripe.
    /// Used for swipe transactions. Format: `%B[PAN]^[NAME]^[YYMM][SERVICE]?`
    ///
    public let track1: String?
    
    /// Track 2 data
    ///
    /// Information stored on the magnetic stripe of a credit or debit card, including the card number, expiration date, and cardholder's name.
    /// Used for swipe or contactless transactions. Format: `[PAN]=[YYMM][SERVICE]`
    ///
    public let track2: String?
    
    // MARK: - EMV Data (for Chip/Contactless)
    
    /// EMV tags
    ///
    /// Array of EMV (Europay, Mastercard, Visa) tag data from chip card transactions.
    /// Each tag corresponds to a particular piece of data stored on the card.
    ///
    public let emvTags: [String]?
    
    /// EMV payment application version
    ///
    /// The version number of the payment application in use.
    ///
    public let emvPaymentAppVersion: String?
    
    // MARK: - Customer Information
    
    /// Customer identifier
    ///
    /// Unique identifier for the customer in the merchant's system.
    /// Optional but recommended for transaction tracking and reporting.
    ///
    public let customerId: String?
    
    // MARK: - Amount Modifiers
    
    /// Tip amount
    ///
    /// The amount of the tips in the transaction currency.
    /// If both `tipAmount` and `tipRate` are provided, `tipAmount` takes precedence.
    ///
    public let tipAmount: Double?
    
    /// Tip rate
    ///
    /// The rate of the tips as a percentage (e.g., 15.0 for 15%).
    /// If both `tipAmount` and `tipRate` are provided, `tipAmount` takes precedence.
    ///
    public let tipRate: Double?
    
    /// Percentage off rate
    ///
    /// The percent of Amount to be discounted (e.g., 5.0 for 5% discount).
    ///
    public let percentageOffRate: Double?
    
    /// Surcharge rate
    ///
    /// The percent of transaction amount to be added to Amount after PercentageOffRate is applied (e.g., 3.0 for 3% surcharge).
    ///
    public let surchargeRate: Double?
    
    /// Use card price flag
    ///
    /// Parameter is mandatory when merchant has ZeroCostProcessingOption == Dual Pricing.
    /// Parameter must be null when merchant has other ZeroCostProcessingOption.
    /// For Dual Pricing, amount should be the card price and useCardPrice should be "true", or amount should be the cash price and useCardPrice should be "false".
    ///
    public let useCardPrice: Bool?
    
    // MARK: - Address Information
    
    /// Billing address
    ///
    /// Billing address information for the transaction.
    /// Used for AVS (Address Verification System) validation.
    ///
    public let billingAddress: AddressDto?
    
    /// Shipping address
    ///
    /// Shipping address information for the transaction.
    ///
    public let shippingAddress: AddressDto?
    
    // MARK: - Contact Information
    
    /// Contact information
    ///
    /// Customer contact information including name, email, and phone number.
    ///
    public let contactInfo: ContactInfoDto?
    
    // MARK: - Additional Fields
    
    /// PIN
    ///
    /// Encrypted PIN data for debit card transactions.
    ///
    public let pin: String?
    
    /// PIN KSN (Key Serial Number)
    ///
    /// Key Serial Number associated with the encrypted PIN.
    ///
    public let pinKsn: String?
    
    /// EMV fallback condition
    ///
    /// Indicates the condition that caused EMV fallback to magnetic stripe.
    ///
    public let emvFallbackCondition: EMVFallbackCondition?
    
    /// EMV fallback last chip read
    ///
    /// Indicates the last successful chip read before fallback.
    ///
    public let emvFallbackLastChipRead: EMVFallbackLastChipRead?
    
    /// Reference ID
    ///
    /// Optional reference identifier for the transaction.
    ///
    public let referenceId: String?
    
    /// Customer initiated transaction flag
    ///
    /// Customer Initiated Transaction if true.
    /// Merchant Initiated Transaction if false.
    /// Default value: false.
    ///
    public let customerInitiatedTransaction: Bool?
    
    // MARK: - Level 2/3 Data
    
    /// Level 2 Data
    ///
    /// Provides enhanced transaction information for commercial card processing,
    /// typically including tax information.
    public let l2: L2Data?
    
    /// Level 3 Data
    ///
    /// Provides detailed line-item information for commercial card transactions,
    /// including invoice numbers, purchase orders, shipping charges, duty charges, and product details.
    public let l3: L3Data?
    
    // MARK: - Initialization
    
    /// Initialize authorization transaction input
    ///
    /// - Parameters:
    ///   - paymentProcessorId: Payment processor identifier (required)
    ///   - amount: Transaction amount (required, must be > 0)
    ///   - currencyId: Currency identifier (required)
    ///   - cardDataSource: Card data source (required)
    ///   - paymentMethodId: Stored payment method ID (optional, alternative to card details)
    ///   - accountNumber: Card number (optional, required if paymentMethodId is nil)
    ///   - securityCode: CVV/CVC (optional, recommended for card-not-present)
    ///   - expirationMonth: Expiration month 1-12 (optional, required if accountNumber is provided)
    ///   - expirationYear: Expiration year (optional, required if accountNumber is provided)
    ///   - track1: Track 1 data (optional, for swipe transactions)
    ///   - track2: Track 2 data (optional, for swipe/contactless transactions)
    ///   - emvTags: EMV tags array (optional, for chip/contactless transactions)
    ///   - emvPaymentAppVersion: EMV payment app version (optional)
    ///   - customerId: Customer identifier (optional)
    ///   - tipAmount: Tip amount (optional)
    ///   - tipRate: Tip rate percentage (optional)
    ///   - percentageOffRate: Discount percentage (optional)
    ///   - surchargeRate: Surcharge percentage (optional)
    ///   - useCardPrice: Use card price flag for dual pricing (optional)
    ///   - billingAddress: Billing address (optional)
    ///   - shippingAddress: Shipping address (optional)
    ///   - contactInfo: Contact information (optional)
    ///   - pin: Encrypted PIN (optional)
    ///   - pinKsn: PIN KSN (optional)
    ///   - emvFallbackCondition: EMV fallback condition (optional)
    ///   - emvFallbackLastChipRead: EMV fallback last chip read (optional)
    ///   - referenceId: Reference identifier (optional)
    ///   - customerInitiatedTransaction: Customer initiated flag (optional, default: false)
    /// - Throws: `AriseApiError.invalidFilters` if validation fails
    public init(
        paymentProcessorId: String,
        amount: Double,
        currencyId: Int32,
        cardDataSource: CardDataSource,
        paymentMethodId: String? = nil,
        accountNumber: String? = nil,
        securityCode: String? = nil,
        expirationMonth: Int32? = nil,
        expirationYear: Int32? = nil,
        track1: String? = nil,
        track2: String? = nil,
        emvTags: [String]? = nil,
        emvPaymentAppVersion: String? = nil,
        customerId: String? = nil,
        tipAmount: Double? = nil,
        tipRate: Double? = nil,
        percentageOffRate: Double? = nil,
        surchargeRate: Double? = nil,
        useCardPrice: Bool? = nil,
        billingAddress: AddressDto? = nil,
        shippingAddress: AddressDto? = nil,
        contactInfo: ContactInfoDto? = nil,
        pin: String? = nil,
        pinKsn: String? = nil,
        emvFallbackCondition: EMVFallbackCondition? = nil,
        emvFallbackLastChipRead: EMVFallbackLastChipRead? = nil,
        referenceId: String? = nil,
        customerInitiatedTransaction: Bool? = nil,
        l2: L2Data? = nil,
        l3: L3Data? = nil
    ) throws {
       
        self.paymentProcessorId = paymentProcessorId
        self.amount = amount
        self.currencyId = currencyId
        self.cardDataSource = cardDataSource
        self.paymentMethodId = paymentMethodId
        self.accountNumber = accountNumber
        self.securityCode = securityCode
        self.expirationMonth = expirationMonth
        self.expirationYear = expirationYear
        self.track1 = track1
        self.track2 = track2
        self.emvTags = emvTags
        self.emvPaymentAppVersion = emvPaymentAppVersion
        self.customerId = customerId
        self.tipAmount = tipAmount
        self.tipRate = tipRate
        self.percentageOffRate = percentageOffRate
        self.surchargeRate = surchargeRate
        self.useCardPrice = useCardPrice
        self.billingAddress = billingAddress
        self.shippingAddress = shippingAddress
        self.contactInfo = contactInfo
        self.pin = pin
        self.pinKsn = pinKsn
        self.emvFallbackCondition = emvFallbackCondition
        self.emvFallbackLastChipRead = emvFallbackLastChipRead
        self.referenceId = referenceId
        self.customerInitiatedTransaction = customerInitiatedTransaction
        self.l2 = l2
        self.l3 = l3
    }
}

