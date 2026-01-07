export interface GetTransactionsResponseDTO {
  amount?: RiseOsV2PaymentGatewayContractsAmountsAmountDtoDTO;
  /** @nullable */
  availableOperations?:
    | RiseOsV2PaymentGatewayContractsTransactionsGetPageGetTransactionPageResponseDtoAvailableOperationDTO[]
    | null;
  /** @nullable */
  baseAmount?: number | null;
  /** @nullable */
  batchId?: string | null;
  cardTokenType?: RiseOsV2PaymentGatewayContractsEnumsTokenTypeDTO;
  /** @nullable */
  currencyCode?: string | null;
  /** @nullable */
  currencyId?: number | null;
  /** @nullable */
  customerCompany?: string | null;
  /** @nullable */
  customerEmail?: string | null;
  /** @nullable */
  customerName?: string | null;
  /** @nullable */
  customerPan?: string | null;
  /** @nullable */
  customerPhone?: string | null;
  /** @nullable */
  date?: string | null;
  id?: string;
  /** @nullable */
  merchant?: string | null;
  merchantId?: string;
  /** @nullable */
  operationMode?: string | null;
  /** @nullable */
  paymentMethodName?: string | null;
  /** @nullable */
  paymentMethodType?: string | null;
  paymentMethodTypeId?: number;
  paymentProcessorId?: string;
  source?: RiseOsV2PaymentGatewayContractsSourceResponseDtoDTO;
  /** @nullable */
  status?: string | null;
  statusId?: number;
  /** @nullable */
  surchargeAmount?: number | null;
  /** @nullable */
  surchargePercentage?: number | null;
  /** @nullable */
  totalAmount?: number | null;
  /** @nullable */
  type?: string | null;
  typeId?: number;
}

export interface RiseOsV2PaymentGatewayContractsTransactionsGetPageGetTransactionPageResponseDtoAvailableOperationDTO {
  /** @nullable */
  availableAmount?: number | null;
  /** @nullable */
  suggestedTips?:
    | RiseOsV2PaymentGatewayContractsAmountsSuggestedTipsDtoDTO[]
    | null;
  /** @nullable */
  type?: string | null;
  typeId?: number;
}

export interface RiseOsV2PaymentGatewayContractsAmountsSuggestedTipsDtoDTO {
  tipAmount?: number;
  tipPercent?: number;
}

export interface RiseOsV2PaymentGatewayContractsAmountsAmountDtoDTO {
  baseAmount?: number;
  cashDiscountAmount?: number;
  cashDiscountRate?: number;
  percentageOffAmount?: number;
  percentageOffRate?: number;
  surchargeAmount?: number;
  surchargeRate?: number;
  taxAmount?: number;
  taxRate?: number;
  tipAmount?: number;
  tipRate?: number;
  totalAmount?: number;
}

export interface RiseOsV2PaymentGatewayContractsSourceResponseDtoDTO {
  /** @nullable */
  id?: string | null;
  /** @nullable */
  name?: string | null;
  /** @nullable */
  type?: string | null;
  /** @nullable */
  typeId?: number | null;
}

export type RiseOsV2PaymentGatewayContractsEnumsTokenTypeDTO =
  (typeof RiseOsV2PaymentGatewayContractsEnumsTokenTypeDTO)[keyof typeof RiseOsV2PaymentGatewayContractsEnumsTokenTypeDTO];

export const RiseOsV2PaymentGatewayContractsEnumsTokenTypeDTO = {
  NUMBER_1: 1,
  NUMBER_2: 2,
} as const;
