import Foundation

final class DevicesService: BaseApiClient, DevicesServiceProtocol, @unchecked Sendable {
    init(tokenService: TokenService, environmentSettings: EnvironmentSettings) {
        super.init(
            tokenService: tokenService,
            environmentSettings: environmentSettings,
            queueLabel: "com.arise.mobile.sdk.devices.api"
        )
    }

    func getDevices() async throws -> DevicesResponse {
        let client = try getApiClient()

        do {
            let generatedResult = try await client.getPayApiV1Devices(.init())
            let result = try DevicesResponseMapper.toModel(generatedResult)
            return result
        } catch {
            try DecodingErrorHandler().handleError(error)
            throw error
        }
    }
    
    func getDeviceInfo(deviceId: String) async throws -> DeviceInfo {
        let client = try getApiClient()
        
        do {
            let generatedResult = try await client.getPayApiV1DevicesDeviceId(.init(path: .init(deviceId: deviceId)))
            let okResponse = try generatedResult.ok
            let deviceResponse = try okResponse.body.json
            let result = try DeviceMapper.toModel(deviceResponse)
            return result
        } catch {
            try DecodingErrorHandler().handleError(error)
            throw error
        }
    }
    
    /// Registers the current device with the merchant.
    ///
    /// This is a private method that gathers device information (deviceName and deviceId)
    /// and sends it to the ARISE API to register the device in the merchant's device list.
    ///
    /// - Throws: `AriseApiError` if the registration request fails
    func registerDevice() async throws {
        let client = try getApiClient()
        
        // Get device identifier from Keychain
        let deviceId = DeviceIdentifier.shared.getDeviceIdentifier().lowercased()
        
        // Get device name from device settings
        let deviceName = DeviceIdentifier.shared.getDeviceName()
        
        _logger.debug("Registering device: \(deviceName) (ID: \(deviceId))")
        
        // Create request body
        let requestBody = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_CreateOrUpdate_CreateOrUpdateDeviceRequest(
            deviceId: deviceId,
            deviceName: deviceName
        )
        
        do {
            let result = try await client.postPayApiV1Devices(.init(
                body: .json(requestBody)
            ))
            
            // Check if registration was successful
            let okResponse = try result.ok
            _logger.info("Device registered successfully: \(deviceName)")
            _logger.verbose("Registration response: \(okResponse.body)")
        } catch {
            _logger.error("Failed to register device: \(error.localizedDescription)")
            try DecodingErrorHandler().handleError(error)
            throw error
        }
    }
    
    /// Generates a Tap to Pay JWT token for the current device.
    ///
    /// This is a private method that requests a short-lived JWT token from the ARISE API
    /// for use with Mastercard Tap to Pay operations.
    ///
    /// - Parameter deviceId: The device identifier
    /// - Returns: A tuple containing the JWT token string and expiration date
    /// - Throws: `AriseApiError` if the request fails
    func getTapToPayJwt(deviceId: String) async throws -> (token: String, expiresAt: Date) {
        let client = try getApiClient()
        
        _logger.verbose("Generating TTP JWT for device: \(deviceId)")
        
        // Create request body
        let requestBody = Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Devices_TapToPay_GenerateTapToPayJwtRequest(
            deviceId: deviceId.lowercased()
        )
        
        let result = try await client.postPayApiV1DevicesTapToPayJwt(.init(
            body: .json(requestBody)
        ))
        
        let okResponse = try result.ok
        let response = try okResponse.body.json
        
        guard let jwtToken = response.jwtToken else {
            throw AriseApiError.invalidResponse("JWT token not found in response")
        }

        guard let expiresAt = response.expiresAt else {
            throw AriseApiError.invalidResponse("JWT token not found in response")
        }
        
        _logger.verbose("TTP JWT generated successfully (expires at: \(expiresAt))")
        return (token: jwtToken, expiresAt: expiresAt)
    }
    
    /// Activates Tap to Pay for the specified device.
    ///
    /// This method sends a request to the ARISE API to activate Tap to Pay functionality
    /// for the current device after successful activation via CloudCommerce SDK.
    ///
    /// - Parameter deviceId: The device identifier
    /// - Throws: `AriseApiError` if the activation request fails
    func activateTapToPay(deviceId: String) async throws {
        let client = try getApiClient()
        
        _logger.verbose("Activating Tap to Pay for device: \(deviceId)")
        
        do {
            let result = try await client.postPayApiV1DevicesDeviceIdTapToPayActivate(.init(
                path: .init(deviceId: deviceId.lowercased())
            ))
            
            // Check if activation was successful
            let okResponse = try result.ok
            _logger.info("✅ Tap to Pay activated successfully for device: \(deviceId)")
            _logger.verbose("Activation response: \(okResponse)")
        } catch {
            _logger.error("Failed to activate Tap to Pay for device: \(error.localizedDescription)")
            try DecodingErrorHandler().handleError(error)
            throw error
        }
    }
}
