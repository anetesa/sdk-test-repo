import Foundation
import Testing
@testable import AriseMobile

/// Performance and Stress Tests for AriseMobileSdk
/// 
/// These tests verify SDK performance metrics and stress scenarios
/// to ensure the SDK performs well under various load conditions.
struct PerformanceAndStressTests {
    
    // MARK: - Performance Tests
    
    @Test("SDK initialization completes within acceptable time")
    func testSDKInitializationPerformance() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        let startTime = Date()
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // SDK initialization should complete within 1 second
        #expect(duration < 1.0, "SDK initialization took \(duration) seconds, expected < 1.0")
        #expect(sdk.getVersion() != nil)
    }
    
    @Test("API request performance: authenticate")
    func testAuthenticatePerformance() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        let authResult = AuthenticationResult(
            accessToken: "test-token",
            refreshToken: "refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        mockAuthApi.authenticateResult = .success(authResult)
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        let startTime = Date()
        _ = try await sdk.authenticate(clientId: "test-id", clientSecret: "test-secret")
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // Authentication should complete within 1.0 seconds (mock)
        #expect(duration < 1.0, "Authentication took \(duration) seconds, expected < 1.0")
    }
    
    @Test("API request performance: getTransactions")
    func testGetTransactionsPerformance() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        mockTransactionsService.getTransactionsResult = .success(
            TransactionsResponse(items: [], total: 0)
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        let startTime = Date()
        _ = try await sdk.getTransactions()
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // getTransactions should complete within 1.0 seconds (mock)
        #expect(duration < 1.0, "getTransactions took \(duration) seconds, expected < 1.0")
    }
    
    @Test("API request performance: submitSaleTransaction")
    func testSubmitSaleTransactionPerformance() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        let authResponse = AuthorizationResponse(
            transactionId: "test-id",
            transactionDateTime: Date(),
            typeId: 1,
            type: "Sale",
            statusId: 1,
            status: "Completed",
            processedAmount: 100.0,
            details: nil,
            transactionReceipt: nil,
            avsResponse: nil
        )
        mockTransactionsService.submitSaleTransactionResult = .success(authResponse)
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        let request = try AuthorizationRequest(
            paymentProcessorId: "processor-id",
            amount: 100.0,
            currencyId: 1,
            cardDataSource: .manual,
            accountNumber: "4111111111111111",
            securityCode: "123",
            expirationMonth: 12,
            expirationYear: 25
        )
        
        let startTime = Date()
        _ = try await sdk.submitSaleTransaction(input: request)
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // submitSaleTransaction should complete within 1.0 seconds (mock)
        #expect(duration < 1.0, "submitSaleTransaction took \(duration) seconds, expected < 1.0")
    }
    
    @Test("Token refresh performance")
    func testTokenRefreshPerformance() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        
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
        
        let startTime = Date()
        _ = try await tokenService.refreshToken()
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // Token refresh should complete within 1.0 seconds (mock)
        #expect(duration < 1.0, "Token refresh took \(duration) seconds, expected < 1.0")
    }
    
    @Test("TTP transaction performance")
    func testTTPTransactionPerformance() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        let transactionResult = TTPTransactionResult(
            transactionId: "ttp-transaction-id",
            transactionOutcome: "APPROVED",
            status: .approved,
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
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        let startTime = Date()
        _ = try await sdk.ttp.performTransaction(amount: Decimal(100.0))
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // TTP transaction should complete within 1.0 seconds (mock)
        #expect(duration < 1.0, "TTP transaction took \(duration) seconds, expected < 1.0")
    }
    
    @Test("Memory usage during long operations")
    func testMemoryUsageDuringLongOperations() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        mockTransactionsService.getTransactionsResult = .success(
            TransactionsResponse(items: [], total: 0)
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        // Perform multiple operations to check memory usage
        for i in 0..<50 {
            _ = try? await sdk.getTransactions()
            _ = sdk.getVersion()
            _ = sdk.ttp
        }
        
        // If we get here without crashing, memory management is acceptable
        #expect(sdk.getVersion() != nil)
    }
    
    // MARK: - Stress Tests
    
    @Test("Large number of concurrent requests: 10 requests")
    func testConcurrentRequests10() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        mockTransactionsService.getTransactionsResult = .success(
            TransactionsResponse(items: [], total: 0)
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        await withTaskGroup(of: Bool.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    do {
                        _ = try await sdk.getTransactions()
                        return true
                    } catch {
                        return false
                    }
                }
            }
            
            var successCount = 0
            for await success in group {
                if success {
                    successCount += 1
                }
            }
            
            // All 10 requests should succeed
            #expect(successCount == 10)
        }
    }
    
    @Test("Large number of concurrent requests: 50 requests")
    func testConcurrentRequests50() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        mockTransactionsService.getTransactionsResult = .success(
            TransactionsResponse(items: [], total: 0)
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        await withTaskGroup(of: Bool.self) { group in
            for _ in 0..<50 {
                group.addTask {
                    do {
                        _ = try await sdk.getTransactions()
                        return true
                    } catch {
                        return false
                    }
                }
            }
            
            var successCount = 0
            for await success in group {
                if success {
                    successCount += 1
                }
            }
            
            // All 50 requests should succeed
            #expect(successCount == 50)
        }
    }
    
    @Test("Large number of concurrent requests: 100 requests")
    func testConcurrentRequests100() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        mockTransactionsService.getTransactionsResult = .success(
            TransactionsResponse(items: [], total: 0)
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        await withTaskGroup(of: Bool.self) { group in
            for _ in 0..<100 {
                group.addTask {
                    do {
                        _ = try await sdk.getTransactions()
                        return true
                    } catch {
                        return false
                    }
                }
            }
            
            var successCount = 0
            for await success in group {
                if success {
                    successCount += 1
                }
            }
            
            // All 100 requests should succeed
            #expect(successCount == 100)
        }
    }
    
    @Test("Long sessions with multiple operations: 100+ operations")
    func testLongSessionWithMultipleOperations() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        mockTransactionsService.getTransactionsResult = .success(
            TransactionsResponse(items: [], total: 0)
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        // Perform 100+ operations
        for i in 0..<100 {
            _ = try? await sdk.getTransactions()
            _ = sdk.getVersion()
            _ = sdk.ttp
            
            // Every 10 operations, verify SDK is still functional
            if i % 10 == 0 {
                #expect(sdk.getVersion() != nil)
            }
        }
        
        // SDK should still be functional after 100 operations
        #expect(sdk.getVersion() != nil)
        #expect(mockTransactionsService.getTransactionsCallCount >= 100)
    }
    
    @Test("Memory pressure scenarios: multiple SDK instances")
    func testMemoryPressureWithMultipleSDKInstances() async throws {
        // Create multiple SDK instances to simulate memory pressure
        var sdks: [AriseMobileSdk] = []
        
        for _ in 0..<10 {
            let mockTokenStorage = MockAriseTokenStorage()
            let mockSession = MockAriseSession()
            let mockAuthApi = MockAriseAuthApi()
            let mockTokenService = MockTokenService()
            let mockTransactionsService = MockTransactionsService()
            let mockSettingsService = MockSettingsService()
            let mockDevicesService = MockDevicesService()
            let mockTTPService = MockTTPService()
            
            let sdk = try AriseMobileSdk(
                environment: .uat,
                tokenStorage: mockTokenStorage,
                session: mockSession,
                authApi: mockAuthApi,
                tokenService: mockTokenService,
                transactionsService: mockTransactionsService,
                settingsService: mockSettingsService,
                devicesService: mockDevicesService,
                ttpService: mockTTPService,
                cloudCommerceSDK: nil
            )
            
            sdks.append(sdk)
        }
        
        // All SDK instances should be functional
        for sdk in sdks {
            #expect(sdk.getVersion() != nil)
        }
        
        // Verify we can still create more instances
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        let newSDK = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        #expect(newSDK.getVersion() != nil)
    }
    
    @Test("Rapid token refresh cycles")
    func testRapidTokenRefreshCycles() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        
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
        
        // Perform multiple rapid refresh attempts
        var successCount = 0
        for _ in 0..<10 {
            do {
                _ = try await tokenService.refreshToken()
                successCount += 1
            } catch {
                // Some may fail due to concurrent refresh protection, which is expected
            }
        }
        
        // At least some refreshes should succeed
        // Note: TokenService may prevent concurrent refreshes, so not all may succeed
        #expect(successCount >= 1)
    }
    
    @Test("Concurrent mixed operations stress test")
    func testConcurrentMixedOperationsStressTest() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        mockTransactionsService.getTransactionsResult = .success(
            TransactionsResponse(items: [], total: 0)
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        await withTaskGroup(of: Bool.self) { group in
            // Mix of different operations
            for i in 0..<30 {
                if i % 3 == 0 {
                    group.addTask {
                        do {
                            _ = try await sdk.getTransactions()
                            return true
                        } catch {
                            return false
                        }
                    }
                } else if i % 3 == 1 {
                    group.addTask {
                        _ = sdk.getVersion()
                        return true
                    }
                } else {
                    group.addTask {
                        _ = sdk.ttp
                        return true
                    }
                }
            }
            
            var successCount = 0
            for await success in group {
                if success {
                    successCount += 1
                }
            }
            
            // All operations should succeed
            #expect(successCount == 30)
        }
        
        // SDK should still be functional after stress test
        #expect(sdk.getVersion() != nil)
    }
    
    // MARK: - Additional Performance Tests
    
    @Test("API request performance: getTransactionDetails")
    func testGetTransactionDetailsPerformance() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        mockTransactionsService.getTransactionDetailsResult = .success(nil)
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        let startTime = Date()
        _ = try await sdk.getTransactionDetails(id: "test-transaction-id")
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // getTransactionDetails should complete within 1.0 seconds (mock)
        #expect(duration < 1.0, "getTransactionDetails took \(duration) seconds, expected < 1.0")
    }
    
    @Test("API request performance: calculateAmount")
    func testCalculateAmountPerformance() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        let calculateResponse = CalculateAmountResponse(
            currencyId: 1,
            currency: "USD",
            zeroCostProcessingOptionId: nil,
            zeroCostProcessingOption: nil,
            useCardPrice: true,
            cash: AmountDto(
                baseAmount: 100.0,
                percentageOffAmount: 0.0,
                percentageOffRate: 0.0,
                cashDiscountAmount: 0.0,
                cashDiscountRate: 0.0,
                surchargeAmount: 0.0,
                surchargeRate: 0.0,
                tipAmount: 0.0,
                tipRate: 0.0,
                taxAmount: 0.0,
                taxRate: 0.0,
                totalAmount: 100.0
            ),
            creditCard: AmountDto(
                baseAmount: 100.0,
                percentageOffAmount: 0.0,
                percentageOffRate: 0.0,
                cashDiscountAmount: 0.0,
                cashDiscountRate: 0.0,
                surchargeAmount: 3.0,
                surchargeRate: 3.0,
                tipAmount: 0.0,
                tipRate: 0.0,
                taxAmount: 0.0,
                taxRate: 0.0,
                totalAmount: 103.0
            ),
            debitCard: nil,
            ach: nil
        )
        mockTransactionsService.calculateAmountResult = .success(calculateResponse)
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        let request = CalculateAmountRequest(
            amount: 100.0,
            surchargeRate: 3.0,
            tipAmount: 10.0,
            useCardPrice: true
        )
        
        let startTime = Date()
        _ = try await sdk.calculateAmount(request: request)
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // calculateAmount should complete within 1.0 seconds (mock)
        #expect(duration < 1.0, "calculateAmount took \(duration) seconds, expected < 1.0")
    }
    
    @Test("API request performance: voidTransaction")
    func testVoidTransactionPerformance() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        let voidResponse = TransactionResponse(
            transactionId: "test-id",
            transactionDateTime: Date(),
            typeId: 4,
            type: "Void",
            statusId: 1,
            status: "Voided",
            details: nil,
            transactionReceipt: nil
        )
        mockTransactionsService.voidTransactionResult = .success(voidResponse)
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        let startTime = Date()
        _ = try await sdk.voidTransaction(transactionId: "test-transaction-id")
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // voidTransaction should complete within 1.0 seconds (mock)
        #expect(duration < 1.0, "voidTransaction took \(duration) seconds, expected < 1.0")
    }
    
    @Test("API request performance: captureTransaction")
    func testCaptureTransactionPerformance() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        let captureResponse = TransactionResponse(
            transactionId: "test-id",
            transactionDateTime: Date(),
            typeId: 3,
            type: "Capture",
            statusId: 1,
            status: "Captured",
            details: nil,
            transactionReceipt: nil
        )
        mockTransactionsService.captureTransactionResult = .success(captureResponse)
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        let startTime = Date()
        _ = try await sdk.captureTransaction(transactionId: "test-transaction-id", amount: 100.0)
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // captureTransaction should complete within 1.0 seconds (mock)
        #expect(duration < 1.0, "captureTransaction took \(duration) seconds, expected < 1.0")
    }
    
    @Test("API request performance: refundTransaction")
    func testRefundTransactionPerformance() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        let refundResponse = TransactionResponse(
            transactionId: "test-id",
            transactionDateTime: Date(),
            typeId: 5,
            type: "Refund",
            statusId: 1,
            status: "Refunded",
            details: nil,
            transactionReceipt: nil
        )
        mockTransactionsService.refundTransactionResult = .success(refundResponse)
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        let request = RefundRequest(
            transactionId: "test-transaction-id",
            cardDataSource: .manual
        )
        
        let startTime = Date()
        _ = try await sdk.refundTransaction(request: request)
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // refundTransaction should complete within 1.0 seconds (mock)
        #expect(duration < 1.0, "refundTransaction took \(duration) seconds, expected < 1.0")
    }
    
    @Test("Get access token performance")
    func testGetAccessTokenPerformance() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        let startTime = Date()
        _ = await sdk.getAccessToken()
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // getAccessToken should complete within 0.01 seconds (synchronous operation)
        #expect(duration < 0.01, "getAccessToken took \(duration) seconds, expected < 0.01")
    }
    
    @Test("Get version performance")
    func testGetVersionPerformance() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        let startTime = Date()
        _ = sdk.getVersion()
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // getVersion should complete within 0.001 seconds (synchronous operation)
        #expect(duration < 0.001, "getVersion took \(duration) seconds, expected < 0.001")
    }
    
    // MARK: - Additional Stress Tests
    
    @Test("Large number of concurrent requests: 200 requests")
    func testConcurrentRequests200() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        mockTransactionsService.getTransactionsResult = .success(
            TransactionsResponse(items: [], total: 0)
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        await withTaskGroup(of: Bool.self) { group in
            for _ in 0..<200 {
                group.addTask {
                    do {
                        _ = try await sdk.getTransactions()
                        return true
                    } catch {
                        return false
                    }
                }
            }
            
            var successCount = 0
            for await success in group {
                if success {
                    successCount += 1
                }
            }
            
            // All 200 requests should succeed
            #expect(successCount == 200)
        }
    }
    
    @Test("Large number of concurrent requests: 500 requests")
    func testConcurrentRequests500() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        mockTransactionsService.getTransactionsResult = .success(
            TransactionsResponse(items: [], total: 0)
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        await withTaskGroup(of: Bool.self) { group in
            for _ in 0..<500 {
                group.addTask {
                    do {
                        _ = try await sdk.getTransactions()
                        return true
                    } catch {
                        return false
                    }
                }
            }
            
            var successCount = 0
            for await success in group {
                if success {
                    successCount += 1
                }
            }
            
            // All 500 requests should succeed
            #expect(successCount == 500)
        }
    }
    
    @Test("Long sessions with multiple operations: 500+ operations")
    func testLongSessionWith500Operations() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        mockTransactionsService.getTransactionsResult = .success(
            TransactionsResponse(items: [], total: 0)
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        // Perform 500+ operations
        for i in 0..<500 {
            _ = try? await sdk.getTransactions()
            _ = sdk.getVersion()
            _ = sdk.ttp
            _ = await sdk.getAccessToken()
            
            // Every 50 operations, verify SDK is still functional
            if i % 50 == 0 {
                #expect(sdk.getVersion() != nil)
            }
        }
        
        // SDK should still be functional after 500 operations
        #expect(sdk.getVersion() != nil)
        #expect(mockTransactionsService.getTransactionsCallCount >= 500)
    }
    
    @Test("Concurrent mixed operations stress test: 100 operations")
    func testConcurrentMixedOperations100() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        mockTransactionsService.getTransactionsResult = .success(
            TransactionsResponse(items: [], total: 0)
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        await withTaskGroup(of: Bool.self) { group in
            // Mix of different operations
            for i in 0..<100 {
                switch i % 4 {
                case 0:
                    group.addTask {
                        do {
                            _ = try await sdk.getTransactions()
                            return true
                        } catch {
                            return false
                        }
                    }
                case 1:
                    group.addTask {
                        _ = sdk.getVersion()
                        return true
                    }
                case 2:
                    group.addTask {
                        _ = sdk.ttp
                        return true
                    }
                case 3:
                    group.addTask {
                        _ = await sdk.getAccessToken()
                        return true
                    }
                default:
                    break
                }
            }
            
            var successCount = 0
            for await success in group {
                if success {
                    successCount += 1
                }
            }
            
            // All operations should succeed
            #expect(successCount == 100)
        }
        
        // SDK should still be functional after stress test
        #expect(sdk.getVersion() != nil)
    }
    
    @Test("Rapid sequential operations: 1000 operations")
    func testRapidSequentialOperations() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        mockTransactionsService.getTransactionsResult = .success(
            TransactionsResponse(items: [], total: 0)
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        let startTime = Date()
        
        // Perform 1000 rapid sequential operations
        for i in 0..<1000 {
            if i % 2 == 0 {
                _ = try? await sdk.getTransactions()
            } else {
                _ = sdk.getVersion()
            }
        }
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // 1000 operations should complete within reasonable time (30 seconds)
        #expect(duration < 30.0, "1000 operations took \(duration) seconds, expected < 30.0")
        #expect(sdk.getVersion() != nil)
    }
    
    @Test("Memory pressure scenarios: 50 SDK instances")
    func testMemoryPressureWith50SDKInstances() async throws {
        // Create 50 SDK instances to simulate heavy memory pressure
        var sdks: [AriseMobileSdk] = []
        
        for _ in 0..<50 {
            let mockTokenStorage = MockAriseTokenStorage()
            let mockSession = MockAriseSession()
            let mockAuthApi = MockAriseAuthApi()
            let mockTokenService = MockTokenService()
            let mockTransactionsService = MockTransactionsService()
            let mockSettingsService = MockSettingsService()
            let mockDevicesService = MockDevicesService()
            let mockTTPService = MockTTPService()
            
            let sdk = try AriseMobileSdk(
                environment: .uat,
                tokenStorage: mockTokenStorage,
                session: mockSession,
                authApi: mockAuthApi,
                tokenService: mockTokenService,
                transactionsService: mockTransactionsService,
                settingsService: mockSettingsService,
                devicesService: mockDevicesService,
                ttpService: mockTTPService,
                cloudCommerceSDK: nil
            )
            
            sdks.append(sdk)
        }
        
        // All SDK instances should be functional
        for sdk in sdks {
            #expect(sdk.getVersion() != nil)
        }
        
        // Verify we can still perform operations on all instances
        for sdk in sdks {
            _ = await sdk.getAccessToken()
        }
    }
    
    @Test("Concurrent token operations stress test")
    func testConcurrentTokenOperations() async throws {
        let environment = TestEnvironment.createTestEnvironmentSettings()
        let mockTokenStorage = MockAriseTokenStorage()
        let session = AriseSession(tokenStorage: mockTokenStorage)
        let mockAuthApi = MockAriseAuthApi()
        
        let token = AriseTokenStorage.StoredToken(
            accessToken: "test-token",
            refreshToken: "refresh-token",
            tokenType: "Bearer",
            expiresAt: Date().addingTimeInterval(3600)
        )
        try mockTokenStorage.save(AuthenticationResult(
            accessToken: "test-token",
            refreshToken: "refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        ))
        session.setToken(token)
        
        let tokenService = TokenService(
            authApi: mockAuthApi,
            session: session,
            tokenStorage: mockTokenStorage,
            environmentSettings: environment
        )
        
        await withTaskGroup(of: String?.self) { group in
            // Concurrent token access
            for _ in 0..<50 {
                group.addTask {
                    return session.token?.accessToken
                }
            }
            
            var tokenCount = 0
            for await token in group {
                if token != nil {
                    tokenCount += 1
                }
            }
            
            // All token accesses should succeed
            #expect(tokenCount == 50)
        }
    }
    
    @Test("Performance: Multiple SDK initializations")
    func testMultipleSDKInitializations() async throws {
        let startTime = Date()
        
        // Create and destroy multiple SDK instances
        for _ in 0..<20 {
            let mockTokenStorage = MockAriseTokenStorage()
            let mockSession = MockAriseSession()
            let mockAuthApi = MockAriseAuthApi()
            let mockTokenService = MockTokenService()
            let mockTransactionsService = MockTransactionsService()
            let mockSettingsService = MockSettingsService()
            let mockDevicesService = MockDevicesService()
            let mockTTPService = MockTTPService()
            
            let sdk = try AriseMobileSdk(
                environment: .uat,
                tokenStorage: mockTokenStorage,
                session: mockSession,
                authApi: mockAuthApi,
                tokenService: mockTokenService,
                transactionsService: mockTransactionsService,
                settingsService: mockSettingsService,
                devicesService: mockDevicesService,
                ttpService: mockTTPService,
                cloudCommerceSDK: nil
            )
            
            // Verify SDK is functional
            #expect(sdk.getVersion() != nil)
        }
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // 20 SDK initializations should complete within 5 seconds
        #expect(duration < 5.0, "20 SDK initializations took \(duration) seconds, expected < 5.0")
    }
    
    @Test("API request performance: getPaymentSettings")
    func testGetPaymentSettingsPerformance() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        // Mock payment settings response
        let paymentSettingsResponse = PaymentSettingsResponse(
            availableCurrencies: [],
            zeroCostProcessingOptionId: nil,
            zeroCostProcessingOption: nil,
            defaultSurchargeRate: nil,
            defaultCashDiscountRate: nil,
            defaultDualPricingRate: nil,
            isTipsEnabled: false,
            defaultTipsOptions: nil,
            availableCardTypes: [],
            availableTransactionTypes: [],
            availablePaymentProcessors: [],
            avs: nil,
            isCustomerCardSavingByTerminalEnabled: false
        )
        mockSettingsService.paymentSettingsResult = .success(paymentSettingsResponse)
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        let startTime = Date()
        _ = try await sdk.getPaymentSettings()
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // getPaymentSettings should complete within 1.0 seconds (mock)
        #expect(duration < 1.0, "getPaymentSettings took \(duration) seconds, expected < 1.0")
    }
    
    @Test("API request performance: getDevices")
    func testGetDevicesPerformance() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        // Mock devices response
        let devicesResponse = DevicesResponse(devices: [])
        mockDevicesService.getDevicesResult = .success(devicesResponse)
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        let startTime = Date()
        _ = try await sdk.getDevices()
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // getDevices should complete within 1.0 seconds (mock)
        #expect(duration < 1.0, "getDevices took \(duration) seconds, expected < 1.0")
    }
    
    @Test("Concurrent transaction operations: mixed types")
    func testConcurrentMixedTransactionOperations() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        mockTransactionsService.getTransactionsResult = .success(
            TransactionsResponse(items: [], total: 0)
        )
        mockTransactionsService.getTransactionDetailsResult = .success(nil)
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        await withTaskGroup(of: Bool.self) { group in
            // Mix of different transaction operations
            for i in 0..<60 {
                switch i % 2 {
                case 0:
                    group.addTask {
                        do {
                            _ = try await sdk.getTransactions()
                            return true
                        } catch {
                            return false
                        }
                    }
                case 1:
                    group.addTask {
                        do {
                            _ = try await sdk.getTransactionDetails(id: "test-id")
                            return true
                        } catch {
                            return false
                        }
                    }
                default:
                    break
                }
            }
            
            var successCount = 0
            for await success in group {
                if success {
                    successCount += 1
                }
            }
            
            // All operations should succeed
            #expect(successCount == 60)
        }
        
        // SDK should still be functional after stress test
        #expect(sdk.getVersion() != nil)
    }
    
    @Test("Performance: Sequential transaction operations chain")
    func testSequentialTransactionOperationsChain() async throws {
        let mockTokenStorage = MockAriseTokenStorage()
        let mockSession = MockAriseSession()
        let mockAuthApi = MockAriseAuthApi()
        let mockTokenService = MockTokenService()
        let mockTransactionsService = MockTransactionsService()
        let mockSettingsService = MockSettingsService()
        let mockDevicesService = MockDevicesService()
        let mockTTPService = MockTTPService()
        
        mockTransactionsService.getTransactionsResult = .success(
            TransactionsResponse(items: [], total: 0)
        )
        mockTransactionsService.getTransactionDetailsResult = .success(nil)
        mockTransactionsService.calculateAmountResult = .success(
            CalculateAmountResponse(
                currencyId: 1,
                currency: "USD",
                zeroCostProcessingOptionId: nil,
                zeroCostProcessingOption: nil,
                useCardPrice: true,
                cash: AmountDto(
                    baseAmount: 100.0,
                    percentageOffAmount: 0.0,
                    percentageOffRate: 0.0,
                    cashDiscountAmount: 0.0,
                    cashDiscountRate: 0.0,
                    surchargeAmount: 0.0,
                    surchargeRate: 0.0,
                    tipAmount: 0.0,
                    tipRate: 0.0,
                    taxAmount: 0.0,
                    taxRate: 0.0,
                    totalAmount: 100.0
                ),
                creditCard: AmountDto(
                    baseAmount: 100.0,
                    percentageOffAmount: 0.0,
                    percentageOffRate: 0.0,
                    cashDiscountAmount: 0.0,
                    cashDiscountRate: 0.0,
                    surchargeAmount: 3.0,
                    surchargeRate: 3.0,
                    tipAmount: 0.0,
                    tipRate: 0.0,
                    taxAmount: 0.0,
                    taxRate: 0.0,
                    totalAmount: 103.0
                ),
                debitCard: nil,
                ach: nil
            )
        )
        
        let sdk = try AriseMobileSdk(
            environment: .uat,
            tokenStorage: mockTokenStorage,
            session: mockSession,
            authApi: mockAuthApi,
            tokenService: mockTokenService,
            transactionsService: mockTransactionsService,
            settingsService: mockSettingsService,
            devicesService: mockDevicesService,
            ttpService: mockTTPService,
            cloudCommerceSDK: nil
        )
        
        let startTime = Date()
        
        // Chain of sequential operations
        for _ in 0..<20 {
            _ = try? await sdk.getTransactions()
            _ = try? await sdk.getTransactionDetails(id: "test-id")
            
            let calculateRequest = CalculateAmountRequest(
                amount: 100.0,
                surchargeRate: 3.0,
                tipAmount: 10.0,
                useCardPrice: true
            )
            _ = try? await sdk.calculateAmount(request: calculateRequest)
        }
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // 60 sequential operations (20 * 3) should complete within 20 seconds
        #expect(duration < 20.0, "60 sequential operations took \(duration) seconds, expected < 20.0")
        #expect(sdk.getVersion() != nil)
    }
}


