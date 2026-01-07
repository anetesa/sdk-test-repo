import Foundation

public struct DeviceUser: Sendable {
    /// Unique identifier of the user profile.
    public let id: String?
    /// First name of the user.
    public let firstName: String?
    /// Last name of the user.
    public let lastName: String?
    /// Email address associated with the profile.
    public let email: String?

    public init(
        id: String?,
        firstName: String?,
        lastName: String?,
        email: String?
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
}

