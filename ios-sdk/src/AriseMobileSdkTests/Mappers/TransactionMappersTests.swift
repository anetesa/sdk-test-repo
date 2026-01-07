import Foundation
import Testing
@testable import AriseMobile

/// Tests for Transaction Mappers functionality
struct TransactionMappersTests {
    
    // MARK: - TransactionDetailMapper Tests
    
    @Test("TransactionDetailMapper converts generated output to model")
    func testTransactionDetailMapperToModel() throws {
        let amountDto = Components.Schemas.PaymentGateway_Contracts_Transactions_TransactionReceiptDto_AmountDto(
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
        
        let avsResponse = Components.Schemas.PaymentGateway_Contracts_Transactions_AvsResponseDto(
            actionId: ._1,
            action: "Match",
            responseCode: "Y",
            groupId: ._1,
            group: "Address",
            resultId: ._1,
            result: "Match",
            codeDescription: "Address and ZIP match"
        )
        
        let responseBody = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_Get_GetIsvTransactionResponse(
            transactionId: "transaction-123",
            transactionDateTime: Date(),
            amount: amountDto,
            currencyId: Int32(1),
            currency: "USD",
            processorId: "processor-789",
            processor: "Test Processor",
            operationTypeId: Int32(1),
            operationType: "sale",
            paymentMethodTypeId: Int32(1),
            paymentMethodType: "credit",
            transactionTypeId: Int32(1),
            transactionType: "sale",
            customerId: "customer-123",
            customerPan: "****1234",
            cardTokenType: ._1,
            statusId: Int32(2),
            status: "approved",
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
            cardDataSourceId: ._7,
            cardDataSource: "manual",
            responseCode: "00",
            responseDescription: "Approved",
            cardProcessingDetails: nil,
            achProcessingDetails: nil,
            availableOperations: nil,
            avsResponse: avsResponse,
            emvTags: nil,
            orderNumber: "ORDER-456",
            baseAmount: 100.0,
            totalAmount: 113.0,
            tsysCardDetails: nil,
            achDetails: nil
        )
        
        let okBody = Operations.GetPayApiV1TransactionsId.Output.Ok.Body.json(responseBody)
        let okResponse = Operations.GetPayApiV1TransactionsId.Output.Ok(body: okBody)
        let output = Operations.GetPayApiV1TransactionsId.Output.ok(okResponse)
        
        let result = try TransactionDetailMapper.toModel(output)
        
        #expect(result.transactionId == "transaction-123")
        #expect(result.orderNumber == "ORDER-456")
        #expect(result.currencyId == 1)
        #expect(result.currency == "USD")
        #expect(result.processor == "Test Processor")
        #expect(result.operationType == "sale")
        #expect(result.status == "approved")
        #expect(result.merchantName == "Test Merchant")
        #expect(result.authCode == "AUTH123")
        #expect(result.responseCode == "00")
        #expect(result.avsResponse?.action == "Match")
        #expect(result.baseAmount == 100.0)
        #expect(result.totalAmount == 113.0)
    }
}
