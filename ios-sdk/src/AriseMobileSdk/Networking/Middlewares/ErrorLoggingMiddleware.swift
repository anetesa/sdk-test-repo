import Foundation
import OpenAPIRuntime
import HTTPTypes

/// Middleware for logging decoding errors, HTTP errors, and other API errors
internal struct ErrorLoggingMiddleware: ClientMiddleware, @unchecked Sendable {
    let logger: AriseLogger
    
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        do {
            let (response, responseBody) = try await next(request, body, baseURL)
            
            // Log HTTP error responses (non-2xx status codes)
            // CRITICAL: Do not read responseBody - just pass it through
            // Reading HTTPBody streams can cause fatal "wroteFinalChunk()" errors
            if response.status.code >= 400 {
                logHttpErrorResponse(
                    statusCode: response.status.code,
                    operationID: operationID
                )
            }
            
            // Return responseBody unchanged - do not read or interact with it
            return (response, responseBody)
        } catch {
            // Log decoding errors and other errors
            logError(error, context: "API Call: \(operationID)")
            throw error
        }
    }
    
    /// Log HTTP error response details
    ///
    /// Logs error responses with status codes >= 400.
    /// Note: ResponseLoggingMiddleware handles logging of response bodies.
    /// CRITICAL: This method does NOT accept responseBody parameter to avoid any risk of reading it.
    ///
    /// - Parameters:
    ///   - statusCode: HTTP status code
    ///   - operationID: Operation identifier for context
    private func logHttpErrorResponse(
        statusCode: Int,
        operationID: String
    ) {
        logger.error("❌ API Error Response - Status Code: \(statusCode)")
        logger.error("Operation: \(operationID)")
        
        // Log status code specific messages
        switch statusCode {
        case 400:
            logger.error("⚠️ Bad request (400)")
        case 401:
            logger.error("⚠️ Unauthorized (401)")
        case 403:
            logger.error("⚠️ Forbidden (403)")
        case 404:
            logger.error("⚠️ Not found (404)")
        case 500...599:
            logger.error("⚠️ Server error (\(statusCode))")
        default:
            logger.error("⚠️ API error (\(statusCode))")
        }
        
        // Note: Response body logging is handled by ResponseLoggingMiddleware
    }
    
    /// Extract and log decoding error details
    ///
    /// Attempts to extract DecodingError from various error types (direct, NSError, ClientError).
    ///
    /// - Parameters:
    ///   - error: Error to analyze and log
    ///   - context: Optional context string for logging (e.g., "API Call", "Response Decoding")
    private func logError(_ error: Error, context: String = "") {
        logger.verbose("═══════════════════════════════════════════════════")
        logger.verbose("📋 Error Details\(context.isEmpty ? "" : " (\(context))"):")
        logger.verbose("═══════════════════════════════════════════════════")
        logger.verbose("Error type: \(type(of: error))")
        logger.verbose("Error description: \(error.localizedDescription)")
        
        // Try to extract DecodingError directly
        if let decodingError = error as? DecodingError {
            logDecodingErrorDetails(decodingError)
            return
        }
        
        // Try to extract from NSError userInfo
        if let nsError = error as NSError? {
            logger.verbose("Error domain: \(nsError.domain)")
            logger.verbose("Error code: \(nsError.code)")
            
            let userInfo = nsError.userInfo
            if !userInfo.isEmpty {
                logger.verbose("User info:")
                for (key, value) in userInfo {
                    logger.verbose("  \(key): \(value)")
                    
                    // Check for underlying error
                    if key == NSUnderlyingErrorKey || key == "underlyingError" {
                        if let underlying = value as? Error {
                            logger.verbose("═══════════════════════════════════════════════════")
                            logger.verbose("📋 Underlying Error Details:")
                            logger.verbose("═══════════════════════════════════════════════════")
                            logger.verbose("Underlying error type: \(type(of: underlying))")
                            logger.verbose("Underlying error: \(underlying.localizedDescription)")
                            
                            if let decodingError = underlying as? DecodingError {
                                logDecodingErrorDetails(decodingError, isUnderlying: true)
                            }
                        }
                    }
                }
            }
        }
        
        // Try to extract from ClientError (OpenAPIRuntime) without reflection
        if let nsError = error as NSError?,
           let underlying = nsError.userInfo[NSUnderlyingErrorKey] as? Error,
           let decodingError = underlying as? DecodingError {
            logDecodingErrorDetails(decodingError, isUnderlying: true)
        }
        
        logger.verbose("═══════════════════════════════════════════════════")
    }
    
    /// Log detailed DecodingError information
    ///
    /// Formats and logs all available information from a DecodingError including:
    /// - Error type (typeMismatch, valueNotFound, keyNotFound, dataCorrupted)
    /// - Coding path where error occurred
    /// - Debug description
    /// - Underlying errors (if any)
    ///
    /// - Parameters:
    ///   - error: DecodingError to log
    ///   - isUnderlying: Whether this is an underlying error (affects log prefix)
    private func logDecodingErrorDetails(_ error: DecodingError, isUnderlying: Bool = false) {
        let prefix = isUnderlying ? "🔴 DECODING ERROR DETECTED (Underlying):" : "🔴 DECODING ERROR DETECTED:"
        logger.error("═══════════════════════════════════════════════════")
        logger.error(prefix)
        logger.error("═══════════════════════════════════════════════════")
        
        switch error {
        case .typeMismatch(let type, let context):
            logger.error("Type mismatch: expected \(type)")
            logger.error("Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            logger.verbose("Debug description: \(context.debugDescription)")
            if let underlyingError = context.underlyingError {
                logger.error("Underlying error: \(underlyingError)")
                if let nsError = underlyingError as NSError? {
                    logger.error("NSError domain: \(nsError.domain)")
                    logger.error("NSError code: \(nsError.code)")
                    logger.error("NSError userInfo: \(nsError.userInfo)")
                }
            }
        case .valueNotFound(let type, let context):
            logger.error("Value not found: expected \(type)")
            logger.error("Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            logger.verbose("Debug description: \(context.debugDescription)")
        case .keyNotFound(let key, let context):
            logger.error("Key not found: \(key.stringValue)")
            logger.error("Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            logger.verbose("Debug description: \(context.debugDescription)")
        case .dataCorrupted(let context):
            logger.error("🔴 Data corrupted")
            logger.error("Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            logger.error("Debug description: \(context.debugDescription)")
            if let underlyingError = context.underlyingError {
                logger.error("Underlying error: \(underlyingError)")
                logger.error("Underlying error type: \(type(of: underlyingError))")
                if let nsError = underlyingError as NSError? {
                    logger.error("NSError domain: \(nsError.domain)")
                    logger.error("NSError code: \(nsError.code)")
                    logger.error("NSError userInfo: \(nsError.userInfo)")
                }
            }
        @unknown default:
            logger.verbose("Unknown decoding error: \(error)")
        }
    }
}

