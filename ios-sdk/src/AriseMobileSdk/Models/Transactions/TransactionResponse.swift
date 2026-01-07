import Foundation

/// Unified transaction result model used by ISV transaction operations
///
/// Maps 1:1 to the OpenAPI schema `PaymentGateway.Contracts.PublicApi.Isv.Transactions.IsvTransactionResponse`.
/// Returned by void, capture, and other operations that expose the shared `IsvTransactionResponse` contract.
public struct TransactionResponse {
    // MARK: - Transaction Identification

    /// Unique transaction identifier
    public let transactionId: String?

    /// Date and time when the transaction event occurred
    ///
    /// Format: ISO 8601 date-time
    public let transactionDateTime: Date?

    // MARK: - Transaction Type and Status

    /// Transaction type identifier
    public let typeId: Int32?

    /// Transaction type name
    public let type: String?

    /// Transaction status identifier
    public let statusId: Int32?

    /// Transaction status name
    public let status: String?

    // MARK: - Detailed Response Data

    /// Transaction response details
    public let details: TransactionResponseDetailsDto?

    /// Transaction receipt information
    public let transactionReceipt: TransactionReceiptDto?

    // MARK: - Convenience Accessors

    /// Authorization code returned by the processor, if available.
    public var authCode: String? {
        details?.authCode
    }

    /// Human-readable response description, if provided.
    public var responseDescription: String? {
        transactionReceipt?.responseDescription
    }

    /// Address Verification System response, if included in the receipt.
    public var avsResponse: AvsResponseDto? {
        transactionReceipt?.avsResponse
    }

    // MARK: - Initialization

    /// Creates a new `IsvTransactionResult`
    public init(
        transactionId: String?,
        transactionDateTime: Date?,
        typeId: Int32?,
        type: String?,
        statusId: Int32?,
        status: String?,
        details: TransactionResponseDetailsDto?,
        transactionReceipt: TransactionReceiptDto?
    ) {
        self.transactionId = transactionId
        self.transactionDateTime = transactionDateTime
        self.typeId = typeId
        self.type = type
        self.statusId = statusId
        self.status = status
        self.details = details
        self.transactionReceipt = transactionReceipt
    }
}


