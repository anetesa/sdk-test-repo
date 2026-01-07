import Foundation
import CloudCommerce

/// Protocol for transaction data used by TTPTransactionMapper
/// This allows for easier testing while maintaining compatibility with CloudCommerce.Transaction
internal protocol CloudCommerceTransactionProtocol {
    var transactionId: String? { get }
    var transactionOutcome: String? { get }
    var orderId: String? { get }
    var authorizedAmount: String? { get }
    var authorizationCode: String? { get }
    var authorisationResponseCode: String? { get }
    var authorizedDate: String? { get }
    var authorizedDateFormat: String? { get }
    var cardBrandName: String? { get }
    var maskedCardNumber: String? { get }
    var externalReferenceID: String? { get }
    var applicationIdentifier: String? { get }
    var applicationPreferredName: String? { get }
    var applicationCryptogram: String? { get }
    var applicationTransactionCounter: String? { get }
    var terminalVerificationResults: String? { get }
    var issuerApplicationData: String? { get }
    var applicationPANSequenceNumber: String? { get }
    var partnerDataMap: [String: String]? { get }
    var cvmTags: [CloudCommerceCVMTag]? { get }
    var cvmAction: String? { get }
}

/// Simple structure for CVM tag data used in testing
/// This is used instead of CloudCommerce.CVMData which cannot be created in tests
internal struct CloudCommerceCVMTag {
    var tag: String?
    var value: String?
}

// Make CloudCommerce types conform to protocols
#if canImport(CloudCommerce)
/// Wrapper to make CloudCommerce.Transaction conform to TransactionProtocol
private struct CloudCommerceTransactionWrapper: CloudCommerceTransactionProtocol {
    let transaction: CloudCommerce.Transaction
    
    var transactionId: String? { transaction.transactionId }
    var transactionOutcome: String? { transaction.transactionOutcome }
    var orderId: String? { transaction.orderId }
    var authorizedAmount: String? { transaction.authorizedAmount }
    var authorizationCode: String? { transaction.authorizationCode }
    var authorisationResponseCode: String? { transaction.authorisationResponseCode }
    var authorizedDate: String? { transaction.authorizedDate }
    var authorizedDateFormat: String? { transaction.authorizedDateFormat }
    var cardBrandName: String? { transaction.cardBrandName }
    var maskedCardNumber: String? { transaction.maskedCardNumber }
    var externalReferenceID: String? { transaction.externalReferenceID }
    var applicationIdentifier: String? { transaction.applicationIdentifier }
    var applicationPreferredName: String? { transaction.applicationPreferredName }
    var applicationCryptogram: String? { transaction.applicationCryptogram }
    var applicationTransactionCounter: String? { transaction.applicationTransactionCounter }
    var terminalVerificationResults: String? { transaction.terminalVerificationResults }
    var issuerApplicationData: String? { transaction.issuerApplicationData }
    var applicationPANSequenceNumber: String? { transaction.applicationPANSequenceNumber }
    var partnerDataMap: [String: String]? { transaction.partnerDataMap }
    var cvmTags: [CloudCommerceCVMTag]? { 
        transaction.cvmTags?.map { CloudCommerceCVMTag(tag: $0.tag, value: $0.value) }
    }
    var cvmAction: String? { transaction.cvmAction }
}
#endif

internal struct TTPTransactionMapper {
    /// Maps CloudCommerce SDK transaction result to TTPTransactionResult.
    #if canImport(CloudCommerce)
    static func toModel(
        _ transaction: CloudCommerce.Transaction
    ) -> TTPTransactionResult {
        return toModel(CloudCommerceTransactionWrapper(transaction: transaction))
    }
    #endif
    
    /// Maps transaction protocol to TTPTransactionResult.
    /// This internal method allows for testing with mock transactions.
    static func toModel(
        _ transaction: CloudCommerceTransactionProtocol
    ) -> TTPTransactionResult {
        // Map transaction outcome to TTPTransactionStatus
        let status: TTPTransactionStatus
        switch transaction.transactionOutcome?.uppercased() {
        case "APPROVED":
            status = .approved
        case "DECLINED":
            status = .declined
        default:
            status = .failed
        }
        
        // Map CVM tags to TTPCVMData
        let cvmTags: [TTPCVMData]?
        if let cloudCommerceCvmTags = transaction.cvmTags {
            cvmTags = cloudCommerceCvmTags.map { cvmTag in
                TTPCVMData(
                    tag: cvmTag.tag,
                    value: cvmTag.value
                )
            }
        } else {
            cvmTags = nil
        }
        
        return TTPTransactionResult(
           
            transactionId: transaction.transactionId,
            transactionOutcome: transaction.transactionOutcome,
            status: status,
            orderId: transaction.orderId,
            authorizedAmount: transaction.authorizedAmount,
            authorizationCode: transaction.authorizationCode,
            authorisationResponseCode: transaction.authorisationResponseCode,
            authorizedDate: transaction.authorizedDate,
            authorizedDateFormat: transaction.authorizedDateFormat,
            cardBrandName: transaction.cardBrandName,
            
            maskedCardNumber: transaction.maskedCardNumber,
            
            externalReferenceID: transaction.externalReferenceID,
            applicationIdentifier: transaction.applicationIdentifier,
            applicationPreferredName: transaction.applicationPreferredName,
            applicationCryptogram: transaction.applicationCryptogram,
            applicationTransactionCounter: transaction.applicationTransactionCounter,
            terminalVerificationResults: transaction.terminalVerificationResults,
            issuerApplicationData: transaction.issuerApplicationData,
            applicationPANSequenceNumber: transaction.applicationPANSequenceNumber,
            partnerDataMap: transaction.partnerDataMap,
            cvmTags: cvmTags,
            cvmAction: transaction.cvmAction
        )
    }
}
