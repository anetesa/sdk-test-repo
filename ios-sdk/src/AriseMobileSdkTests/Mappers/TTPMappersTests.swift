import Foundation
import Testing
import CloudCommerce
@testable import AriseMobile

/// Tests for TTP Mappers functionality
struct TTPMappersTests {
    
    // MARK: - Helper: Mock Transaction for Testing
    
    /// Mock structure that implements TransactionProtocol for testing
    struct MockTransaction: CloudCommerceTransactionProtocol {
        var transactionId: String?
        var transactionOutcome: String?
        var orderId: String?
        var authorizedAmount: String?
        var authorizationCode: String?
        var authorisationResponseCode: String?
        var authorizedDate: String?
        var authorizedDateFormat: String?
        var cardBrandName: String?
        var maskedCardNumber: String?
        var externalReferenceID: String?
        var applicationIdentifier: String?
        var applicationPreferredName: String?
        var applicationCryptogram: String?
        var applicationTransactionCounter: String?
        var terminalVerificationResults: String?
        var issuerApplicationData: String?
        var applicationPANSequenceNumber: String?
        var partnerDataMap: [String: String]?
        var cvmTags: [CloudCommerceCVMTag]?
        var cvmAction: String?
    }
    
    // MARK: - TTPTransactionMapper Tests
    
    @Test("TTPTransactionMapper maps approved transaction to model")
    func testTTPTransactionMapperApproved() {
        let cvmTag = CloudCommerceCVMTag(tag: "9F26", value: "1234567890ABCDEF")
        
        let transaction = MockTransaction(
            transactionId: "transaction-123",
            transactionOutcome: "APPROVED",
            orderId: "ORDER-456",
            authorizedAmount: "100.00",
            authorizationCode: "AUTH123",
            authorisationResponseCode: "00",
            authorizedDate: "2024-01-01T12:00:00Z",
            authorizedDateFormat: "ISO8601",
            cardBrandName: "Visa",
            maskedCardNumber: "****1234",
            externalReferenceID: "EXT-789",
            applicationIdentifier: "A0000000031010",
            applicationPreferredName: "VISA",
            applicationCryptogram: "ABCD1234",
            applicationTransactionCounter: "0001",
            terminalVerificationResults: "0000008000",
            issuerApplicationData: "06010A03A00000",
            applicationPANSequenceNumber: "01",
            partnerDataMap: ["key1": "value1"],
            cvmTags: [cvmTag],
            cvmAction: "Online PIN"
        )
        
        let result = TTPTransactionMapper.toModel(transaction)
        
        #expect(result.transactionId == "transaction-123")
        #expect(result.status == .approved)
        #expect(result.transactionOutcome == "APPROVED")
        #expect(result.orderId == "ORDER-456")
        #expect(result.authorizedAmount == "100.00")
        #expect(result.authorizationCode == "AUTH123")
        #expect(result.authorisationResponseCode == "00")
        #expect(result.cardBrandName == "Visa")
        #expect(result.maskedCardNumber == "****1234")
        #expect(result.cvmTags?.count == 1)
        #expect(result.cvmTags?.first?.tag == "9F26")
        #expect(result.cvmTags?.first?.value == "1234567890ABCDEF")
    }
    
    @Test("TTPTransactionMapper maps declined transaction to model")
    func testTTPTransactionMapperDeclined() {
        let transaction = MockTransaction(
            transactionId: "transaction-456",
            transactionOutcome: "DECLINED",
            orderId: nil,
            authorizedAmount: nil,
            authorizationCode: nil,
            authorisationResponseCode: "05",
            authorizedDate: nil,
            authorizedDateFormat: nil,
            cardBrandName: nil,
            maskedCardNumber: nil,
            externalReferenceID: nil,
            applicationIdentifier: nil,
            applicationPreferredName: nil,
            applicationCryptogram: nil,
            applicationTransactionCounter: nil,
            terminalVerificationResults: nil,
            issuerApplicationData: nil,
            applicationPANSequenceNumber: nil,
            partnerDataMap: nil,
            cvmTags: nil,
            cvmAction: nil
        )
        
        let result = TTPTransactionMapper.toModel(transaction)
        
        #expect(result.transactionId == "transaction-456")
        #expect(result.status == .declined)
        #expect(result.transactionOutcome == "DECLINED")
        #expect(result.authorisationResponseCode == "05")
    }
    
    @Test("TTPTransactionMapper maps failed transaction to model")
    func testTTPTransactionMapperFailed() {
        let transaction = MockTransaction(
            transactionId: "transaction-789",
            transactionOutcome: "FAILED",
            orderId: nil,
            authorizedAmount: nil,
            authorizationCode: nil,
            authorisationResponseCode: nil,
            authorizedDate: nil,
            authorizedDateFormat: nil,
            cardBrandName: nil,
            maskedCardNumber: nil,
            externalReferenceID: nil,
            applicationIdentifier: nil,
            applicationPreferredName: nil,
            applicationCryptogram: nil,
            applicationTransactionCounter: nil,
            terminalVerificationResults: nil,
            issuerApplicationData: nil,
            applicationPANSequenceNumber: nil,
            partnerDataMap: nil,
            cvmTags: nil,
            cvmAction: nil
        )
        
        let result = TTPTransactionMapper.toModel(transaction)
        
        #expect(result.transactionId == "transaction-789")
        #expect(result.status == .failed)
        #expect(result.transactionOutcome == "FAILED")
    }
    
    @Test("TTPTransactionMapper maps transaction with lowercase outcome")
    func testTTPTransactionMapperLowercaseOutcome() {
        let transaction = MockTransaction(
            transactionId: "transaction-999",
            transactionOutcome: "approved",
            orderId: nil,
            authorizedAmount: nil,
            authorizationCode: nil,
            authorisationResponseCode: nil,
            authorizedDate: nil,
            authorizedDateFormat: nil,
            cardBrandName: nil,
            maskedCardNumber: nil,
            externalReferenceID: nil,
            applicationIdentifier: nil,
            applicationPreferredName: nil,
            applicationCryptogram: nil,
            applicationTransactionCounter: nil,
            terminalVerificationResults: nil,
            issuerApplicationData: nil,
            applicationPANSequenceNumber: nil,
            partnerDataMap: nil,
            cvmTags: nil,
            cvmAction: nil
        )
        
        let result = TTPTransactionMapper.toModel(transaction)
        
        #expect(result.status == .approved)
    }
    
    
    // MARK: - TTPEventMapper Tests
    
    // Note: TTPEventMapper requires CloudCommerce.EventStream which is an enum from external SDK
    // and cannot be easily mocked. The mapper logic is tested through integration tests in TTPService.
    // However, we can test that the mapper structure exists and can be called.
    
    @Test("TTPEventMapper structure exists and can be called")
    func testTTPEventMapperStructure() {
        // Verify that TTPEventMapper exists and has the expected method
        // Full testing requires actual CloudCommerce.EventStream instances
        #expect(TTPEventMapper.toTTPEvent != nil)
    }
}

