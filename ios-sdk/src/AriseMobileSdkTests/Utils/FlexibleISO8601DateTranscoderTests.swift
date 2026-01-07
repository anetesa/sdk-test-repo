import Foundation
import Testing
@testable import AriseMobile

/// Tests for FlexibleISO8601DateTranscoder utility
struct FlexibleISO8601DateTranscoderTests {
    
    // MARK: - Date Decoding
    
    @Test("FlexibleISO8601DateTranscoder decodes date with fractional seconds")
    func testDecodesDateWithFractionalSeconds() throws {
        let transcoder = FlexibleISO8601DateTranscoder.shared
        
        // ISO8601 with fractional seconds
        let dateString = "2024-10-30T07:13:38.123Z"
        let date = try transcoder.decode(dateString)
        
        // Should successfully decode
        #expect(date.timeIntervalSince1970 > 0)
    }
    
    @Test("FlexibleISO8601DateTranscoder decodes date without fractional seconds")
    func testDecodesDateWithoutFractionalSeconds() throws {
        let transcoder = FlexibleISO8601DateTranscoder.shared
        
        // ISO8601 without fractional seconds
        let dateString = "2024-10-30T07:13:38Z"
        let date = try transcoder.decode(dateString)
        
        // Should successfully decode
        #expect(date.timeIntervalSince1970 > 0)
    }
    
    @Test("FlexibleISO8601DateTranscoder decodes date with milliseconds")
    func testDecodesDateWithMilliseconds() throws {
        let transcoder = FlexibleISO8601DateTranscoder.shared
        
        // ISO8601 with milliseconds
        let dateString = "2024-10-30T07:13:38.000Z"
        let date = try transcoder.decode(dateString)
        
        // Should successfully decode
        #expect(date.timeIntervalSince1970 > 0)
    }
    
    @Test("FlexibleISO8601DateTranscoder decodes date with microseconds")
    func testDecodesDateWithMicroseconds() throws {
        let transcoder = FlexibleISO8601DateTranscoder.shared
        
        // ISO8601 with microseconds
        let dateString = "2024-10-30T07:13:38.123456Z"
        let date = try transcoder.decode(dateString)
        
        // Should successfully decode
        #expect(date.timeIntervalSince1970 > 0)
    }
    
    @Test("FlexibleISO8601DateTranscoder decodes date with timezone offset")
    func testDecodesDateWithTimezoneOffset() throws {
        let transcoder = FlexibleISO8601DateTranscoder.shared
        
        // ISO8601 with timezone offset (not Z)
        let dateString = "2024-10-30T07:13:38+00:00"
        let date = try transcoder.decode(dateString)
        
        // Should successfully decode
        #expect(date.timeIntervalSince1970 > 0)
    }
    
    // MARK: - Date Encoding
    
    @Test("FlexibleISO8601DateTranscoder encodes date to ISO8601 with fractional seconds")
    func testEncodesDateToISO8601WithFractionalSeconds() {
        let transcoder = FlexibleISO8601DateTranscoder.shared
        
        let date = Date(timeIntervalSince1970: 1727601218.123) // 2024-09-30T07:13:38.123Z
        let encoded = transcoder.encode(date)
        
        // Should be in ISO8601 format with fractional seconds
        #expect(encoded.contains("T"))
        #expect(encoded.contains("Z") || encoded.contains("+") || encoded.contains("-"))
        #expect(encoded.contains(".")) // Fractional seconds
    }
    
    @Test("FlexibleISO8601DateTranscoder encodes date correctly")
    func testEncodesDateCorrectly() {
        let transcoder = FlexibleISO8601DateTranscoder.shared
        
        // Use a known date
        let date = Date(timeIntervalSince1970: 1727601218) // 2024-09-30T07:13:38Z
        let encoded = transcoder.encode(date)
        
        // Should be a valid ISO8601 string
        #expect(!encoded.isEmpty)
        #expect(encoded.contains("2024"))
    }
    
    // MARK: - Round-trip Tests
    
    @Test("FlexibleISO8601DateTranscoder round-trip with fractional seconds")
    func testRoundTripWithFractionalSeconds() throws {
        let transcoder = FlexibleISO8601DateTranscoder.shared
        
        let originalDate = Date(timeIntervalSince1970: 1727601218.123)
        let encoded = transcoder.encode(originalDate)
        let decoded = try transcoder.decode(encoded)
        
        // Dates should be very close (within 1 second due to fractional precision)
        let difference = abs(decoded.timeIntervalSince1970 - originalDate.timeIntervalSince1970)
        #expect(difference < 1.0)
    }
    
    @Test("FlexibleISO8601DateTranscoder round-trip without fractional seconds")
    func testRoundTripWithoutFractionalSeconds() throws {
        let transcoder = FlexibleISO8601DateTranscoder.shared
        
        // Decode a date without fractional seconds
        let dateString = "2024-10-30T07:13:38Z"
        let decoded = try transcoder.decode(dateString)
        
        // Encode it back
        let encoded = transcoder.encode(decoded)
        
        // Should be able to decode the encoded string
        let redecoded = try transcoder.decode(encoded)
        
        // Dates should match (within 1 second)
        let difference = abs(redecoded.timeIntervalSince1970 - decoded.timeIntervalSince1970)
        #expect(difference < 1.0)
    }
    
    // MARK: - Various ISO8601 Formats
    
    @Test("FlexibleISO8601DateTranscoder handles various ISO8601 formats")
    func testHandlesVariousISO8601Formats() throws {
        let transcoder = FlexibleISO8601DateTranscoder.shared
        
        // Test various formats
        let formats = [
            "2024-10-30T07:13:38Z",
            "2024-10-30T07:13:38.000Z",
            "2024-10-30T07:13:38.123Z",
            "2024-10-30T07:13:38.123456Z"
        ]
        
        for format in formats {
            let date = try transcoder.decode(format)
            #expect(date.timeIntervalSince1970 > 0)
        }
    }
    
    @Test("FlexibleISO8601DateTranscoder handles dates with different precisions")
    func testHandlesDatesWithDifferentPrecisions() throws {
        let transcoder = FlexibleISO8601DateTranscoder.shared
        
        // Test different fractional second precisions
        let dates = [
            "2024-10-30T07:13:38Z",           // No fractional seconds
            "2024-10-30T07:13:38.1Z",         // 1 digit
            "2024-10-30T07:13:38.12Z",        // 2 digits
            "2024-10-30T07:13:38.123Z",       // 3 digits (milliseconds)
            "2024-10-30T07:13:38.1234Z",      // 4 digits
            "2024-10-30T07:13:38.12345Z",     // 5 digits
            "2024-10-30T07:13:38.123456Z"     // 6 digits (microseconds)
        ]
        
        for dateString in dates {
            let date = try transcoder.decode(dateString)
            #expect(date.timeIntervalSince1970 > 0)
        }
    }
    
    // MARK: - Error Handling
    
    @Test("FlexibleISO8601DateTranscoder throws error for invalid date string")
    func testThrowsErrorForInvalidDateString() {
        let transcoder = FlexibleISO8601DateTranscoder.shared
        
        // Note: ISO8601DateFormatter may accept some variations (e.g., "/" instead of "-")
        // So we only test strings that are definitely invalid
        let invalidStrings = [
            "invalid date",
            "07:13:38",
            "",
            "not a date",
            "2024-10-30", // Missing time component
            "2024-10-30 07:13:38", // Space instead of T
            "abc123",
            "2024-13-45T99:99:99Z" // Invalid date/time values
        ]
        
        for invalidString in invalidStrings {
            do {
                _ = try transcoder.decode(invalidString)
                // If we get here, the string was successfully decoded, which is unexpected
                Issue.record("Expected error for invalid date string: \(invalidString)")
            } catch {
                // Should throw DecodingError
                #expect(error is DecodingError, "Expected DecodingError for '\(invalidString)', got \(type(of: error))")
            }
        }
    }
    
    @Test("FlexibleISO8601DateTranscoder throws descriptive error")
    func testThrowsDescriptiveError() {
        let transcoder = FlexibleISO8601DateTranscoder.shared
        
        do {
            _ = try transcoder.decode("invalid")
            Issue.record("Expected error")
        } catch let error as DecodingError {
            // Should have a descriptive error message
            let debugDescription: String
            switch error {
            case .typeMismatch(_, let context),
                 .valueNotFound(_, let context),
                 .keyNotFound(_, let context),
                 .dataCorrupted(let context):
                debugDescription = context.debugDescription
            @unknown default:
                debugDescription = error.localizedDescription
            }
            #expect(debugDescription.contains("ISO8601") || debugDescription.contains("invalid"))
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Edge Cases
    
    @Test("FlexibleISO8601DateTranscoder handles dates at epoch")
    func testHandlesDatesAtEpoch() throws {
        let transcoder = FlexibleISO8601DateTranscoder.shared
        
        // Date at Unix epoch
        let dateString = "1970-01-01T00:00:00Z"
        let date = try transcoder.decode(dateString)
        
        #expect(abs(date.timeIntervalSince1970) < 1.0)
    }
    
    @Test("FlexibleISO8601DateTranscoder handles dates in the future")
    func testHandlesDatesInFuture() throws {
        let transcoder = FlexibleISO8601DateTranscoder.shared
        
        // Date in the future
        let dateString = "2099-12-31T23:59:59Z"
        let date = try transcoder.decode(dateString)
        
        #expect(date.timeIntervalSince1970 > Date().timeIntervalSince1970)
    }
    
    @Test("FlexibleISO8601DateTranscoder handles dates in the past")
    func testHandlesDatesInPast() throws {
        let transcoder = FlexibleISO8601DateTranscoder.shared
        
        // Date in the past
        let dateString = "1900-01-01T00:00:00Z"
        let date = try transcoder.decode(dateString)
        
        #expect(date.timeIntervalSince1970 < Date().timeIntervalSince1970)
    }
    
    @Test("FlexibleISO8601DateTranscoder encodes and decodes current date")
    func testEncodesAndDecodesCurrentDate() throws {
        let transcoder = FlexibleISO8601DateTranscoder.shared
        
        let now = Date()
        let encoded = transcoder.encode(now)
        let decoded = try transcoder.decode(encoded)
        
        // Should be very close (within 1 second)
        let difference = abs(decoded.timeIntervalSince1970 - now.timeIntervalSince1970)
        #expect(difference < 1.0)
    }
    
    // MARK: - Shared Instance
    
    @Test("FlexibleISO8601DateTranscoder has shared instance")
    func testHasSharedInstance() {
        let instance1 = FlexibleISO8601DateTranscoder.shared
        let instance2 = FlexibleISO8601DateTranscoder.shared
        
        // Use the same Date object to ensure consistent encoding
        let testDate = Date()
        
        // Should be the same instance (struct, so value equality)
        // Both instances should encode the same date identically
        #expect(instance1.encode(testDate) == instance2.encode(testDate))
    }
}

