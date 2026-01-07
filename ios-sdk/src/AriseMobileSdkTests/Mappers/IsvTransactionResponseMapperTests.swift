import Foundation
import Testing
@testable import AriseMobile

/// Tests for TransactionResponseMapper (IsvTransactionResponse)
struct IsvTransactionResponseMapperTests {
    
    @Test("TransactionResponseMapper maps response with all fields")
    func testTransactionResponseMapperWithAllFields() {
        let details = Components.Schemas.PaymentGateway_Contracts_Transactions_TransactionResponseDetailsDto(
            hostResponseCode: "00",
            hostResponseMessage: "Approved",
            hostResponseDefinition: nil,
            code: "00",
            message: "Approved",
            processorResponseCode: nil,
            authCode: "AUTH123",
            maskedPan: "****1234"
        )
        
        let receiptAmount = Components.Schemas.PaymentGateway_Contracts_Transactions_TransactionReceiptDto_AmountDto(
            baseAmount: 100.0,
            percentageOffAmount: nil,
            percentageOffRate: nil,
            cashDiscountAmount: nil,
            cashDiscountRate: nil,
            surchargeAmount: 3.0,
            surchargeRate: 3.0,
            tipAmount: 10.0,
            tipRate: 10.0,
            totalAmount: 113.0
        )
        
        let receipt = Components.Schemas.PaymentGateway_Contracts_Transactions_TransactionReceiptDto(
            transactionId: nil,
            transactionDateTime: nil,
            amount: receiptAmount,
            currencyId: 1,
            currency: "USD",
            processorId: nil,
            processor: nil,
            operationTypeId: nil,
            operationType: nil,
            paymentMethodTypeId: nil,
            paymentMethodType: nil,
            transactionTypeId: nil,
            transactionType: nil,
            customerId: nil,
            customerPan: nil,
            cardTokenType: nil,
            statusId: nil,
            status: nil,
            merchantName: "Test Merchant",
            merchantAddress: "123 Main St",
            merchantPhoneNumber: "555-1234",
            merchantEmailAddress: "merchant@test.com",
            merchantWebsite: "https://test.com",
            authCode: "AUTH123",
            source: nil,
            cardholderAuthenticationMethodId: nil,
            cardholderAuthenticationMethod: nil,
            cvmResultMsg: nil,
            cardDataSourceId: nil,
            cardDataSource: nil,
            responseCode: nil,
            responseDescription: nil,
            cardProcessingDetails: nil,
            achProcessingDetails: nil,
            availableOperations: nil,
            avsResponse: nil,
            emvTags: nil,
            orderNumber: "ORDER-456"
        )
        
        let response = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_IsvTransactionResponse(
            transactionId: "txn-123",
            transactionDateTime: Date(),
            typeId: 1,
            _type: "sale",
            statusId: 2,
            status: "approved",
            details: details,
            transactionReceipt: receipt
        )
        
        let result = TransactionResponseMapper.toModel(response)
        
        #expect(result.transactionId == "txn-123")
        #expect(result.typeId == 1)
        #expect(result.type == "sale")
        #expect(result.statusId == 2)
        #expect(result.status == "approved")
        #expect(result.details != nil)
        #expect(result.transactionReceipt != nil)
    }
    
    @Test("TransactionResponseMapper maps response with nil details")
    func testTransactionResponseMapperWithNilDetails() {
        let response = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_IsvTransactionResponse(
            transactionId: "txn-456",
            transactionDateTime: Date(),
            typeId: 2,
            _type: "refund",
            statusId: 3,
            status: "declined",
            details: nil,
            transactionReceipt: nil
        )
        
        let result = TransactionResponseMapper.toModel(response)
        
        #expect(result.transactionId == "txn-456")
        #expect(result.type == "refund")
        #expect(result.status == "declined")
        #expect(result.details == nil)
        #expect(result.transactionReceipt == nil)
    }
    
    @Test("TransactionResponseMapper maps response with empty details")
    func testTransactionResponseMapperWithEmptyDetails() {
        let response = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_IsvTransactionResponse(
            transactionId: "txn-789",
            transactionDateTime: Date(),
            typeId: 3,
            _type: "void",
            statusId: 1,
            status: "pending",
            details: nil,
            transactionReceipt: nil
        )
        
        let result = TransactionResponseMapper.toModel(response)
        
        #expect(result.transactionId == "txn-789")
        #expect(result.details == nil)
    }
}

