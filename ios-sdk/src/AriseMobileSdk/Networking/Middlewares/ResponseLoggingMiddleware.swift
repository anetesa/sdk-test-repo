import Foundation
import OpenAPIRuntime
import HTTPTypes

/// Shared storage for buffered response body data between middleware
/// This allows ResponseLoggingMiddleware to buffer the body and ErrorHandlingMiddleware
/// to access it without re-reading (which causes fatal errors)
internal actor ResponseBodyBuffer {
    private var bufferedData: [String: Data] = [:]
    
    func set(operationID: String, data: Data?) {
        bufferedData[operationID] = data
    }
    
    func get(operationID: String) -> Data? {
        return bufferedData[operationID]
    }
    
    func clear(operationID: String) {
        bufferedData.removeValue(forKey: operationID)
    }
}

/// Global buffer instance (shared between middleware instances)
internal let responseBodyBuffer = ResponseBodyBuffer()

/// Middleware for logging raw HTTP response bodies at VERBOSE level
internal struct ResponseLoggingMiddleware: ClientMiddleware, @unchecked Sendable {
    let logger: AriseLogger
    
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        let (response, responseBody) = try await next(request, body, baseURL)
        
        // Log raw response at VERBOSE level
        logger.verbose("═══════════════════════════════════════════════════")
        logger.verbose("📥 Raw HTTP Response")
        logger.verbose("═══════════════════════════════════════════════════")
        logger.verbose("Operation: \(operationID)")
        logger.verbose("Status Code: \(response.status.code)")
        logger.verbose("Headers: \(response.headerFields)")
        
        // CRITICAL: Do NOT read response body to avoid fatal "wroteFinalChunk()" errors.
        // Reading HTTPBody streams can cause fatal errors if the stream is already closed
        // or has been consumed. The body stream can only be read once.
        // 
        // For error responses: ErrorHandlingMiddleware will use data from buffer if available
        // (e.g., from tests that pre-populate the buffer). If buffer is empty, it will create
        // a generic error message.
        // For successful responses: The body should be consumed by the client code, not middleware.
        
        logger.verbose("Response Body: (not read to avoid fatal stream errors)")
        logger.verbose("Note: Response body streams can only be read once and must be consumed by client code.")
        
        // Set buffer to nil - we're not reading the body here
        await responseBodyBuffer.set(operationID: operationID, data: nil)
        
        logger.verbose("═══════════════════════════════════════════════════")

        // Return original body unchanged - let client code consume it
        return (response, responseBody)
    }
}

