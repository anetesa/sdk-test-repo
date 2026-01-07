import Foundation
import OpenAPIRuntime

/// A flexible ISO8601 date transcoder that handles dates with and without fractional seconds.
///
/// This transcoder attempts to parse dates in multiple formats:
/// 1. ISO8601 with fractional seconds (e.g., "2024-10-30T07:13:38.000Z")
/// 2. ISO8601 without fractional seconds (e.g., "2024-10-30T07:13:38Z")
///
/// This allows the SDK to handle date formats that may vary from the API response.
public struct FlexibleISO8601DateTranscoder: DateTranscoder, Sendable {
    
    /// Shared instance of the flexible date transcoder
    public static let shared = FlexibleISO8601DateTranscoder()
    
    // Thread-safe formatters (ISO8601DateFormatter is thread-safe for reading)
    private let formatterWithFractionalSeconds: ISO8601DateFormatter
    private let formatterWithoutFractionalSeconds: ISO8601DateFormatter
    
    private init() {
        // Formatter for dates with fractional seconds (e.g., "2024-10-30T07:13:38.000Z")
        formatterWithFractionalSeconds = ISO8601DateFormatter()
        formatterWithFractionalSeconds.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        // Formatter for dates without fractional seconds (e.g., "2024-10-30T07:13:38Z")
        formatterWithoutFractionalSeconds = ISO8601DateFormatter()
        formatterWithoutFractionalSeconds.formatOptions = [.withInternetDateTime]
    }
    
    /// Decodes a date string to a Date object.
    ///
    /// Attempts to parse the date string using multiple formats:
    /// 1. First tries with fractional seconds
    /// 2. Falls back to format without fractional seconds
    ///
    /// - Parameter dateString: The ISO8601 date string to decode
    /// - Returns: A Date object if parsing succeeds
    /// - Throws: An error if the date string cannot be parsed
    public func decode(_ dateString: String) throws -> Date {
        // Try parsing with fractional seconds first
        if let date = formatterWithFractionalSeconds.date(from: dateString) {
            return date
        }
        
        // Fall back to parsing without fractional seconds
        if let date = formatterWithoutFractionalSeconds.date(from: dateString) {
            return date
        }
        
        // If both attempts fail, throw a descriptive error
        throw DecodingError.dataCorrupted(
            DecodingError.Context(
                codingPath: [],
                debugDescription: "Expected date string to be ISO8601-formatted (with or without fractional seconds), but received: \(dateString)"
            )
        )
    }
    
    /// Encodes a Date object to an ISO8601 date string.
    ///
    /// Uses the format with fractional seconds for consistency.
    ///
    /// - Parameter date: The Date object to encode
    /// - Returns: An ISO8601 date string with fractional seconds
    public func encode(_ date: Date) -> String {
        return formatterWithFractionalSeconds.string(from: date)
    }
}

