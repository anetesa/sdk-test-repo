/// Transaction response details
///
/// Detailed response information from a transaction including authorization codes, response codes, and messages.
/// Contains information about whether the transaction was approved or declined.
///
public struct TransactionResponseDetailsDto {
    /// Host response code
    ///
    /// A two-character response code indicating the status of the authorization request
    ///
    public let hostResponseCode: String?
    
    /// Host response message
    ///
    /// Authorization response message from the payment processor
    ///
    public let hostResponseMessage: String?
    
    /// Host response definition
    ///
    /// Detailed definition or explanation of the host response
    ///
    public let hostResponseDefinition: String?
    
    /// High-level operation response code
    ///
    /// High-level operation response - approve, decline or error
    ///
    public let code: String?
    
    /// Response message
    ///
    /// Free-form result description providing details about the transaction result
    ///
    public let message: String?
    
    /// Processor response code
    ///
    /// Processor-specific response code that precisely describes the operation result
    ///
    public let processorResponseCode: String?
    
    /// Authorization code
    ///
    /// The authorization code received for the transaction.
    /// Only present for approved transactions.
    ///
    public let authCode: String?
    
    /// Masked PAN (Primary Account Number)
    ///
    /// Masked card number for security compliance
    ///
    /// - Important: This field is masked for PCI compliance
    public let maskedPan: String?
    
    public init(
        hostResponseCode: String?,
        hostResponseMessage: String?,
        hostResponseDefinition: String?,
        code: String?,
        message: String?,
        processorResponseCode: String?,
        authCode: String?,
        maskedPan: String?
    ) {
        self.hostResponseCode = hostResponseCode
        self.hostResponseMessage = hostResponseMessage
        self.hostResponseDefinition = hostResponseDefinition
        self.code = code
        self.message = message
        self.processorResponseCode = processorResponseCode
        self.authCode = authCode
        self.maskedPan = maskedPan
    }
}
