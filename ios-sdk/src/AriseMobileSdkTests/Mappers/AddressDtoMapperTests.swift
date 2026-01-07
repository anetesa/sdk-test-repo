import Foundation
import Testing
@testable import AriseMobile

/// Tests for AddressDtoMapper
struct AddressDtoMapperTests {
    
    @Test("AddressDtoMapper maps address with all fields")
    func testAddressDtoMapperWithAllFields() {
        let address = AddressDto(
            line1: "123 Main St",
            line2: "Apt 4B",
            city: "New York",
            postalCode: "10001",
            stateName: "New York",
            stateId: 1,
            countryId: 1
        )
        
        let result = AddressDtoMapper.toGeneratedInput(address)
        
        #expect(result != nil)
        #expect(result?.city == "New York")
        #expect(result?.countryId == 1)
        #expect(result?.line1 == "123 Main St")
        #expect(result?.line2 == "Apt 4B")
        #expect(result?.postalCode == "10001")
        #expect(result?.stateName == "New York")
        #expect(result?.stateId == 1)
    }
    
    @Test("AddressDtoMapper maps address with nil optional fields")
    func testAddressDtoMapperWithNilOptionalFields() {
        let address = AddressDto(
            line1: "456 Oak Ave",
            line2: nil,
            city: "Los Angeles",
            postalCode: "90001",
            stateName: "California",
            stateId: nil,
            countryId: 2
        )
        
        let result = AddressDtoMapper.toGeneratedInput(address)
        
        #expect(result != nil)
        #expect(result?.city == "Los Angeles")
        #expect(result?.line1 == "456 Oak Ave")
        #expect(result?.line2 == nil)
        #expect(result?.stateId == nil)
    }
    
    @Test("AddressDtoMapper returns nil for nil address")
    func testAddressDtoMapperWithNilAddress() {
        let result = AddressDtoMapper.toGeneratedInput(nil)
        #expect(result == nil)
    }
    
    @Test("AddressDtoMapper maps address with empty strings")
    func testAddressDtoMapperWithEmptyStrings() {
        let address = AddressDto(
            line1: "",
            line2: "",
            city: "",
            postalCode: "",
            stateName: "",
            stateId: 0,
            countryId: 0
        )
        
        let result = AddressDtoMapper.toGeneratedInput(address)
        
        #expect(result != nil)
        #expect(result?.city == "")
        #expect(result?.line1 == "")
    }
}


