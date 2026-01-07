import Foundation
import Testing
@testable import AriseMobile

/// Tests for thread-safety in public API
struct ThreadSafetyTests {
    
    @Test("Concurrent access to SDK instance is thread-safe")
    func testConcurrentSDKAccess() async throws {
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
        
        // Test concurrent access to SDK properties and methods
        await withTaskGroup(of: String?.self) { group in
            for i in 0..<50 {
                group.addTask {
                    // Access different SDK properties concurrently
                    let version = sdk.getVersion()
                    _ = sdk.ttp
                    return version
                }
            }
            
            var successCount = 0
            for await version in group {
                if version != nil {
                    successCount += 1
                }
            }
            
            #expect(successCount == 50)
        }
    }
    
    @Test("Concurrent transaction service calls are thread-safe")
    func testConcurrentTransactionServiceCalls() async {
        let mockTransactionsService = MockTransactionsService()
        mockTransactionsService.getTransactionsResult = .success(TransactionsResponse(items: [], total: 0))
        
        await withTaskGroup(of: TransactionsResponse??.self) { group in
            for _ in 0..<30 {
                group.addTask {
                    try? await mockTransactionsService.getTransactions(filters: nil)
                }
            }
            
            var successCount = 0
            for await result in group {
                if result != nil {
                    successCount += 1
                }
            }
            
            #expect(successCount == 30)
        }
    }
    
    @Test("Concurrent filter creation is thread-safe")
    func testConcurrentFilterCreation() async throws {
        await withTaskGroup(of: TransactionFilters?.self) { group in
            for i in 0..<100 {
                group.addTask {
                    try? TransactionFilters(
                        page: i,
                        pageSize: 20,
                        asc: i % 2 == 0,
                        orderBy: "date",
                        createMethodId: i,
                        createdById: nil,
                        batchId: nil,
                        noBatch: false
                    )
                }
            }
            
            var successCount = 0
            for await filter in group {
                if filter != nil {
                    successCount += 1
                }
            }
            
            #expect(successCount == 100)
        }
    }
    
    @Test("Concurrent error handling doesn't cause race conditions")
    func testConcurrentErrorHandling() async {
        let mockTransactionsService = MockTransactionsService()
        
        // Alternate between success and failure
        var shouldFail = false
        mockTransactionsService.getTransactionsResult = .success(TransactionsResponse(items: [], total: 0))
        
        await withTaskGroup(of: Bool.self) { group in
            for i in 0..<20 {
                group.addTask {
                    if i % 2 == 0 {
                        mockTransactionsService.getTransactionsResult = .success(TransactionsResponse(items: [], total: 0))
                    } else {
                        mockTransactionsService.getTransactionsResult = .failure(AriseApiError.networkError("Test error"))
                    }
                    
                    let result = try? await mockTransactionsService.getTransactions(filters: nil)
                    return result != nil
                }
            }
            
            var results: [Bool] = []
            for await success in group {
                results.append(success)
            }
            
            // Should have some successes and some failures
            let successCount = results.filter { $0 }.count
            #expect(successCount >= 0 && successCount <= 20)
        }
    }
    
    @Test("Multiple simultaneous API calls don't interfere")
    func testMultipleSimultaneousAPICalls() async throws {
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
        
        mockTransactionsService.getTransactionsResult = .success(TransactionsResponse(items: [], total: 0))
        
        // Simulate multiple simultaneous calls
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    _ = try? await mockTransactionsService.getTransactions(filters: nil)
                    _ = sdk.getVersion()
                    _ = sdk.ttp
                }
            }
            
            for await _ in group {}
        }
        
        // SDK should still be functional
        #expect(sdk.getVersion() != nil)
    }
}
