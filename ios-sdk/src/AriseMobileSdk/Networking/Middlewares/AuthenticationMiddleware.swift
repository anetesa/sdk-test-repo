import Foundation
import OpenAPIRuntime
import HTTPTypes

/// Middleware for adding Authorization header to API requests
internal struct AuthenticationMiddleware: ClientMiddleware, @unchecked Sendable {
    let token: String?

    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var modifiedRequest = request
        
        if let token, !token.isEmpty {
            modifiedRequest.headerFields[.authorization] = "Bearer \(token)"
        }
        
        return try await next(modifiedRequest, body, baseURL)
    }
}

