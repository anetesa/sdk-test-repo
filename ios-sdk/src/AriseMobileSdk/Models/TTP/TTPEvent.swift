import Foundation

/// Events from Tap to Pay operations.
///
/// This enum mirrors the structure of `CloudCommerce.EventStream` and represents
/// all possible events that can occur during Tap to Pay transactions.
public enum TTPEvent {
    /// Low-level events from the card reader.
    ///
    /// These events come directly from the ProximityReader framework and represent
    /// physical card reader state changes and progress updates.
    case readerEvent(TTPReaderEvent)
    
    /// High-level business logic events from the CloudCommerce SDK.
    ///
    /// These events represent transaction lifecycle and business logic states.
    case customEvent(TTPCustomEvent)
}

/// Reader events from the ProximityReader framework.
///
/// These events correspond to `ProximityReader.PaymentCardReader.Event` and represent
/// low-level card reader state changes and progress updates.
public enum TTPReaderEvent {
    /// Progress update during firmware update or initialization.
    ///
    /// - Parameter progress: Progress percentage (0-100)
    case updateProgress(Int)
    
    /// Reader is not ready.
    case notReady
    
    /// Reader is ready for card tap.
    case readyForTap
    
    /// Card has been detected.
    case cardDetected
    
    /// Card should be removed.
    case removeCard
    
    /// Card read completed successfully.
    case readCompleted
    
    /// Card read failed, retry needed.
    case readRetry
    
    /// Card read was cancelled.
    case readCancelled
    
    /// PIN entry requested on reader.
    case pinEntryRequested
    
    /// PIN entry completed.
    case pinEntryCompleted
    
    /// User interface was dismissed.
    case userInterfaceDismissed
    
    /// Reader interface not completed.
    case readNotCompleted
}

/// Custom events from the CloudCommerce SDK.
///
/// These events correspond to `CloudCommerce.CustomEvent` and represent
/// high-level transaction lifecycle and business logic states.
public enum TTPCustomEvent {
    /// Terminal is preparing.
    case preparing
    
    /// Terminal is ready.
    case ready
    
    /// Reader is not ready.
    ///
    /// - Parameter reason: Reason why reader is not ready
    case readerNotReady(String)
    
    /// Card has been detected.
    case cardDetected
    
    /// Card read succeeded.
    case cardReadSuccess
    
    /// Card read failed.
    case cardReadFailure
    
    /// Payment is being authorized.
    case authorizing
    
    /// Transaction was approved.
    case approved
    
    /// Transaction was declined.
    case declined
    
    /// An error occurred during the transaction.
    case errorOccurred
    
    /// Transaction is in progress.
    case inProgress
    
    /// Reader progress update.
    ///
    /// - Parameter progress: Progress percentage (0-100)
    case updateReaderProgress(Int)
    
    /// Unknown event.
    ///
    /// - Parameter description: Description of the unknown event
    case unknownEvent(String)
}
