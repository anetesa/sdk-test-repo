import Foundation
import Testing
@testable import AriseMobile

/// Tests for TransactionDetailMapper
struct TransactionDetailMapperTests {
    
    // MARK: - toModel Tests
    
    @Test("TransactionDetailMapper maps response with all fields")
    func testTransactionDetailMapperWithAllFields() throws {
        let amount = Components.Schemas.PaymentGateway_Contracts_Transactions_TransactionReceiptDto_AmountDto(
            baseAmount: 100.0,
            percentageOffAmount: 10.0,
            percentageOffRate: 10.0,
            cashDiscountAmount: 5.0,
            cashDiscountRate: 5.0,
            surchargeAmount: 3.0,
            surchargeRate: 3.0,
            tipAmount: 15.0,
            tipRate: 15.0,
            totalAmount: 113.0
        )
        
        let source = Components.Schemas.PaymentGateway_Contracts_SourceResponseDto(
            typeId: 1,
            _type: "pos",
            id: "source-1",
            name: "POS Terminal"
        )
        
        let cardDetails = Components.Schemas.PaymentGateway_Contracts_Transactions_TransactionReceiptDto_CardDetailsDto(
            authCode: "AUTH123",
            mid: "merchant-123",
            tid: "terminal-456",
            cardCreditDebitTypeId: 1,
            cardCreditDebitType: "Credit",
            processCreditDebitTypeId: 1,
            processCreditDebitType: "Credit",
            rrn: "rrn-789",
            cardTypeId: 1,
            cardType: "Visa"
        )
        
        let availableOperation = Components.Schemas.PaymentGateway_Contracts_Enums_TransactionOperation(
            typeId: ._1,
            _type: "void",
            availableAmount: 113.0,
            suggestedTips: nil
        )
        
        let response = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_Get_GetIsvTransactionResponse(
            transactionId: "txn-123",
            transactionDateTime: Date(),
            amount: amount,
            currencyId: 1,
            currency: "USD",
            processorId: "processor-1",
            processor: "Test Processor",
            operationTypeId: 1,
            operationType: "Sale",
            paymentMethodTypeId: 1,
            paymentMethodType: "Credit Card",
            transactionTypeId: 1,
            transactionType: "Sale",
            customerId: "customer-123",
            customerPan: "****1234",
            cardTokenType: ._1,
            statusId: 2,
            status: "approved",
            merchantName: "Test Merchant",
            merchantAddress: "123 Main St",
            merchantPhoneNumber: "555-1234",
            merchantEmailAddress: "merchant@test.com",
            merchantWebsite: "https://test.com",
            authCode: "AUTH123",
            source: source,
            cardholderAuthenticationMethodId: nil,
            cardholderAuthenticationMethod: nil,
            cvmResultMsg: nil,
            cardDataSourceId: ._1,
            cardDataSource: "Swipe",
            responseCode: "00",
            responseDescription: "Approved",
            cardProcessingDetails: cardDetails,
            achProcessingDetails: nil,
            availableOperations: [availableOperation],
            avsResponse: nil,
            emvTags: nil,
            orderNumber: "ORDER-456",
            baseAmount: 100.0,
            totalAmount: 113.0,
            tsysCardDetails: nil,
            achDetails: nil
        )
        
        let okBody = Operations.GetPayApiV1TransactionsId.Output.Ok.Body.json(response)
        let okResponse = Operations.GetPayApiV1TransactionsId.Output.Ok(body: okBody)
        let output = Operations.GetPayApiV1TransactionsId.Output.ok(okResponse)
        
        let result = try TransactionDetailMapper.toModel(output)
        
        #expect(result.transactionId == "txn-123")
        #expect(result.currency == "USD")
        #expect(result.amount != nil)
        #expect(result.amount?.baseAmount == 100.0)
        #expect(result.amount?.totalAmount == 113.0)
        #expect(result.source != nil)
        #expect(result.source?.id == "source-1")
        #expect(result.cardTokenType == CardTokenType.local)
        #expect(result.cardProcessingDetails != nil)
        #expect(result.availableOperations?.count == 1)
    }
    
    @Test("TransactionDetailMapper maps response with nil fields")
    func testTransactionDetailMapperWithNilFields() throws {
        let response = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_Get_GetIsvTransactionResponse(
            transactionId: "txn-456",
            transactionDateTime: Date(),
            amount: nil,
            currencyId: nil,
            currency: nil,
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
            merchantName: nil,
            merchantAddress: nil,
            merchantPhoneNumber: nil,
            merchantEmailAddress: nil,
            merchantWebsite: nil,
            authCode: nil,
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
            orderNumber: nil,
            baseAmount: nil,
            totalAmount: nil,
            tsysCardDetails: nil,
            achDetails: nil
        )
        
        let okBody = Operations.GetPayApiV1TransactionsId.Output.Ok.Body.json(response)
        let okResponse = Operations.GetPayApiV1TransactionsId.Output.Ok(body: okBody)
        let output = Operations.GetPayApiV1TransactionsId.Output.ok(okResponse)
        
        let result = try TransactionDetailMapper.toModel(output)
        
        #expect(result.transactionId == "txn-456")
        #expect(result.amount == nil)
        #expect(result.source == nil)
        #expect(result.cardTokenType == nil)
        #expect(result.cardProcessingDetails == nil)
        #expect(result.availableOperations == nil)
    }
    
    // MARK: - Helper Methods Tests
    
    @Test("TransactionDetailMapper mapTransactionAmountDto maps all fields")
    func testMapTransactionAmountDto() {
        let amount = Components.Schemas.PaymentGateway_Contracts_Transactions_TransactionReceiptDto_AmountDto(
            baseAmount: 100.0,
            percentageOffAmount: 10.0,
            percentageOffRate: 10.0,
            cashDiscountAmount: 5.0,
            cashDiscountRate: 5.0,
            surchargeAmount: 3.0,
            surchargeRate: 3.0,
            tipAmount: 15.0,
            tipRate: 15.0,
            totalAmount: 113.0
        )
        
        let result = TransactionDetailMapper.mapTransactionAmountDto(amount)
        
        #expect(result.baseAmount == 100.0)
        #expect(result.percentageOffAmount == 10.0)
        #expect(result.percentageOffRate == 10.0)
        #expect(result.cashDiscountAmount == 5.0)
        #expect(result.cashDiscountRate == 5.0)
        #expect(result.surchargeAmount == 3.0)
        #expect(result.surchargeRate == 3.0)
        #expect(result.tipAmount == 15.0)
        #expect(result.tipRate == 15.0)
        #expect(result.totalAmount == 113.0)
    }
    
    @Test("TransactionDetailMapper mapSourceResponseDto returns nil for nil source")
    func testMapSourceResponseDtoWithNil() {
        let result = TransactionDetailMapper.mapSourceResponseDto(nil)
        #expect(result == nil)
    }
    
    @Test("TransactionDetailMapper mapSourceResponseDto maps source with all fields")
    func testMapSourceResponseDtoWithAllFields() {
        let source = Components.Schemas.PaymentGateway_Contracts_SourceResponseDto(
            typeId: 1,
            _type: "pos",
            id: "source-1",
            name: "POS Terminal"
        )
        
        let result = TransactionDetailMapper.mapSourceResponseDto(source)
        
        #expect(result != nil)
        #expect(result?.typeId == 1)
        #expect(result?.type == "pos")
        #expect(result?.id == "source-1")
        #expect(result?.name == "POS Terminal")
    }
    
    @Test("TransactionDetailMapper mapSourceResponseDto maps source with nil name")
    func testMapSourceResponseDtoWithNilName() {
        let source = Components.Schemas.PaymentGateway_Contracts_SourceResponseDto(
            typeId: 1,
            _type: "pos",
            id: "source-1",
            name: nil
        )
        
        let result = TransactionDetailMapper.mapSourceResponseDto(source)
        
        #expect(result != nil)
        #expect(result?.name == "")
    }
    
    @Test("TransactionDetailMapper mapCardTokenType maps _1 to local")
    func testMapCardTokenTypeLocal() {
        let result = TransactionDetailMapper.mapCardTokenType(Components.Schemas.PaymentGateway_Contracts_Enums_TokenType._1)
        #expect(result == CardTokenType.local)
    }
    
    @Test("TransactionDetailMapper mapCardTokenType maps _2 to network")
    func testMapCardTokenTypeNetwork() {
        let result = TransactionDetailMapper.mapCardTokenType(Components.Schemas.PaymentGateway_Contracts_Enums_TokenType._2)
        #expect(result == CardTokenType.network)
    }
    
    @Test("TransactionDetailMapper mapCardTokenType returns nil for nil")
    func testMapCardTokenTypeNil() {
        let result = TransactionDetailMapper.mapCardTokenType(nil)
        #expect(result == nil)
    }
    
    @Test("TransactionDetailMapper mapCardholderAuthenticationMethod maps method")
    func testMapCardholderAuthenticationMethod() {
        let method = Components.Schemas.PaymentGateway_Contracts_Enums_CardholderAuthenticationMethod._0
        let result = TransactionDetailMapper.mapCardholderAuthenticationMethod(method)
        #expect(result != nil)
        #expect(result?.rawValue == 0)
    }
    
    @Test("TransactionDetailMapper mapCardholderAuthenticationMethod returns nil for nil")
    func testMapCardholderAuthenticationMethodNil() {
        let result = TransactionDetailMapper.mapCardholderAuthenticationMethod(nil)
        #expect(result == nil)
    }
    
    @Test("TransactionDetailMapper mapCardDetailsDto maps all fields")
    func testMapCardDetailsDto() {
        let cardDetails = Components.Schemas.PaymentGateway_Contracts_Transactions_TransactionReceiptDto_CardDetailsDto(
            authCode: "AUTH123",
            mid: "merchant-123",
            tid: "terminal-456",
            cardCreditDebitTypeId: 1,
            cardCreditDebitType: "Credit",
            processCreditDebitTypeId: 1,
            processCreditDebitType: "Credit",
            rrn: "rrn-789",
            cardTypeId: 1,
            cardType: "Visa"
        )
        
        let result = TransactionDetailMapper.mapCardDetailsDto(cardDetails)
        
        #expect(result.authCode == "AUTH123")
        #expect(result.mid == "merchant-123")
        #expect(result.tid == "terminal-456")
        #expect(result.cardCreditDebitTypeId == 1)
        #expect(result.cardCreditDebitType == "Credit")
        #expect(result.processCreditDebitTypeId == 1)
        #expect(result.processCreditDebitType == "Credit")
        #expect(result.rrn == "rrn-789")
        #expect(result.cardTypeId == 1)
        #expect(result.cardType == "Visa")
    }
    
    @Test("TransactionDetailMapper mapElectronicCheckDetails maps all fields")
    func testMapElectronicCheckDetails() {
        let details = Components.Schemas.PaymentGateway_Contracts_Transactions_TransactionReceiptDto_ElectronicCheckDetails(
            customerAccountNumber: "123456789",
            customerRoutingNumber: "987654321",
            accountHolderType: "Individual",
            accountHolderTypeId: 1,
            accountType: "Checking",
            accountTypeId: 1,
            taxId: "12-3456789"
        )
        
        let result = TransactionDetailMapper.mapElectronicCheckDetails(details)
        
        #expect(result.customerAccountNumber == "123456789")
        #expect(result.customerRoutingNumber == "987654321")
        #expect(result.accountHolderType == "Individual")
        #expect(result.accountHolderTypeId == 1)
        #expect(result.accountType == "Checking")
        #expect(result.accountTypeId == 1)
        #expect(result.taxId == "12-3456789")
    }
    
    @Test("TransactionDetailMapper mapTransactionOperation maps operation with suggested tips")
    func testMapTransactionOperationWithSuggestedTips() {
        let suggestedTip = Components.Schemas.PaymentGateway_Contracts_Amounts_SuggestedTipsDto(
            tipPercent: 15.0,
            tipAmount: 7.5
        )
        
        let operation = Components.Schemas.PaymentGateway_Contracts_Enums_TransactionOperation(
            typeId: ._1,
            _type: "void",
            availableAmount: 113.0,
            suggestedTips: [suggestedTip]
        )
        
        let result = TransactionDetailMapper.mapTransactionOperation(operation)
        
        #expect(result.typeId == 1)
        #expect(result.type == "void")
        #expect(result.availableAmount == 113.0)
        #expect(result.suggestedTips?.count == 1)
        #expect(result.suggestedTips?.first?.tipPercent == 15.0)
        #expect(result.suggestedTips?.first?.tipAmount == 7.5)
    }
    
    @Test("TransactionDetailMapper mapTransactionOperation filters out tips with nil values")
    func testMapTransactionOperationFiltersNilTips() {
        let tipWithNil = Components.Schemas.PaymentGateway_Contracts_Amounts_SuggestedTipsDto(
            tipPercent: nil,
            tipAmount: nil
        )
        
        let tipValid = Components.Schemas.PaymentGateway_Contracts_Amounts_SuggestedTipsDto(
            tipPercent: 15.0,
            tipAmount: 7.5
        )
        
        let operation = Components.Schemas.PaymentGateway_Contracts_Enums_TransactionOperation(
            typeId: ._1,
            _type: "void",
            availableAmount: 113.0,
            suggestedTips: [tipWithNil, tipValid]
        )
        
        let result = TransactionDetailMapper.mapTransactionOperation(operation)
        
        #expect(result.suggestedTips?.count == 1)
        #expect(result.suggestedTips?.first?.tipPercent == 15.0)
    }
    
    @Test("TransactionDetailMapper mapEmvTagsDto maps all fields")
    func testMapEmvTagsDto() {
        let rawTag = Components.Schemas.KeyValuePair2(
            key: "9F26",
            value: "ABCD1234"
        )
        
        let emvTags = Components.Schemas.PaymentGateway_Contracts_Transactions_TransactionReceiptDto_EmvTagsDto(
            ac: "AC123",
            tvr: "TVR123",
            tsi: "TSI123",
            aid: "A0000000031010",
            applicationLabel: "VISA",
            rawTags: [rawTag]
        )
        
        let result = TransactionDetailMapper.mapEmvTagsDto(emvTags)
        
        #expect(result.ac == "AC123")
        #expect(result.tvr == "TVR123")
        #expect(result.tsi == "TSI123")
        #expect(result.aid == "A0000000031010")
        #expect(result.applicationLabel == "VISA")
        #expect(result.rawTags?.count == 1)
        #expect(result.rawTags?.first?.tag == "9F26")
        #expect(result.rawTags?.first?.value == "ABCD1234")
    }
    
    @Test("TransactionDetailMapper mapEmvTagsDto filters raw tags with nil keys")
    func testMapEmvTagsDtoFiltersNilKeys() {
        let rawTagWithNil = Components.Schemas.KeyValuePair2(
            key: nil,
            value: "ABCD1234"
        )
        
        let rawTagValid = Components.Schemas.KeyValuePair2(
            key: "9F26",
            value: "ABCD1234"
        )
        
        let emvTags = Components.Schemas.PaymentGateway_Contracts_Transactions_TransactionReceiptDto_EmvTagsDto(
            ac: nil,
            tvr: nil,
            tsi: nil,
            aid: nil,
            applicationLabel: nil,
            rawTags: [rawTagWithNil, rawTagValid]
        )
        
        let result = TransactionDetailMapper.mapEmvTagsDto(emvTags)
        
        #expect(result.rawTags?.count == 1)
        #expect(result.rawTags?.first?.tag == "9F26")
    }
}

