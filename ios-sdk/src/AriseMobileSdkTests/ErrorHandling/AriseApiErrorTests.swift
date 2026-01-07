import Foundation
import Testing
@testable import AriseMobile

/// Tests for AriseApiError enum and error handling
struct AriseApiErrorTests {
    
    // MARK: - Error Creation Tests
    
    @Test("AriseApiError.badRequest can be created")
    func testBadRequestCreation() {
        let error = AriseApiError.badRequest("Invalid parameters", nil)
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("BadRequest") == true)
    }
    
    @Test("AriseApiError.unauthorized can be created")
    func testUnauthorizedCreation() {
        let error = AriseApiError.unauthorized("Invalid token")
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("Authentication") == true)
    }
    
    @Test("AriseApiError.forbidden can be created")
    func testForbiddenCreation() {
        let error = AriseApiError.forbidden("Access denied", nil)
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("Forbidden") == true)
    }
    
    @Test("AriseApiError.notFound can be created")
    func testNotFoundCreation() {
        let error = AriseApiError.notFound("Resource not found", nil)
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("NotFound") == true)
    }
    
    @Test("AriseApiError.serverError can be created")
    func testServerErrorCreation() {
        let error = AriseApiError.serverError("Internal server error", nil)
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("Server Error") == true)
    }
    
    @Test("AriseApiError.unknown can be created")
    func testUnknownErrorCreation() {
        let error = AriseApiError.unknown("Unknown error", nil)
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("Unknown Error") == true)
    }
    
    @Test("AriseApiError.invalidResponse can be created")
    func testInvalidResponseCreation() {
        let error = AriseApiError.invalidResponse("Invalid response format")
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("Invalid Response") == true)
    }
    
    @Test("AriseApiError.networkError can be created")
    func testNetworkErrorCreation() {
        let error = AriseApiError.networkError("Network timeout")
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("Network Error") == true)
    }
    
    // MARK: - ErrorInfo Tests
    
    @Test("AriseApiError with ErrorInfo preserves error details")
    func testErrorWithErrorInfo() {
        let errorInfo = ErrorInfo(
            details: "Validation failed",
            statusCode: 400,
            correlationId: "corr-123",
            errorCode: "ERR_400",
            source: "API",
            exceptionType: "ValidationException"
        )
        
        let error = AriseApiError.badRequest("Bad request", errorInfo)
        
        #expect(error.errorInfo != nil)
        #expect(error.errorInfo?.details == "Validation failed")
        #expect(error.errorInfo?.statusCode == 400)
        #expect(error.errorInfo?.correlationId == "corr-123")
        #expect(error.errorInfo?.errorCode == "ERR_400")
    }
    
    @Test("AriseApiError.unauthorized has nil errorInfo")
    func testUnauthorizedHasNilErrorInfo() {
        let error = AriseApiError.unauthorized("Invalid token")
        #expect(error.errorInfo == nil)
    }
    
    @Test("AriseApiError.invalidResponse has nil errorInfo")
    func testInvalidResponseHasNilErrorInfo() {
        let error = AriseApiError.invalidResponse("Invalid format")
        #expect(error.errorInfo == nil)
    }
    
    @Test("AriseApiError.networkError has nil errorInfo")
    func testNetworkErrorHasNilErrorInfo() {
        let error = AriseApiError.networkError("Timeout")
        #expect(error.errorInfo == nil)
    }
    
    // MARK: - Error Description Tests
    
    @Test("All AriseApiError cases have non-empty error descriptions")
    func testAllErrorsHaveDescriptions() {
        let errors: [AriseApiError] = [
            .badRequest("Test", nil),
            .unauthorized("Test"),
            .forbidden("Test", nil),
            .notFound("Test", nil),
            .serverError("Test", nil),
            .unknown("Test", nil),
            .invalidResponse("Test"),
            .networkError("Test")
        ]
        
        for error in errors {
            #expect(error.errorDescription != nil)
            #expect(!error.errorDescription!.isEmpty)
        }
    }
    
    @Test("AriseApiError conforms to LocalizedError")
    func testAriseApiErrorConformsToLocalizedError() {
        let error = AriseApiError.networkError("Test")
        #expect(error is LocalizedError)
    }
    
    // MARK: - Error Throwing and Catching Tests
    
    @Test("AriseApiError can be thrown and caught")
    func testAriseApiErrorThrowing() throws {
        func throwError() throws {
            throw AriseApiError.networkError("Test error")
        }
        
        do {
            try throwError()
            Issue.record("Expected error to be thrown")
        } catch let error as AriseApiError {
            if case .networkError(let message) = error {
                #expect(message == "Test error")
            } else {
                Issue.record("Expected networkError, got \(error)")
            }
        } catch {
            Issue.record("Expected AriseApiError, got \(type(of: error))")
        }
    }
    
    @Test("Different AriseApiError cases are distinct")
    func testErrorCasesAreDistinct() {
        let error1 = AriseApiError.networkError("Error 1")
        let error2 = AriseApiError.serverError("Error 2", nil)
        
        // Errors should be different types
        if case .networkError = error1 {
            if case .networkError = error2 {
                Issue.record("Expected different error types")
            }
        }
        
        #expect(error1.errorDescription != error2.errorDescription)
    }
}



