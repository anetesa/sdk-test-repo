import Foundation

/// Result of getTransactions request containing transactions list and pagination metadata
/// 
/// Represents a paginated list of transactions from the ARISE API.
/// 
public struct TransactionsResponse {
    /// List of transaction summaries
    /// 
    /// Array of transaction summary objects for the current page
    /// 
    public let items: [TransactionSummary]
    
    /// Total number of transactions across all pages
    /// 
    /// Total count of transactions matching the query criteria
    /// 
    public let total: Int
    
    public init(items: [TransactionSummary], total: Int) {
        self.items = items
        self.total = total
    }
    
}






