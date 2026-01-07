export interface TransactionSalePayload {
  merchantId: string;
  paymentProcessorId: string;
  amount: number;
  /*
    contactInfo: {
      smsNotification: boolean;
    };*/
  billingAddress: {
    countryId: number;
    postalCode: string;
  };
  shippingAddress: {
    countryId: number;
    postalCode: string;
  };

  l2: {
    salesTax: number;
  };
  l3: {
    shippingCharges: number;
    dutyCharges: number;
    products: {
      name: string;
      code: string;
      measurementUnit: string;
      quantity: number;
      unitPrice: number;
      discountRate: number;
    }[];
  };

  currencyId: number;
  accountNumber: string;
  expirationMonth: number;
  expirationYear: number;
  securityCode: string;
  surchargeRate?: number | null;
  useCardPrice?: boolean | null;
  cardDataSource?: number; // Optional because it was missing, but required by SDK
  referenceId?: string; // Optional but recommended/required for some flows
}

export interface TransactionSaleResponse {
  processedAmount: number;
  avsResponse: AVSResponse | null;
  creditDebitType: number;
  transactionId: string;
  transactionDateTime: string;
  typeId: number;
  type: string;
  statusId: number;
  status: string;
  transactionStatusId: number;
  details: {
    hostResponseCode: string;
    hostResponseMessage: string;
    hostResponseDefinition: string;
    code: string;
    message: string;
    processorResponseCode: string;
    authCode: string;
    maskedPan: string;
  };
}

// Transaction Details Response Types
export interface TransactionAmount {
  baseAmount: number;
  percentageOffAmount: number;
  percentageOffRate: number;
  cashDiscountAmount: number;
  cashDiscountRate: number;
  surchargeAmount: number;
  surchargeRate: number;
  tipAmount: number;
  tipRate: number;
  taxAmount: number;
  taxRate: number;
  totalAmount: number;
}

export interface SuggestedTip {
  tipPercent: number;
  tipAmount: number;
}

export interface AvailableOperation {
  typeId: number;
  type: string;
  availableAmount: number;
  suggestedTips: SuggestedTip[];
}

export interface TransactionHistory {
  id: string;
  transactionDateTime: string;
  transactionAmount: number;
  transactionTypeId: number;
  transactionType: string;
  transactionStatusId: number;
  transactionStatus: string;
}

export interface AVSResponse {
  actionId: number;
  action: string;
  responseCode: string;
  groupId: number;
  group: string;
  resultId: number;
  result: string;
  codeDescription: string;
}

export interface TransactionSource {
  typeId: number;
  type: string;
  id: string;
  name: string;
  version?: string;
}

export interface CardProcessingDetails {
  authCode: string;
  mid: string;
  tid: string;
  cardCreditDebitTypeId: number;
  cardCreditDebitType: string;
  processCreditDebitTypeId: number;
  processCreditDebitType: string;
  rrn: string;
  cardTypeId: number;
  cardType: string;
}

export interface ACHProcessingDetails {
  customerAccountNumber: string;
  customerRoutingNumber: string;
  accountHolderType: string;
  accountHolderTypeId: number;
  accountType: string;
  accountTypeId: number;
  taxId: string;
}

export interface EMVTag {
  key: string;
  value: string;
}

export interface EMVTags {
  ac: string;
  tvr: string;
  tsi: string;
  aid: string;
  applicationLabel: string;
  rawTags: EMVTag[];
}

export interface TransactionReceiptAmount {
  baseAmount: number;
  percentageOffAmount: number;
  percentageOffRate: number;
  cashDiscountAmount: number;
  cashDiscountRate: number;
  surchargeAmount: number;
  surchargeRate: number;
  tipAmount: number;
  tipRate: number;
  totalAmount: number;
}

export interface TransactionReceipt {
  transactionId: string;
  transactionDateTime: string;
  amount: TransactionReceiptAmount;
  currencyId: number;
  currency: string;
  processorId: string;
  processor: string;
  operationTypeId: number;
  operationType: string;
  paymentMethodTypeId: number;
  paymentMethodType: string;
  transactionTypeId: number;
  transactionType: string;
  customerId: string;
  customerPan: string;
  cardTokenType: number;
  statusId: number;
  status: string;
  merchantName: string;
  merchantAddress: string;
  merchantPhoneNumber: string;
  merchantEmailAddress: string;
  merchantWebsite: string;
  authCode: string;
  source: TransactionSource;
  cardholderAuthenticationMethodId: number;
  cardholderAuthenticationMethod: string;
  cvmResultMsg: string;
  cardDataSourceId: number;
  cardDataSource: string;
  responseCode: string;
  responseDescription: string;
  cardProcessingDetails: CardProcessingDetails;
  achProcessingDetails: ACHProcessingDetails;
  availableOperations: AvailableOperation[];
  avsResponse: AVSResponse;
  emvTags: EMVTags;
  orderNumber: string;
}

export interface TransactionDetailsResponse {
  id: string;
  paymentProcessorId: string;
  date: string;
  amount: TransactionAmount;
  currencyCode: string;
  currencyId: number;
  createdBy: string;
  merchant: string;
  processor: string;
  processorId: string;
  operationMode: string;
  paymentMethodType: string;
  paymentMethodTypeId: number;
  paymentMethodName: string;
  customerId: string;
  customerName: string;
  customerCompany: string;
  customerPan: string;
  customerEmail: string;
  customerPhone: string;
  status: string;
  statusId: number;
  responseCode: string;
  responseMessage: string;
  responseDescription: string;
  avsResponseCode: string;
  availableStates: string[];
  refunded: boolean;
  cardType: string;
  typeId: number;
  type: string;
  creditDebitTypeId: number;
  creditDebitTypeType: string;
  authCode: string;
  mid: string;
  tid: string;
  referenceId: string;
  merchantId: string;
  availableOperations: AvailableOperation[];
  histories: TransactionHistory[];
  avsResponse: AVSResponse;
  source: TransactionSource;
  transactionReceipt: TransactionReceipt;
}

export interface TransactionSaleError {
  Errors: Record<string, string[]>;
  Details: string;
  StatusCode: number;
  Source: string;
  ExceptionType: string;
  CorrelationId: string;
  ErrorCode: string;
}
