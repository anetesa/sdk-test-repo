import Foundation

class TransactionsService: BaseApiClient, TransactionsServiceProtocol, @unchecked Sendable {
    
    
    init(tokenService: TokenService, environmentSettings: EnvironmentSettings) {
        super.init(
            tokenService: tokenService,
            environmentSettings: environmentSettings,
            queueLabel: "com.arise.mobile.sdk.transactions.api.config"
        )
    }
    
    func getTransactions(filters: TransactionFilters?) async throws -> TransactionsResponse? {
        
        let client = try getApiClient()
        let generatedInput = TransactionFiltersMapper.toGeneratedInput(filters)
        
        do{
            let generatedResult = try await client.getPayApiV1Transactions(generatedInput)
            let result = try TransactionsResponseMapper.toModel(generatedResult)
            
            return result
        } catch {
            try DecodingErrorHandler().handleError(error)
            throw error
        }
    }
    
    func getTransactionDetails(id: String) async throws -> TransactionDetails? {
       
        let client = try getApiClient()
        
        do {
            let generatedResult = try await client.getPayApiV1TransactionsId(.init(path: .init(id: id)))
            let result = try TransactionDetailMapper.toModel(generatedResult)
            
            return result
        } catch {
            try DecodingErrorHandler().handleError(error)
            throw error
        }
    }
        
    func submitAuthTransaction(request: AuthorizationRequest) async throws -> AuthorizationResponse {
        
        let client = try getApiClient()
        let generatedInput = AuthorizationTransactionMapper.toGeneratedInput(request)
        
        do {
            let generatedResult = try await client.postPayApiV1TransactionsAuth(.init(body: .json(generatedInput)))
            let result = try AuthorizationTransactionMapper.toModel(generatedResult)
            
            return result
        } catch {
            try DecodingErrorHandler().handleError(error)
            throw error
        }
    }
    
    func submitSaleTransaction(request: AuthorizationRequest) async throws -> AuthorizationResponse {
        let client = try getApiClient()
        let generatedInput = SaleTransactionMapper.toGeneratedInput(request)
        
        do {
            let generatedResult = try await client.postPayApiV1TransactionsSale(.init(body: .json(generatedInput)))
            let result = try SaleTransactionMapper.toModel(generatedResult)
            
            return result
        } catch {
            try DecodingErrorHandler().handleError(error)
            throw error
        }
    }

    func calculateAmount(request: CalculateAmountRequest) async throws -> CalculateAmountResponse {
        let client = try getApiClient()
        let generatedInput = CalculateAmountMapper.toGeneratedInput(request)

        do {
            let generatedResult = try await client.getPayApiV1TransactionsCalculateAmount(generatedInput)
            return try CalculateAmountMapper.toModel(generatedResult)
        } catch {
            try DecodingErrorHandler().handleError(error)
            throw error
        }
    }
         
    func voidTransaction(transactionId: String) async throws -> TransactionResponse {
       
        let client = try getApiClient()
        let generatedInput = VoidTransactionMapper.toGeneratedInput(transactionId)
        do {
            let generatedResult = try await client.postPayApiV1TransactionsVoid(.init(body: .json(generatedInput)))
            let result = try VoidTransactionMapper.toModel(generatedResult)
            
            return result
        } catch {
            try DecodingErrorHandler().handleError(error)
            throw error
        }
    }

    func captureTransaction(transactionId: String, amount: Double) async throws -> TransactionResponse {
        let client = try getApiClient()
        let generatedInput = CaptureTransactionMapper.toGeneratedInput(
            transactionId: transactionId,
            amount: amount
        )
        do {
            let generatedResult = try await client.postPayApiV1TransactionsCapture(.init(body: .json(generatedInput)))
            let result = try CaptureTransactionMapper.toModel(generatedResult)
            
            return result
        } catch {
            try DecodingErrorHandler().handleError(error)
            throw error
        }
    }

    func refundTransaction(request: RefundRequest) async throws -> TransactionResponse {
        let client = try getApiClient()

        do {
            let generatedInput = RefundTransactionMapper.toGeneratedInput(request)
            let generatedResult = try await client.postPayApiV1TransactionsReturn(.init(body: .json(generatedInput)))
            let result = try RefundTransactionMapper.toModel(generatedResult)
            
            return result
        } catch {
            try DecodingErrorHandler().handleError(error)
            throw error
        }
    }
}
