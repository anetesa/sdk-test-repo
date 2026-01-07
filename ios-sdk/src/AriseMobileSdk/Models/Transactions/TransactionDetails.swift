import Foundation

/// Detailed transaction information
/// 
/// Represents complete transaction details from the ARISE API.
/// 
public struct TransactionDetails {
    // MARK: - Basic Transaction Information
    
    /// Unique transaction identifier
    /// 
    public let transactionId: String?
    
    /// Date and time when the transaction occurred
    /// 
    /// Format: ISO 8601 date-time
    /// 
    public let transactionDateTime: Date?
    
    /// Merchant order number
    /// 
    /// Optional order identifier provided by the merchant
    /// 
    public let orderNumber: String?
    
    // MARK: - Amount Information
    
    /// Complete amount information including base amount, surcharges, tips, discounts, and total amount
    /// 
    /// - SeeAlso: `TransactionAmountDto` for structure details
    public let amount: TransactionReceiptAmountDto?
    
    /// Currency identifier
    /// 
    /// Numeric currency code (ISO 4217)
    /// 
    public let currencyId: Int32?
    
    /// Currency code
    /// 
    /// Three-letter currency code (ISO 4217)
    /// 
    public let currency: String?
    
    // MARK: - Deprecated Amount Fields
    
    /// Base transaction amount (deprecated)
    /// 
    /// - Important: Use `amount.baseAmount` instead
    /// - Deprecated: Since version 1.1.0
    @available(*, deprecated, message: "Use amount.baseAmount instead")
    public let baseAmount: Double?
    
    /// Total transaction amount (deprecated)
    /// 
    /// - Important: Use `amount.totalAmount` instead
    /// - Deprecated: Since version 1.1.0
    @available(*, deprecated, message: "Use amount.totalAmount instead")
    public let totalAmount: Double?
    
    // MARK: - Processor Information
    
    /// Payment processor identifier
    /// 
    public let processorId: String?
    
    /// Payment processor name
    /// 
    public let processor: String?
    
    // MARK: - Operation and Transaction Type Information
    
    /// Operation type identifier
    /// 
    /// Numeric identifier for the operation type (e.g., Sale, Auth, Capture, Void, Refund)
    /// 
    public let operationTypeId: Int32?
    
    /// Operation type name
    /// 
    /// Human-readable operation type name
    /// 
    public let operationType: String?
    
    /// Transaction type identifier
    /// 
    /// Numeric identifier for the transaction type
    /// 
    public let transactionTypeId: Int32?
    
    /// Transaction type name
    /// 
    /// Human-readable transaction type name
    /// 
    public let transactionType: String?
    
    // MARK: - Payment Method Information
    
    /// Payment method type identifier
    /// 
    /// Numeric identifier for the payment method type (e.g., Credit Card, Debit Card, ACH)
    /// 
    public let paymentMethodTypeId: Int32?
    
    /// Payment method type name
    /// 
    /// Human-readable payment method type name
    /// 
    public let paymentMethodType: String?
    
    // MARK: - Customer Information
    
    /// Customer identifier
    /// 
    /// Unique identifier for the customer in the merchant's system
    /// 
    public let customerId: String?
    
    /// Customer PAN (Primary Account Number)
    /// 
    /// Masked card number or account number for security compliance
    /// 
    /// - Important: This field is masked for PCI compliance
    public let customerPan: String?
    
    /// Card token type
    /// 
    /// Indicates whether the card is stored locally or on the network
    /// 
    /// - SeeAlso: `CardTokenType` enum for values
    public let cardTokenType: CardTokenType?
    
    // MARK: - Status Information
    
    /// Transaction status identifier
    /// 
    /// Numeric identifier for the transaction status (e.g., Approved, Declined, Pending)
    /// 
    public let statusId: Int32?
    
    /// Transaction status name
    /// 
    /// Human-readable transaction status name
    /// 
    public let status: String?
    
    // MARK: - Merchant Information
    
    /// Merchant name
    /// 
    public let merchantName: String?
    
    /// Merchant address
    /// 
    public let merchantAddress: String?
    
    /// Merchant phone number
    /// 
    public let merchantPhoneNumber: String?
    
    /// Merchant email address
    /// 
    public let merchantEmailAddress: String?
    
    /// Merchant website
    /// 
    public let merchantWebsite: String?
    
    // MARK: - Transaction Details
    
    /// Authorization code
    /// 
    /// Authorization code returned by the payment processor
    /// 
    /// - Note: Only present for approved transactions
    public let authCode: String?
    
    /// Transaction source information
    /// 
    /// Information about the source of the transaction (e.g., POS terminal, online, mobile)
    /// 
    /// - SeeAlso: `SourceResponseDto` for structure details
    public let source: SourceResponseDto?
    
    /// Response code
    /// 
    /// Response code from the payment processor indicating transaction result
    /// 
    /// - SeeAlso: `responseDescription` for human-readable message
    public let responseCode: String?
    
    /// Response description
    /// 
    /// Human-readable description of the transaction response
    /// 
    /// - SeeAlso: `responseCode` for numeric code
    public let responseDescription: String?
    
    // MARK: - Card Authentication and Processing Details
    
    /// Cardholder authentication method identifier
    /// 
    /// Numeric identifier for the cardholder authentication method used
    /// 
    public let cardholderAuthenticationMethodId: CardholderAuthenticationMethod?
    
    /// Cardholder authentication method name
    /// 
    /// Human-readable cardholder authentication method name
    /// 
    public let cardholderAuthenticationMethod: String?
    
    /// CVM (Cardholder Verification Method) result message
    /// 
    /// Result message from cardholder verification
    /// 
    public let cvmResultMsg: String?
    
    /// Card data source identifier
    /// 
    /// Numeric identifier for the card data source (e.g., Swipe, Chip, Contactless)
    /// 
    public let cardDataSourceId: CardDataSource?
    
    /// Card data source name
    /// 
    /// Human-readable card data source name
    /// 
    public let cardDataSource: String?
    
    // MARK: - Processing Details
    
    /// Card processing details
    /// 
    /// Detailed information about card processing
    /// 
    /// - SeeAlso: `CardDetailsDto` for structure details
    public let cardProcessingDetails: CardDetailsDto?
    
    /// ACH (Electronic Check) processing details
    /// 
    /// Detailed information about ACH/electronic check processing
    /// 
    /// - SeeAlso: `ElectronicCheckDetails` for structure details
    public let achProcessingDetails: ElectronicCheckDetails?
    
    // MARK: - Additional Information
    
    /// Available operations for this transaction
    /// 
    /// List of operations that can be performed on this transaction (e.g., Void, Refund, Capture)
    /// 
    /// - SeeAlso: `TransactionOperation` for structure details
    public let availableOperations: [TransactionOperation]?
    
    /// AVS (Address Verification System) response
    /// 
    /// Response from address verification system
    /// 
    /// - SeeAlso: `AvsResponseDto` for structure details
    public let avsResponse: AvsResponseDto?
    
    /// EMV tags information
    /// 
    /// EMV (Europay, Mastercard, Visa) tag data from chip card transactions
    /// 
    /// - SeeAlso: `EmvTagsDto` for structure details
    public let emvTags: EmvTagsDto?
    
    // MARK: - Additional Details
    
    /// TSYS card details
    /// 
    /// Additional card details specific to TSYS processor
    /// 
    /// - SeeAlso: `TsysCardDetailsDto` for structure details
    public let tsysCardDetails: TsysCardDetailsDto?
    
    /// ACH details
    /// 
    /// Additional ACH transaction details
    /// 
    /// - SeeAlso: `AchDetailsDto` for structure details
    public let achDetails: AchDetailsDto?
    
    public init(
        transactionId: String?,
        transactionDateTime: Date?,
        orderNumber: String?,
        amount: TransactionReceiptAmountDto?,
        currencyId: Int32?,
        currency: String?,
        baseAmount: Double?,
        totalAmount: Double?,
        processorId: String?,
        processor: String?,
        operationTypeId: Int32?,
        operationType: String?,
        transactionTypeId: Int32?,
        transactionType: String?,
        paymentMethodTypeId: Int32?,
        paymentMethodType: String?,
        customerId: String?,
        customerPan: String?,
        cardTokenType: CardTokenType?,
        statusId: Int32?,
        status: String?,
        merchantName: String?,
        merchantAddress: String?,
        merchantPhoneNumber: String?,
        merchantEmailAddress: String?,
        merchantWebsite: String?,
        authCode: String?,
        source: SourceResponseDto?,
        responseCode: String?,
        responseDescription: String?,
        cardholderAuthenticationMethodId: CardholderAuthenticationMethod?,
        cardholderAuthenticationMethod: String?,
        cvmResultMsg: String?,
        cardDataSourceId: CardDataSource?,
        cardDataSource: String?,
        cardProcessingDetails: CardDetailsDto?,
        achProcessingDetails: ElectronicCheckDetails?,
        availableOperations: [TransactionOperation]?,
        avsResponse: AvsResponseDto?,
        emvTags: EmvTagsDto?,
        tsysCardDetails: TsysCardDetailsDto?,
        achDetails: AchDetailsDto?
    ) {
        self.transactionId = transactionId
        self.transactionDateTime = transactionDateTime
        self.orderNumber = orderNumber
        self.amount = amount
        self.currencyId = currencyId
        self.currency = currency
        self.baseAmount = baseAmount
        self.totalAmount = totalAmount
        self.processorId = processorId
        self.processor = processor
        self.operationTypeId = operationTypeId
        self.operationType = operationType
        self.transactionTypeId = transactionTypeId
        self.transactionType = transactionType
        self.paymentMethodTypeId = paymentMethodTypeId
        self.paymentMethodType = paymentMethodType
        self.customerId = customerId
        self.customerPan = customerPan
        self.cardTokenType = cardTokenType
        self.statusId = statusId
        self.status = status
        self.merchantName = merchantName
        self.merchantAddress = merchantAddress
        self.merchantPhoneNumber = merchantPhoneNumber
        self.merchantEmailAddress = merchantEmailAddress
        self.merchantWebsite = merchantWebsite
        self.authCode = authCode
        self.source = source
        self.responseCode = responseCode
        self.responseDescription = responseDescription
        self.cardholderAuthenticationMethodId = cardholderAuthenticationMethodId
        self.cardholderAuthenticationMethod = cardholderAuthenticationMethod
        self.cvmResultMsg = cvmResultMsg
        self.cardDataSourceId = cardDataSourceId
        self.cardDataSource = cardDataSource
        self.cardProcessingDetails = cardProcessingDetails
        self.achProcessingDetails = achProcessingDetails
        self.availableOperations = availableOperations
        self.avsResponse = avsResponse
        self.emvTags = emvTags
        self.tsysCardDetails = tsysCardDetails
        self.achDetails = achDetails
    }
}
