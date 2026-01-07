export interface RefundTransactionPayload {
  amount: number;
  transactionId: string;
  paymentProcessorId: string;
}

export interface TransactionRefundError {
  response: {
    data: {
      Errors: Record<string, string[]>;
      Details: string;
      StatusCode: number;
      Source: string;
      ExceptionType: string;
      CorrelationId: string;
      ErrorCode: string;
    };
  };
}
