import Foundation
import Testing
@testable import AriseMobile

/// Tests for MapperError enum
struct MapperErrorTests {
    
    @Test("MapperError.missingField has correct error description")
    func testMissingFieldErrorDescription() {
        let error = MapperError.missingField(fieldName: "amount", entityName: "Transaction")
        let description = error.errorDescription
        
        #expect(description != nil)
        #expect(description == "Missing required field: amount in Transaction")
    }
    
    @Test("MapperError.missingField error description includes field name")
    func testMissingFieldErrorDescriptionIncludesFieldName() {
        let error = MapperError.missingField(fieldName: "customerId", entityName: "Order")
        let description = error.errorDescription
        
        #expect(description?.contains("customerId") == true)
        #expect(description?.contains("Missing required field") == true)
    }
    
    @Test("MapperError.missingField error description includes entity name")
    func testMissingFieldErrorDescriptionIncludesEntityName() {
        let error = MapperError.missingField(fieldName: "status", entityName: "Payment")
        let description = error.errorDescription
        
        #expect(description?.contains("Payment") == true)
        #expect(description?.contains("status") == true)
    }
    
    @Test("MapperError conforms to LocalizedError")
    func testMapperErrorConformsToLocalizedError() {
        let error = MapperError.missingField(fieldName: "test", entityName: "Test")
        #expect(error is LocalizedError)
    }
    
    @Test("MapperError errorDescription is not nil for all cases")
    func testMapperErrorErrorDescriptionIsNotNil() {
        let error = MapperError.missingField(fieldName: "field", entityName: "Entity")
        #expect(error.errorDescription != nil)
        #expect(!error.errorDescription!.isEmpty)
    }
    
    @Test("MapperError errorDescription format is consistent")
    func testMapperErrorErrorDescriptionFormat() {
        let error1 = MapperError.missingField(fieldName: "field1", entityName: "Entity1")
        let error2 = MapperError.missingField(fieldName: "field2", entityName: "Entity2")
        
        let desc1 = error1.errorDescription!
        let desc2 = error2.errorDescription!
        
        // Both should follow the same format
        #expect(desc1.hasPrefix("Missing required field:"))
        #expect(desc2.hasPrefix("Missing required field:"))
        #expect(desc1.contains("in"))
        #expect(desc2.contains("in"))
    }
}



