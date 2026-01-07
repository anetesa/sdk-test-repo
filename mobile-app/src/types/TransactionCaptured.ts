export interface CaptureTransactionPayload {
  amount: number;
  transactionId: string;
}

export interface TransactionCaptureError {
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
