import Foundation
import React
// Import the AriseMobileSdk framework from ios-sdk
import class AriseMobileSdk.AriseMobileSdk
import enum AriseMobileSdk.Environment
import enum AriseMobileSdk.TTPError
import enum AriseMobileSdk.TTPEvent
import enum AriseMobileSdk.TTPReaderEvent
import enum AriseMobileSdk.TTPCustomEvent
import enum AriseMobileSdk.TTPTransactionStatus
import enum AriseMobileSdk.AriseApiError
import enum AriseMobileSdk.AuthenticationError
import struct AriseMobileSdk.ErrorInfo
import struct AriseMobileSdk.TTPTransactionRequest
import struct AriseMobileSdk.TTPTransactionResult
import struct AriseMobileSdk.TTPCVMData
import struct AriseMobileSdk.PaymentSettingsResponse
import struct AriseMobileSdk.NamedOption
import struct AriseMobileSdk.PaymentProcessor
import struct AriseMobileSdk.SettlementBatchTimeSlot
import struct AriseMobileSdk.AvsOptions
import struct AriseMobileSdk.DeviceInfo
import struct AriseMobileSdk.DeviceUser
import struct AriseMobileSdk.TransactionFilters
import struct AriseMobileSdk.TransactionSummary
import struct AriseMobileSdk.AmountDto
import struct AriseMobileSdk.SourceResponseDto
import struct AriseMobileSdk.AvailableOperation
import struct AriseMobileSdk.SuggestedTipsDto
import struct AriseMobileSdk.AuthorizationRequest
import struct AriseMobileSdk.AuthorizationResponse
import struct AriseMobileSdk.RefundRequest
import struct AriseMobileSdk.CalculateAmountRequest
import struct AriseMobileSdk.CalculateAmountResponse
import struct AriseMobileSdk.TransactionResponse
import struct AriseMobileSdk.TransactionResponseDetailsDto
import struct AriseMobileSdk.AddressDto
import struct AriseMobileSdk.L2Data
import struct AriseMobileSdk.L3Data
import struct AriseMobileSdk.TransactionProduct
import enum AriseMobileSdk.CardDataSource

@objc(AriseMobileSdkModule)
@MainActor
final class AriseMobileSdkModule: RCTEventEmitter {
  private var sdk: AriseMobileSdk?
  private var currentEnvironment: Environment?
  private let moduleErrorDomain = "com.arise.sdk.bridge"
  private var isPrepareInProgress = false

  private let isoFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
  }()

  private func parseDouble(from value: Any?) -> Double? {
    if let n = value as? NSNumber { return n.doubleValue }
    if let d = value as? Double { return d }
    if let s = value as? String { return Double(s) }
    return nil
  }

  private func parseInt(from value: Any?) -> Int? {
    if let n = value as? NSNumber { return n.intValue }
    if let i = value as? Int { return i }
    if let s = value as? String { return Int(s) }
    return nil
  }

  @objc static override func requiresMainQueueSetup() -> Bool {
    return true
  }

  @objc override func supportedEvents() -> [String]! {
    return ["TTPEvent"]
  }

  @objc(configure:countryCode:resolver:rejecter:)
  func configure(
    environment: NSString?,
    countryCode: NSString?,
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      let targetEnvironment = parseEnvironment(environment as String?)
      
      do {
        // Always reset SDK instance when configure is called to ensure clean state for new user/session
        print("Configuring AriseMobileSdk with country code: \(countryCode ?? "nil")")
        
        // Explicitly clear stored tokens from previous instance if it exists
        if let existingSdk = sdk {
            print("🧹 [AriseMobileSdkModule] Clearing stored tokens from previous instance during configure")
            existingSdk.clearStoredToken()
        } else {
            // Even if no instance exists in memory, clear Keychain to ensure fresh start
            print("🧹 [AriseMobileSdkModule] Clearing persisted tokens from Keychain during configure (fresh start)")
            try? AriseMobileSdk(environment: targetEnvironment, countryCode: countryCode as String?).clearStoredToken()
        }
        
        // Force recreation of SDK instance
        sdk = nil
        sdk = try AriseMobileSdk(environment: targetEnvironment, countryCode: countryCode as String?)
        
        // NUCLEAR OPTION: Ensure the new instance starts completely clean
        // Even if it tried to restore a token from disk during init, we wipe it now.
        // This forces the app to re-authenticate properly for the new user.
        print("🧹 [AriseMobileSdkModule] Wiping any restored tokens from new SDK instance to guarantee fresh session")
        sdk?.clearStoredToken()
        
        // Configure verbose logging for detailed SDK debugging
        sdk?.setLogLevel(.verbose)
        currentEnvironment = targetEnvironment
        
        resolver([
          "environment": environmentIdentifier(for: targetEnvironment),
        ])
      } catch {
        let nsError = error as NSError
        rejecter("ARISE_CONFIGURATION_ERROR", nsError.localizedDescription, nsError)
      }
    }
  }

  @objc(authenticate:clientSecret:resolver:rejecter:)
  func authenticate(
    clientId: String,
    clientSecret: String,
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      Task { @MainActor in
        do {
          let sdk = try self.getSdk()
          let result = try await sdk.authenticate(clientId: clientId, clientSecret: clientSecret)

          // Ensure the token is cached in session/keychain before resolving to JS.
          _ = await sdk.getAccessToken()

          var payload: [String: Any] = [
            "accessToken": result.accessToken,
            "expiresIn": result.expiresIn,
            "tokenType": result.tokenType,
          ]
          payload["refreshToken"] = result.refreshToken ?? NSNull()

          resolver(payload)
        } catch let nsError as NSError where nsError.domain == self.moduleErrorDomain {
          rejecter("ARISE_SDK_NOT_CONFIGURED", nsError.localizedDescription, nsError)
        } catch {
          let errorInfo = self.mapAuthenticationError(error)
          rejecter(errorInfo.code, errorInfo.message, errorInfo.underlyingError)
        }
      }
    }
  }

  @objc(reset:rejecter:)
  func reset(
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      print("🧹 [AriseMobileSdkModule] Resetting SDK state...")
      
      // Explicitly clear stored tokens from Keychain/UserDefaults
      // This is crucial to prevent stale sessions/deviceIds from persisting
      if let existingSdk = self.sdk {
          existingSdk.clearStoredToken()
      } else {
          // If SDK is nil, tokens might still exist in Keychain from a previous run.
          // Create a temporary instance to wipe them.
          // We use .uat as default, assuming storage is shared or independent of env for clearing.
          try? AriseMobileSdk(environment: .uat).clearStoredToken()
      }
      
      // Destroy the instance
      self.sdk = nil
      self.currentEnvironment = nil
      self.isPrepareInProgress = false
      
      print("✅ [AriseMobileSdkModule] SDK instance reset and tokens cleared")
      resolver(nil)
    }
  }

  @objc(getPaymentSettings:rejecter:)
  func getPaymentSettings(
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    Task {
      do {
        let sdk = try getSdk()
        let settings = try await sdk.getPaymentSettings()
        resolver(paymentSettingsDictionary(from: settings))
      } catch let nsError as NSError where nsError.domain == moduleErrorDomain {
        rejecter("ARISE_SDK_NOT_CONFIGURED", nsError.localizedDescription, nsError)
      } catch let apiError as AriseApiError {
        let errorInfo = mapAriseApiError(apiError)
        rejecter(errorInfo.code, errorInfo.message, errorInfo.underlyingError)
      } catch {
        let nsError = error as NSError
        rejecter("ARISE_PAYMENT_SETTINGS_ERROR", nsError.localizedDescription, nsError)
      }
    }
  }

  @objc(getDeviceInfo:resolver:rejecter:)
  func getDeviceInfo(
    deviceId: NSString,
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    Task {
      do {
        let sdk = try getSdk()
        let device = try await sdk.getDeviceInfo(deviceId: deviceId as String)
        resolver(deviceDictionary(from: device))
      } catch let nsError as NSError where nsError.domain == moduleErrorDomain {
        rejecter("ARISE_SDK_NOT_CONFIGURED", nsError.localizedDescription, nsError)
      } catch let apiError as AriseApiError {
        let errorInfo = mapAriseApiError(apiError)
        rejecter(errorInfo.code, errorInfo.message, errorInfo.underlyingError)
      } catch {
        let nsError = error as NSError
        rejecter("ARISE_DEVICE_INFO_ERROR", nsError.localizedDescription, nsError)
      }
    }
  }

  @objc(getDeviceId:rejecter:)
  func getDeviceId(
    _ resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      do {
        let sdk = try self.getSdk()
        resolver(sdk.getDeviceId())
      } catch {
        let nsError = error as NSError
        rejecter("ARISE_GET_DEVICE_ID_ERROR", nsError.localizedDescription, nsError)
      }
    }
  }

  @objc(getTransactions:resolver:rejecter:)
  func getTransactions(
    filters: NSDictionary?,
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    Task {
      do {
        let sdk = try getSdk()
        let transactionFilters = try parseTransactionFilters(from: filters)
        let response = try await sdk.getTransactions(filters: transactionFilters)
        
        var result: [String: Any] = [:]
        if let response = response {
            result["items"] = response.items.map { transactionSummaryDictionary(from: $0) }
            result["total"] = response.total
        } else {
            result["items"] = []
            result["total"] = 0
        }
        
        resolver(result)
      } catch let nsError as NSError where nsError.domain == moduleErrorDomain {
        rejecter("ARISE_SDK_NOT_CONFIGURED", nsError.localizedDescription, nsError)
      } catch let apiError as AriseApiError {
        let errorInfo = mapAriseApiError(apiError)
        rejecter(errorInfo.code, errorInfo.message, errorInfo.underlyingError)
      } catch {
        let nsError = error as NSError
        rejecter("ARISE_GET_TRANSACTIONS_ERROR", nsError.localizedDescription, nsError)
      }
    }
  }

  @objc(submitSaleTransaction:resolver:rejecter:)
  func submitSaleTransaction(
    input: NSDictionary,
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    print("AriseMobileSdkModule: submitSaleTransaction called with input: \(input)")
    Task {
      do {
        let sdk = try getSdk()
        let request = try parseAuthorizationRequest(from: input)
        print("AriseMobileSdkModule: Parsed AuthorizationRequest: \(request)")
        let response = try await sdk.submitSaleTransaction(input: request)
        resolver(authorizationResponseDictionary(from: response))
      } catch let nsError as NSError where nsError.domain == moduleErrorDomain {
        print("AriseMobileSdkModule: Module error: \(nsError)")
        rejecter("ARISE_SDK_NOT_CONFIGURED", nsError.localizedDescription, nsError)
      } catch let apiError as AriseApiError {
        print("AriseMobileSdkModule: API error: \(apiError)")
        let errorInfo = mapAriseApiError(apiError)
        rejecter(errorInfo.code, errorInfo.message, errorInfo.underlyingError)
      } catch {
        print("AriseMobileSdkModule: Unexpected error: \(error)")
        let nsError = error as NSError
        rejecter("ARISE_SALE_ERROR", nsError.localizedDescription, nsError)
      }
    }
  }

    @objc(voidTransaction:resolver:rejecter:)
  func voidTransaction(
    transactionId: String,
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    Task {
      do {
        let sdk = try getSdk()
        let response = try await sdk.voidTransaction(transactionId: transactionId)
        // TransactionResponse can be treated similar to AuthorizationResponse for this purpose
        // assuming TransactionResponse has similar fields or is a type alias/compatible.
        // If TransactionResponse differs, we might need a specific mapper.
        // Checking codebase, voidTransaction returns TransactionResponse.
        // Let's assume TransactionResponse has similar structure or use a shared mapper if possible.
        // But TransactionResponse in SDK maps to IsvTransactionResponse which usually matches AuthorizationResponse structure.
        // We'll manually map here to be safe, reusing the logic.
        
        var result: [String: Any] = [:]
        result["transactionId"] = response.transactionId ?? NSNull()
        result["status"] = response.status ?? NSNull()
        result["statusId"] = response.statusId.map { Int($0) } ?? NSNull()
        result["type"] = response.type ?? NSNull()
        result["typeId"] = response.typeId.map { Int($0) } ?? NSNull()
        
        if let date = response.transactionDateTime {
            result["transactionDateTime"] = isoFormatter.string(from: date)
        } else {
            result["transactionDateTime"] = NSNull()
        }
        
        if let details = response.details {
            result["details"] = transactionResponseDetailsDictionary(from: details)
        } else {
            result["details"] = NSNull()
        }
        
        resolver(result)
      } catch let nsError as NSError where nsError.domain == moduleErrorDomain {
        rejecter("ARISE_SDK_NOT_CONFIGURED", nsError.localizedDescription, nsError)
      } catch let apiError as AriseApiError {
        let errorInfo = mapAriseApiError(apiError)
        rejecter(errorInfo.code, errorInfo.message, errorInfo.underlyingError)
      } catch {
        let nsError = error as NSError
        rejecter("ARISE_VOID_ERROR", nsError.localizedDescription, nsError)
      }
    }
  }

  @objc(captureTransaction:amount:resolver:rejecter:)
  func captureTransaction(
    transactionId: String,
    amount: Double,
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    Task {
      do {
        let sdk = try getSdk()
        let response = try await sdk.captureTransaction(transactionId: transactionId, amount: amount)
        
        var result: [String: Any] = [:]
        result["transactionId"] = response.transactionId ?? NSNull()
        result["status"] = response.status ?? NSNull()
        result["statusId"] = response.statusId.map { Int($0) } ?? NSNull()
        result["type"] = response.type ?? NSNull()
        result["typeId"] = response.typeId.map { Int($0) } ?? NSNull()
        
        if let date = response.transactionDateTime {
            result["transactionDateTime"] = isoFormatter.string(from: date)
        } else {
            result["transactionDateTime"] = NSNull()
        }
        
        if let details = response.details {
            result["details"] = transactionResponseDetailsDictionary(from: details)
        } else {
            result["details"] = NSNull()
        }
        
        resolver(result)
      } catch let nsError as NSError where nsError.domain == moduleErrorDomain {
        rejecter("ARISE_SDK_NOT_CONFIGURED", nsError.localizedDescription, nsError)
      } catch let apiError as AriseApiError {
        let errorInfo = mapAriseApiError(apiError)
        rejecter(errorInfo.code, errorInfo.message, errorInfo.underlyingError)
      } catch {
        let nsError = error as NSError
        rejecter("ARISE_CAPTURE_ERROR", nsError.localizedDescription, nsError)
      }
    }
  }

  @objc(refundTransaction:resolver:rejecter:)
  func refundTransaction(
    input: NSDictionary,
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    Task {
      do {
        let sdk = try getSdk()
        let request = try parseRefundRequest(from: input)
        let response = try await sdk.refundTransaction(request: request)
        
        var result: [String: Any] = [:]
        result["transactionId"] = response.transactionId ?? NSNull()
        result["status"] = response.status ?? NSNull()
        result["statusId"] = response.statusId.map { Int($0) } ?? NSNull()
        result["type"] = response.type ?? NSNull()
        result["typeId"] = response.typeId.map { Int($0) } ?? NSNull()
        
        if let date = response.transactionDateTime {
            result["transactionDateTime"] = isoFormatter.string(from: date)
        } else {
            result["transactionDateTime"] = NSNull()
        }
        
        if let details = response.details {
            result["details"] = transactionResponseDetailsDictionary(from: details)
        } else {
            result["details"] = NSNull()
        }
        
        resolver(result)
      } catch let nsError as NSError where nsError.domain == moduleErrorDomain {
        rejecter("ARISE_SDK_NOT_CONFIGURED", nsError.localizedDescription, nsError)
      } catch let apiError as AriseApiError {
        let errorInfo = mapAriseApiError(apiError)
        rejecter(errorInfo.code, errorInfo.message, errorInfo.underlyingError)
      } catch {
        let nsError = error as NSError
        rejecter("ARISE_REFUND_ERROR", nsError.localizedDescription, nsError)
      }
    }
  }

  @objc(calculateAmount:resolver:rejecter:)
  func calculateAmount(
    request: NSDictionary,
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    Task {
      do {
        let sdk = try getSdk()
        let calcRequest = try parseCalculateAmountRequest(from: request)
        let response = try await sdk.calculateAmount(request: calcRequest)
        resolver(calculateAmountResponseDictionary(from: response))
      } catch let nsError as NSError where nsError.domain == moduleErrorDomain {
        if nsError.code == 1001 {
          rejecter("ARISE_INVALID_ARGUMENTS", nsError.localizedDescription, nsError)
          return
        }
        if nsError.code == 2001 {
          rejecter("ARISE_SDK_NOT_CONFIGURED", nsError.localizedDescription, nsError)
          return
        }
        rejecter("ARISE_SDK_NOT_CONFIGURED", nsError.localizedDescription, nsError)
      } catch let apiError as AriseApiError {
        let errorInfo = mapAriseApiError(apiError)
        rejecter(errorInfo.code, errorInfo.message, errorInfo.underlyingError)
      } catch {
        let nsError = error as NSError
        rejecter("ARISE_CALCULATE_AMOUNT_ERROR", nsError.localizedDescription, nsError)
      }
    }
  }

  @objc(checkCompatibility:rejecter:)
  func checkCompatibility(
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    Task {
      do {
        var sdkInstance: AriseMobileSdk
        if let existing = sdk {
            sdkInstance = existing
        } else {
            // Default to UAT just to access the method
            sdkInstance = try AriseMobileSdk(environment: .uat)
        }
        
        let result = sdkInstance.ttp.checkCompatibility()
        
        resolver([
            "isCompatible": result.isCompatible,
            "incompatibilityReasons": result.incompatibilityReasons
        ])
      } catch {
        let nsError = error as NSError
        rejecter("ARISE_COMPATIBILITY_CHECK_ERROR", nsError.localizedDescription, nsError)
      }
    }
  }

  @objc(prepare:rejecter:)
  func prepare(
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    // Guarantee execution on main thread - React Native bridge methods can be called from any thread
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      Task { @MainActor in
        do {
          let sdk = try self.getSdk()
          try await sdk.ttp.prepare()
          resolver(nil)
          self.isPrepareInProgress = false
        } catch let nsError as NSError where nsError.domain == self.moduleErrorDomain {
          rejecter("ARISE_SDK_NOT_CONFIGURED", nsError.localizedDescription, nsError)
          self.isPrepareInProgress = false
        } catch let apiError as AriseApiError {
          let errorInfo = self.mapAriseApiError(apiError)
          rejecter(errorInfo.code, errorInfo.message, errorInfo.underlyingError)
          self.isPrepareInProgress = false
        } catch {
          let nsError = error as NSError
          rejecter("ARISE_PREPARE_ERROR", nsError.localizedDescription, nsError)
          self.isPrepareInProgress = false
        }
      }
    }
  }

  @objc(activate:rejecter:)
  func activate(
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    // Guarantee execution on main thread - React Native bridge methods can be called from any thread
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      Task { @MainActor in
        do {
          let sdk = try self.getSdk()
          try await sdk.ttp.activate()
          
          // Return the latest SDK TTP status after activation completes
          let status = try await sdk.ttp.getStatus()
          let statusString: String
          switch status {
          case .active:
            statusString = "Active"
          case .inactive:
            statusString = "Inactive"
          @unknown default:
            statusString = "Unknown"
          }
          
          resolver(statusString)
        } catch let nsError as NSError where nsError.domain == self.moduleErrorDomain {
          rejecter("ARISE_SDK_NOT_CONFIGURED", nsError.localizedDescription, nsError)
        } catch let apiError as AriseApiError {
          let errorInfo = self.mapAriseApiError(apiError)
          rejecter(errorInfo.code, errorInfo.message, errorInfo.underlyingError)
        } catch {
          let nsError = error as NSError
          rejecter("ARISE_ACTIVATION_ERROR", nsError.localizedDescription, nsError)
        }
      }
    }
  }
    
  @objc(activateTapToPayFromUI:rejecter:)
  func activateTapToPayFromUI(
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
      DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      Task { @MainActor in
        do {
          let sdk = try AriseMobileSdk(environment: .uat)
          let token = try await sdk.authenticate(clientId: "92a7ef18-a183-47cc-83ac-b05173a8264c", clientSecret: "7b82dc59-1db6-4408-8966-8251c24e0ae4")
          print("token : \(token)")
          try await sdk.ttp.activate()
          
          // Return the latest SDK TTP status after activation completes
          let status = try await sdk.ttp.getStatus()
          let statusString: String
          switch status {
          case .active:
            statusString = "Active"
          case .inactive:
            statusString = "Inactive"
          @unknown default:
            statusString = "Unknown"
          }
          
          resolver(statusString)
        } catch let nsError as NSError where nsError.domain == self.moduleErrorDomain {
          rejecter("ARISE_SDK_NOT_CONFIGURED", nsError.localizedDescription, nsError)
        } catch let apiError as AriseApiError {
          let errorInfo = self.mapAriseApiError(apiError)
          rejecter(errorInfo.code, errorInfo.message, errorInfo.underlyingError)
        } catch {
          let nsError = error as NSError
          rejecter("ARISE_ACTIVATION_ERROR", nsError.localizedDescription, nsError)
        }
      }
    }
  }

  @objc(getTapToPayStatus:rejecter:)
  func getTapToPayStatus(
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    Task {
      do {
        let sdk = try getSdk()
        let status = try await sdk.ttp.getStatus()

        // Map TTPStatus enum to a string for JS consumption
        let statusString: String
        switch status {
        case .active:
            statusString = "Active"
        case .inactive:
            statusString = "Inactive"
        @unknown default:
            statusString = "Unknown"
        }

        resolver(statusString)
      } catch let nsError as NSError where nsError.domain == moduleErrorDomain {
        rejecter("ARISE_SDK_NOT_CONFIGURED", nsError.localizedDescription, nsError)
      } catch let apiError as AriseApiError {
        let errorInfo = mapAriseApiError(apiError)
        rejecter(errorInfo.code, errorInfo.message, errorInfo.underlyingError)
      } catch {
        let nsError = error as NSError
        rejecter("ARISE_TTP_STATUS_ERROR", nsError.localizedDescription, nsError)
      }
    }
  }

  @objc(resume:rejecter:)
  func resume(
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    // Guarantee execution on main thread
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      Task { @MainActor in
        do {
          print("🔄 [AriseMobileSdkModule] resume() called from React Native")
          
          let sdk = try self.getSdk()
          print("✅ [AriseMobileSdkModule] SDK instance obtained")
          
          print("🔄 [AriseMobileSdkModule] Calling sdk.ttp.resume()...")
          try await sdk.ttp.resume()
          print("✅ [AriseMobileSdkModule] TTP resumed successfully")
          
          resolver(nil)
        } catch let nsError as NSError where nsError.domain == self.moduleErrorDomain {
          print("❌ [AriseMobileSdkModule] Module configuration error: \(nsError.localizedDescription)")
          if nsError.code == 1001 {
            rejecter("ARISE_INVALID_ARGUMENTS", nsError.localizedDescription, nsError)
          } else if nsError.code == 2001 {
            rejecter("ARISE_SDK_NOT_CONFIGURED", nsError.localizedDescription, nsError)
          } else {
            rejecter("ARISE_TRANSACTION_ERROR", nsError.localizedDescription, nsError)
          }
        } catch let ttpError as TTPError {
          print("❌ [AriseMobileSdkModule] TTP error during resume:")
          print("   TTPError type: \(ttpError)")
          print("   Description: \(ttpError.localizedDescription ?? "no description")")
          print("   Error code: \(ttpError.errorCode ?? "no code")")
          let errorInfo = self.mapTTPError(ttpError)
          rejecter(errorInfo.code, errorInfo.message, errorInfo.underlyingError)
        } catch let apiError as AriseApiError {
          print("❌ [AriseMobileSdkModule] API error during resume: \(apiError.localizedDescription ?? "no description")")
          let errorInfo = self.mapAriseApiError(apiError)
          rejecter(errorInfo.code, errorInfo.message, errorInfo.underlyingError)
        } catch {
          print("❌ [AriseMobileSdkModule] Unexpected error during resume:")
          print("   Error: \(error.localizedDescription)")
          print("   Error Type: \(type(of: error))")
          let nsError = error as NSError
          rejecter("ARISE_RESUME_ERROR", nsError.localizedDescription, nsError)
        }
      }
    }
  }

  @objc(performTransaction:resolver:rejecter:)
  func performTransaction(
    transactionDetails: NSDictionary,
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    // Guarantee execution on main thread
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      Task { @MainActor in
        do {
          print("💳 [AriseMobileSdkModule] performTransaction() called from React Native")
          
          let sdk = try self.getSdk()
          
          // Parse transaction request from JavaScript dictionary
          let request = try self.parseTTPTransactionRequest(from: transactionDetails)
          print("✅ [AriseMobileSdkModule] Transaction request parsed: amount=\(request.amount), orderId=\(request.orderId ?? "nil")")
          
          // Perform transaction via wrapper
          print("🔄 [AriseMobileSdkModule] Calling sdk.ttp.performTransaction()...")
          let result = try await sdk.ttp.performTransaction(request: request)
          print("✅ [AriseMobileSdkModule] Transaction completed: \(result.status.rawValue), transactionId=\(result.transactionId ?? "nil")")
          
          // Convert result to dictionary for React Native
          let resultDict = self.ttpTransactionResultDictionary(from: result)
          resolver(resultDict)
          
        } catch let nsError as NSError where nsError.domain == self.moduleErrorDomain {
          print("❌ [AriseMobileSdkModule] Module configuration error: \(nsError.localizedDescription)")
          rejecter("ARISE_SDK_NOT_CONFIGURED", nsError.localizedDescription, nsError)
        } catch let ttpError as TTPError {
          print("❌ [AriseMobileSdkModule] TTP error during transaction:")
          print("   TTPError type: \(ttpError)")
          print("   Description: \(ttpError.localizedDescription ?? "no description")")
          let errorInfo = self.mapTTPError(ttpError)
          rejecter(errorInfo.code, errorInfo.message, errorInfo.underlyingError)
        } catch let apiError as AriseApiError {
          print("❌ [AriseMobileSdkModule] API error during transaction: \(apiError.localizedDescription ?? "no description")")
          let errorInfo = self.mapAriseApiError(apiError)
          rejecter(errorInfo.code, errorInfo.message, errorInfo.underlyingError)
        } catch {
          let nsError = error as NSError
          print("❌ [AriseMobileSdkModule] Unexpected error during transaction:")
          print("   Error: \(nsError.localizedDescription)")
          print("   Error Type: \(type(of: error))")
          rejecter("ARISE_TRANSACTION_ERROR", nsError.localizedDescription, nsError)
        }
      }
    }
  }

  @objc(showEducationalInfo:rejecter:)
  func showEducationalInfo(
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    // Must run on main thread
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      Task { @MainActor in
        do {
            let sdk = try self.getSdk()
            
            // Get root view controller
            guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
              rejecter("ARISE_NO_VIEW_CONTROLLER", "No root view controller available", nil)
              return
            }
            
            // Find the topmost presented view controller
            var topController = rootViewController
            while let presented = topController.presentedViewController {
              topController = presented
            }
            
            try await sdk.ttp.showEducationalInfo(from: topController)
            resolver(["success": true])
        } catch let nsError as NSError where nsError.domain == self.moduleErrorDomain {
          rejecter("ARISE_SDK_NOT_CONFIGURED", nsError.localizedDescription, nsError)
        } catch let ttpError as TTPError {
          print("❌ [AriseMobileSdkModule] Failed to show educational info: \(ttpError)")
          let errorInfo = self.mapTTPError(ttpError)
          rejecter(errorInfo.code, errorInfo.message, errorInfo.underlyingError)
        } catch {
          print("❌ [AriseMobileSdkModule] Education error: \(error)")
          let nsError = error as NSError
          rejecter("ARISE_EDUCATION_ERROR", nsError.localizedDescription, nsError)
        }
      }
    }
  }

  @objc(eventsStream:rejecter:)
  func eventsStream(
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    Task {
      do {
        print("🚀 [AriseMobileSdkModule] eventsStream() called")
        let sdk = try getSdk()
        print("✅ [AriseMobileSdkModule] SDK instance obtained")
        
        let eventStream = try sdk.ttp.eventsStream()
        print("✅ [AriseMobileSdkModule] Event stream created successfully")

        // Convert AsyncStream to a promise that resolves immediately
        // The actual streaming will be handled through event emitters
        let streamId = UUID().uuidString
        print("📡 [AriseMobileSdkModule] Stream ID: \(streamId)")
        
        resolver([
          "streamId": streamId,
          "status": "started"
        ])
        
        print("✅ [AriseMobileSdkModule] Promise resolved, starting background stream processing")

        // Start processing the stream in the background
        Task.detached { [weak self] in
          guard let self = self else { 
            print("❌ [AriseMobileSdkModule] Self is nil, cannot process events")
            return 
          }
          
          print("🎬 [AriseMobileSdkModule] Background task started for stream: \(streamId)")
          var eventCount = 0

          for await event in eventStream {
            eventCount += 1
            print("📬 [AriseMobileSdkModule] Event #\(eventCount) received from stream")
            // Send event to JavaScript on the main actor
            await MainActor.run {
              print("📤 [AriseMobileSdkModule] Sending event #\(eventCount) to JavaScript...")
              self.sendEventToJavaScript(event: event)
              print("✅ [AriseMobileSdkModule] Event #\(eventCount) sent to JavaScript")
            }
          }
          
          print("🏁 [AriseMobileSdkModule] Event stream ended. Total events: \(eventCount)")
        }
      } catch let nsError as NSError where nsError.domain == moduleErrorDomain {
        print("❌ [AriseMobileSdkModule] Module error: \(nsError.localizedDescription)")
        rejecter("ARISE_SDK_NOT_CONFIGURED", nsError.localizedDescription, nsError)
      } catch let ttpError as TTPError {
        print("❌ [AriseMobileSdkModule] TTP error: \(ttpError.localizedDescription ?? "unknown")")
        let errorInfo = self.mapTTPError(ttpError)
        rejecter(errorInfo.code, errorInfo.message, errorInfo.underlyingError)
      } catch {
        let nsError = error as NSError
        print("❌ [AriseMobileSdkModule] Unexpected error: \(nsError.localizedDescription)")
        rejecter("ARISE_EVENTS_STREAM_ERROR", nsError.localizedDescription, nsError)
      }
    }
  }

  private func sendEventToJavaScript(event: TTPEvent) {
    // Send event through React Native's event emitter
    let eventData = ttpEventDictionary(from: event)
    print("🔔 [AriseMobileSdkModule] Sending TTPEvent to JavaScript: \(eventData)")
    sendEvent(withName: "TTPEvent", body: eventData)
    print("✅ [AriseMobileSdkModule] sendEvent completed")
  }

  private func getSdk() throws -> AriseMobileSdk {
    guard let environment = currentEnvironment else {
      throw moduleNotConfiguredError()
    }

    if let existingSdk = sdk {
      return existingSdk
    }

    let newSdk = try AriseMobileSdk(environment: environment)
    sdk = newSdk
    return newSdk
  }

  private func parseEnvironment(_ value: String?) -> Environment {
    guard let rawValue = value?.lowercased() else {
      return .uat
    }

    switch rawValue {
    case "production", "prod":
      return .production
    default:
      return .uat
    }
  }

  private func environmentIdentifier(for environment: Environment) -> String {
    switch environment {
    case .production:
      return "production"
    case .uat:
      return "uat"
    }
  }

  private func moduleNotConfiguredError() -> NSError {
    NSError(
      domain: moduleErrorDomain,
      code: 2001,
      userInfo: [
        NSLocalizedDescriptionKey: "AriseMobileSdkModule is not configured. Call configure(environment:) before invoking SDK methods.",
      ]
    )
  }

  private func mapAuthenticationError(_ error: Error) -> (code: String, message: String, underlyingError: NSError?) {
    if let authError = error as? AuthenticationError {
      switch authError {
      case .invalidCredentials:
        return (
          "ARISE_INVALID_CREDENTIALS",
          authError.localizedDescription,
          createNSError(code: 1001, message: authError.localizedDescription)
        )
      case .networkError(let message):
        return (
          "ARISE_NETWORK_ERROR",
          message,
          createNSError(code: 1002, message: message)
        )
      case .invalidResponse:
        return (
          "ARISE_INVALID_RESPONSE",
          authError.localizedDescription,
          createNSError(code: 1003, message: authError.localizedDescription)
        )
      case .tokenExpired:
        return (
          "ARISE_TOKEN_EXPIRED",
          authError.localizedDescription,
          createNSError(code: 1004, message: authError.localizedDescription)
        )
      case .unknown(let message):
        return (
          "ARISE_UNKNOWN_ERROR",
          message,
          createNSError(code: 1005, message: message)
        )
      }
    }

    let nsError = error as NSError
    return ("ARISE_SDK_ERROR", nsError.localizedDescription, nsError)
  }

  private func mapAriseApiError(_ error: AriseApiError) -> (code: String, message: String, underlyingError: NSError?) {
    let defaultMessage = error.localizedDescription.isEmpty ? "Unknown API error" : error.localizedDescription

    func createApiNSError(
      bridgeCode: String,
      message: String,
      errorInfo: ErrorInfo?
    ) -> NSError {
      var userInfo: [String: Any] = [
        NSLocalizedDescriptionKey: message,
        "BridgeCode": bridgeCode
      ]

      if let info = errorInfo {
        userInfo["StatusCode"] = info.statusCode
        if let correlationId = info.correlationId { userInfo["CorrelationId"] = correlationId }
        if let errorCode = info.errorCode { userInfo["ErrorCode"] = errorCode }
        if let source = info.source { userInfo["Source"] = source }
        if let exceptionType = info.exceptionType { userInfo["ExceptionType"] = exceptionType }
        if let details = info.details { userInfo["Details"] = details }
      }

      return NSError(
        domain: "com.arise.sdk.api",
        code: 3000,
        userInfo: userInfo
      )
    }

    switch error {
    case .networkError(let message):
      let resolvedMessage = message.isEmpty ? defaultMessage : message
      let bridgeCode = "ARISE_API_NETWORK_ERROR"
      let nsError = createApiNSError(bridgeCode: bridgeCode, message: resolvedMessage, errorInfo: nil)
      return (bridgeCode, resolvedMessage, nsError)

    case .invalidResponse(let message):
      let resolvedMessage = message.isEmpty ? defaultMessage : message
      let bridgeCode = "ARISE_API_INVALID_RESPONSE"
      let nsError = createApiNSError(bridgeCode: bridgeCode, message: resolvedMessage, errorInfo: nil)
      return (bridgeCode, resolvedMessage, nsError)

    case .unauthorized(let message):
      let resolvedMessage = message.isEmpty ? defaultMessage : message
      let bridgeCode = "ARISE_API_UNAUTHORIZED"
      let nsError = createApiNSError(bridgeCode: bridgeCode, message: resolvedMessage, errorInfo: nil)
      return (bridgeCode, resolvedMessage, nsError)

    case .badRequest(let message, _):
      let resolvedMessage = message.isEmpty ? defaultMessage : message
      let bridgeCode = "ARISE_API_BAD_REQUEST"
      let info = error.errorInfo
      // Prefer the backend/platform errorCode when present (e.g. "V0000") so JS can map it.
      let jsCode = (info?.errorCode?.isEmpty == false) ? info!.errorCode! : bridgeCode
      let nsError = createApiNSError(bridgeCode: bridgeCode, message: resolvedMessage, errorInfo: info)
      return (jsCode, resolvedMessage, nsError)

    case .forbidden(let message, _):
      let resolvedMessage = message.isEmpty ? defaultMessage : message
      let bridgeCode = "ARISE_API_FORBIDDEN"
      let info = error.errorInfo
      let jsCode = (info?.errorCode?.isEmpty == false) ? info!.errorCode! : bridgeCode
      let nsError = createApiNSError(bridgeCode: bridgeCode, message: resolvedMessage, errorInfo: info)
      return (jsCode, resolvedMessage, nsError)

    case .notFound(let message, _):
      let resolvedMessage = message.isEmpty ? defaultMessage : message
      let bridgeCode = "ARISE_API_NOT_FOUND"
      let info = error.errorInfo
      let jsCode = (info?.errorCode?.isEmpty == false) ? info!.errorCode! : bridgeCode
      let nsError = createApiNSError(bridgeCode: bridgeCode, message: resolvedMessage, errorInfo: info)
      return (jsCode, resolvedMessage, nsError)

    case .serverError(let message, _):
      let resolvedMessage = message.isEmpty ? defaultMessage : message
      let bridgeCode = "ARISE_API_SERVER_ERROR"
      let info = error.errorInfo
      let jsCode = (info?.errorCode?.isEmpty == false) ? info!.errorCode! : bridgeCode
      let nsError = createApiNSError(bridgeCode: bridgeCode, message: resolvedMessage, errorInfo: info)
      return (jsCode, resolvedMessage, nsError)

    case .unknown(let message, _):
      let resolvedMessage = message.isEmpty ? defaultMessage : message
      let bridgeCode = "ARISE_API_UNKNOWN_ERROR"
      let info = error.errorInfo
      let jsCode = (info?.errorCode?.isEmpty == false) ? info!.errorCode! : bridgeCode
      let nsError = createApiNSError(bridgeCode: bridgeCode, message: resolvedMessage, errorInfo: info)
      return (jsCode, resolvedMessage, nsError)
    }
  }

  private func createNSError(code: Int, message: String) -> NSError {
    NSError(
      domain: "com.arise.sdk.authentication",
      code: code,
      userInfo: [NSLocalizedDescriptionKey: message]
    )
  }

  private func paymentSettingsDictionary(from settings: PaymentSettingsResponse) -> [String: Any] {
    var dictionary: [String: Any] = [
      "availableCurrencies": settings.availableCurrencies.map { namedOptionDictionary(from: $0) },
      "availableCardTypes": settings.availableCardTypes.map { namedOptionDictionary(from: $0) },
      "availableTransactionTypes": settings.availableTransactionTypes.map { namedOptionDictionary(from: $0) },
      "availablePaymentProcessors": settings.availablePaymentProcessors.map { paymentProcessorDictionary(from: $0) },
      "isTipsEnabled": settings.isTipsEnabled,
      "isCustomerCardSavingByTerminalEnabled": settings.isCustomerCardSavingByTerminalEnabled
    ]

    dictionary["zeroCostProcessingOptionId"] = settings.zeroCostProcessingOptionId.map { Int($0) } ?? NSNull()
    dictionary["zeroCostProcessingOption"] = settings.zeroCostProcessingOption ?? NSNull()
    dictionary["defaultSurchargeRate"] = settings.defaultSurchargeRate ?? NSNull()
    dictionary["defaultCashDiscountRate"] = settings.defaultCashDiscountRate ?? NSNull()
    dictionary["defaultDualPricingRate"] = settings.defaultDualPricingRate ?? NSNull()
    dictionary["defaultTipsOptions"] = settings.defaultTipsOptions ?? NSNull()
    dictionary["avs"] = settings.avs.map { avsOptionsDictionary(from: $0) } ?? NSNull()

    return dictionary
  }

  private func namedOptionDictionary(from option: NamedOption) -> [String: Any] {
    [
      "id": Int(option.id),
      "name": option.name ?? NSNull()
    ]
  }

  private func paymentProcessorDictionary(from processor: PaymentProcessor) -> [String: Any] {
    var dictionary: [String: Any] = [:]

    dictionary["id"] = processor.id ?? NSNull()
    dictionary["name"] = processor.name ?? NSNull()
    dictionary["isDefault"] = processor.isDefault ?? NSNull()
    dictionary["typeId"] = processor.typeId.map { Int($0) } ?? NSNull()
    dictionary["type"] = processor.type ?? NSNull()

    if let timeSlots = processor.settlementBatchTimeSlots {
      dictionary["settlementBatchTimeSlots"] = timeSlots.map { settlementBatchTimeSlotDictionary(from: $0) }
    } else {
      dictionary["settlementBatchTimeSlots"] = NSNull()
    }

    return dictionary
  }

  private func settlementBatchTimeSlotDictionary(from slot: SettlementBatchTimeSlot) -> [String: Any] {
    [
      "hours": slot.hours.map { Int($0) } ?? NSNull(),
      "minutes": slot.minutes.map { Int($0) } ?? NSNull(),
      "timezoneName": slot.timezoneName ?? NSNull()
    ]
  }

  private func avsOptionsDictionary(from avs: AvsOptions) -> [String: Any] {
    [
      "isEnabled": avs.isEnabled ?? NSNull(),
      "profileId": avs.profileId.map { Int($0) } ?? NSNull(),
      "profile": avs.profile ?? NSNull()
    ]
  }

  private func deviceDictionary(from device: DeviceInfo) -> [String: Any] {
    var dictionary: [String: Any] = [
      "tapToPayEnabled": device.tapToPayEnabled,
      "userProfiles": device.userProfiles.map { deviceUserDictionary(from: $0) }
    ]

    dictionary["deviceId"] = device.deviceId ?? NSNull()
    dictionary["deviceName"] = device.deviceName ?? NSNull()
    dictionary["tapToPayStatus"] = device.tapToPayStatus ?? NSNull()
    dictionary["tapToPayStatusId"] = device.tapToPayStatusId ?? NSNull()

    if let lastLoginAt = device.lastLoginAt {
      dictionary["lastLoginAt"] = isoFormatter.string(from: lastLoginAt)
    } else {
      dictionary["lastLoginAt"] = NSNull()
    }

    return dictionary
  }

  private func deviceUserDictionary(from user: DeviceUser) -> [String: Any] {
    [
      "id": user.id ?? NSNull(),
      "firstName": user.firstName ?? NSNull(),
      "lastName": user.lastName ?? NSNull(),
      "email": user.email ?? NSNull()
    ]
  }

  // MARK: - Transaction Helpers

  private func parseTransactionFilters(from dictionary: NSDictionary?) throws -> TransactionFilters? {
    guard let dict = dictionary else { return nil }
    
    return try TransactionFilters(
        page: dict["page"] as? Int,
        pageSize: dict["pageSize"] as? Int,
        asc: dict["asc"] as? Bool,
        orderBy: dict["orderBy"] as? String,
        createMethodId: dict["createMethodId"] as? Int,
        createdById: dict["createdById"] as? String,
        batchId: dict["batchId"] as? String,
        noBatch: dict["noBatch"] as? Bool
    )
  }
  
  private func transactionSummaryDictionary(from summary: TransactionSummary) -> [String: Any] {
    var dictionary: [String: Any] = [
        "id": summary.id,
        "paymentProcessorId": summary.paymentProcessorId,
        "merchantId": summary.merchantId,
        "status": summary.status,
        "statusId": summary.statusId,
        "typeId": summary.typeId,
        "baseAmount": summary.baseAmount,
        "totalAmount": summary.totalAmount,
        "amount": amountDictionary(from: summary.amount),
        "source": sourceResponseDictionary(from: summary.source)
    ]
    
    if let date = summary.date {
        dictionary["date"] = isoFormatter.string(from: date)
    } else {
        dictionary["date"] = NSNull()
    }
    
    dictionary["surchargeAmount"] = summary.surchargeAmount ?? NSNull()
    dictionary["surchargePercentage"] = summary.surchargePercentage ?? NSNull()
    dictionary["currencyCode"] = summary.currencyCode ?? NSNull()
    dictionary["currencyId"] = summary.currencyId.map { Int($0) } ?? NSNull()
    dictionary["merchant"] = summary.merchant ?? NSNull()
    dictionary["operationMode"] = summary.operationMode ?? NSNull()
    dictionary["paymentMethodType"] = summary.paymentMethodType ?? NSNull()
    dictionary["paymentMethodTypeId"] = summary.paymentMethodTypeId ?? NSNull()
    dictionary["paymentMethodName"] = summary.paymentMethodName ?? NSNull()
    dictionary["customerName"] = summary.customerName ?? NSNull()
    dictionary["customerCompany"] = summary.customerCompany ?? NSNull()
    dictionary["customerPan"] = summary.customerPan ?? NSNull()
    dictionary["cardTokenType"] = summary.cardTokenType.map { $0.rawValue } ?? NSNull()
    dictionary["customerEmail"] = summary.customerEmail ?? NSNull()
    dictionary["customerPhone"] = summary.customerPhone ?? NSNull()
    dictionary["type"] = summary.type ?? NSNull()
    dictionary["batchId"] = summary.batchId ?? NSNull()
    
    if let operations = summary.availableOperations {
        dictionary["availableOperations"] = operations.map { availableOperationDictionary(from: $0) }
    } else {
        dictionary["availableOperations"] = NSNull()
    }
    
    return dictionary
  }
  
  private func amountDictionary(from amount: AmountDto) -> [String: Any] {
    [
        "baseAmount": amount.baseAmount,
        "percentageOffAmount": amount.percentageOffAmount,
        "percentageOffRate": amount.percentageOffRate,
        "cashDiscountAmount": amount.cashDiscountAmount,
        "cashDiscountRate": amount.cashDiscountRate,
        "surchargeAmount": amount.surchargeAmount,
        "surchargeRate": amount.surchargeRate,
        "tipAmount": amount.tipAmount,
        "tipRate": amount.tipRate,
        "taxAmount": amount.taxAmount,
        "taxRate": amount.taxRate,
        "totalAmount": amount.totalAmount
    ]
  }
  
  private func sourceResponseDictionary(from source: SourceResponseDto) -> [String: Any] {
    [
        "typeId": source.typeId ?? NSNull(),
        "type": source.type ?? NSNull(),
        "id": source.id ?? NSNull(),
        "name": source.name
    ]
  }
  
  private func availableOperationDictionary(from operation: AvailableOperation) -> [String: Any] {
    var dictionary: [String: Any] = [
        "typeId": operation.typeId,
    ]
    
    dictionary["type"] = operation.type ?? NSNull()
    dictionary["availableAmount"] = operation.availableAmount ?? NSNull()
    
    if let tips = operation.suggestedTips {
        dictionary["suggestedTips"] = tips.map { suggestedTipsDictionary(from: $0) }
    } else {
        dictionary["suggestedTips"] = NSNull()
    }
    
    return dictionary
  }
  
  private func suggestedTipsDictionary(from tips: SuggestedTipsDto) -> [String: Any] {
    [
        "tipPercent": tips.tipPercent,
        "tipAmount": tips.tipAmount
    ]
  }

  private func parseAuthorizationRequest(from dictionary: NSDictionary) throws -> AuthorizationRequest {
    guard let paymentProcessorId = dictionary["paymentProcessorId"] as? String else {
      throw NSError(domain: moduleErrorDomain, code: 1001, userInfo: [NSLocalizedDescriptionKey: "Missing paymentProcessorId"])
    }
    guard let amount = dictionary["amount"] as? Double else {
      throw NSError(domain: moduleErrorDomain, code: 1001, userInfo: [NSLocalizedDescriptionKey: "Missing amount"])
    }
    guard let currencyId = dictionary["currencyId"] as? Int32 else {
      throw NSError(domain: moduleErrorDomain, code: 1001, userInfo: [NSLocalizedDescriptionKey: "Missing currencyId"])
    }
    guard let cardDataSourceValue = dictionary["cardDataSource"] as? Int,
          let cardDataSource = CardDataSource(rawValue: cardDataSourceValue) else {
      throw NSError(domain: moduleErrorDomain, code: 1001, userInfo: [NSLocalizedDescriptionKey: "Invalid cardDataSource"])
    }

    return try AuthorizationRequest(
        paymentProcessorId: paymentProcessorId,
        amount: amount,
        currencyId: currencyId,
        cardDataSource: cardDataSource,
        paymentMethodId: dictionary["paymentMethodId"] as? String,
        accountNumber: dictionary["accountNumber"] as? String,
        securityCode: dictionary["securityCode"] as? String,
        expirationMonth: (dictionary["expirationMonth"] as? Int).map { Int32($0) },
        expirationYear: (dictionary["expirationYear"] as? Int).map { Int32($0) },
        track1: dictionary["track1"] as? String,
        track2: dictionary["track2"] as? String,
        emvTags: dictionary["emvTags"] as? [String],
        emvPaymentAppVersion: dictionary["emvPaymentAppVersion"] as? String,
        customerId: dictionary["customerId"] as? String,
        tipAmount: dictionary["tipAmount"] as? Double,
        tipRate: dictionary["tipRate"] as? Double,
        percentageOffRate: dictionary["percentageOffRate"] as? Double,
        surchargeRate: dictionary["surchargeRate"] as? Double,
        useCardPrice: dictionary["useCardPrice"] as? Bool,
        billingAddress: parseAddress(from: dictionary["billingAddress"] as? NSDictionary),
        shippingAddress: parseAddress(from: dictionary["shippingAddress"] as? NSDictionary),
        contactInfo: nil, // TODO: Parse contact info if needed
        pin: dictionary["pin"] as? String,
        pinKsn: dictionary["pinKsn"] as? String,
        emvFallbackCondition: nil, // TODO: Parse fallback condition if needed
        emvFallbackLastChipRead: nil, // TODO: Parse fallback chip read if needed
        referenceId: dictionary["referenceId"] as? String,
        customerInitiatedTransaction: dictionary["customerInitiatedTransaction"] as? Bool,
        l2: parseL2Data(from: dictionary["l2"] as? NSDictionary),
        l3: parseL3Data(from: dictionary["l3"] as? NSDictionary)
    )
  }

  private func parseRefundRequest(from dictionary: NSDictionary) throws -> RefundRequest {
    guard let transactionId = dictionary["transactionId"] as? String else {
      throw NSError(domain: moduleErrorDomain, code: 1001, userInfo: [NSLocalizedDescriptionKey: "Missing transactionId"])
    }
    
    let amount = dictionary["amount"] as? Double
    
    // Default to manual if not provided
    let cardDataSourceValue = dictionary["cardDataSource"] as? Int ?? 7
    guard let cardDataSource = CardDataSource(rawValue: cardDataSourceValue) else {
      throw NSError(domain: moduleErrorDomain, code: 1001, userInfo: [NSLocalizedDescriptionKey: "Invalid cardDataSource"])
    }
    
    return RefundRequest(
        transactionId: transactionId,
        amount: amount,
        cardDataSource: cardDataSource,
        track1: dictionary["track1"] as? String,
        track2: dictionary["track2"] as? String,
        emvTags: dictionary["emvTags"] as? [String],
        emvPaymentAppVersion: dictionary["emvPaymentAppVersion"] as? String,
        pin: dictionary["pin"] as? String,
        pinKsn: dictionary["pinKsn"] as? String
    )
  }

  private func parseCalculateAmountRequest(from dictionary: NSDictionary) throws -> CalculateAmountRequest {
    // Minimal fix: accept numeric strings coming from React/JS (e.g. "5.88")
    guard let amount = parseDouble(from: dictionary["amount"]) else {
      throw NSError(domain: moduleErrorDomain, code: 1001, userInfo: [NSLocalizedDescriptionKey: "Missing amount"])
    }

    return CalculateAmountRequest(
        amount: amount,
        percentageOffRate: parseDouble(from: dictionary["percentageOffRate"]),
        surchargeRate: parseDouble(from: dictionary["surchargeRate"]),
        tipAmount: parseDouble(from: dictionary["tipAmount"]),
        tipRate: parseDouble(from: dictionary["tipRate"]),
        currencyId: parseInt(from: dictionary["currencyId"]).map { Int32($0) },
        useCardPrice: dictionary["useCardPrice"] as? Bool
    )
  }

  private func calculateAmountResponseDictionary(from response: CalculateAmountResponse) -> [String: Any] {
    var dictionary: [String: Any] = [:]
    
    dictionary["currencyId"] = response.currencyId.map { Int($0) } ?? NSNull()
    dictionary["currency"] = response.currency ?? NSNull()
    dictionary["zeroCostProcessingOptionId"] = response.zeroCostProcessingOptionId.map { Int($0) } ?? NSNull()
    dictionary["zeroCostProcessingOption"] = response.zeroCostProcessingOption ?? NSNull()
    dictionary["useCardPrice"] = response.useCardPrice ?? NSNull()
    
    if let cash = response.cash {
        dictionary["cash"] = amountDictionary(from: cash)
    }
    
    if let creditCard = response.creditCard {
        dictionary["creditCard"] = amountDictionary(from: creditCard)
    }
    
    if let debitCard = response.debitCard {
        dictionary["debitCard"] = amountDictionary(from: debitCard)
    }
    
    if let ach = response.ach {
        dictionary["ach"] = amountDictionary(from: ach)
    }
    
    return dictionary
  }

  private func parseAddress(from dictionary: NSDictionary?) -> AddressDto? {
    guard let dict = dictionary else { return nil }
    
    return AddressDto(
        line1: dict["line1"] as? String,
        line2: dict["line2"] as? String,
        city: dict["city"] as? String,
        postalCode: dict["postalCode"] as? String,
        stateName: dict["stateName"] as? String,
        stateId: (dict["stateId"] as? Int).map { Int32($0) },
        countryId: (dict["countryId"] as? Int).map { Int32($0) }
    )
  }

  private func parseL2Data(from dictionary: NSDictionary?) -> L2Data? {
    guard let dict = dictionary else { return nil }
    
    // Extract salesTax from dictionary and map it to salesTaxRate
    let salesTaxRate = dict["salesTax"] as? Double
    
    // Only create L2Data if we have valid data
    guard salesTaxRate != nil else {
      return nil
    }
    
    return L2Data(salesTaxRate: salesTaxRate)
  }

  private func parseL3Data(from dictionary: NSDictionary?) -> L3Data? {
    guard let dict = dictionary else { return nil }
    
    let invoiceNumber = dict["invoiceNumber"] as? String
    let purchaseOrder = dict["purchaseOrder"] as? String
    let shippingCharges = dict["shippingCharges"] as? Double
    let dutyCharges = dict["dutyCharges"] as? Double
    
    var products: [TransactionProduct]?
    if let productsArray = dict["products"] as? [[String: Any]] {
      let parsedProducts = productsArray.compactMap { productDict -> TransactionProduct? in
        parseTransactionProduct(from: productDict)
      }
      products = parsedProducts.isEmpty ? nil : parsedProducts
    } else if let productsArray = dict["products"] as? [NSDictionary] {
      // Handle NSDictionary array - convert to [String: Any]
      let parsedProducts = productsArray.compactMap { nsDict -> TransactionProduct? in
        var dict: [String: Any] = [:]
        for (key, value) in nsDict {
          if let keyString = key as? String {
            dict[keyString] = value
          }
        }
        return parseTransactionProduct(from: dict)
      }
      products = parsedProducts.isEmpty ? nil : parsedProducts
    }
    
    // Only create L3Data if we have at least some data
    if invoiceNumber == nil && purchaseOrder == nil && shippingCharges == nil && 
       dutyCharges == nil && products == nil {
      return nil
    }
    
    return L3Data(
      invoiceNumber: invoiceNumber,
      purchaseOrder: purchaseOrder,
      shippingCharges: shippingCharges,
      dutyCharges: dutyCharges,
      products: products
    )
  }

  private func parseTransactionProduct(from productDict: [String: Any]) -> TransactionProduct? {
    // All fields are optional, so we create TransactionProduct even with minimal data
    let name = productDict["name"] as? String
    let code = productDict["code"] as? String
    let unitPrice = productDict["unitPrice"] as? Double
    let measurementUnit = productDict["measurementUnit"] as? String
    let quantity = productDict["quantity"] as? Double
    let taxAmount = productDict["taxAmount"] as? Double
    let discountRate = productDict["discountRate"] as? Double
    let description = productDict["description"] as? String
    let measurementUnitId = (productDict["measurementUnitId"] as? Int).map { Int32($0) }
    
    return TransactionProduct(
      name: name,
      code: code,
      unitPrice: unitPrice,
      measurementUnit: measurementUnit,
      quantity: quantity,
      taxAmount: taxAmount,
      discountRate: discountRate,
      description: description,
      measurementUnitId: measurementUnitId
    )
  }
  
  private func authorizationResponseDictionary(from response: AuthorizationResponse) -> [String: Any] {
    var dictionary: [String: Any] = [:]
    
    dictionary["transactionId"] = response.transactionId ?? NSNull()
    if let date = response.transactionDateTime {
        dictionary["transactionDateTime"] = isoFormatter.string(from: date)
    } else {
        dictionary["transactionDateTime"] = NSNull()
    }
    dictionary["typeId"] = response.typeId.map { Int($0) } ?? NSNull()
    dictionary["type"] = response.type ?? NSNull()
    dictionary["statusId"] = response.statusId.map { Int($0) } ?? NSNull()
    dictionary["status"] = response.status ?? NSNull()
    dictionary["processedAmount"] = response.processedAmount ?? NSNull()
    dictionary["authCode"] = response.authCode ?? NSNull()
    
    if let details = response.details {
        dictionary["details"] = transactionResponseDetailsDictionary(from: details)
    } else {
        dictionary["details"] = NSNull()
    }
    
    return dictionary
  }

  private func transactionResponseDetailsDictionary(from details: TransactionResponseDetailsDto) -> [String: Any] {
    [
      //test comment
        "hostResponseCode": details.hostResponseCode ?? NSNull(),
        "hostResponseMessage": details.hostResponseMessage ?? NSNull(),
        "hostResponseDefinition": details.hostResponseDefinition ?? NSNull(),
        "code": details.code ?? NSNull(),
        "message": details.message ?? NSNull(),
        "processorResponseCode": details.processorResponseCode ?? NSNull(),
        "authCode": details.authCode ?? NSNull(),
        "maskedPan": details.maskedPan ?? NSNull()
    ]
  }

  private func mapTTPError(_ error: TTPError) -> (code: String, message: String, underlyingError: NSError?) {
    let defaultMessage = error.localizedDescription ?? "Unknown TTP error"

    switch error {
    case .sdkNotInitialized:
      return ("ARISE_SDK_NOT_INITIALIZED", "Tap to Pay SDK is not initialized", createNSError(code: 4001, message: defaultMessage))
    case .notActive(let message):
      return ("ARISE_TTP_NOT_ACTIVE", "Tap to Pay is not active: \(message)", createNSError(code: 4002, message: defaultMessage))
    case .activationFailed(let message, _):
      return ("ARISE_TTP_ACTIVATION_FAILED", "Tap to Pay activation failed: \(message)", createNSError(code: 4003, message: defaultMessage))
    case .failedToAbortTransaction(let message, _):
      return ("ARISE_CANNOT_ABORT_TRANSACTION", "Cannot abort transaction: \(message)", createNSError(code: 4004, message: defaultMessage))
    case .transactionFailed(let message, _):
      return ("ARISE_TRANSACTION_FAILED", "Transaction failed: \(message)", createNSError(code: 4005, message: defaultMessage))
    case .configurationFailed(let message, _):
      return ("ARISE_CONFIGURATION_FAILED", "Configuration failed: \(message)", createNSError(code: 4006, message: defaultMessage))
    case .unknown(let message, _):
      return ("ARISE_TTP_ERROR", "Unknown error: \(message)", createNSError(code: 4000, message: defaultMessage))
    }
  }

  private func ttpEventDictionary(from event: TTPEvent) -> [String: Any] {
    switch event {
    case .readerEvent(let readerEvent):
      return [
        "type": "readerEvent",
        "event": readerEventDictionary(from: readerEvent)
      ]
    case .customEvent(let customEvent):
      return [
        "type": "customEvent",
        "event": customEventDictionary(from: customEvent)
      ]
    }
  }

  private func readerEventDictionary(from event: TTPReaderEvent) -> [String: Any] {
    switch event {
    case .updateProgress(let progress):
      return ["type": "updateProgress", "progress": progress]
    case .notReady:
      return ["type": "notReady"]
    case .readyForTap:
      return ["type": "readyForTap"]
    case .cardDetected:
      return ["type": "cardDetected"]
    case .removeCard:
      return ["type": "removeCard"]
    case .readCompleted:
      return ["type": "readCompleted"]
    case .readRetry:
      return ["type": "readRetry"]
    case .readCancelled:
      return ["type": "readCancelled"]
    case .pinEntryRequested:
      return ["type": "pinEntryRequested"]
    case .pinEntryCompleted:
      return ["type": "pinEntryCompleted"]
    case .userInterfaceDismissed:
      return ["type": "userInterfaceDismissed"]
    case .readNotCompleted:
      return ["type": "readNotCompleted"]
    }
  }

  private func customEventDictionary(from event: TTPCustomEvent) -> [String: Any] {
    switch event {
    case .preparing:
      return ["type": "preparing"]
    case .ready:
      return ["type": "ready"]
    case .readerNotReady(let reason):
      return ["type": "readerNotReady", "reason": reason]
    case .cardDetected:
      return ["type": "cardDetected"]
    case .cardReadSuccess:
      return ["type": "cardReadSuccess"]
    case .cardReadFailure:
      return ["type": "cardReadFailure"]
    case .authorizing:
      return ["type": "authorizing"]
    case .approved:
      return ["type": "approved"]
    case .declined:
      return ["type": "declined"]
    case .errorOccurred:
      return ["type": "errorOccurred"]
    case .inProgress:
      return ["type": "inProgress"]
    case .updateReaderProgress(let progress):
      return ["type": "updateReaderProgress", "progress": progress]
    case .unknownEvent(let description):
      return ["type": "unknownEvent", "description": description]
    }
  }

  // MARK: - TTP Transaction Helpers

  private func parseTTPTransactionRequest(from dictionary: NSDictionary) throws -> TTPTransactionRequest {
    // The SDK expects Decimal. We do not "fix" values here:
    // - require amount as String (avoid JS float artifacts from NSNumber)
    // - validate <= 2 decimals (allow "8.7"; reject > 2 decimals)
    // - convert to Decimal (required by TTPTransactionRequest)
    let rawAmountValue = dictionary["amount"]
    guard let amountStringRaw = rawAmountValue as? String else {
      throw NSError(
        domain: moduleErrorDomain,
        code: 1001,
        userInfo: [NSLocalizedDescriptionKey: "Invalid amount type: expected String with <=2 decimals, got \(String(describing: rawAmountValue))."]
      )
    }

    let amountString = amountStringRaw.trimmingCharacters(in: .whitespacesAndNewlines)

    // Validate <= 2 decimals
    if let dotIndex = amountString.firstIndex(of: ".") {
      let decimals = amountString[amountString.index(after: dotIndex)...]
      if decimals.count > 2 {
        throw NSError(
          domain: moduleErrorDomain,
          code: 1001,
          userInfo: [NSLocalizedDescriptionKey: "Invalid amount: \(amountString). Expected <=2 decimals (e.g. \"8.7\" or \"8.70\")."]
        )
      }
    }

    guard let amount = Decimal(string: amountString) else {
      throw NSError(
        domain: moduleErrorDomain,
        code: 1001,
        userInfo: [NSLocalizedDescriptionKey: "Invalid amount: \(amountString). Expected a numeric string with <=2 decimals."]
      )
    }
    let currencyCode = dictionary["currencyCode"] as? String ?? "USD"
    let tip = dictionary["tip"] as? String
    let discount = dictionary["discount"] as? String
    let salesTaxAmount = dictionary["salesTaxAmount"] as? String
    let federalTaxAmount = dictionary["federalTaxAmount"] as? String
    let subTotal = dictionary["subTotal"] as? String ?? "0.00"
    let orderId = dictionary["orderId"] as? String
    let surchargeRate = dictionary["customData"] as? [String: String]
    let surchargeRateString = surchargeRate?["surchargeRate"]
    
    return TTPTransactionRequest(
      amount: amount,
      currencyCode: currencyCode,
      tip: tip,
      discount: discount,
      salesTaxAmount: salesTaxAmount,
      federalTaxAmount: federalTaxAmount,
      subTotal: subTotal,
      orderId: orderId,
      surchargeRate: surchargeRateString
    )
  }

  private func ttpTransactionResultDictionary(from result: TTPTransactionResult) -> [String: Any] {
    var dictionary: [String: Any] = [
      "status": result.status.rawValue
    ]
    
    dictionary["transactionId"] = result.transactionId ?? NSNull()
    dictionary["transactionOutcome"] = result.transactionOutcome ?? NSNull()
    dictionary["orderId"] = result.orderId ?? NSNull()
    dictionary["authorizedAmount"] = result.authorizedAmount ?? NSNull()
    dictionary["authorizationCode"] = result.authorizationCode ?? NSNull()
    dictionary["authorisationResponseCode"] = result.authorisationResponseCode ?? NSNull()
    dictionary["authorizedDate"] = result.authorizedDate ?? NSNull()
    dictionary["authorizedDateFormat"] = result.authorizedDateFormat ?? NSNull()
    dictionary["cardBrandName"] = result.cardBrandName ?? NSNull()
    dictionary["maskedCardNumber"] = result.maskedCardNumber ?? NSNull()
    dictionary["externalReferenceID"] = result.externalReferenceID ?? NSNull()
    dictionary["applicationIdentifier"] = result.applicationIdentifier ?? NSNull()
    dictionary["applicationPreferredName"] = result.applicationPreferredName ?? NSNull()
    dictionary["applicationCryptogram"] = result.applicationCryptogram ?? NSNull()
    dictionary["applicationTransactionCounter"] = result.applicationTransactionCounter ?? NSNull()
    dictionary["terminalVerificationResults"] = result.terminalVerificationResults ?? NSNull()
    dictionary["issuerApplicationData"] = result.issuerApplicationData ?? NSNull()
    dictionary["applicationPANSequenceNumber"] = result.applicationPANSequenceNumber ?? NSNull()
    dictionary["partnerDataMap"] = result.partnerDataMap ?? NSNull()
    dictionary["cvmAction"] = result.cvmAction ?? NSNull()
    
    if let cvmTags = result.cvmTags {
      dictionary["cvmTags"] = cvmTags.map { cvmDataDictionary(from: $0) }
    } else {
      dictionary["cvmTags"] = NSNull()
    }
    
    return dictionary
  }

  private func cvmDataDictionary(from cvmData: TTPCVMData) -> [String: Any] {
    var dictionary: [String: Any] = [:]
    
    dictionary["tag"] = cvmData.tag ?? NSNull()
    dictionary["value"] = cvmData.value ?? NSNull()
    
    return dictionary
  }
}
