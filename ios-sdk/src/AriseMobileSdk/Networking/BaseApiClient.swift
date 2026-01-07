import Foundation
import OpenAPIURLSession
import OpenAPIRuntime

/// Base class for API clients providing common functionality:
/// - Thread-safe API configuration
/// - Token management and automatic refresh
/// - Error handling
/// - Request/response logging
internal class BaseApiClient: @unchecked Sendable {
    
    let _logger = AriseLogger.shared
    let _environmentSettings: EnvironmentSettings
    let _tokenService: TokenService
    
    // Instance-level configuration to avoid global state conflicts
    var instanceBaseURL: String {
        _environmentSettings.apiBaseUrl
    }
    
    // Serial queue for thread-safe access to API client configuration
    // Each subclass should use its own queue label for better debugging
    let configurationQueue: DispatchQueue
    
    // Swift OpenAPI Generator client instance
    // Created lazily with proper configuration
    private var _apiClient: Client?
    // Track the token used to create the current client
    private var _cachedToken: String?
        
    init(tokenService: TokenService, environmentSettings: EnvironmentSettings, queueLabel: String) {
        self._environmentSettings = environmentSettings
        self._tokenService = tokenService
        self.configurationQueue = DispatchQueue(label: queueLabel, qos: .utility)
        _logger.verbose("\(String(describing: type(of: self))) initialized for environment: \(environmentSettings)")
    }
    
    /// Get or create API client instance with proper configuration
    /// Thread-safe: uses serial queue to ensure single instance creation
    /// Caches client instance and only recreates when token changes
    /// 
    /// Note: Recreates client when token changes since Swift OpenAPI Generator's Client
    /// doesn't support updating middleware after initialization.
    /// 
    /// - Parameter token: Authentication token
    /// - Returns: Configured API client instance
    /// - Throws: AriseApiError if base URL is invalid
    func getApiClient() throws -> Client {
        var result: Client!
        let work: () -> Void = {
            // Get current token from session (may have been updated by TokenRefreshMiddleware)
            // Use session token if available, otherwise use provided token
            // FIX: Use tokenService's token instead of global AriseSession.shared to ensure correct session
            // BaseApiClient doesn't have direct access to session, but TokenService does
            // Since getAccessToken() in BaseApiClient calls _tokenService.getAccessToken(), we can use that pattern
            // But we can't call async here.
            // However, we know TokenService holds the session. We should rely on what was passed to us.
            
            // NOTE: We cannot access _tokenService.session directly as it's private in TokenService?
            // Wait, TokenService is internal. Let's see if session is accessible.
            // TokenService doesn't expose session publicly.
            // BUT, AriseSession.shared is the culprit.
            
            // Strategy: We rely on the token being passed into executeWithConfiguration, OR
            // we assume that if we are inside the SDK, we should use the token from the TokenService we have reference to.
            // But getApiClient is synchronous inside the block.
            
            // Let's modify BaseApiClient to NOT read from AriseSession.shared.
            // It should read from somewhere else.
            // Actually, getApiClient should probably take an optional token argument?
            // Or we assume the token was refreshed?
            
            // If we look at `executeWithConfiguration`, it calls `getApiClient`.
            // But `getApiClient` doesn't take a token.
            
            // Wait, the `work` closure captures `self`.
            // We can't easily get the token synchronously from `_tokenService` if it's async?
            // `_tokenService.getAccessToken()` is async.
            
            // But `BaseApiClient` has `_tokenService`.
            // Can we add a synchronous property to `TokenService` to get the current token from its session?
            // Yes, let's do that.
            
            // For now, let's look at what we can change here.
            // If I can't change TokenService right now (I can, it's in the repo), I should.
            
            // Let's assume I will add `currentAccessToken` property to TokenService.
            let currentToken = self._tokenService.currentAccessToken
            
            // Check if we can reuse existing client
            if let existingClient = self._apiClient,
               let cachedToken = self._cachedToken,
               cachedToken == currentToken {
                result = existingClient
                return
            }
            
            // Validate URL
            guard let serverURL = URL(string: self.instanceBaseURL) else {
                // Use error instead of fatalError for graceful error handling
                result = nil
                self._logger.error("❌ Invalid base URL: \(self.instanceBaseURL)")
                return
            }
            
            // Create closure for token refresh
            // After token refresh, invalidate the client so it will be recreated with new token
            // Note: Token is updated in AriseSession by TokenRefreshService before this returns
            // The cache invalidation ensures next getApiClient call will fetch the new token from session
            let refreshTokenClosure: @Sendable () async throws -> String = { [weak self] in
                guard let self = self else {
                    throw NSError(domain: "AriseMobileSdk", code: -1, userInfo: [NSLocalizedDescriptionKey: "BaseApiClient deallocated"])
                }
                let refreshResult = try await self._tokenService.refreshToken()
                
                // Invalidate client cache synchronously to prevent race conditions
                // Token is already updated in AriseSession by tokenRefreshService.refreshToken()
                // We use sync to ensure cache invalidation happens before any new client creation
                // Note: This is safe because refreshTokenClosure is called from middleware, not from configurationQueue
                self.configurationQueue.sync(execute: {
                    self._apiClient = nil
                    self._cachedToken = nil
                })
                
                return refreshResult.accessToken
            }
            
            // Create new client with current token
            // RequestLoggingMiddleware will log all HTTP requests
            // Use FlexibleISO8601DateTranscoder to handle dates with and without fractional seconds
            let client = Client(
                serverURL: serverURL,
                configuration: Configuration(dateTranscoder: FlexibleISO8601DateTranscoder.shared),
                transport: URLSessionTransport(),
                middlewares: [
                    RequestLoggingMiddleware(logger: self._logger),
                    AuthenticationMiddleware(token: currentToken),
                    ErrorLoggingMiddleware(logger: self._logger),
                    ErrorHandlingMiddleware(logger: self._logger),
                    TokenRefreshMiddleware(logger: self._logger, refreshTokenClosure: refreshTokenClosure),
                    ResponseLoggingMiddleware(logger: self._logger)
                ]
            )
            
            self._apiClient = client
            self._cachedToken = currentToken
            result = client
        }
        configurationQueue.sync(execute: work)
        
        // Handle invalid URL error
        guard let client = result else {
            throw AriseApiError.networkError("Invalid base URL: \(instanceBaseURL)")
        }
        
        return client
    }
    
    /// Execute API request with thread-safe configuration
    /// Creates/updates API client with proper authentication
    /// Centralizes error handling for all API clients
    func executeWithConfiguration<T>(token: String, execute: @escaping () async throws -> T) async throws -> T {
        // Ensure client is created with current token (getApiClient handles this)
        _ = try getApiClient()
        
        // RequestLoggingMiddleware will log all HTTP requests
        do {
            return try await execute()
        } catch let urlError as URLError {
            // Handle network errors centrally
            _logger.error("❌ Network Error: \(urlError.localizedDescription)")
            throw createNetworkError(urlError.localizedDescription)
        } catch let error as AriseApiError {
            // Re-throw AriseApiError as-is (created by handleApiErrorResponse)
            throw error
        } catch {
            // All other errors (decoding errors, HTTP errors) are handled by handleApiErrorResponse
            // which is called from subclasses when needed
            throw error
        }
    }
    
    /// Create a network error
    /// Can be overridden by subclasses if needed
    func createNetworkError(_ message: String) -> Error {
        return AriseApiError.networkError(message)
    }
    
    /// Get access token from session or storage
    /// Session automatically restores token from persistent storage on first access
    func getAccessToken() async -> String? {
        return await _tokenService.getAccessToken()
    }
        
}
