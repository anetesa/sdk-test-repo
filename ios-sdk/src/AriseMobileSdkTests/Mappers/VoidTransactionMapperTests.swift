import Foundation
import Testing
@testable import AriseMobile

/// Tests for VoidTransactionMapper
struct VoidTransactionMapperTests {
    
    @Test("VoidTransactionMapper maps transactionId to generated input")
    func testVoidTransactionMapperToGeneratedInput() {
        let transactionId = "txn-12345"
        
        let result = VoidTransactionMapper.toGeneratedInput(transactionId)
        
        #expect(result.transactionId == "txn-12345")
    }
    
    @Test("VoidTransactionMapper maps response to model")
    func testVoidTransactionMapperToModel() throws {
        let details = Components.Schemas.PaymentGateway_Contracts_Transactions_TransactionResponseDetailsDto(
            hostResponseCode: "00",
            code: "00",
            authCode: "AUTH123"
        )
        
        let receiptAmount = Components.Schemas.PaymentGateway_Contracts_Transactions_TransactionReceiptDto_AmountDto(
            baseAmount: 100.0,
            surchargeAmount: 3.0,
            tipAmount: 10.0,
            totalAmount: 113.0
        )
        
        let receipt = Components.Schemas.PaymentGateway_Contracts_Transactions_TransactionReceiptDto(
            amount: receiptAmount,
            currencyId: 1,
            currency: "USD",
            merchantName: "Test Merchant",
            authCode: "AUTH123"
        )
        
        let response = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_IsvTransactionResponse(
            transactionId: "txn-12345",
            transactionDateTime: Date(),
            typeId: 3,
            _type: "void",
            statusId: 2,
            status: "approved",
            details: details,
            transactionReceipt: receipt
        )
        
        let okBody = Operations.PostPayApiV1TransactionsVoid.Output.Ok.Body.json(response)
        let okResponse = Operations.PostPayApiV1TransactionsVoid.Output.Ok(body: okBody)
        let output = Operations.PostPayApiV1TransactionsVoid.Output.ok(okResponse)
        
        let result = try VoidTransactionMapper.toModel(output)
        
        #expect(result.transactionId == "txn-12345")
        #expect(result.status == "approved")
        #expect(result.type == "void")
        #expect(result.details != nil)
        #expect(result.transactionReceipt != nil)
    }
    
    @Test("VoidTransactionMapper maps response with nil fields")
    func testVoidTransactionMapperToModelWithNilFields() throws {
        let response = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_IsvTransactionResponse(
            transactionId: "txn-67890",
            transactionDateTime: Date(),
            typeId: 3,
            _type: "void",
            statusId: 3,
            status: "declined",
            details: nil,
            transactionReceipt: nil
        )
        
        let okBody = Operations.PostPayApiV1TransactionsVoid.Output.Ok.Body.json(response)
        let okResponse = Operations.PostPayApiV1TransactionsVoid.Output.Ok(body: okBody)
        let output = Operations.PostPayApiV1TransactionsVoid.Output.ok(okResponse)
        
        let result = try VoidTransactionMapper.toModel(output)
        
        #expect(result.transactionId == "txn-67890")
        #expect(result.status == "declined")
        #expect(result.details == nil)
        #expect(result.transactionReceipt == nil)
    }
}

