import ProximityReader
import Foundation

@objc(TapToPhoneModule)
class TapToPhoneModule: NSObject {

    var cardReader: PaymentCardReader?
    var session: PaymentCardReaderSession?

    // Check if Tap to Pay is supported on this device
    @objc
    func isTapToPaySupported(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if PaymentCardReader.isSupported {
            resolve(true)
        } else {
            resolve(false)
        }
    }

    // Initialize the reader and session
    @objc
    func initializeReader(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        guard PaymentCardReader.isSupported else {
            reject("ERROR", "Device does not support Tap to Pay.", nil)
            return
        }

        // Create prepare options for PaymentCardReader
        let options = PaymentCardReader.PrepareOptions()

      self.token = ''

        do {
            // Prepare the session using the options
          self.session = try self.cardReader?.prepare(using: self.token)
            resolve("Reader initialized")
        } catch let error {
            reject("ERROR", "Failed to initialize reader: \(error.localizedDescription)", error)
        }
    }

    // Start a payment session
    @objc
    func startPaymentSession(_ amount: Double, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        guard let session = self.session else {
            reject("ERROR", "No session available", nil)
            return
        }

        let transactionRequest = PaymentCardTransactionRequest(amount: amount)
        session.readCard { result in
            switch result {
            case .success(let paymentCardReadResult):
                // Handle the successful card read and send data to backend
                resolve(paymentCardReadResult.paymentCardData)
            case .failure(let error):
                reject("ERROR", "Payment failed: \(error.localizedDescription)", error)
            }
        }
    }

    // Handle errors and close session
    @objc
    func endSession(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        self.session = nil
        self.cardReader = nil
        resolve("Session ended")
    }
}
