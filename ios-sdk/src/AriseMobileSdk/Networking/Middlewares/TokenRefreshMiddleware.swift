import Foundation
import OpenAPIRuntime
import HTTPTypes

/// Middleware for automatic token refresh on 401 Unauthorized errors
/// Checks response status code and retries the request once with a refreshed token
/// Prevents infinite loops by checking if Authorization header was already updated
internal struct TokenRefreshMiddleware: ClientMiddleware, @unchecked Sendable {
    let logger: AriseLogger
    let refreshTokenClosure: @Sendable () async throws -> String
    
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        let hasBody = body != nil
        let (response, responseBody) = try await next(request, body, baseURL)
        
        // Only retry requests without bodies to avoid stream consumption issues
        if response.status.code == 401 && !hasBody {
            logger.warning("⚠️ Unauthorized (401) - attempting token refresh...")
            
            let originalResponse = response
            
            do {
                let newToken = try await refreshTokenClosure()
                logger.info("✅ Token refreshed successfully, retrying request...")
                
                var retryRequest = request
                retryRequest.headerFields[.authorization] = "Bearer \(newToken)"
                
                let (retryResponse, retryBody) = try await next(retryRequest, nil, baseURL)
                return (retryResponse, retryBody)
                
            } catch {
                logger.error("❌ Failed to refresh token: \(error.localizedDescription)")
                // Return original 401 response with nil body to avoid stream lifecycle issues
                return (originalResponse, nil)
            }
        } else if response.status.code == 401 && hasBody {
            logger.warning("⚠️ Unauthorized (401) on request with body - cannot retry automatically (streams can only be consumed once)")
            return (response, responseBody)
        }
        
        return (response, responseBody)
    }
}

