import Foundation
import Testing
@testable import AriseMobile

/// Tests for TransactionSummaryMapper
struct TransactionSummaryMapperTests {
    
    @Test("TransactionSummaryMapper maps valid transaction summary")
    func testTransactionSummaryMapperValid() {
        let amount = Components.Schemas.PaymentGateway_Contracts_Amounts_AmountDto(
            baseAmount: 100.0,
            percentageOffAmount: nil,
            percentageOffRate: nil,
            cashDiscountAmount: nil,
            cashDiscountRate: nil,
            surchargeAmount: 3.0,
            surchargeRate: 3.0,
            tipAmount: 10.0,
            tipRate: 10.0,
            taxAmount: nil,
            taxRate: nil,
            totalAmount: 113.0
        )
        
        let suggestedTip = Components.Schemas.PaymentGateway_Contracts_Amounts_SuggestedTipsDto(
            tipPercent: 15.0,
            tipAmount: 7.5
        )
        
        let availableOperation = Components.Schemas.PaymentGateway_Contracts_Transactions_GetPage_GetTransactionPageResponseDto_AvailableOperation(
            typeId: 1,
            _type: "void",
            availableAmount: 113.0,
            suggestedTips: [suggestedTip]
        )
        
        let source = Components.Schemas.PaymentGateway_Contracts_SourceResponseDto(
            typeId: 1,
            _type: "pos",
            id: "source-1",
            name: "POS Terminal"
        )
        
        let item = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_GetPage_GetIsvTransactionsResponse(
            id: "txn-123",
            paymentProcessorId: "processor-1",
            date: Date(),
            baseAmount: 100.0,
            totalAmount: 113.0,
            surchargeAmount: 3.0,
            surchargePercentage: 3.0,
            currencyCode: "USD",
            currencyId: 1,
            merchant: "Test Merchant",
            merchantId: "merchant-1",
            operationMode: "online",
            paymentMethodType: "credit",
            paymentMethodTypeId: 1,
            paymentMethodName: "Visa",
            customerName: "John Doe",
            customerCompany: "Company Inc",
            customerPan: "****1234",
            cardTokenType: ._1,
            customerEmail: "john@example.com",
            customerPhone: "555-1234",
            status: "approved",
            statusId: 2,
            typeId: 1,
            _type: "sale",
            batchId: "batch-1",
            source: source,
            availableOperations: [availableOperation],
            amount: amount
        )
        
        let result = TransactionSummaryMapper.toModel(item)
        
        #expect(result != nil)
        #expect(result?.id == "txn-123")
        #expect(result?.merchantId == "merchant-1")
        #expect(result?.paymentProcessorId == "processor-1")
        #expect(result?.baseAmount == 100.0)
        #expect(result?.totalAmount == 113.0)
        #expect(result?.surchargeAmount == 3.0)
        #expect(result?.surchargePercentage == 3.0)
        #expect(result?.currencyCode == "USD")
        #expect(result?.currencyId == 1)
        #expect(result?.merchant == "Test Merchant")
        #expect(result?.status == "approved")
        #expect(result?.statusId == 2)
        #expect(result?.typeId == 1)
        #expect(result?.type == "sale")
        #expect(result?.availableOperations?.count == 1)
    }
    
    @Test("TransactionSummaryMapper returns nil for missing id")
    func testTransactionSummaryMapperMissingId() {
        let item = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_GetPage_GetIsvTransactionsResponse(
            id: nil,
            paymentProcessorId: nil,
            date: Date(),
            baseAmount: 0.0,
            totalAmount: 0.0,
            surchargeAmount: nil,
            surchargePercentage: nil,
            currencyCode: nil,
            currencyId: nil,
            merchant: nil,
            merchantId: "merchant-1",
            operationMode: nil,
            paymentMethodType: nil,
            paymentMethodTypeId: nil,
            paymentMethodName: nil,
            customerName: nil,
            customerCompany: nil,
            customerPan: nil,
            cardTokenType: nil,
            customerEmail: nil,
            customerPhone: nil,
            status: nil,
            statusId: nil,
            typeId: nil,
            _type: nil,
            batchId: nil,
            source: nil,
            availableOperations: nil,
            amount: nil
        )
        
        let result = TransactionSummaryMapper.toModel(item)
        #expect(result == nil)
    }
    
    @Test("TransactionSummaryMapper returns nil for empty id")
    func testTransactionSummaryMapperEmptyId() {
        let item = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_GetPage_GetIsvTransactionsResponse(
            id: "",
            paymentProcessorId: nil,
            date: Date(),
            baseAmount: 0.0,
            totalAmount: 0.0,
            surchargeAmount: nil,
            surchargePercentage: nil,
            currencyCode: nil,
            currencyId: nil,
            merchant: nil,
            merchantId: "merchant-1",
            operationMode: nil,
            paymentMethodType: nil,
            paymentMethodTypeId: nil,
            paymentMethodName: nil,
            customerName: nil,
            customerCompany: nil,
            customerPan: nil,
            cardTokenType: nil,
            customerEmail: nil,
            customerPhone: nil,
            status: nil,
            statusId: nil,
            typeId: nil,
            _type: nil,
            batchId: nil,
            source: nil,
            availableOperations: nil,
            amount: nil
        )
        
        let result = TransactionSummaryMapper.toModel(item)
        #expect(result == nil)
    }
    
    @Test("TransactionSummaryMapper returns nil for missing merchantId")
    func testTransactionSummaryMapperMissingMerchantId() {
        let item = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_GetPage_GetIsvTransactionsResponse(
            id: "txn-123",
            paymentProcessorId: nil,
            date: Date(),
            baseAmount: 0.0,
            totalAmount: 0.0,
            surchargeAmount: nil,
            surchargePercentage: nil,
            currencyCode: nil,
            currencyId: nil,
            merchant: nil,
            merchantId: nil,
            operationMode: nil,
            paymentMethodType: nil,
            paymentMethodTypeId: nil,
            paymentMethodName: nil,
            customerName: nil,
            customerCompany: nil,
            customerPan: nil,
            cardTokenType: nil,
            customerEmail: nil,
            customerPhone: nil,
            status: nil,
            statusId: nil,
            typeId: nil,
            _type: nil,
            batchId: nil,
            source: nil,
            availableOperations: nil,
            amount: nil
        )
        
        let result = TransactionSummaryMapper.toModel(item)
        #expect(result == nil)
    }
    
    @Test("TransactionSummaryMapper maps with default values")
    func testTransactionSummaryMapperWithDefaults() {
        let amount = Components.Schemas.PaymentGateway_Contracts_Amounts_AmountDto(
            baseAmount: 50.0,
            percentageOffAmount: nil,
            percentageOffRate: nil,
            cashDiscountAmount: nil,
            cashDiscountRate: nil,
            surchargeAmount: nil,
            surchargeRate: nil,
            tipAmount: nil,
            tipRate: nil,
            taxAmount: nil,
            taxRate: nil,
            totalAmount: 50.0
        )
        
        let source = Components.Schemas.PaymentGateway_Contracts_SourceResponseDto(
            typeId: 1,
            _type: "pos",
            id: "source-default",
            name: "Default Source"
        )
        
        let item = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_GetPage_GetIsvTransactionsResponse(
            id: "txn-default",
            paymentProcessorId: nil,
            date: Date(),
            baseAmount: nil,
            totalAmount: nil,
            surchargeAmount: nil,
            surchargePercentage: nil,
            currencyCode: nil,
            currencyId: nil,
            merchant: nil,
            merchantId: "merchant-1",
            operationMode: nil,
            paymentMethodType: nil,
            paymentMethodTypeId: nil,
            paymentMethodName: nil,
            customerName: nil,
            customerCompany: nil,
            customerPan: nil,
            cardTokenType: nil,
            customerEmail: nil,
            customerPhone: nil,
            status: nil,
            statusId: nil,
            typeId: nil,
            _type: nil,
            batchId: nil,
            source: source,
            availableOperations: nil,
            amount: amount
        )
        
        let result = TransactionSummaryMapper.toModel(item)
        
        #expect(result != nil)
        #expect(result?.paymentProcessorId == "") // Should default to empty string
        #expect(result?.baseAmount == 0.0) // Should default to 0.0
        #expect(result?.totalAmount == 0.0) // Should default to 0.0
        #expect(result?.status == "") // Should default to empty string
        #expect(result?.statusId == 0) // Should default to 0
        #expect(result?.typeId == 0) // Should default to 0
    }
}


