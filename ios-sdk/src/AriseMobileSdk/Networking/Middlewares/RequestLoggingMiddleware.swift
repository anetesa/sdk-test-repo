import Foundation
import OpenAPIRuntime
import HTTPTypes

/// Middleware for logging HTTP request details at VERBOSE level
internal struct RequestLoggingMiddleware: ClientMiddleware, @unchecked Sendable {
    let logger: AriseLogger
    
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        // Log request details at VERBOSE level
        logger.verbose("═══════════════════════════════════════════════════")
        logger.verbose("📤 HTTP Request")
        logger.verbose("═══════════════════════════════════════════════════")
        
        // Build full URL
        let fullURL = baseURL.appendingPathComponent(request.path ?? "")
        logger.verbose("🌐 URL: \(fullURL.absoluteString)")
        logger.verbose("📋 Method: \(request.method.rawValue)")
        
        // Log headers (mask Authorization token)
        if !request.headerFields.isEmpty {
            var headersString = "📋 Headers:\n"
            for field in request.headerFields.sorted(by: { $0.name.canonicalName < $1.name.canonicalName }) {
                let key = field.name.canonicalName
                let value = field.value
                if key.lowercased() == "authorization" {
                    let maskedValue = value.prefix(20) + "..."
                    headersString += "   \(key): \(maskedValue)\n"
                } else {
                    headersString += "   \(key): \(value)\n"
                }
            }
            logger.verbose(headersString.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        
        if body != nil {
            logger.verbose("📦 Body: (present, not read to avoid stream errors)")
        } else {
            logger.verbose("📦 Body: (nil)")
        }
        
        logger.verbose("═══════════════════════════════════════════════════")
        
        // Pass body through unchanged - let OpenAPI client handle it
        // This avoids any interference with the bidirectional streaming mechanism
        return try await next(request, body, baseURL)
    }
}

