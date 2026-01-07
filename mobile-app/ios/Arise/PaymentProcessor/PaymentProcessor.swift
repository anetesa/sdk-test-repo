import Foundation
import React
import PaymentCardReader

@objc(PaymentProcessorModule)
class PaymentProcessorModule: NSObject, RCTBridgeModule {

    var session: PaymentCardReaderSession?
    var reader: PaymentCardReader?

       static func moduleName() -> String! {
        return "PaymentProcessorModule"
    }
    
    static func requiresMainQueueSetup() -> Bool {
        return true
    }

    @objc(configureDevice:resolver:rejecter:)
    func configureDevice(tokenData: String, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
        guard let reader = self.reader else {
            rejecter("NO_READER", "Reader not initialized", nil)
            return
        }
        guard let token = PaymentCardReader.Token(rawValue: tokenData) else {
            rejecter("INVALID_TOKEN", "Invalid token data", nil)
            return
        }

        let events = reader.events

        Task { @MainActor in
            for await event in events {
                if case .updateProgress(let progress) = event {
                    // Optionally send progress back to React Native using RCTEventEmitter
                }
            }
        }

        Task {
            do {
                self.session = try await reader.prepare(using: token)
                resolver("Device configured successfully")
            } catch {
                rejecter("PREPARE_FAILED", "Failed to prepare the device", error)
            }
        }
    }
}