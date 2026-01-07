import Foundation

/// Normalized payment transaction result
///
/// Represents the response payload shared by authorization and sale endpoints.
/// Contains transaction status, authorization code, receipt information, and optional AVS details.
///
public struct AuthorizationResponse {
    // MARK: - Transaction Identification
    
    /// Unique transaction identifier
    ///
    /// Unique identifier of the authorized transaction.
    /// Use this ID for subsequent operations like capture or void.
    ///
    public let transactionId: String?
    
    /// Date and time of transaction execution
    ///
    /// Date of execution when the authorization was processed.
    /// Format: ISO 8601 date-time
    ///
    public let transactionDateTime: Date?
    
    // MARK: - Transaction Type and Status
    
    /// Transaction type identifier
    ///
    /// Type id of transaction (e.g., 1 = Authorization).
    ///
    public let typeId: Int32?
    
    /// Transaction type name
    ///
    /// Type name of transaction (e.g., "Authorization").
    ///
    public let type: String?
    
    /// Transaction status identifier
    ///
    /// Status id of transaction (e.g., 1 = Authorized, 2 = Declined).
    ///
    public let statusId: Int32?
    
    /// Transaction status name
    ///
    /// Status name of transaction (e.g., "Authorized", "Declined").
    ///
    public let status: String?
    
    // MARK: - Amount Information
    
    /// Processed amount
    ///
    /// Indicates which amount is authorized. The amount may differ from the amount in the request
    /// due to surcharges, discounts, or other adjustments applied during processing.
    ///
    /// - Important: This is the actual amount that was authorized, which may differ from the requested amount
    public let processedAmount: Double?
    
    // MARK: - Transaction Details
    
    /// Transaction response details
    ///
    /// Detailed response information including authorization code, response codes, and messages.
    /// Contains information about whether the transaction was approved or declined.
    ///
    /// - SeeAlso: `TransactionResponseDetailsDto` for structure details
    public let details: TransactionResponseDetailsDto?
    
    /// Transaction receipt
    ///
    /// Complete transaction receipt information.
    /// Contains full transaction details including amounts, customer information, and available operations.
    ///
    /// - SeeAlso: `TransactionReceiptDto` for structure details
    public let transactionReceipt: TransactionReceiptDto?
    
    // MARK: - AVS Response
    
    /// AVS (Address Verification System) response
    ///
    /// Response from address verification system.
    /// Contains AVS validation results including action, response code, and result.
    ///
    /// - SeeAlso: `AvsResponseDto` for structure details
    public let avsResponse: AvsResponseDto?
    
    // MARK: - Computed Properties
    
    /// Authorization code
    ///
    /// Authorization code returned by the payment processor.
    /// Only present for approved transactions.
    ///
    /// - Returns: Authorization code if available, `nil` otherwise
    public var authCode: String? {
        return details?.authCode
    }
    
    // MARK: - Initialization
    
    /// Initialize payment transaction result
    ///
    /// - Parameters:
    ///   - transactionId: Unique transaction identifier
    ///   - transactionDateTime: Date and time of transaction execution
    ///   - typeId: Transaction type identifier
    ///   - type: Transaction type name
    ///   - statusId: Transaction status identifier
    ///   - status: Transaction status name
    ///   - processedAmount: Processed amount
    ///   - details: Transaction response details
    ///   - transactionReceipt: Transaction receipt
    ///   - avsResponse: AVS response
    public init(
        transactionId: String?,
        transactionDateTime: Date?,
        typeId: Int32?,
        type: String?,
        statusId: Int32?,
        status: String?,
        processedAmount: Double?,
        details: TransactionResponseDetailsDto?,
        transactionReceipt: TransactionReceiptDto?,
        avsResponse: AvsResponseDto?
    ) {
        self.transactionId = transactionId
        self.transactionDateTime = transactionDateTime
        self.typeId = typeId
        self.type = type
        self.statusId = statusId
        self.status = status
        self.processedAmount = processedAmount
        self.details = details
        self.transactionReceipt = transactionReceipt
        self.avsResponse = avsResponse
    }
}

