import Foundation

struct TransactionsResponseMapper {
    
    /// Map OpenAPI generated output to SDK's TransactionsResult model
    /// - Parameters:
    ///   - generated: Generated API response from OpenAPI client
    ///   - page: Current page number (0-based) - reserved for future use
    ///   - pageSize: Page size - reserved for future use
    /// - Returns: TransactionsResult in SDK format with items and total count
    /// - Throws: Error if response is not successful
    static func toModel(
        _ generated: Operations.GetPayApiV1Transactions.Output,
        page: Int = 0,
        pageSize: Int = 20
    ) throws -> TransactionsResponse {
        // Extract the successful response
        let okResponse = try generated.ok
        let pageResponse = try okResponse.body.json
        
        // Map transaction items
        let transactionItems = (pageResponse.items ?? []).compactMap { item -> TransactionSummary? in
            TransactionSummaryMapper.toModel(item)
        }
        
        // Get total count from response
        let total = Int(pageResponse.total ?? 0)
        
        return TransactionsResponse(
            items: transactionItems,
            total: total
        )
    }

}
