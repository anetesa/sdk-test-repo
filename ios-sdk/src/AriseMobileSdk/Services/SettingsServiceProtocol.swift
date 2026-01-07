import Foundation

/// Protocol for SettingsService to enable dependency injection and testing
internal protocol SettingsServiceProtocol {
    func getPaymentSettings() async throws -> PaymentSettingsResponse
}

