import Foundation
import Testing
@testable import AriseMobile

/// Tests for PaymentTransactionResultMapper (IsvAuthorizationResultMapper) functionality
struct PaymentTransactionResultMapperTests {
    
    // MARK: - IsvAuthorizationResultMapper Tests
    
    @Test("IsvAuthorizationResultMapper converts generated response to model")
    func testIsvAuthorizationResultMapperToModel() {
        let details = Components.Schemas.PaymentGateway_Contracts_Transactions_TransactionResponseDetailsDto(
            hostResponseCode: "00",
            hostResponseMessage: "Approved",
            hostResponseDefinition: "Transaction approved",
            code: "00",
            message: "Success",
            processorResponseCode: "000",
            authCode: "AUTH123",
            maskedPan: "****1234"
        )
        
        let receipt = Components.Schemas.PaymentGateway_Contracts_Transactions_TransactionReceiptDto(
            transactionId: "receipt-123",
            transactionDateTime: Date(),
            amount: nil,
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
            customerId: nil,
            customerPan: "****1234",
            cardTokenType: nil,
            statusId: Int32(2),
            status: "approved",
            merchantName: "Test Merchant",
            merchantAddress: nil,
            merchantPhoneNumber: nil,
            merchantEmailAddress: nil,
            merchantWebsite: nil,
            authCode: "AUTH123",
            source: nil,
            cardholderAuthenticationMethodId: nil,
            cardholderAuthenticationMethod: nil,
            cvmResultMsg: nil,
            cardDataSourceId: nil,
            cardDataSource: nil,
            responseCode: "00",
            responseDescription: "Approved",
            cardProcessingDetails: nil,
            achProcessingDetails: nil,
            availableOperations: nil,
            avsResponse: nil,
            emvTags: nil,
            orderNumber: "ORDER-456"
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
        
        let generatedResponse = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_Authorization_IsvAuthorizationResponse(
            transactionId: "transaction-123",
            transactionDateTime: Date(),
            typeId: 1,
            _type: "sale",
            statusId: 2,
            status: "approved",
            details: details,
            transactionReceipt: receipt,
            processedAmount: 100.0,
            avsResponse: avsResponse
        )
        
        let result = IsvAuthorizationResultMapper.toModel(generatedResponse)
        
        #expect(result.transactionId == "transaction-123")
        #expect(result.typeId == 1)
        #expect(result.type == "sale")
        #expect(result.statusId == 2)
        #expect(result.status == "approved")
        #expect(result.processedAmount == 100.0)
        #expect(result.details?.hostResponseCode == "00")
        #expect(result.transactionReceipt?.transactionId == "receipt-123")
        #expect(result.avsResponse?.action == "Match")
    }
    
    // MARK: - Edge Cases and Additional Tests
    
    @Test("IsvAuthorizationResultMapper handles nil optional fields")
    func testIsvAuthorizationResultMapperWithNilFields() {
        let generatedResponse = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_Authorization_IsvAuthorizationResponse(
            transactionId: nil,
            transactionDateTime: nil,
            typeId: nil,
            _type: nil,
            statusId: nil,
            status: nil,
            details: nil,
            transactionReceipt: nil,
            processedAmount: nil,
            avsResponse: nil
        )
        
        let result = IsvAuthorizationResultMapper.toModel(generatedResponse)
        
        #expect(result.transactionId == nil)
        #expect(result.transactionDateTime == nil)
        #expect(result.typeId == nil)
        #expect(result.type == nil)
        #expect(result.statusId == nil)
        #expect(result.status == nil)
        #expect(result.processedAmount == nil)
        #expect(result.details == nil)
        #expect(result.transactionReceipt == nil)
        #expect(result.avsResponse == nil)
    }
    
    @Test("IsvAuthorizationResultMapper handles response with only required fields")
    func testIsvAuthorizationResultMapperMinimal() {
        let generatedResponse = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_Authorization_IsvAuthorizationResponse(
            transactionId: "minimal-transaction",
            transactionDateTime: Date(),
            typeId: 1,
            _type: "sale",
            statusId: 2,
            status: "approved",
            details: nil,
            transactionReceipt: nil,
            processedAmount: 100.0,
            avsResponse: nil
        )
        
        let result = IsvAuthorizationResultMapper.toModel(generatedResponse)
        
        #expect(result.transactionId == "minimal-transaction")
        #expect(result.processedAmount == 100.0)
        #expect(result.details == nil)
        #expect(result.transactionReceipt == nil)
    }
    
    @Test("IsvAuthorizationResultMapper handles different status values")
    func testIsvAuthorizationResultMapperDifferentStatuses() {
        let statuses: [(Int32?, String?)] = [
            (2, "approved"),
            (3, "declined"),
            (4, "failed"),
            (nil, nil)
        ]
        
        for (statusId, status) in statuses {
            let generatedResponse = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_Authorization_IsvAuthorizationResponse(
                transactionId: "test-transaction",
                transactionDateTime: Date(),
                typeId: 1,
                _type: "sale",
                statusId: statusId,
                status: status,
                details: nil,
                transactionReceipt: nil,
                processedAmount: 100.0,
                avsResponse: nil
            )
            
            let result = IsvAuthorizationResultMapper.toModel(generatedResponse)
            
            #expect(result.statusId == statusId)
            #expect(result.status == status)
        }
    }
    
    @Test("IsvAuthorizationResultMapper handles different transaction types")
    func testIsvAuthorizationResultMapperDifferentTypes() {
        let types: [(Int32?, String?)] = [
            (1, "sale"),
            (2, "auth"),
            (3, "capture"),
            (nil, nil)
        ]
        
        for (typeId, type) in types {
            let generatedResponse = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_Authorization_IsvAuthorizationResponse(
                transactionId: "test-transaction",
                transactionDateTime: Date(),
                typeId: typeId,
                _type: type,
                statusId: 2,
                status: "approved",
                details: nil,
                transactionReceipt: nil,
                processedAmount: 100.0,
                avsResponse: nil
            )
            
            let result = IsvAuthorizationResultMapper.toModel(generatedResponse)
            
            #expect(result.typeId == typeId)
            #expect(result.type == type)
        }
    }
}

