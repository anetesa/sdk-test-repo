import Foundation
import Testing
@testable import AriseMobile

/// Tests for TransactionsResponseMapper
struct TransactionsResponseMapperTests {
    
    @Test("TransactionsResponseMapper maps response with items")
    func testTransactionsResponseMapperWithItems() throws {
        let amount = Components.Schemas.PaymentGateway_Contracts_Amounts_AmountDto(
            baseAmount: 100.0,
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
            totalAmount: 100.0
        )
        
        let source1 = Components.Schemas.PaymentGateway_Contracts_SourceResponseDto(
            typeId: 1,
            _type: "pos",
            id: "source-1",
            name: "POS Terminal 1"
        )
        
        let source2 = Components.Schemas.PaymentGateway_Contracts_SourceResponseDto(
            typeId: 2,
            _type: "ecommerce",
            id: "source-2",
            name: "E-commerce"
        )
        
        let item1 = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_GetPage_GetIsvTransactionsResponse(
            id: "txn-1",
            paymentProcessorId: "processor-1",
            date: Date(),
            baseAmount: 50.0,
            totalAmount: 50.0,
            surchargeAmount: nil,
            surchargePercentage: nil,
            currencyCode: "USD",
            currencyId: 1,
            merchant: "Merchant 1",
            merchantId: "merchant-1",
            operationMode: "online",
            paymentMethodType: "credit",
            paymentMethodTypeId: 1,
            paymentMethodName: "Visa",
            customerName: "John Doe",
            customerCompany: nil,
            customerPan: "****1234",
            cardTokenType: ._1,
            customerEmail: "john@example.com",
            customerPhone: "555-1234",
            status: "approved",
            statusId: 2,
            typeId: 1,
            _type: "sale",
            batchId: nil,
            source: source1,
            availableOperations: nil,
            amount: amount
        )
        
        let item2 = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_GetPage_GetIsvTransactionsResponse(
            id: "txn-2",
            paymentProcessorId: "processor-2",
            date: Date(),
            baseAmount: 75.0,
            totalAmount: 75.0,
            surchargeAmount: nil,
            surchargePercentage: nil,
            currencyCode: "USD",
            currencyId: 1,
            merchant: "Merchant 2",
            merchantId: "merchant-2",
            operationMode: "offline",
            paymentMethodType: "debit",
            paymentMethodTypeId: 2,
            paymentMethodName: "Mastercard",
            customerName: "Jane Smith",
            customerCompany: "Company Inc",
            customerPan: "****5678",
            cardTokenType: ._2,
            customerEmail: "jane@example.com",
            customerPhone: "555-5678",
            status: "declined",
            statusId: 3,
            typeId: 2,
            _type: "refund",
            batchId: "batch-1",
            source: source2,
            availableOperations: nil,
            amount: amount
        )
        
        let pageResponse = Components.Schemas.TransactionsPageResponse(
            items: [item1, item2],
            total: 2
        )
        
        let okBody = Operations.GetPayApiV1Transactions.Output.Ok.Body.json(pageResponse)
        let okResponse = Operations.GetPayApiV1Transactions.Output.Ok(body: okBody)
        let output = Operations.GetPayApiV1Transactions.Output.ok(okResponse)
        
        let result = try TransactionsResponseMapper.toModel(output, page: 0, pageSize: 20)
        
        #expect(result.items.count == 2)
        #expect(result.total == 2)
        #expect(result.items.first?.id == "txn-1")
        #expect(result.items.last?.id == "txn-2")
    }
    
    @Test("TransactionsResponseMapper maps response with empty items")
    func testTransactionsResponseMapperWithEmptyItems() throws {
        let pageResponse = Components.Schemas.TransactionsPageResponse(
            items: [],
            total: 0
        )
        
        let okBody = Operations.GetPayApiV1Transactions.Output.Ok.Body.json(pageResponse)
        let okResponse = Operations.GetPayApiV1Transactions.Output.Ok(body: okBody)
        let output = Operations.GetPayApiV1Transactions.Output.ok(okResponse)
        
        let result = try TransactionsResponseMapper.toModel(output, page: 0, pageSize: 20)
        
        #expect(result.items.count == 0)
        #expect(result.total == 0)
    }
    
    @Test("TransactionsResponseMapper maps response with nil items")
    func testTransactionsResponseMapperWithNilItems() throws {
        let pageResponse = Components.Schemas.TransactionsPageResponse(
            items: nil,
            total: 0
        )
        
        let okBody = Operations.GetPayApiV1Transactions.Output.Ok.Body.json(pageResponse)
        let okResponse = Operations.GetPayApiV1Transactions.Output.Ok(body: okBody)
        let output = Operations.GetPayApiV1Transactions.Output.ok(okResponse)
        
        let result = try TransactionsResponseMapper.toModel(output, page: 0, pageSize: 20)
        
        #expect(result.items.count == 0)
        #expect(result.total == 0)
    }
    
    @Test("TransactionsResponseMapper filters out invalid items")
    func testTransactionsResponseMapperFiltersInvalidItems() throws {
        let amount = Components.Schemas.PaymentGateway_Contracts_Amounts_AmountDto(
            baseAmount: 100.0,
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
            totalAmount: 100.0
        )
        
        // Valid item
        let source = Components.Schemas.PaymentGateway_Contracts_SourceResponseDto(
            typeId: 1,
            _type: "pos",
            id: "source-1",
            name: "POS Terminal"
        )
        
        let validItem = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_GetPage_GetIsvTransactionsResponse(
            id: "txn-valid",
            paymentProcessorId: nil,
            date: Date(),
            baseAmount: 50.0,
            totalAmount: 50.0,
            surchargeAmount: nil,
            surchargePercentage: nil,
            currencyCode: "USD",
            currencyId: 1,
            merchant: "Merchant",
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
        
        // Invalid item - missing id
        let invalidItem1 = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_GetPage_GetIsvTransactionsResponse(
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
            merchantId: "merchant-2",
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
        
        // Invalid item - missing merchantId
        let invalidItem2 = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_GetPage_GetIsvTransactionsResponse(
            id: "txn-no-merchant",
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
        
        let pageResponse = Components.Schemas.TransactionsPageResponse(
            items: [validItem, invalidItem1, invalidItem2],
            total: 3
        )
        
        let okBody = Operations.GetPayApiV1Transactions.Output.Ok.Body.json(pageResponse)
        let okResponse = Operations.GetPayApiV1Transactions.Output.Ok(body: okBody)
        let output = Operations.GetPayApiV1Transactions.Output.ok(okResponse)
        
        let result = try TransactionsResponseMapper.toModel(output, page: 0, pageSize: 20)
        
        // Should only include valid item
        #expect(result.items.count == 1)
        #expect(result.items.first?.id == "txn-valid")
        #expect(result.total == 3) // Total from response, not filtered count
    }
}

