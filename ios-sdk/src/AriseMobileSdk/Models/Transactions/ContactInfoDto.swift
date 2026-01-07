import Foundation

/// Contact information structure
///
/// This group contains fields regarding a customer's contact details such as email id, phone no. etc.
///
public struct ContactInfoDto {
    /// First name
    ///
    /// The first name of the customer.
    ///
    public let firstName: String?
    
    /// Last name
    ///
    /// The last name of the customer.
    ///
    public let lastName: String?
    
    /// Company name
    ///
    /// The name of the cardholder's company.
    ///
    public let companyName: String?
    
    /// Email address
    ///
    /// The email of the customer.
    ///
    public let email: String?
    
    /// Mobile phone number
    ///
    /// The customer's mobile phone number.
    ///
    public let mobileNumber: String?
    
    /// SMS notification enabled
    ///
    /// Whether SMS notifications are enabled for this customer.
    ///
    public let smsNotification: Bool?
    
    /// Initialize contact info DTO
    ///
    /// - Parameters:
    ///   - firstName: First name
    ///   - lastName: Last name
    ///   - companyName: Company name
    ///   - email: Email address
    ///   - mobileNumber: Mobile phone number
    ///   - smsNotification: SMS notification enabled
    public init(
        firstName: String? = nil,
        lastName: String? = nil,
        companyName: String? = nil,
        email: String? = nil,
        mobileNumber: String? = nil,
        smsNotification: Bool? = nil
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.companyName = companyName
        self.email = email
        self.mobileNumber = mobileNumber
        self.smsNotification = smsNotification
    }
}

