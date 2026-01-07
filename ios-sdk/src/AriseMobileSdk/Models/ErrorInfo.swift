import Foundation
import OpenAPIRuntime
import HTTPTypes

/// Structure for holding extracted error information
public struct ErrorInfo {
    public let details: String?
    public let statusCode: Int
    public let correlationId: String?
    public let errorCode: String?
    public let source: String?
    public let exceptionType: String?
}
