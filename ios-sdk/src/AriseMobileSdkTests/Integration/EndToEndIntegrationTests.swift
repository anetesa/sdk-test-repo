import Foundation
import Testing
@testable import AriseMobile

/// End-to-End Integration Flow Tests
/// 
/// These tests verify complete user scenarios across multiple SDK components,
/// testing the interaction between services, storage, and API clients.
struct EndToEndIntegrationTests {
    
    // MARK: - Authentication Flow Tests
    
    @Test("Full authentication flow: authenticate -> getAccessToken -> refreshAccessToken -> clearStoredToken")
    func testFullAuthenticationFlow() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        
        // Setup initial authentication result
        let authResult = AuthenticationResult(
            accessToken: "initial-access-token",
            refreshToken: "refresh-token-123",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(authResult)
        
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: session,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: session,
            authApi: mockAuthApi,
            tokenService: tokenService
        )
        
        // Step 1: Authenticate
        let clientId = "test-client-id"
        let clientSecret = "test-client-secret"
        let result = try await sdk.authenticate(clientId: clientId, clientSecret: clientSecret)
        #expect(result.accessToken == "initial-access-token")
        #expect(result.refreshToken == "refresh-token-123")
        #expect(mockAuthApi.authenticateCallCount == 1)
        
        // Step 2: Get access token
        let token = await sdk.getAccessToken()
        #expect(token == "initial-access-token")
        
        // Step 3: Refresh access token
        let refreshResult = AuthenticationResult(
            accessToken: "refreshed-access-token",
            refreshToken: "new-refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.refreshTokenResult = .success(refreshResult)
        
        let refreshed = try await sdk.refreshAccessToken()
        #expect(refreshed.accessToken == "refreshed-access-token")
        #expect(mockAuthApi.refreshTokenCallCount == 1)
        
        // Verify new token is accessible
        let newToken = await sdk.getAccessToken()
        #expect(newToken == "refreshed-access-token")
        
        // Step 4: Clear stored token
        sdk.clearStoredToken()
        let clearedToken = await sdk.getAccessToken()
        #expect(clearedToken == nil)
    }
    
    @Test("Authentication with invalid credentials")
    func testAuthenticationWithInvalidCredentials() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        
        mockAuthApi.authenticateResult = .failure(AuthenticationError.invalidCredentials)
        
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: session,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: session,
            authApi: mockAuthApi,
            tokenService: tokenService
        )
        
        // Attempt authentication with invalid credentials
        await Test.assertThrowsError {
            _ = try await sdk.authenticate(clientId: "invalid-id", clientSecret: "invalid-secret")
        }
        
        // Verify no token is stored
        let token = await sdk.getAccessToken()
        #expect(token == nil)
        #expect(mockAuthApi.authenticateCallCount == 1)
    }
    
    @Test("Refresh token expiration and re-authentication")
    func testRefreshTokenExpirationAndReAuthentication() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        
        // Initial authentication
        let initialAuthResult = AuthenticationResult(
            accessToken: "initial-access-token",
            refreshToken: "refresh-token-123",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(initialAuthResult)
        
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: session,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: session,
            authApi: mockAuthApi,
            tokenService: tokenService
        )
        
        // Authenticate initially
        _ = try await sdk.authenticate(clientId: "test-client-id", clientSecret: "test-client-secret")
        
        // Simulate refresh token expiration
        mockAuthApi.refreshTokenResult = .failure(AuthenticationError.tokenExpired)
        
        // Attempt refresh - should fail
        await Test.assertThrowsError {
            _ = try await sdk.refreshAccessToken()
        }
        
        // Re-authenticate
        let reAuthResult = AuthenticationResult(
            accessToken: "new-access-token",
            refreshToken: "new-refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(reAuthResult)
        
        let reAuth = try await sdk.authenticate(clientId: "test-client-id", clientSecret: "test-client-secret")
        #expect(reAuth.accessToken == "new-access-token")
        #expect(mockAuthApi.authenticateCallCount == 2)
    }
    
    @Test("Concurrent authentication attempts")
    func testConcurrentAuthenticationAttempts() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        
        let authResult = AuthenticationResult(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(authResult)
        
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: session,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: session,
            authApi: mockAuthApi,
            tokenService: tokenService
        )
        
        // Perform concurrent authentication attempts
        try await withThrowingTaskGroup(of: AuthenticationResult.self) { group in
            for i in 0..<5 {
                group.addTask {
                    try await sdk.authenticate(clientId: "client-\(i)", clientSecret: "secret-\(i)")
                }
            }
            
            var results: [AuthenticationResult] = []
            for try await result in group {
                results.append(result)
            }
            
            // All should succeed (though behavior depends on implementation)
            #expect(results.count == 5)
        }
    }
    
    @Test("Token persistence between sessions")
    func testTokenPersistenceBetweenSessions() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session1 = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        
        // First session: authenticate
        let authResult = AuthenticationResult(
            accessToken: "persistent-access-token",
            refreshToken: "persistent-refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(authResult)
        
        let tokenService1 = TokenService(
            authApi: mockAuthApi,
            session: session1,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        let sdk1 = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: session1,
            authApi: mockAuthApi,
            tokenService: tokenService1
        )
        
        _ = try await sdk1.authenticate(clientId: "test-client-id", clientSecret: "test-client-secret")
        
        // Simulate app restart - create new session with same storage
        let session2 = AriseSession(tokenStorage: mockTokenStorage)
        let tokenService2 = TokenService(
            authApi: mockAuthApi,
            session: session2,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        let sdk2 = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: session2,
            authApi: mockAuthApi,
            tokenService: tokenService2
        )
        
        // Token should be accessible in new session
        let token = await sdk2.getAccessToken()
        #expect(token == "persistent-access-token")
    }
    
    // MARK: - Transaction Flow Tests
    
    @Test("Sale flow: submitSaleTransaction -> getTransactionDetails -> voidTransaction")
    func testSaleFlow() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        let mockTransactionsService = MockTransactionsService()
        let mockTTPService = MockTTPService()
        
        // Setup authentication
        let authResult = AuthenticationResult(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(authResult)
        
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: session,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: session,
            authApi: mockAuthApi,
            tokenService: tokenService,
            transactionsService: mockTransactionsService,
            ttpService: mockTTPService
        )
        
        // Step 1: Authenticate
        _ = try await sdk.authenticate(clientId: "test-client-id", clientSecret: "test-client-secret")
        
        // Step 2: Submit sale transaction
        let saleRequest = try AuthorizationRequest(
            paymentProcessorId: "processor-id",
            amount: 100.0,
            currencyId: 1,
            cardDataSource: .manual,
            accountNumber: "4111111111111111",
            securityCode: "123",
            expirationMonth: 12,
            expirationYear: 25
        )
        
        let saleResponse = AuthorizationResponse(
            transactionId: "sale-transaction-id",
            transactionDateTime: Date(),
            typeId: 2,
            type: "Sale",
            statusId: 2,
            status: "Approved",
            processedAmount: 100.0,
            details: nil,
            transactionReceipt: nil,
            avsResponse: nil
        )
        mockTransactionsService.submitSaleTransactionResult = .success(saleResponse)
        
        let saleResult = try await sdk.submitSaleTransaction(input: saleRequest)
        #expect(saleResult.transactionId == "sale-transaction-id")
        #expect(mockTransactionsService.submitSaleTransactionCallCount == 1)
        
        // Step 3: Get transaction details
        let transactionDetails = TransactionFactory.createTransactionDetails(
            transactionId: "sale-transaction-id",
            amount: 100.0,
            status: "Approved"
        )
        mockTransactionsService.getTransactionDetailsResult = .success(transactionDetails)
        
        let details = try await sdk.getTransactionDetails(id: "sale-transaction-id")
        #expect(details?.transactionId == "sale-transaction-id")
        #expect(mockTransactionsService.getTransactionDetailsCallCount == 1)
        
        // Step 4: Void transaction
        let voidResponse = TransactionResponse(
            transactionId: "sale-transaction-id",
            transactionDateTime: Date(),
            typeId: 3,
            type: "Void",
            statusId: 3,
            status: "Voided",
            details: nil,
            transactionReceipt: nil
        )
        mockTransactionsService.voidTransactionResult = .success(voidResponse)
        
        let voidResult = try await sdk.voidTransaction(transactionId: "sale-transaction-id")
        #expect(voidResult.transactionId == "sale-transaction-id")
        #expect(voidResult.status == "Voided")
        #expect(mockTransactionsService.voidTransactionCallCount == 1)
    }
    
    @Test("Auth flow: submitAuthTransaction -> captureTransaction -> getTransactionDetails")
    func testAuthFlow() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        let mockTransactionsService = MockTransactionsService()
        let mockTTPService = MockTTPService()
        
        // Setup authentication
        let authTokenResult = AuthenticationResult(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(authTokenResult)
        
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: session,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: session,
            authApi: mockAuthApi,
            tokenService: tokenService,
            transactionsService: mockTransactionsService,
            ttpService: mockTTPService
        )
        
        // Step 1: Authenticate
        _ = try await sdk.authenticate(clientId: "test-client-id", clientSecret: "test-client-secret")
        
        // Step 2: Submit authorization transaction
        let authRequest = try AuthorizationRequest(
            paymentProcessorId: "processor-id",
            amount: 100.0,
            currencyId: 1,
            cardDataSource: .manual,
            accountNumber: "4111111111111111",
            securityCode: "123",
            expirationMonth: 12,
            expirationYear: 25
        )
        
        let authResponse = AuthorizationResponse(
            transactionId: "auth-transaction-id",
            transactionDateTime: Date(),
            typeId: 1,
            type: "Authorization",
            statusId: 1,
            status: "Authorized",
            processedAmount: 100.0,
            details: nil,
            transactionReceipt: nil,
            avsResponse: nil
        )
        mockTransactionsService.submitAuthTransactionResult = .success(authResponse)
        
        let transactionResult = try await sdk.submitAuthTransaction(input: authRequest)
        #expect(transactionResult.transactionId == "auth-transaction-id")
        #expect(mockTransactionsService.submitAuthTransactionCallCount == 1)
        
        // Step 3: Capture transaction
        let captureResponse = TransactionResponse(
            transactionId: "auth-transaction-id",
            transactionDateTime: Date(),
            typeId: 4,
            type: "Capture",
            statusId: 4,
            status: "Captured",
            details: nil,
            transactionReceipt: nil
        )
        mockTransactionsService.captureTransactionResult = .success(captureResponse)
        
        let captureResult = try await sdk.captureTransaction(transactionId: "auth-transaction-id", amount: 100.0)
        #expect(captureResult.transactionId == "auth-transaction-id")
        #expect(captureResult.status == "Captured")
        #expect(mockTransactionsService.captureTransactionCallCount == 1)
        
        // Step 4: Get transaction details
        let transactionDetails = TransactionFactory.createTransactionDetails(
            transactionId: "auth-transaction-id",
            amount: 100.0,
            status: "Captured"
        )
        mockTransactionsService.getTransactionDetailsResult = .success(transactionDetails)
        
        let details = try await sdk.getTransactionDetails(id: "auth-transaction-id")
        #expect(details?.transactionId == "auth-transaction-id")
        #expect(details?.status == "Captured")
    }
    
    @Test("Refund flow: submitSaleTransaction -> refundTransaction (partial) -> refundTransaction (full)")
    func testRefundFlow() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        let mockTransactionsService = MockTransactionsService()
        let mockTTPService = MockTTPService()
        
        // Setup authentication
        let authResult = AuthenticationResult(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(authResult)
        
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: session,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: session,
            authApi: mockAuthApi,
            tokenService: tokenService,
            transactionsService: mockTransactionsService,
            ttpService: mockTTPService
        )
        
        // Step 1: Authenticate
        _ = try await sdk.authenticate(clientId: "test-client-id", clientSecret: "test-client-secret")
        
        // Step 2: Submit sale transaction
        let saleRequest = try AuthorizationRequest(
            paymentProcessorId: "processor-id",
            amount: 100.0,
            currencyId: 1,
            cardDataSource: .manual,
            accountNumber: "4111111111111111",
            securityCode: "123",
            expirationMonth: 12,
            expirationYear: 25
        )
        
        let saleResponse = AuthorizationResponse(
            transactionId: "sale-transaction-id",
            transactionDateTime: Date(),
            typeId: 2,
            type: "Sale",
            statusId: 2,
            status: "Approved",
            processedAmount: 100.0,
            details: nil,
            transactionReceipt: nil,
            avsResponse: nil
        )
        mockTransactionsService.submitSaleTransactionResult = .success(saleResponse)
        
        _ = try await sdk.submitSaleTransaction(input: saleRequest)
        
        // Step 3: Partial refund
        let partialRefundRequest = RefundRequest(
            transactionId: "sale-transaction-id",
            amount: 50.0,
            cardDataSource: .manual
        )
        
        let partialRefundResponse = TransactionResponse(
            transactionId: "sale-transaction-id",
            transactionDateTime: Date(),
            typeId: 5,
            type: "Refund",
            statusId: 5,
            status: "Partially Refunded",
            details: nil,
            transactionReceipt: nil
        )
        mockTransactionsService.refundTransactionResult = .success(partialRefundResponse)
        
        let partialRefundResult = try await sdk.refundTransaction(request: partialRefundRequest)
        #expect(partialRefundResult.transactionId == "sale-transaction-id")
        #expect(mockTransactionsService.refundTransactionCallCount == 1)
        
        // Step 4: Full refund
        let fullRefundRequest = RefundRequest(
            transactionId: "sale-transaction-id",
            cardDataSource: .manual
        )
        
        let fullRefundResponse = TransactionResponse(
            transactionId: "sale-transaction-id",
            transactionDateTime: Date(),
            typeId: 5,
            type: "Refund",
            statusId: 5,
            status: "Refunded",
            details: nil,
            transactionReceipt: nil
        )
        mockTransactionsService.refundTransactionResult = .success(fullRefundResponse)
        
        let fullRefundResult = try await sdk.refundTransaction(request: fullRefundRequest)
        #expect(fullRefundResult.status == "Refunded")
        #expect(mockTransactionsService.refundTransactionCallCount == 2)
    }
    
    @Test("Calculate amount flow: calculateAmount -> submitSaleTransaction")
    func testCalculateAmountFlow() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        let mockTransactionsService = MockTransactionsService()
        let mockTTPService = MockTTPService()
        
        // Setup authentication
        let authResult = AuthenticationResult(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(authResult)
        
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: session,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: session,
            authApi: mockAuthApi,
            tokenService: tokenService,
            transactionsService: mockTransactionsService,
            ttpService: mockTTPService
        )
        
        // Step 1: Authenticate
        _ = try await sdk.authenticate(clientId: "test-client-id", clientSecret: "test-client-secret")
        
        // Step 2: Calculate amount
        let calculateRequest = CalculateAmountRequest(
            amount: 100.0,
            surchargeRate: 3.0,
            tipAmount: 10.0,
            useCardPrice: true
        )
        
        let calculateResponse = CalculateAmountResponse(
            currencyId: 1,
            currency: "USD",
            zeroCostProcessingOptionId: nil,
            zeroCostProcessingOption: nil,
            useCardPrice: true,
            cash: AmountDto(
                baseAmount: 110.0,
                percentageOffAmount: 0.0,
                percentageOffRate: 0.0,
                cashDiscountAmount: 0.0,
                cashDiscountRate: 0.0,
                surchargeAmount: 0.0,
                surchargeRate: 0.0,
                tipAmount: 10.0,
                tipRate: 0.0,
                taxAmount: 0.0,
                taxRate: 0.0,
                totalAmount: 110.0
            ),
            creditCard: AmountDto(
                baseAmount: 100.0,
                percentageOffAmount: 0.0,
                percentageOffRate: 0.0,
                cashDiscountAmount: 0.0,
                cashDiscountRate: 0.0,
                surchargeAmount: 3.0,
                surchargeRate: 3.0,
                tipAmount: 10.0,
                tipRate: 0.0,
                taxAmount: 0.0,
                taxRate: 0.0,
                totalAmount: 113.0
            ),
            debitCard: nil,
            ach: nil
        )
        mockTransactionsService.calculateAmountResult = .success(calculateResponse)
        
        let calculation = try await sdk.calculateAmount(request: calculateRequest)
        #expect(calculation.creditCard?.totalAmount == 113.0)
        #expect(mockTransactionsService.calculateAmountCallCount == 1)
        
        // Step 3: Submit sale transaction with calculated amount
        let saleRequest = try AuthorizationRequest(
            paymentProcessorId: "processor-id",
            amount: calculation.creditCard?.totalAmount ?? 113.0,
            currencyId: 1,
            cardDataSource: .manual,
            accountNumber: "4111111111111111",
            securityCode: "123",
            expirationMonth: 12,
            expirationYear: 25,
            tipAmount: 10.0,
            useCardPrice: true
        )
        
        let saleResponse = AuthorizationResponse(
            transactionId: "calculated-transaction-id",
            transactionDateTime: Date(),
            typeId: 2,
            type: "Sale",
            statusId: 2,
            status: "Approved",
            processedAmount: 113.0,
            details: nil,
            transactionReceipt: nil,
            avsResponse: nil
        )
        mockTransactionsService.submitSaleTransactionResult = .success(saleResponse)
        
        let saleResult = try await sdk.submitSaleTransaction(input: saleRequest)
        #expect(saleResult.transactionId == "calculated-transaction-id")
    }
    
    @Test("getTransactions with various filters")
    func testGetTransactionsWithFilters() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        let mockTransactionsService = MockTransactionsService()
        let mockTTPService = MockTTPService()
        
        // Setup authentication
        let authResult = AuthenticationResult(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(authResult)
        
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: session,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: session,
            authApi: mockAuthApi,
            tokenService: tokenService,
            transactionsService: mockTransactionsService,
            ttpService: mockTTPService
        )
        
        // Authenticate
        _ = try await sdk.authenticate(clientId: "test-client-id", clientSecret: "test-client-secret")
        
        // Test 1: Get transactions without filters
        let transactions1 = TransactionsResponse(
            items: [],
            total: 0
        )
        mockTransactionsService.getTransactionsResult = .success(transactions1)
        
        let result1 = try await sdk.getTransactions()
        #expect(result1?.total == 0)
        #expect(mockTransactionsService.getTransactionsCallCount == 1)
        
        // Test 2: Get transactions with pagination filters
        let filters = try TransactionFilters(
            page: 0,
            pageSize: 10,
            asc: true,
            orderBy: "date"
        )
        
        let transactions2 = TransactionsResponse(
            items: [],
            total: 100
        )
        mockTransactionsService.getTransactionsResult = .success(transactions2)
        
        let result2 = try await sdk.getTransactions(filters: filters)
        #expect(result2?.total == 100)
        #expect(mockTransactionsService.getTransactionsCallCount == 2)
        
        // Test 3: Get transactions with batch filter
        let batchFilters = try TransactionFilters(
            page: 0,
            pageSize: 20,
            batchId: "batch-id-123"
        )
        
        let transactions3 = TransactionsResponse(
            items: [],
            total: 5
        )
        mockTransactionsService.getTransactionsResult = .success(transactions3)
        
        let result3 = try await sdk.getTransactions(filters: batchFilters)
        #expect(result3?.total == 5)
        #expect(mockTransactionsService.getTransactionsCallCount == 3)
    }
    
    @Test("Error handling in transaction flow: declined transactions")
    func testErrorHandlingDeclinedTransactions() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        let mockTransactionsService = MockTransactionsService()
        let mockTTPService = MockTTPService()
        
        // Setup authentication
        let authResult = AuthenticationResult(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(authResult)
        
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: session,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: session,
            authApi: mockAuthApi,
            tokenService: tokenService,
            transactionsService: mockTransactionsService,
            ttpService: mockTTPService
        )
        
        // Authenticate
        _ = try await sdk.authenticate(clientId: "test-client-id", clientSecret: "test-client-secret")
        
        // Attempt sale transaction that gets declined
        let saleRequest = try AuthorizationRequest(
            paymentProcessorId: "processor-id",
            amount: 100.0,
            currencyId: 1,
            cardDataSource: .manual,
            accountNumber: "4111111111111111",
            securityCode: "123",
            expirationMonth: 12,
            expirationYear: 25
        )
        
        let declinedResponse = AuthorizationResponse(
            transactionId: "declined-transaction-id",
            transactionDateTime: Date(),
            typeId: 2,
            type: "Sale",
            statusId: 3,
            status: "Declined",
            processedAmount: 100.0,
            details: nil,
            transactionReceipt: nil,
            avsResponse: nil
        )
        mockTransactionsService.submitSaleTransactionResult = .success(declinedResponse)
        
        // Transaction should complete but with declined status
        let result = try await sdk.submitSaleTransaction(input: saleRequest)
        #expect(result.status == "Declined")
        
        // Should still be able to get transaction details
        let transactionDetails = TransactionFactory.createTransactionDetails(
            transactionId: "declined-transaction-id",
            amount: 100.0,
            status: "Declined"
        )
        mockTransactionsService.getTransactionDetailsResult = .success(transactionDetails)
        
        let details = try await sdk.getTransactionDetails(id: "declined-transaction-id")
        #expect(details?.status == "Declined")
    }
    
    // MARK: - TTP Activation and Transaction Flow Tests
    
    @Test("Full TTP activation flow: checkCompatibility -> activate -> getStatus -> prepare")
    func testFullTTPActivationFlow() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        let mockTTPService = MockTTPService()
        let mockDevicesService = MockDevicesService()
        
        // Setup authentication
        let authResult = AuthenticationResult(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(authResult)
        
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: session,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: session,
            authApi: mockAuthApi,
            tokenService: tokenService,
            ttpService: mockTTPService
        )
        
        // Step 1: Authenticate
        _ = try await sdk.authenticate(clientId: "test-client-id", clientSecret: "test-client-secret")
        
        // Step 2: Check compatibility
        let compatibilityResult = sdk.ttp.checkCompatibility()
        #expect(compatibilityResult.isCompatible == true)
        #expect(mockTTPService.checkCompatibilityCallCount == 1)
        
        // Step 3: Get initial status (should be inactive)
        mockTTPService.getStatusResult = .success(.inactive)
        let initialStatus = try await sdk.ttp.getStatus()
        #expect(initialStatus == .inactive)
        #expect(mockTTPService.getStatusCallCount == 1)
        
        // Step 4: Activate TTP
        mockTTPService.activateResult = .success(())
        try await sdk.ttp.activate()
        #expect(mockTTPService.activateCallCount == 1)
        
        // Step 5: Get status after activation (should be active)
        mockTTPService.getStatusResult = .success(.active)
        let activeStatus = try await sdk.ttp.getStatus()
        #expect(activeStatus == .active)
        #expect(mockTTPService.getStatusCallCount == 2)
        
        // Step 6: Prepare TTP
        mockTTPService.prepareResult = .success(())
        try await sdk.ttp.prepare()
        #expect(mockTTPService.prepareCallCount == 1)
    }
    
    @Test("TTP activation with incompatible device")
    func testTTPActivationWithIncompatibleDevice() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        let mockTTPService = MockTTPService()
        
        // Setup incompatible device
        mockTTPService.checkCompatibilityResult = TTPCompatibilityResult(
            isCompatible: false,
            deviceModelCheck: DeviceModelCheck(isCompatible: false, modelIdentifier: "iPhone8,1"),
            iosVersionCheck: IOSVersionCheck(isCompatible: true, version: "18.0", minimumRequiredVersion: "18.0"),
            locationPermission: .granted,
            tapToPayEntitlement: .available,
            incompatibilityReasons: ["Device model is not compatible"]
        )
        
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: session,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: session,
            authApi: mockAuthApi,
            tokenService: tokenService,
            ttpService: mockTTPService
        )
        
        // Check compatibility - should indicate incompatible
        let compatibilityResult = sdk.ttp.checkCompatibility()
        #expect(compatibilityResult.isCompatible == false)
        #expect(compatibilityResult.incompatibilityReasons.isEmpty == false)
    }
    
    @Test("TTP transaction flow: prepare -> performTransaction -> abortTransaction")
    func testTTPTransactionFlow() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        let mockTTPService = MockTTPService()
        
        // Setup authentication
        let authResult = AuthenticationResult(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(authResult)
        
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: session,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: session,
            authApi: mockAuthApi,
            tokenService: tokenService,
            ttpService: mockTTPService
        )
        
        // Authenticate
        _ = try await sdk.authenticate(clientId: "test-client-id", clientSecret: "test-client-secret")
        
        // Step 1: Prepare TTP
        mockTTPService.prepareResult = .success(())
        try await sdk.ttp.prepare()
        #expect(mockTTPService.prepareCallCount == 1)
        
        // Step 2: Perform transaction (using mock - won't show UI in test)
        let transactionResult = TTPTransactionResult(
            transactionId: "ttp-transaction-id",
            transactionOutcome: "APPROVED",
            status: TTPTransactionStatus.approved,
            orderId: nil,
            authorizedAmount: "100.00",
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
        mockTTPService.performTransactionResult = .success(transactionResult)
        
        // Note: In real scenario this would be @MainActor, but mock allows testing
        let request = TTPTransactionRequest(
            amount: Decimal(100.0),
            currencyCode: "USD",
            subTotal: "100.00",
            orderId: nil,
            surchargeRate: nil
        )
        let result = try await sdk.ttp.performTransaction(request: request)
        #expect(result.transactionId == "ttp-transaction-id")
        #expect(result.status == TTPTransactionStatus.approved)
        #expect(mockTTPService.performTransactionCallCount == 1)
        
        // Step 3: Abort transaction (if needed)
        mockTTPService.abortTransactionResult = .success(true)
        let aborted = try await sdk.ttp.abortTransaction()
        #expect(aborted == true)
        #expect(mockTTPService.abortTransactionCallCount == 1)
    }
    
    @Test("TTP eventsStream integration")
    func testTTPEventsStreamIntegration() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        let mockTTPService = MockTTPService()
        
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: session,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: session,
            authApi: mockAuthApi,
            tokenService: tokenService,
            ttpService: mockTTPService
        )
        
        // Create event stream
        let eventStream = try sdk.ttp.eventsStream()
        #expect(mockTTPService.eventsStreamCallCount == 1)
        
        // Stream should be accessible (though empty in mock)
        var eventCount = 0
        for try await _ in eventStream {
            eventCount += 1
        }
        #expect(eventCount == 0) // Mock stream is empty
    }
    
    // MARK: - Device Management Flow Tests
    
    @Test("Full device flow: getDevices -> getDeviceInfo")
    func testFullDeviceFlow() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        // Setup authentication
        let authResult = AuthenticationResult(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(authResult)
        
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: session,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: session,
            authApi: mockAuthApi,
            tokenService: tokenService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService
        )
        
        // Authenticate
        _ = try await sdk.authenticate(clientId: "test-client-id", clientSecret: "test-client-secret")
        
        // Step 1: Get devices
        let devicesResponse = DevicesResponse(devices: [])
        mockDevicesService.getDevicesResult = .success(devicesResponse)
        
        let devices = try await sdk.getDevices()
        #expect(devices.devices.isEmpty == true)
        #expect(mockDevicesService.getDevicesCallCount == 1)
        
        // Step 2: Get device info
        let deviceId = "test-device-id"
        let deviceInfo = DeviceInfo(
            deviceId: deviceId,
            deviceName: "Test Device",
            lastLoginAt: Date(),
            tapToPayStatus: "Active",
            tapToPayStatusId: 1,
            tapToPayEnabled: true,
            userProfiles: []
        )
        mockDevicesService.deviceInfoResult = .success(deviceInfo)
        
        let info = try await sdk.getDeviceInfo(deviceId: deviceId)
        #expect(info.deviceId == deviceId)
        #expect(info.deviceName == "Test Device")
        #expect(mockDevicesService.getDeviceInfoCallCount == 1)
    }
    
    // MARK: - Error Propagation Tests
    
    @Test("NetworkError propagation: NetworkError -> Service -> SDK -> Client")
    func testNetworkErrorPropagation() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        let mockTransactionsService = MockTransactionsService()
        let mockTTPService = MockTTPService()
        
        // Setup authentication
        let authResult = AuthenticationResult(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(authResult)
        
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: session,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: session,
            authApi: mockAuthApi,
            tokenService: tokenService,
            transactionsService: mockTransactionsService,
            ttpService: mockTTPService
        )
        
        // Authenticate
        _ = try await sdk.authenticate(clientId: "test-client-id", clientSecret: "test-client-secret")
        
        // Simulate network error
        let networkError = URLError(.notConnectedToInternet)
        mockTransactionsService.getTransactionDetailsResult = .failure(AriseApiError.networkError(networkError.localizedDescription))
        
        // Error should propagate to client
        await Test.assertThrowsError {
            _ = try await sdk.getTransactionDetails(id: "test-id")
        }
    }
    
    @Test("APIError propagation: APIError -> Service -> SDK -> Client")
    func testAPIErrorPropagation() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        let mockTransactionsService = MockTransactionsService()
        let mockTTPService = MockTTPService()
        
        // Setup authentication
        let authResult = AuthenticationResult(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(authResult)
        
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: session,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: session,
            authApi: mockAuthApi,
            tokenService: tokenService,
            transactionsService: mockTransactionsService,
            ttpService: mockTTPService
        )
        
        // Authenticate
        _ = try await sdk.authenticate(clientId: "test-client-id", clientSecret: "test-client-secret")
        
        // Simulate API error
        mockTransactionsService.getTransactionDetailsResult = .failure(AriseApiError.notFound("Transaction not found", nil))
        
        // Error should propagate to client
        await Test.assertThrowsError {
            _ = try await sdk.getTransactionDetails(id: "non-existent-id")
        }
    }
    
    // MARK: - Concurrent Operations Tests
    
    @Test("Concurrent transaction requests")
    func testConcurrentTransactionRequests() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        let mockTransactionsService = MockTransactionsService()
        let mockTTPService = MockTTPService()
        
        // Setup authentication
        let authResult = AuthenticationResult(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(authResult)
        
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: session,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: session,
            authApi: mockAuthApi,
            tokenService: tokenService,
            transactionsService: mockTransactionsService,
            ttpService: mockTTPService
        )
        
        // Authenticate
        _ = try await sdk.authenticate(clientId: "test-client-id", clientSecret: "test-client-secret")
        
        // Setup mock responses
        let transactionDetails = TransactionFactory.createTransactionDetails(
            transactionId: "concurrent-transaction-id",
            amount: 100.0,
            status: "Approved"
        )
        mockTransactionsService.getTransactionDetailsResult = .success(transactionDetails)
        
        // Perform concurrent requests
        try await withThrowingTaskGroup(of: TransactionDetails?.self) { group in
            for i in 0..<5 {
                group.addTask {
                    try await sdk.getTransactionDetails(id: "concurrent-transaction-id-\(i)")
                }
            }
            
            var results: [TransactionDetails?] = []
            for try await result in group {
                results.append(result)
            }
            
            // All should succeed
            #expect(results.count == 5)
        }
        
        // Verify all requests were made
        #expect(mockTransactionsService.getTransactionDetailsCallCount == 5)
    }
    
    @Test("Concurrent TTP operations")
    func testConcurrentTTPOperations() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        let mockTTPService = MockTTPService()
        
        // Setup authentication
        let authResult = AuthenticationResult(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(authResult)
        
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: session,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: session,
            authApi: mockAuthApi,
            tokenService: tokenService,
            ttpService: mockTTPService
        )
        
        // Authenticate
        _ = try await sdk.authenticate(clientId: "test-client-id", clientSecret: "test-client-secret")
        
        // Setup mock responses
        mockTTPService.getStatusResult = .success(.active)
        
        // Perform concurrent status checks
        try await withThrowingTaskGroup(of: TTPStatus.self) { group in
            for _ in 0..<3 {
                group.addTask {
                    try await sdk.ttp.getStatus()
                }
            }
            
            var results: [TTPStatus] = []
            for try await result in group {
                results.append(result)
            }
            
            // All should succeed
            #expect(results.count == 3)
            #expect(results.allSatisfy { $0 == .active })
        }
        
        // Verify all requests were made
        #expect(mockTTPService.getStatusCallCount == 3)
    }
    
    @Test("Race conditions in token refresh")
    func testRaceConditionsInTokenRefresh() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        
        // Setup expired token
        let expiredToken = AriseTokenStorage.StoredToken(
            accessToken: "old-token",
            refreshToken: "refresh-token",
            tokenType: "Bearer",
            expiresAt: Date().addingTimeInterval(-3600) // Expired
        )
        try mockTokenStorage.save(AuthenticationResult(
            accessToken: "old-token",
            refreshToken: "refresh-token",
            expiresIn: -3600,
            tokenType: "Bearer"
        ))
        session.setToken(expiredToken)
        session.setCredentials(clientId: "test-client-id", clientSecret: "test-client-secret")
        
        // Setup refresh response
        let refreshResult = AuthenticationResult(
            accessToken: "new-token",
            refreshToken: "new-refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.refreshTokenResult = .success(refreshResult)
        
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: session,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: session,
            authApi: mockAuthApi,
            tokenService: tokenService
        )
        
        // Concurrent refresh attempts should be handled gracefully
        try await withThrowingTaskGroup(of: AuthenticationResult.self) { group in
            for _ in 0..<3 {
                group.addTask {
                    try await sdk.refreshAccessToken()
                }
            }
            
            var results: [AuthenticationResult] = []
            for try await result in group {
                results.append(result)
            }
            
            // All should succeed (implementation should handle race conditions)
            #expect(results.count == 3)
        }
    }
    
    // MARK: - Network Failure Scenarios Tests
    
    @Test("Network timeout handling for API methods")
    func testNetworkTimeoutHandling() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        let mockTransactionsService = MockTransactionsService()
        let mockTTPService = MockTTPService()
        
        // Setup authentication
        let authResult = AuthenticationResult(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(authResult)
        
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: session,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: session,
            authApi: mockAuthApi,
            tokenService: tokenService,
            transactionsService: mockTransactionsService,
            ttpService: mockTTPService
        )
        
        // Authenticate
        _ = try await sdk.authenticate(clientId: "test-client-id", clientSecret: "test-client-secret")
        
        // Simulate timeout error
        let timeoutError = URLError(.timedOut)
        mockTransactionsService.getTransactionDetailsResult = .failure(AriseApiError.networkError(timeoutError.localizedDescription))
        
        // Should throw network error
        await Test.assertThrowsError {
            _ = try await sdk.getTransactionDetails(id: "test-id")
        }
    }
    
    @Test("Network connectivity loss scenarios")
    func testNetworkConnectivityLoss() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        let mockTransactionsService = MockTransactionsService()
        let mockTTPService = MockTTPService()
        
        // Setup authentication
        let authResult = AuthenticationResult(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(authResult)
        
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: session,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: session,
            authApi: mockAuthApi,
            tokenService: tokenService,
            transactionsService: mockTransactionsService,
            ttpService: mockTTPService
        )
        
        // Authenticate
        _ = try await sdk.authenticate(clientId: "test-client-id", clientSecret: "test-client-secret")
        
        // Simulate connectivity loss
        let connectivityError = URLError(.notConnectedToInternet)
        mockTransactionsService.getTransactionsResult = .failure(AriseApiError.networkError(connectivityError.localizedDescription))
        
        // Should throw network error
        await Test.assertThrowsError {
            _ = try await sdk.getTransactions()
        }
    }
}

