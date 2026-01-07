import Foundation

/// Settlement batch time slot with timezone.
public struct SettlementBatchTimeSlot {
    /// Hours component of the time.
    public let hours: Int32?
    
    /// Minutes component of the time.
    public let minutes: Int32?
    
    /// IANA timezone name (e.g., "America/New_York").
    public let timezoneName: String?
    
    public init(hours: Int32?, minutes: Int32?, timezoneName: String?) {
        self.hours = hours
        self.minutes = minutes
        self.timezoneName = timezoneName
    }
}

