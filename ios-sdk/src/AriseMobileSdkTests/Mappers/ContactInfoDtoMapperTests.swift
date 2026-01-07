import Foundation
import Testing
@testable import AriseMobile

/// Tests for ContactInfoDtoMapper
struct ContactInfoDtoMapperTests {
    
    @Test("ContactInfoDtoMapper maps contact info with all fields")
    func testContactInfoDtoMapperWithAllFields() {
        let contactInfo = ContactInfoDto(
            firstName: "John",
            lastName: "Doe",
            companyName: "Test Company",
            email: "john@example.com",
            mobileNumber: "555-1234",
            smsNotification: true
        )
        
        let result = ContactInfoDtoMapper.toGeneratedInput(contactInfo)
        
        #expect(result != nil)
        #expect(result?.firstName == "John")
        #expect(result?.lastName == "Doe")
        #expect(result?.companyName == "Test Company")
        #expect(result?.email == "john@example.com")
        #expect(result?.mobileNumber == "555-1234")
        #expect(result?.smsNotification == true)
    }
    
    @Test("ContactInfoDtoMapper maps contact info with nil optional fields")
    func testContactInfoDtoMapperWithNilOptionalFields() {
        let contactInfo = ContactInfoDto(
            firstName: "Jane",
            lastName: "Smith",
            companyName: nil,
            email: "jane@example.com",
            mobileNumber: nil,
            smsNotification: false
        )
        
        let result = ContactInfoDtoMapper.toGeneratedInput(contactInfo)
        
        #expect(result != nil)
        #expect(result?.firstName == "Jane")
        #expect(result?.lastName == "Smith")
        #expect(result?.companyName == nil)
        #expect(result?.mobileNumber == nil)
        #expect(result?.smsNotification == false)
    }
    
    @Test("ContactInfoDtoMapper returns nil for nil contact info")
    func testContactInfoDtoMapperWithNilContactInfo() {
        let result = ContactInfoDtoMapper.toGeneratedInput(nil)
        #expect(result == nil)
    }
    
    @Test("ContactInfoDtoMapper maps contact info with empty strings")
    func testContactInfoDtoMapperWithEmptyStrings() {
        let contactInfo = ContactInfoDto(
            firstName: "",
            lastName: "",
            companyName: "",
            email: "",
            mobileNumber: "",
            smsNotification: false
        )
        
        let result = ContactInfoDtoMapper.toGeneratedInput(contactInfo)
        
        #expect(result != nil)
        #expect(result?.firstName == "")
        #expect(result?.lastName == "")
    }
}



