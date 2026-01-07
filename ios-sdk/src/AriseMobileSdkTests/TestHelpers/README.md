# Test Helpers

This directory contains test utilities, mocks, and helpers for unit testing AriseMobileSdk.

## Structure

```
TestHelpers/
├── Mocks/              # Mock implementations of external dependencies
├── Factories/          # Test data factories
├── Utilities/          # Test utilities and extensions
└── TestEnvironment.swift  # Test environment configuration
```

## Mocks

### MockCloudCommerceSDK
Mock implementation of CloudCommerceSDK for testing TTP functionality.

**Usage:**
```swift
let mockSDK = MockCloudCommerceSDK()
mockSDK.prepareResult = .success(CloudCommerce.PrepareResult())
mockSDK.performTransactionResult = .success(transactionResult)
```

### MockApiClient
Mock API client for network testing.

**Usage:**
```swift
let mockClient = MockApiClient()
mockClient.shouldFail = false
mockClient.responseDelay = 0.1
```

### MockKeychain
Mock Keychain storage for testing token persistence.

**Usage:**
```swift
let mockKeychain = MockKeychain()
try mockKeychain.saveToken(token)
let loadedToken = try mockKeychain.loadToken()
```

### MockLocationManager
Mock CLLocationManager for testing location permissions.

**Usage:**
```swift
let mockLocationManager = MockLocationManager()
mockLocationManager.mockAuthorizationStatus = .authorizedWhenInUse
```

### MockAriseAuthApi
Mock AriseAuthApi for testing authentication flows.

**Usage:**
```swift
let mockAuthApi = MockAriseAuthApi()
mockAuthApi.authenticateResult = .success(authResult)
let result = try await mockAuthApi.authenticate(clientId: "id", clientSecret: "secret")
```

**Note:** For full usage in tests, AriseAuthApi needs to be injected as a dependency into TokenService. Currently, TokenService creates AriseAuthApi internally, which limits testability.

## Factories

### DeviceFactory
Creates test device data.

**Usage:**
```swift
let device = DeviceFactory.createTTPEnabledDevice()
let disabledDevice = DeviceFactory.createTTPDisabledDevice()
```

### TransactionFactory
Creates test transaction data.

**Usage:**
```swift
let transaction = TransactionFactory.createSuccessfulSaleTransaction(amount: 50.00)
let failedTransaction = TransactionFactory.createFailedTransaction()
```

## Utilities

### AsyncTestUtilities
Utilities for testing async/await code.

**Usage:**
```swift
let conditionMet = await AsyncTestUtilities.waitForCondition {
    someValue != nil
}

let result = await AsyncTestUtilities.execute {
    try await someAsyncOperation()
}
```

### XCTestExtensions
Extensions for compatibility with Swift Testing framework.

**Usage:**
```swift
Test.assertTrue(condition, "Condition should be true")
Test.assertEqual(actual, expected)
Test.assertThrowsError {
    try await operationThatShouldFail()
}
```

## Test Environment

### TestEnvironment
Configuration for test environments.

**Usage:**
```swift
let testSettings = TestEnvironment.createTestEnvironmentSettings()
let uatSettings = TestEnvironment.createUATEnvironmentSettings()
```

