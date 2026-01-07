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
  taxAmount?: number; // opcional en el receipt
  taxRate?: number; // opcional en el receipt
  totalAmount: number;
}

export interface SuggestedTip {
  tipPercent: number;
  tipAmount: number;
}

export interface AvailableOperation {
  typeId: number;
  type: string;
  availableAmount: number | null;
  suggestedTips: SuggestedTip[];
}

export interface History {
  id: string;
  transactionDateTime: string;
  transactionAmount: number;
  transactionTypeId: number;
  transactionType: string;
  transactionStatusId: number;
  transactionStatus: string;
}

export interface AvsResponse {
  actionId: number;
  action: string;
  responseCode: string;
  groupId: number;
  group: string;
  resultId: number;
  result: string;
  codeDescription: string;
}

export interface Source {
  typeId: number;
  type: string;
  id: string;
  name: string;
  version?: string; // en receipt no siempre aparece
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

export interface AchProcessingDetails {
  customerAccountNumber: string;
  customerRoutingNumber: string;
  accountHolderType: string;
  accountHolderTypeId: number;
  accountType: string;
  accountTypeId: number;
  taxId: string;
}

export interface EmvTag {
  key: string;
  value: string;
}

export interface EmvTags {
  ac: string;
  tvr: string;
  tsi: string;
  aid: string;
  applicationLabel: string;
  rawTags: EmvTag[];
}

export interface TransactionReceipt {
  transactionId: string;
  transactionDateTime: string;
  amount: TransactionAmount;
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
  source: Source;
  cardholderAuthenticationMethodId: number;
  cardholderAuthenticationMethod: string;
  cvmResultMsg: string;
  cardDataSourceId: number;
  cardDataSource: string;
  responseCode: string;
  responseDescription: string;
  cardProcessingDetails: CardProcessingDetails;
  achProcessingDetails: AchProcessingDetails;
  availableOperations: AvailableOperation[];
  avsResponse: AvsResponse;
  emvTags: EmvTags;
  orderNumber: string;
}

export interface TransactionIdMerchantIdResponse {
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
  histories: History[];
  avsResponse: AvsResponse;
  source: Source;
  transactionReceipt: TransactionReceipt;
  customerAccountNumber: string;
  externalReferenceId?: string;
}
