import Foundation

/// Result of a Tap to Pay transaction.
///
/// Maps directly to CloudCommerce.Transaction structure.
public struct TTPTransactionResult {
    /// Transaction identifier from the payment processor.
    public let transactionId: String?
    
    /// Transaction outcome (APPROVED, DECLINED, etc.).
    public let transactionOutcome: String?
    
    /// Transaction status derived from transactionOutcome.
    public let status: TTPTransactionStatus
    
    /// Order identifier.
    public let orderId: String?
    
    /// Authorized amount as string.
    public let authorizedAmount: String?
    
    /// Authorization code from the payment processor.
    public let authorizationCode: String?
    
    /// Authorization response code (British spelling).
    public let authorisationResponseCode: String?
    
    /// Authorized date as string.
    public let authorizedDate: String?
    
    /// Format of the authorized date.
    public let authorizedDateFormat: String?
    
    /// Card brand name (e.g., Visa, Mastercard).
    public let cardBrandName: String?
    
    /// Masked card number (last 4 digits).
    public let maskedCardNumber: String?
    
    /// External reference ID.
    public let externalReferenceID: String?
    
    /// Application identifier.
    public let applicationIdentifier: String?
    
    /// Application preferred name.
    public let applicationPreferredName: String?
    
    /// Application cryptogram.
    public let applicationCryptogram: String?
    
    /// Application transaction counter.
    public let applicationTransactionCounter: String?
    
    /// Terminal verification results.
    public let terminalVerificationResults: String?
    
    /// Issuer application data.
    public let issuerApplicationData: String?
    
    /// Application PAN sequence number.
    public let applicationPANSequenceNumber: String?
    
    /// Partner data map.
    public let partnerDataMap: [String: String]?
    
    /// CVM tags.
    public let cvmTags: [TTPCVMData]?
    
    /// CVM action.
    public let cvmAction: String?
    
    public init(
        transactionId: String?,
        transactionOutcome: String?,
        status: TTPTransactionStatus,
        orderId: String?,
        authorizedAmount: String?,
        authorizationCode: String?,
        authorisationResponseCode: String?,
        authorizedDate: String?,
        authorizedDateFormat: String?,
        cardBrandName: String?,
        maskedCardNumber: String?,
        externalReferenceID: String?,
        applicationIdentifier: String?,
        applicationPreferredName: String?,
        applicationCryptogram: String?,
        applicationTransactionCounter: String?,
        terminalVerificationResults: String?,
        issuerApplicationData: String?,
        applicationPANSequenceNumber: String?,
        partnerDataMap: [String: String]?,
        cvmTags: [TTPCVMData]?,
        cvmAction: String?
    ) {
        self.transactionId = transactionId
        self.transactionOutcome = transactionOutcome
        self.status = status
        self.orderId = orderId
        self.authorizedAmount = authorizedAmount
        self.authorizationCode = authorizationCode
        self.authorisationResponseCode = authorisationResponseCode
        self.authorizedDate = authorizedDate
        self.authorizedDateFormat = authorizedDateFormat
        self.cardBrandName = cardBrandName
        self.maskedCardNumber = maskedCardNumber
        self.externalReferenceID = externalReferenceID
        self.applicationIdentifier = applicationIdentifier
        self.applicationPreferredName = applicationPreferredName
        self.applicationCryptogram = applicationCryptogram
        self.applicationTransactionCounter = applicationTransactionCounter
        self.terminalVerificationResults = terminalVerificationResults
        self.issuerApplicationData = issuerApplicationData
        self.applicationPANSequenceNumber = applicationPANSequenceNumber
        self.partnerDataMap = partnerDataMap
        self.cvmTags = cvmTags
        self.cvmAction = cvmAction
    }
}
