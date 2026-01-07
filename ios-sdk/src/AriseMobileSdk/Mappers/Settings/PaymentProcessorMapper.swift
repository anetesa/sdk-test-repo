import Foundation

internal struct PaymentProcessorMapper {
    static func toModel(_ dto: Components.Schemas.PaymentProcessorDto) -> PaymentProcessor {
        return PaymentProcessor(
            id: dto.id,
            name: dto.name,
            isDefault: dto.isDefault,
            typeId: dto.typeId,
            type: dto._type,
            settlementBatchTimeSlots: dto.settlementBatchTimeSlots?.map { slot in
                SettlementBatchTimeSlotMapper.toModel(slot)
            }
        )
    }
}

