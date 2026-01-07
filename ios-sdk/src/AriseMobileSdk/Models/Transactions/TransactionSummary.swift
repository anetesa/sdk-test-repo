import Foundation

/// Summary information about a transaction
/// 
/// Represents summary transaction information in a transaction list.
/// 
public struct TransactionSummary {
    /// Transaction unique identifier
    /// 
    public let id: String
    
    /// Payment processor identifier
    /// 
    public let paymentProcessorId: String
    
    /// Transaction date and time
    /// 
    /// Format: ISO 8601 date-time
    /// 
    public let date: Date?
    
    /// Base transaction amount
    /// 
    /// Original transaction amount before fees and surcharges
    /// 
    public let baseAmount: Double
    
    /// Total transaction amount
    /// 
    /// Final amount including all fees, surcharges, and tips
    /// 
    public let totalAmount: Double
    
    /// Surcharge amount
    /// 
    /// Additional fee amount charged to the customer
    /// 
    public let surchargeAmount: Double?
    
    /// Surcharge percentage
    /// 
    /// Surcharge rate as percentage (e.g., 3.0 for 3%)
    /// 
    public let surchargePercentage: Double?
    
    /// Currency code
    /// 
    /// Three-letter currency code (ISO 4217)
    /// 
    public let currencyCode: String?
    
    /// Currency identifier
    /// 
    /// Numeric currency code (ISO 4217)
    /// 
    public let currencyId: Int32?
    
    /// Merchant name
    /// 
    public let merchant: String?
    
    /// Merchant identifier
    /// 
    public let merchantId: String
    
    /// Operation mode
    /// 
    /// Mode in which the transaction was processed
    /// 
    public let operationMode: String?
    
    /// Payment method type name
    /// 
    /// Human-readable payment method type name
    /// 
    public let paymentMethodType: String?
    
    /// Payment method type identifier
    /// 
    /// Numeric identifier for the payment method type
    /// 
    public let paymentMethodTypeId: Int?
    
    /// Payment method name
    /// 
    /// Specific payment method name (e.g., "Visa", "Mastercard")
    /// 
    public let paymentMethodName: String?
    
    /// Customer name
    /// 
    public let customerName: String?
    
    /// Customer company name
    /// 
    public let customerCompany: String?
    
    /// Customer PAN (Primary Account Number)
    /// 
    /// Masked card number or account number
    /// 
    /// - Important: This field is masked for PCI compliance
    public let customerPan: String?
    
    /// Card token type
    /// 
    /// Indicates whether the card is stored locally or on the network
    /// 
    /// - SeeAlso: `CardTokenType` enum for values
    public let cardTokenType: CardTokenType?
    
    /// Customer email address
    /// 
    public let customerEmail: String?
    
    /// Customer phone number
    /// 
    public let customerPhone: String?
    
    /// Transaction status name
    /// 
    /// Human-readable transaction status name
    /// 
    public let status: String
    
    /// Transaction status identifier
    /// 
    /// Numeric identifier for the transaction status
    /// 
    public let statusId: Int
    
    /// Transaction type identifier
    /// 
    /// Numeric identifier for the transaction type
    /// 
    public let typeId: Int
    
    /// Transaction type name
    /// 
    /// Human-readable transaction type name
    /// 
    public let type: String?
    
    /// Batch identifier
    /// 
    /// Identifier of the settlement batch containing this transaction
    /// 
    public let batchId: String?
    
    /// Transaction source information
    /// 
    /// Information about the source of the transaction
    /// 
    /// - SeeAlso: `SourceResponseDto` for structure details
    public let source: SourceResponseDto
    
    /// Available operations for this transaction
    /// 
    /// List of operations that can be performed on this transaction
    /// 
    /// - SeeAlso: `AvailableOperation` for structure details
    public let availableOperations: Array<AvailableOperation>?
    
    /// Complete amount information
    /// 
    /// Detailed amount information including base, surcharges, tips, discounts, and total
    /// 
    /// - SeeAlso: `AmountDto` for structure details
    public let amount: AmountDto
    
    public init(
        id: String,
        paymentProcessorId: String = "",
        date: Date? = nil,
        baseAmount: Double,
        totalAmount: Double,
        surchargeAmount: Double? = nil,
        surchargePercentage: Double? = nil,
        currencyCode: String? = nil,
        currencyId: Int32? = nil,
        merchant: String? = nil,
        merchantId: String,
        operationMode: String? = nil,
        paymentMethodType: String? = nil,
        paymentMethodTypeId: Int? = nil,
        paymentMethodName: String? = nil,
        customerName: String? = nil,
        customerCompany: String? = nil,
        customerPan: String? = nil,
        cardTokenType: CardTokenType? = nil,
        customerEmail: String? = nil,
        customerPhone: String? = nil,
        status: String,
        statusId: Int,
        typeId: Int,
        type: String? = nil,
        batchId: String? = nil,
        source: SourceResponseDto,
        availableOperations: Array<AvailableOperation>? = nil,
        amount: AmountDto,
        authCode: String? = nil,
        responseCode: String? = nil
    ) {
        self.id = id
        self.paymentProcessorId = paymentProcessorId
        self.date = date
        self.baseAmount = baseAmount
        self.totalAmount = totalAmount
        self.surchargeAmount = surchargeAmount
        self.surchargePercentage = surchargePercentage
        self.currencyCode = currencyCode
        self.currencyId = currencyId
        self.merchant = merchant
        self.merchantId = merchantId
        self.operationMode = operationMode
        self.paymentMethodType = paymentMethodType
        self.paymentMethodTypeId = paymentMethodTypeId
        self.paymentMethodName = paymentMethodName
        self.customerName = customerName
        self.customerCompany = customerCompany
        self.customerPan = customerPan
        self.cardTokenType = cardTokenType
        self.customerEmail = customerEmail
        self.customerPhone = customerPhone
        self.status = status
        self.statusId = statusId
        self.typeId = typeId
        self.type = type
        self.batchId = batchId
        self.source = source
        self.availableOperations = availableOperations
        self.amount = amount
    }

    
}
