import Foundation
import CloudCommerce
#if canImport(ProximityReader)
import ProximityReader
#endif

/// Mapper for converting CloudCommerce SDK events to TTP events.
///
/// This mapper converts `CloudCommerce.EventStream` events to `TTPEvent` enum,
/// preserving the same structure for easier handling in the SDK.
public struct TTPEventMapper {
    
    /// Converts a CloudCommerce SDK event to a TTPEvent.
    ///
    /// - Parameter event: The CloudCommerce.EventStream event to convert
    /// - Returns: A TTPEvent representing the SDK event
    public static func toTTPEvent(_ event: CloudCommerce.EventStream) -> TTPEvent {
        switch event {
        case .readerEvent(let readerEvent):
            return .readerEvent(mapReaderEvent(readerEvent))
            
        case .customEvent(let customEvent):
            return .customEvent(mapCustomEvent(customEvent))
        @unknown default:
            // Handle unknown EventStream cases
            return .customEvent(.unknownEvent("Unknown event stream: \(event)"))
        }
    }
    
    /// Maps a ProximityReader.PaymentCardReader.Event to TTPReaderEvent.
    ///
    /// - Parameter readerEvent: The reader event from ProximityReader framework
    /// - Returns: A TTPReaderEvent representing the reader event
    private static func mapReaderEvent(_ readerEvent: ProximityReader.PaymentCardReader.Event) -> TTPReaderEvent {
        switch readerEvent {
        case .updateProgress(let progress):
            return .updateProgress(progress)
        case .notReady:
            return .notReady
        case .readyForTap:
            return .readyForTap
        case .cardDetected:
            return .cardDetected
        case .removeCard:
            return .removeCard
        case .readCompleted:
            return .readCompleted
        case .readRetry:
            return .readRetry
        case .readCancelled:
            return .readCancelled
        case .pinEntryRequested:
            return .pinEntryRequested
        case .pinEntryCompleted:
            return .pinEntryCompleted
        case .userInterfaceDismissed:
            return .userInterfaceDismissed
        case .readNotCompleted:
            return .readNotCompleted
        @unknown default:
            // For unknown reader events, use readNotCompleted as fallback
            return .readNotCompleted
        }
    }
    
    /// Maps a custom event from CloudCommerce SDK to TTPCustomEvent.
    ///
    /// - Parameter customEvent: The custom event from CloudCommerce SDK
    /// - Returns: A TTPCustomEvent representing the custom event
    private static func mapCustomEvent(_ customEvent: Any) -> TTPCustomEvent {
        // Use Mirror to inspect the custom event and match cases
        let mirror = Mirror(reflecting: customEvent)
        let description = String(describing: customEvent)
        
        // Match by case name from string description
        if description.contains("preparing") {
            return .preparing
        } else if description.contains("ready") && !description.contains("notReady") && !description.contains("readerNotReady") {
            return .ready
        } else if description.contains("readerNotReady") {
            // Try to extract reason from associated value
            if let reason = extractReason(from: mirror) {
                return .readerNotReady(reason)
            }
            return .readerNotReady("Reader not ready")
        } else if description.contains("cardDetected") {
            return .cardDetected
        } else if description.contains("cardReadSuccess") {
            return .cardReadSuccess
        } else if description.contains("cardReadFailure") {
            return .cardReadFailure
        } else if description.contains("authorizing") {
            return .authorizing
        } else if description.contains("approved") {
            return .approved
        } else if description.contains("declined") {
            return .declined
        } else if description.contains("errorOccurred") {
            return .errorOccurred
        } else if description.contains("inProgress") {
            return .inProgress
        } else if description.contains("updateReaderProgress") {
            // Try to extract progress value
            if let progress = extractProgress(from: mirror) {
                return .updateReaderProgress(progress)
            }
            return .updateReaderProgress(0)
        } else if description.contains("unknownEvent") {
            if let desc = extractDescription(from: mirror) {
                return .unknownEvent(desc)
            }
            return .unknownEvent(description)
        }
        
        return .unknownEvent("Unknown custom event: \(description)")
    }
    
    /// Extracts reason string from mirror reflection
    private static func extractReason(from mirror: Mirror) -> String? {
        for child in mirror.children {
            if let value = child.value as? String {
                return value
            }
        }
        return nil
    }
    
    /// Extracts progress value from mirror reflection
    private static func extractProgress(from mirror: Mirror) -> Int? {
        for child in mirror.children {
            if let progress = child.value as? Int {
                return progress
            }
        }
        return nil
    }
    
    /// Extracts description string from mirror reflection
    private static func extractDescription(from mirror: Mirror) -> String? {
        for child in mirror.children {
            if let desc = child.value as? String {
                return desc
            }
        }
        return nil
    }
}

