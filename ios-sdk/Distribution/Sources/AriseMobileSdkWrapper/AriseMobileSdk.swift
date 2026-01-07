// AriseMobileSdkWrapper
// This wrapper provides access to the binary frameworks
// Both frameworks require external dependencies that must be provided

import Foundation

// In SPM, binary target name MUST match the module name inside the framework
// The framework's module is "AriseMobileSdk" (from PRODUCT_MODULE_NAME)
// Framework file is named "AriseMobile.xcframework" but module inside is "AriseMobileSdk"
// We import using the target name, which matches the module name
// Note: @_exported import may not work with binary targets, so types must be accessed via module prefix
// Example: AriseMobileSdk.AriseMobile, AriseMobileSdk.LogLevel, AriseMobileSdk.Environment
@_exported import AriseMobileSdk

// Import CloudCommerce using module name (target name matches module name)
@_exported import CloudCommerce

// Import dependencies required by AriseMobileSdk
@_exported import OpenAPIRuntime
@_exported import OpenAPIURLSession
@_exported import HTTPTypes

// Import dependencies required by CloudCommerce
@_exported import CryptoSwift
@_exported import SwiftASN1
@_exported import X509

// Note: Both AriseMobileSdk and CloudCommerce require external dependencies.
// These dependencies are linked dynamically at runtime to avoid duplicate class definitions.
