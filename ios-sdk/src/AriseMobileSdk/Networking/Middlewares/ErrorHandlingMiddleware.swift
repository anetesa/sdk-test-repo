import Foundation
import OpenAPIRuntime
import HTTPTypes

/// Middleware for converting server errors to AriseApiError.
///
/// This middleware intercepts HTTP error responses (status >= 400) and converts them
/// to AriseApiError before they reach the client code. It extracts error information
/// from the response body and creates appropriate AriseApiError instances.
internal struct ErrorHandlingMiddleware: ClientMiddleware, @unchecked Sendable {
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
            
            // Check for HTTP error responses (status >= 400)
            // IMPORTANT: ErrorHandlingMiddleware runs AFTER TokenRefreshMiddleware in the response chain.
            // This means TokenRefreshMiddleware gets the response first and can attempt token refresh on 401.
            // If refresh succeeds, we get a successful response (status < 400).
            // If refresh fails or wasn't attempted, we get the 401 and should handle it.
            // For other errors (400, 404, 500, etc.), we handle them immediately.
            
            // Handle all errors except 401 - let TokenRefreshMiddleware handle 401 first
            if response.status.code >= 400 && response.status.code != 401 {
                logger.verbose("ErrorHandlingMiddleware: Processing error response with status \(response.status.code)")
                let bufferedData: Data? = await responseBodyBuffer.get(operationID: operationID)
                
                let errorInfo = extractErrorInfo(from: bufferedData, statusCode: response.status.code)
                
                if let errorInfo = errorInfo {
                    logger.error("❌ Server Error (\(response.status.code)): \(errorInfo.details ?? "Unknown error")")
                    if let correlationId = errorInfo.correlationId {
                        logger.error("Correlation ID: \(correlationId)")
                    }
                    throw createAriseApiError(from: errorInfo, statusCode: response.status.code)
                } else {
                    // If we can't extract error info, create a generic error
                    let message = "Server returned error status \(response.status.code)"
                    logger.error("❌ Server Error (\(response.status.code)): \(message)")
                    logger.verbose("ErrorHandlingMiddleware: Could not extract error details from body (ResponseLoggingMiddleware does not read body to avoid fatal errors)")
                    throw createAriseApiError(from: nil, statusCode: response.status.code, defaultMessage: message)
                }
            }
            
            // For 401, we let it pass through. TokenRefreshMiddleware (which runs before us in response chain)
            // will attempt to refresh the token. If refresh succeeds, we won't see 401.
            // If refresh fails, the 401 will be returned to the client code, which should handle it.
            // However, if we receive 401 here, it means TokenRefreshMiddleware already tried to refresh
            // and it failed, so we should handle it.
            if response.status.code == 401 {
                logger.verbose("ErrorHandlingMiddleware: Received 401 after TokenRefreshMiddleware attempt")
                // Try to get buffered data from ResponseLoggingMiddleware first
                let bufferedData = await responseBodyBuffer.get(operationID: operationID)
                let message = "Authentication failed. Please re-authenticate."
                logger.error("❌ Authentication Error (401): \(message)")
                // Throw AriseApiError for 401
                // Note: We don't need to return the body since we're throwing an error
                throw createAriseApiError(from: nil, statusCode: response.status.code, defaultMessage: message)
            }
            
            // For successful responses, return the responseBody as-is
            // ResponseLoggingMiddleware (which runs before us) does not read the body
            // Clear the buffer for this operation
            await responseBodyBuffer.clear(operationID: operationID)
            return (response, responseBody)
        } catch let error as AriseApiError {
            // Already an AriseApiError, re-throw
            throw error
        } catch {
            throw error
        }
    }
        
    /// Extracts error information from response body data.
    ///
    /// Attempts to decode error response body to extract error details, status code,
    /// correlation ID, and error code.
    ///
    /// - Parameters:
    ///   - bodyData: Buffered response body data (already read from HTTPBody)
    ///   - statusCode: HTTP status code
    /// - Returns: ErrorInfo structure with extracted error information, or nil if extraction fails
    private func extractErrorInfo(from bodyData: Data?, statusCode: Int) -> ErrorInfo? {
        guard let bodyData = bodyData, !bodyData.isEmpty else {
            return nil
        }
        
        // Try to decode as JSON error response.
        //
        // Some backends return lowerCamelCase keys:
        // {
        //   "details": "Error message",
        //   "statusCode": 400,
        //   "correlationId": "uuid",
        //   "errorCode": "ERROR_CODE",
        //   "source": "PaymentGateway.Isv",
        //   "exceptionType": "ValidationException",
        //   "errors": { "field": ["message"] }
        // }
        //
        // Others return PascalCase keys:
        // {
        //   "Details": "...",
        //   "StatusCode": 400,
        //   "CorrelationId": "uuid",
        //   "ErrorCode": "V0000",
        //   "Source": "...",
        //   "ExceptionType": "...",
        //   "Errors": { "field": ["message"] }
        // }
        
        guard let json = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any] else {
            return nil
        }

        func readString(_ keys: [String]) -> String? {
            for key in keys {
                if let s = json[key] as? String, !s.isEmpty { return s }
            }
            return nil
        }

        func readInt(_ keys: [String]) -> Int? {
            for key in keys {
                if let n = json[key] as? NSNumber { return n.intValue }
                if let i = json[key] as? Int { return i }
            }
            return nil
        }

        // Prefer explicit details if present; otherwise try to derive a message from validation Errors.
        var details = readString(["details", "Details"])
        if details == nil {
            let errorsObject = json["errors"] ?? json["Errors"] ?? json["Errors".lowercased()]
            if let errorsDict = errorsObject as? [String: Any] {
                if let firstKey = errorsDict.keys.first {
                    if let messages = errorsDict[firstKey] as? [Any],
                       let firstMessage = messages.first as? String,
                       !firstMessage.isEmpty {
                        details = firstMessage
                    }
                }
            }
        }

        let statusCodeFromBody = readInt(["statusCode", "StatusCode"]) ?? statusCode
        let correlationId = readString(["correlationId", "CorrelationId"])
        let errorCode = readString(["errorCode", "ErrorCode"])
        let source = readString(["source", "Source"])
        let exceptionType = readString(["exceptionType", "ExceptionType"])
        
        return ErrorInfo(
            details: details,
            statusCode: statusCodeFromBody,
            correlationId: correlationId,
            errorCode: errorCode,
            source: source,
            exceptionType: exceptionType
        )
    }
    
    /// Creates AriseApiError from error information.
    ///
    /// - Parameters:
    ///   - errorInfo: ErrorInfo structure with error details, or nil
    ///   - statusCode: HTTP status code
    ///   - defaultMessage: Default error message if errorInfo is nil
    /// - Returns: Appropriate AriseApiError instance
    private func createAriseApiError(from errorInfo: ErrorInfo?, statusCode: Int, defaultMessage: String? = nil) -> AriseApiError {
        var message: String
        if(errorInfo != nil){
            var messageParts: [String] = []
            
            if let details = errorInfo?.details, !details.isEmpty {
                messageParts.append(details)
            } else if let exceptionType = errorInfo?.exceptionType {
                messageParts.append(exceptionType)
            } else {
                messageParts.append("Server returned error status \(statusCode)")
            }
            
            if let correlationId = errorInfo?.correlationId {
                messageParts.append("(Correlation ID: \(correlationId))")
            }
            
            if let errorCode = errorInfo?.errorCode {
                messageParts.append("(Error Code: \(errorCode))")
            }
            
            message = messageParts.joined(separator: " ")
        }else{
            message = defaultMessage ?? "Server returned error status \(statusCode)"
        }
       
        switch statusCode {
        case 400:
            return AriseApiError.badRequest(message, errorInfo)
        case 401:
            return AriseApiError.unauthorized(message)
        case 403:
            return AriseApiError.forbidden(message, errorInfo)
        case 404:
            return AriseApiError.notFound(message, errorInfo)
        case 500...599:
            return AriseApiError.serverError(message, errorInfo)
        default:
            return AriseApiError.unknown(message, errorInfo)
        }
    }
}

