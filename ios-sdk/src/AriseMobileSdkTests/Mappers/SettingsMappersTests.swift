import Foundation
import Testing
@testable import AriseMobile

/// Tests for Settings Mappers functionality
struct SettingsMappersTests {
    
    // MARK: - PaymentSettingsResponseMapper Tests
    
    @Test("PaymentSettingsResponseMapper converts generated output to model")
    func testPaymentSettingsResponseMapperToModel() throws {
        let currencyDto = Components.Schemas.PaymentGateway_Contracts_Configurations_Payments_GetPaymentConfigurationsResponseDto_EnumDto(
            id: 1,
            name: "USD"
        )
        
        let cardTypeDto = Components.Schemas.PaymentGateway_Contracts_Configurations_Payments_GetPaymentConfigurationsResponseDto_EnumDto(
            id: 1,
            name: "Visa"
        )
        
        let transactionTypeDto = Components.Schemas.PaymentGateway_Contracts_Configurations_Payments_GetPaymentConfigurationsResponseDto_EnumDto(
            id: 2,
            name: "Sale"
        )
        
        let processorDto = Components.Schemas.PaymentProcessorDto(
            id: "test-processor-id",
            name: "Test Processor",
            isDefault: true,
            typeId: Int32(1),
            _type: "credit",
            settlementBatchTimeSlots: nil
        )
        
        let avsOptions = Components.Schemas.PaymentGateway_Contracts_Configurations_Payments_GetPaymentConfigurationsResponseDto_AvsOptions(
            isEnabled: true,
            profileId: Int32(123),
            profile: "Test Profile"
        )
        
        let responseBody = Components.Schemas.PaymentGateway_Contracts_Configurations_Payments_GetPaymentConfigurationsResponseDto(
            zeroCostProcessingOptionId: Int32(1),
            zeroCostProcessingOption: "None",
            defaultTipsOptions: [10.0, 15.0, 20.0],
            defaultSurchargeRate: 3.5,
            defaultCashDiscountRate: 2.0,
            defaultDualPricingRate: 1.5,
            availableCurrencies: [currencyDto],
            availableCardTypes: [cardTypeDto],
            availableTransactionTypes: [transactionTypeDto],
            isTipsEnabled: true,
            availablePaymentProcessors: [processorDto],
            avs: avsOptions,
            isCustomerCardSavingByTerminalEnabled: false,
            companyName: "Test Company",
            mccCode: "1234",
            mccCodeDescription: nil,
            currencyId: Int32(1),
            currencyIsoCode: "USD",
            maxTransactionAmount: nil
        )
        
        let okBody = Operations.GetPayApiV1ConfigurationsPayments.Output.Ok.Body.json(responseBody)
        let okResponse = Operations.GetPayApiV1ConfigurationsPayments.Output.Ok(body: okBody)
        let output = Operations.GetPayApiV1ConfigurationsPayments.Output.ok(okResponse)
        
        let result = try PaymentSettingsResponseMapper.toModel(output)
        
        #expect(result.availableCurrencies.count == 1)
        #expect(result.availableCurrencies.first?.id == 1)
        #expect(result.availableCurrencies.first?.name == "USD")
        #expect(result.availableCardTypes.count == 1)
        #expect(result.availableCardTypes.first?.id == 1)
        #expect(result.availableCardTypes.first?.name == "Visa")
        #expect(result.availableTransactionTypes.count == 1)
        #expect(result.availableTransactionTypes.first?.id == 2)
        #expect(result.availableTransactionTypes.first?.name == "Sale")
        #expect(result.availablePaymentProcessors.count == 1)
        #expect(result.availablePaymentProcessors.first?.id == "test-processor-id")
        #expect(result.avs?.isEnabled == true)
        #expect(result.avs?.profileId == 123)
        #expect(result.isTipsEnabled == true)
        #expect(result.defaultSurchargeRate == 3.5)
        #expect(result.companyName == "Test Company")
        #expect(result.currencyId == 1)
        #expect(result.currencyCode == "USD")
    }
    
    // MARK: - PaymentProcessorMapper Tests
    
    @Test("PaymentProcessorMapper converts generated processor to model")
    func testPaymentProcessorMapperToModel() {
        let generatedProcessor = Components.Schemas.PaymentProcessorDto(
            id: "test-processor-id",
            name: "Test Processor",
            isDefault: true,
            typeId: Int32(1),
            _type: "credit",
            settlementBatchTimeSlots: nil
        )
        
        let result = PaymentProcessorMapper.toModel(generatedProcessor)
        
        #expect(result.id == "test-processor-id")
        #expect(result.name == "Test Processor")
        #expect(result.isDefault == true)
        #expect(result.typeId == 1)
        #expect(result.type == "credit")
    }
    
    @Test("PaymentProcessorMapper converts generated processor with settlement batch time slots to model")
    func testPaymentProcessorMapperWithSettlementBatchTimeSlots() {
        let timeSlot = Components.Schemas.SettlementBatchTimeSlot(
            hours: 14,
            minutes: 30,
            timezoneName: "America/New_York"
        )
        
        let generatedProcessor = Components.Schemas.PaymentProcessorDto(
            id: "test-processor-id",
            name: "Test Processor",
            isDefault: true,
            typeId: Int32(1),
            _type: "credit",
            settlementBatchTimeSlots: [timeSlot]
        )
        
        let result = PaymentProcessorMapper.toModel(generatedProcessor)
        
        #expect(result.id == "test-processor-id")
        #expect(result.settlementBatchTimeSlots?.count == 1)
        #expect(result.settlementBatchTimeSlots?.first?.hours == 14)
        #expect(result.settlementBatchTimeSlots?.first?.minutes == 30)
        #expect(result.settlementBatchTimeSlots?.first?.timezoneName == "America/New_York")
    }
    
    // MARK: - AvsOptionsMapper Tests
    
    @Test("AvsOptionsMapper converts generated AVS options to model")
    func testAvsOptionsMapperToModel() {
        let generatedAvs = Components.Schemas.PaymentGateway_Contracts_Configurations_Payments_GetPaymentConfigurationsResponseDto_AvsOptions(
            isEnabled: true,
            profileId: Int32(123),
            profile: "Test Profile"
        )
        
        let result = AvsOptionsMapper.toModel(generatedAvs)
        
        #expect(result.isEnabled == true)
        #expect(result.profileId == 123)
        #expect(result.profile == "Test Profile")
    }
    
    // MARK: - SettlementBatchTimeSlotMapper Tests
    
    @Test("SettlementBatchTimeSlotMapper converts generated DTO to model")
    func testSettlementBatchTimeSlotMapperToModel() {
        let generatedDto = Components.Schemas.SettlementBatchTimeSlot(
            hours: 14,
            minutes: 30,
            timezoneName: "America/New_York"
        )
        
        let result = SettlementBatchTimeSlotMapper.toModel(generatedDto)
        
        #expect(result.hours == 14)
        #expect(result.minutes == 30)
        #expect(result.timezoneName == "America/New_York")
    }
    
    // MARK: - Edge Cases and Additional Tests
    
    @Test("PaymentSettingsResponseMapper handles nil optional fields")
    func testPaymentSettingsResponseMapperWithNilFields() throws {
        let responseBody = Components.Schemas.PaymentGateway_Contracts_Configurations_Payments_GetPaymentConfigurationsResponseDto(
            zeroCostProcessingOptionId: nil,
            zeroCostProcessingOption: nil,
            defaultTipsOptions: nil,
            defaultSurchargeRate: nil,
            defaultCashDiscountRate: nil,
            defaultDualPricingRate: nil,
            availableCurrencies: [],
            availableCardTypes: [],
            availableTransactionTypes: [],
            isTipsEnabled: false,
            availablePaymentProcessors: [],
            avs: nil,
            isCustomerCardSavingByTerminalEnabled: false,
            companyName: nil,
            mccCode: nil,
            mccCodeDescription: nil,
            currencyId: nil,
            currencyIsoCode: nil,
            maxTransactionAmount: nil
        )
        
        let okBody = Operations.GetPayApiV1ConfigurationsPayments.Output.Ok.Body.json(responseBody)
        let okResponse = Operations.GetPayApiV1ConfigurationsPayments.Output.Ok(body: okBody)
        let output = Operations.GetPayApiV1ConfigurationsPayments.Output.ok(okResponse)
        
        let result = try PaymentSettingsResponseMapper.toModel(output)
        
        #expect(result.availableCurrencies.count == 0)
        #expect(result.availableCardTypes.count == 0)
        #expect(result.availablePaymentProcessors.count == 0)
        #expect(result.avs == nil)
        #expect(result.isTipsEnabled == false)
    }
    
    @Test("PaymentSettingsResponseMapper handles empty arrays")
    func testPaymentSettingsResponseMapperEmptyArrays() throws {
        let responseBody = Components.Schemas.PaymentGateway_Contracts_Configurations_Payments_GetPaymentConfigurationsResponseDto(
            zeroCostProcessingOptionId: Int32(1),
            zeroCostProcessingOption: "None",
            defaultTipsOptions: [],
            defaultSurchargeRate: 0.0,
            defaultCashDiscountRate: 0.0,
            defaultDualPricingRate: 0.0,
            availableCurrencies: [],
            availableCardTypes: [],
            availableTransactionTypes: [],
            isTipsEnabled: false,
            availablePaymentProcessors: [],
            avs: nil,
            isCustomerCardSavingByTerminalEnabled: false,
            companyName: "Test",
            mccCode: "1234",
            mccCodeDescription: nil,
            currencyId: Int32(1),
            currencyIsoCode: "USD",
            maxTransactionAmount: nil
        )
        
        let okBody = Operations.GetPayApiV1ConfigurationsPayments.Output.Ok.Body.json(responseBody)
        let okResponse = Operations.GetPayApiV1ConfigurationsPayments.Output.Ok(body: okBody)
        let output = Operations.GetPayApiV1ConfigurationsPayments.Output.ok(okResponse)
        
        let result = try PaymentSettingsResponseMapper.toModel(output)
        
        #expect(result.defaultTipsOptions?.count == 0)
        #expect(result.availableCurrencies.count == 0)
        #expect(result.availableCardTypes.count == 0)
    }
    
    @Test("PaymentProcessorMapper handles nil optional fields")
    func testPaymentProcessorMapperWithNilFields() {
        let generatedProcessor = Components.Schemas.PaymentProcessorDto(
            id: "test-processor-id",
            name: nil,
            isDefault: false,
            typeId: nil,
            _type: nil,
            settlementBatchTimeSlots: nil
        )
        
        let result = PaymentProcessorMapper.toModel(generatedProcessor)
        
        #expect(result.id == "test-processor-id")
        #expect(result.name == nil)
        #expect(result.isDefault == false)
        #expect(result.typeId == nil)
        #expect(result.type == nil)
    }
    
    @Test("PaymentProcessorMapper handles multiple settlement batch time slots")
    func testPaymentProcessorMapperMultipleTimeSlots() {
        let timeSlot1 = Components.Schemas.SettlementBatchTimeSlot(
            hours: 9,
            minutes: 0,
            timezoneName: "America/New_York"
        )
        
        let timeSlot2 = Components.Schemas.SettlementBatchTimeSlot(
            hours: 17,
            minutes: 30,
            timezoneName: "America/New_York"
        )
        
        let generatedProcessor = Components.Schemas.PaymentProcessorDto(
            id: "test-processor-id",
            name: "Test Processor",
            isDefault: true,
            typeId: Int32(1),
            _type: "credit",
            settlementBatchTimeSlots: [timeSlot1, timeSlot2]
        )
        
        let result = PaymentProcessorMapper.toModel(generatedProcessor)
        
        #expect(result.settlementBatchTimeSlots?.count == 2)
        #expect(result.settlementBatchTimeSlots?[0].hours == 9)
        #expect(result.settlementBatchTimeSlots?[1].hours == 17)
    }
    
    @Test("AvsOptionsMapper handles nil profileId")
    func testAvsOptionsMapperWithNilProfileId() {
        let generatedAvs = Components.Schemas.PaymentGateway_Contracts_Configurations_Payments_GetPaymentConfigurationsResponseDto_AvsOptions(
            isEnabled: false,
            profileId: nil,
            profile: nil
        )
        
        let result = AvsOptionsMapper.toModel(generatedAvs)
        
        #expect(result.isEnabled == false)
        #expect(result.profileId == nil)
        #expect(result.profile == nil)
    }
    
    @Test("SettlementBatchTimeSlotMapper handles edge time values")
    func testSettlementBatchTimeSlotMapperEdgeValues() {
        // Test midnight
        let midnight = Components.Schemas.SettlementBatchTimeSlot(
            hours: 0,
            minutes: 0,
            timezoneName: "UTC"
        )
        let result1 = SettlementBatchTimeSlotMapper.toModel(midnight)
        #expect(result1.hours == 0)
        #expect(result1.minutes == 0)
        
        // Test end of day
        let endOfDay = Components.Schemas.SettlementBatchTimeSlot(
            hours: 23,
            minutes: 59,
            timezoneName: "UTC"
        )
        let result2 = SettlementBatchTimeSlotMapper.toModel(endOfDay)
        #expect(result2.hours == 23)
        #expect(result2.minutes == 59)
    }
}

