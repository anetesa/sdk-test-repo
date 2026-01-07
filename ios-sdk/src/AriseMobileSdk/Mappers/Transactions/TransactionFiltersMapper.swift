struct TransactionFiltersMapper {
    static func toGeneratedInput(_ filters: TransactionFilters?) -> Operations.GetPayApiV1Transactions.Input {
        
        guard let filters = filters else {
            return Operations.GetPayApiV1Transactions.Input()
        }
        
        var query = Operations.GetPayApiV1Transactions.Input.Query()
        
        // Map pagination parameters (convert Int to Int32)
        if let page = filters.page {
            query.page = Int32(page)
        }
        if let pageSize = filters.pageSize {
            query.pageSize = Int32(pageSize)
        }
        
        // Map sorting parameters
        query.asc = filters.asc
        query.orderBy = filters.orderBy
        
        // Map filter parameters
        if let createMethodId = filters.createMethodId {
            query.createMethodId = Int32(createMethodId)
        }
        query.createdById = filters.createdById
        query.batchId = filters.batchId
        query.noBatch = filters.noBatch
        
        // Create input with query parameters
        let generatedInput = Operations.GetPayApiV1Transactions.Input(query: query)
        
        return generatedInput
    }
    
}
