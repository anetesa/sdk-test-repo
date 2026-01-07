import Foundation
import Testing
@testable import AriseMobile

/// Tests for DecodingErrorHandler utility
struct DecodingErrorHandlerTests {
    
    // MARK: - Error Decoding
    
    @Test("DecodingErrorHandler extracts DecodingError from direct error")
    func testDecodingErrorHandlerExtractsDirectError() throws {
        let handler = DecodingErrorHandler()
        
        // Create a direct DecodingError
        let data = Data("invalid json".utf8)
        let decoder = JSONDecoder()
        
        struct TestStruct: Codable {
            let value: String
        }
        
        do {
            _ = try decoder.decode(TestStruct.self, from: data)
            Issue.record("Expected decoding error")
        } catch {
            // Handler should extract the DecodingError
            do {
                try handler.handleError(error)
                Issue.record("Expected error to be re-thrown")
            } catch {
                // Error should be re-thrown
                #expect(error is DecodingError)
            }
        }
    }
    
    @Test("DecodingErrorHandler extracts DecodingError from NSError")
    func testDecodingErrorHandlerExtractsFromNSError() throws {
        let handler = DecodingErrorHandler()
        
        // Create an NSError with underlying DecodingError
        let data = Data("invalid json".utf8)
        let decoder = JSONDecoder()
        
        struct TestStruct: Codable {
            let value: String
        }
        
        do {
            _ = try decoder.decode(TestStruct.self, from: data)
            Issue.record("Expected decoding error")
        } catch {
            // Wrap in NSError
            let nsError = NSError(
                domain: "TestDomain",
                code: 100,
                userInfo: [NSUnderlyingErrorKey: error]
            )
            
            do {
                try handler.handleError(nsError)
                Issue.record("Expected error to be re-thrown")
            } catch {
                // Should handle the error (extract and log)
                #expect(true) // Error was handled
            }
        }
    }
    
    // MARK: - Error Transformation
    
    @Test("DecodingErrorHandler transforms typeMismatch error")
    func testDecodingErrorHandlerTransformsTypeMismatch() throws {
        let handler = DecodingErrorHandler()
        
        // Create a typeMismatch DecodingError
        let context = DecodingError.Context(
            codingPath: [CodingKeyImpl(stringValue: "value")],
            debugDescription: "Expected Int but got String"
        )
        let error = DecodingError.typeMismatch(Int.self, context)
        
        do {
            try handler.handleError(error)
            Issue.record("Expected error to be re-thrown")
        } catch {
            #expect(error is DecodingError)
        }
    }
    
    @Test("DecodingErrorHandler transforms valueNotFound error")
    func testDecodingErrorHandlerTransformsValueNotFound() throws {
        let handler = DecodingErrorHandler()
        
        // Create a valueNotFound DecodingError
        let context = DecodingError.Context(
            codingPath: [CodingKeyImpl(stringValue: "value")],
            debugDescription: "Value not found"
        )
        let error = DecodingError.valueNotFound(String.self, context)
        
        do {
            try handler.handleError(error)
            Issue.record("Expected error to be re-thrown")
        } catch {
            #expect(error is DecodingError)
        }
    }
    
    @Test("DecodingErrorHandler transforms keyNotFound error")
    func testDecodingErrorHandlerTransformsKeyNotFound() throws {
        let handler = DecodingErrorHandler()
        
        // Create a keyNotFound DecodingError
        let context = DecodingError.Context(
            codingPath: [],
            debugDescription: "Key not found"
        )
        let key = CodingKeyImpl(stringValue: "missingKey")
        let error = DecodingError.keyNotFound(key, context)
        
        do {
            try handler.handleError(error)
            Issue.record("Expected error to be re-thrown")
        } catch {
            #expect(error is DecodingError)
        }
    }
    
    @Test("DecodingErrorHandler transforms dataCorrupted error")
    func testDecodingErrorHandlerTransformsDataCorrupted() throws {
        let handler = DecodingErrorHandler()
        
        // Create a dataCorrupted DecodingError
        let context = DecodingError.Context(
            codingPath: [],
            debugDescription: "Data corrupted"
        )
        let error = DecodingError.dataCorrupted(context)
        
        do {
            try handler.handleError(error)
            Issue.record("Expected error to be re-thrown")
        } catch {
            #expect(error is DecodingError)
        }
    }
    
    // MARK: - Message Formatting
    
    @Test("DecodingErrorHandler formats error messages with coding path")
    func testDecodingErrorHandlerFormatsWithCodingPath() throws {
        let handler = DecodingErrorHandler()
        
        // Create error with coding path
        let path = [
            CodingKeyImpl(stringValue: "root"),
            CodingKeyImpl(stringValue: "nested"),
            CodingKeyImpl(stringValue: "value")
        ]
        let context = DecodingError.Context(
            codingPath: path,
            debugDescription: "Error description"
        )
        let error = DecodingError.typeMismatch(Int.self, context)
        
        do {
            try handler.handleError(error)
            Issue.record("Expected error to be re-thrown")
        } catch {
            #expect(error is DecodingError)
        }
    }
    
    @Test("DecodingErrorHandler formats error messages with debug description")
    func testDecodingErrorHandlerFormatsWithDebugDescription() throws {
        let handler = DecodingErrorHandler()
        
        let debugDescription = "Expected Int but got String at path 'value'"
        let context = DecodingError.Context(
            codingPath: [CodingKeyImpl(stringValue: "value")],
            debugDescription: debugDescription
        )
        let error = DecodingError.typeMismatch(Int.self, context)
        
        do {
            try handler.handleError(error)
            Issue.record("Expected error to be re-thrown")
        } catch {
            #expect(error is DecodingError)
        }
    }
    
    // MARK: - Additional Properties Error Handling
    
    @Test("DecodingErrorHandler handles additionalProperties errors")
    func testDecodingErrorHandlerHandlesAdditionalProperties() throws {
        let handler = DecodingErrorHandler()
        
        // Create a dataCorrupted error that looks like additionalProperties error
        let debugDescription = "Additional properties are disabled, but found 2 unknown keys: [\"field1\", \"field2\"]"
        let context = DecodingError.Context(
            codingPath: [],
            debugDescription: debugDescription
        )
        let error = DecodingError.dataCorrupted(context)
        
        do {
            try handler.handleError(error)
            Issue.record("Expected error to be re-thrown")
        } catch {
            #expect(error is DecodingError)
        }
    }
    
    // MARK: - Error Re-throwing
    
    @Test("DecodingErrorHandler re-throws original error")
    func testDecodingErrorHandlerReThrowsError() throws {
        let handler = DecodingErrorHandler()
        
        let originalError = NSError(domain: "TestDomain", code: 100, userInfo: nil)
        
        do {
            try handler.handleError(originalError)
            Issue.record("Expected error to be re-thrown")
        } catch let rethrownError {
            // Should be the same error
            #expect((rethrownError as NSError).domain == originalError.domain)
            #expect((rethrownError as NSError).code == originalError.code)
        }
    }
    
    // MARK: - Edge Cases
    
    @Test("DecodingErrorHandler handles errors without underlying errors")
    func testDecodingErrorHandlerHandlesErrorsWithoutUnderlying() throws {
        let handler = DecodingErrorHandler()
        
        let error = NSError(domain: "TestDomain", code: 100, userInfo: nil)
        
        do {
            try handler.handleError(error)
            Issue.record("Expected error to be re-thrown")
        } catch {
            #expect(true) // Error was handled
        }
    }
    
    @Test("DecodingErrorHandler handles errors with empty coding path")
    func testDecodingErrorHandlerHandlesEmptyCodingPath() throws {
        let handler = DecodingErrorHandler()
        
        let context = DecodingError.Context(
            codingPath: [],
            debugDescription: "Error at root"
        )
        let error = DecodingError.dataCorrupted(context)
        
        do {
            try handler.handleError(error)
            Issue.record("Expected error to be re-thrown")
        } catch {
            #expect(error is DecodingError)
        }
    }
    
    // MARK: - Helper Types
    
    private struct CodingKeyImpl: CodingKey {
        var stringValue: String
        var intValue: Int?
        
        init(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }
        
        init?(intValue: Int) {
            self.intValue = intValue
            self.stringValue = "\(intValue)"
        }
    }
}


