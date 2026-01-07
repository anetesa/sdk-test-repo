import Foundation
@testable import AriseMobile

/// Mock implementation of SettingsServiceProtocol for testing
final class MockSettingsService: SettingsServiceProtocol {
    // MARK: - Configuration
    
    var paymentSettingsResult: Result<PaymentSettingsResponse, Error> = .success(
        PaymentSettingsResponse(
            availableCurrencies: [],
            zeroCostProcessingOptionId: nil,
            zeroCostProcessingOption: nil,
            defaultSurchargeRate: nil,
            defaultCashDiscountRate: nil,
            defaultDualPricingRate: nil,
            isTipsEnabled: false,
            defaultTipsOptions: nil,
            availableCardTypes: [],
            availableTransactionTypes: [],
            availablePaymentProcessors: [],
            avs: nil,
            isCustomerCardSavingByTerminalEnabled: false,
            companyName: "Mock Company",
            mccCode: "1234",
            currencyCode: "USD",
            currencyId: 1,
            countryCode: "USA"
        )
    )
    
    // MARK: - Call Tracking
    
    private(set) var getPaymentSettingsCallCount = 0
    
    // MARK: - Initialization
    
    init() {
        // Mock doesn't need initialization - all methods are mocked
    }
    
    // MARK: - SettingsServiceProtocol Implementation
    
    func getPaymentSettings() async throws -> PaymentSettingsResponse {
        getPaymentSettingsCallCount += 1
        
        switch paymentSettingsResult {
        case .success(let settings):
            return settings
        case .failure(let error):
            throw error
        }
    }
    
    // MARK: - Reset
    
    func reset() {
        getPaymentSettingsCallCount = 0
    }
}

