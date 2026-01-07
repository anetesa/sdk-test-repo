import Foundation

/// Payment processor configuration.
public struct PaymentProcessor {
    /// Unique processor identifier (UUID).
    public let id: String?
    
    /// Processor name (e.g., "TSYS").
    public let name: String?
    
    /// Whether this is the default processor.
    public let isDefault: Bool?
    
    /// Processor type identifier.
    public let typeId: Int32?
    
    /// Processor type name.
    public let type: String?
    
    /// Settlement batch time slots with timezone information.
    public let settlementBatchTimeSlots: [SettlementBatchTimeSlot]?
    
    public init(
        id: String?,
        name: String?,
        isDefault: Bool?,
        typeId: Int32?,
        type: String?,
        settlementBatchTimeSlots: [SettlementBatchTimeSlot]?
    ) {
        self.id = id
        self.name = name
        self.isDefault = isDefault
        self.typeId = typeId
        self.type = type
        self.settlementBatchTimeSlots = settlementBatchTimeSlots
    }
}

