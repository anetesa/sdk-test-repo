import Foundation

internal struct SettlementBatchTimeSlotMapper {
    static func toModel(_ dto: Components.Schemas.SettlementBatchTimeSlot) -> SettlementBatchTimeSlot {
        return SettlementBatchTimeSlot(
            hours: dto.hours,
            minutes: dto.minutes,
            timezoneName: dto.timezoneName
        )
    }
}

