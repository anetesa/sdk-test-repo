import Foundation

/// Address information structure
///
/// A commonly used address structure for billing and shipping addresses.
/// Not all the fields are used in all processors, but generally ought to be provided.
///
public struct AddressDto {
    /// Address line 1
    ///
    /// First line of the street address.
    /// Alphanumeric and Special Character | Min Length=6 Max Length=128.
    ///
    public let line1: String?
    
    /// Address line 2
    ///
    /// Second line of the street address (apartment, suite, etc.).
    /// Alphanumeric and Special Character | Min Length=6 Max Length=128.
    ///
    public let line2: String?
    
    /// City
    ///
    /// City name.
    /// Alphanumeric and Special Character | Min Length=6 Max Length=128.
    ///
    public let city: String?
    
    /// Postal code (ZIP code)
    ///
    /// Zip code or postal code.
    /// Alphanumeric and Special Character | Min Length=2 Max Length=15.
    ///
    public let postalCode: String?
    
    /// State name
    ///
    /// State name, for countries with no predefined states.
    ///
    public let stateName: String?
    
    /// State identifier
    ///
    /// State id for countries with predefined states.
    ///
    public let stateId: Int32?
    
    /// Country identifier
    ///
    /// The country id.
    ///
    public let countryId: Int32?
    
    /// Initialize address DTO
    ///
    /// - Parameters:
    ///   - line1: Address line 1
    ///   - line2: Address line 2
    ///   - city: City name
    ///   - postalCode: Postal code (ZIP code)
    ///   - stateName: State name
    ///   - stateId: State identifier
    ///   - countryId: Country identifier
    public init(
        line1: String? = nil,
        line2: String? = nil,
        city: String? = nil,
        postalCode: String? = nil,
        stateName: String? = nil,
        stateId: Int32? = nil,
        countryId: Int32? = nil
    ) {
        self.line1 = line1
        self.line2 = line2
        self.city = city
        self.postalCode = postalCode
        self.stateName = stateName
        self.stateId = stateId
        self.countryId = countryId
    }
}

