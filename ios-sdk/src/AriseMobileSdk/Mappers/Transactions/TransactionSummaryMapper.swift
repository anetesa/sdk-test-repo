import Foundation

struct TransactionSummaryMapper{
    /// Map a single transaction item from OpenAPI format to SDK format
    /// - Parameter item: Transaction item from generated OpenAPI client
    /// - Returns: TransactionSummary in SDK format, or nil if required fields are missing
    public static func toModel(
        _ item: Components.Schemas.PaymentGateway_Contracts_PublicApi_Isv_Transactions_GetPage_GetIsvTransactionsResponse
    ) -> TransactionSummary? {
        // Validate required fields - id and merchantId are required
        guard let id = item.id, !id.isEmpty else {
            return nil
        }
        
        guard let merchantId = item.merchantId, !merchantId.isEmpty else {
            return nil
        }
        
        // Map required non-optional fields with defaults if missing
        let paymentProcessorId = item.paymentProcessorId ?? ""
        
        // Map source - create default if missing (required field)
        guard let source = TransactionDetailMapper.mapSourceResponseDto(item.source) else {
            return nil
        }
        
        // Map amount - create default if missing (required field)
        let amount = AmountDtoMapper.toModel(item.amount)
        
        // Map cardTokenType enum
        let cardTokenType = TransactionDetailMapper.mapCardTokenType(item.cardTokenType)
        
        // Map availableOperations
        let availableOperations = item.availableOperations?.map { AvailableOperationMapper.toModel($0) }
        
        // Map all fields from OpenAPI format to SDK format
        return TransactionSummary(
            id: id,
            paymentProcessorId: paymentProcessorId,
            date: item.date,
            baseAmount: item.baseAmount ?? 0.0,
            totalAmount: item.totalAmount ?? 0.0,
            surchargeAmount: item.surchargeAmount,
            surchargePercentage: item.surchargePercentage,
            currencyCode: item.currencyCode,
            currencyId: item.currencyId,
            merchant: item.merchant,
            merchantId: merchantId,
            operationMode: item.operationMode,
            paymentMethodType: item.paymentMethodType,
            paymentMethodTypeId: item.paymentMethodTypeId.map { Int($0) },
            paymentMethodName: item.paymentMethodName,
            customerName: item.customerName,
            customerCompany: item.customerCompany,
            customerPan: item.customerPan,
            cardTokenType: cardTokenType,
            customerEmail: item.customerEmail,
            customerPhone: item.customerPhone,
            status: item.status ?? "",
            statusId: Int(item.statusId ?? 0),
            typeId: Int(item.typeId ?? 0),
            type: item._type,  // Note: _type in generated code (type is reserved in Swift)
            batchId: item.batchId,
            source: source,
            availableOperations: availableOperations,
            amount: amount
        )
    }
}
