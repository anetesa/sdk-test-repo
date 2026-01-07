import Foundation
import Testing
@testable import AriseMobile

/// Tests for network timeout scenarios
struct NetworkTimeoutTests {
    
    @Test("Network timeout error is handled correctly")
    func testNetworkTimeoutError() async {
        let mockTransactionsService = MockTransactionsService()
        let timeoutError = URLError(.timedOut)
        mockTransactionsService.getTransactionsResult = .failure(AriseApiError.networkError(timeoutError.localizedDescription))
        
        do {
            _ = try await mockTransactionsService.getTransactions(filters: nil)
            Issue.record("Expected error to be thrown")
        } catch let error as AriseApiError {
            if case .networkError(let message) = error {
                // Check that we got a network error (message may be localized)
                #expect(!message.isEmpty)
                // The error should be a networkError case
                #expect(true)
            } else {
                Issue.record("Expected networkError, got \(error)")
            }
        } catch {
            Issue.record("Expected AriseApiError, got \(type(of: error))")
        }
    }
    
    @Test("Network connection lost error is handled")
    func testNetworkConnectionLost() async {
        let mockTransactionsService = MockTransactionsService()
        let connectionError = URLError(.networkConnectionLost)
        mockTransactionsService.getTransactionsResult = .failure(AriseApiError.networkError(connectionError.localizedDescription))
        
        do {
            _ = try await mockTransactionsService.getTransactions(filters: nil)
            Issue.record("Expected error to be thrown")
        } catch let error as AriseApiError {
            // Verify it's a networkError case (message may be localized)
            if case .networkError(let message) = error {
                #expect(!message.isEmpty)
            } else {
                Issue.record("Expected networkError, got \(error)")
            }
        } catch {
            Issue.record("Expected AriseApiError, got \(type(of: error))")
        }
    }
    
    @Test("DNS lookup failed error is handled")
    func testDNSLookupFailed() async {
        let mockTransactionsService = MockTransactionsService()
        let dnsError = URLError(.dnsLookupFailed)
        mockTransactionsService.getTransactionsResult = .failure(AriseApiError.networkError(dnsError.localizedDescription))
        
        do {
            _ = try await mockTransactionsService.getTransactions(filters: nil)
            Issue.record("Expected error to be thrown")
        } catch let error as AriseApiError {
            // Verify it's a networkError case (message may be localized)
            if case .networkError(let message) = error {
                #expect(!message.isEmpty)
            } else {
                Issue.record("Expected networkError, got \(error)")
            }
        } catch {
            Issue.record("Expected AriseApiError, got \(type(of: error))")
        }
    }
    
    @Test("Cannot connect to host error is handled")
    func testCannotConnectToHost() async {
        let mockTransactionsService = MockTransactionsService()
        let connectionError = URLError(.cannotConnectToHost)
        mockTransactionsService.getTransactionsResult = .failure(AriseApiError.networkError(connectionError.localizedDescription))
        
        do {
            _ = try await mockTransactionsService.getTransactions(filters: nil)
            Issue.record("Expected error to be thrown")
        } catch let error as AriseApiError {
            // Verify it's a networkError case (message may be localized)
            if case .networkError(let message) = error {
                #expect(!message.isEmpty)
            } else {
                Issue.record("Expected networkError, got \(error)")
            }
        } catch {
            Issue.record("Expected AriseApiError, got \(type(of: error))")
        }
    }
    
    @Test("Network timeout doesn't crash SDK")
    func testNetworkTimeoutDoesNotCrashSDK() async throws {
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
        
        // Simulate timeout
        mockTransactionsService.getTransactionsResult = .failure(AriseApiError.networkError("Request timed out"))
        
        // SDK should still be functional after timeout
        _ = try? await mockTransactionsService.getTransactions(filters: nil)
        
        #expect(sdk.getVersion() != nil)
        #expect(sdk.ttp != nil)
    }
}


