import Foundation
import OpenAPIURLSession
import OpenAPIRuntime
@testable import AriseMobile

/// Mock API client for network testing
/// This is a simplified mock that can be extended based on specific test needs
final class MockApiClient {
    
    // MARK: - Configuration
    
    var shouldFail = false
    var error: Error?
    var responseDelay: TimeInterval = 0
    
    // MARK: - Call Tracking
    
    private(set) var requestCount = 0
    private(set) var lastRequest: Any?
    
    // MARK: - Reset
    
    func reset() {
        shouldFail = false
        error = nil
        responseDelay = 0
        requestCount = 0
        lastRequest = nil
    }
    
    // MARK: - Mock Methods
    
    func execute<T>(_ request: @escaping () async throws -> T) async throws -> T {
        requestCount += 1
        lastRequest = request
        
        if responseDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(responseDelay * 1_000_000_000))
        }
        
        if shouldFail {
            if let error = error {
                throw error
            } else {
                throw NSError(domain: "MockApiClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock API client failure"])
            }
        }
        
        return try await request()
    }
}

/// Mock implementation of BaseApiClient for testing
final class MockBaseApiClient: BaseApiClient, @unchecked Sendable {
    
    var mockClient: MockApiClient
    
    init(tokenService: TokenService, environmentSettings: EnvironmentSettings, mockClient: MockApiClient = MockApiClient()) {
        self.mockClient = mockClient
        super.init(tokenService: tokenService, environmentSettings: environmentSettings, queueLabel: "com.arise.mobile.sdk.test.api")
    }
    
    override func getApiClient() throws -> Client {
        // In tests, we might want to throw an error or return a mock
        // For now, this will throw to indicate that a real client shouldn't be used in tests
        throw NSError(domain: "MockBaseApiClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Use mockClient instead of getApiClient() in tests"])
    }
}

