export interface CalculateAmountResponseDTO {
  ach?: RiseOsV2PaymentGatewayContractsAmountsAmountDtoDTO;
  cash?: RiseOsV2PaymentGatewayContractsAmountsAmountDtoDTO;
  creditCard?: RiseOsV2PaymentGatewayContractsAmountsAmountDtoDTO;
  /** @nullable */
  readonly currency?: string | null;
  currencyId?: RiseOsV2PaymentGatewayContractsEnumsCurrencyDTO;
  debitCard?: RiseOsV2PaymentGatewayContractsAmountsAmountDtoDTO;
  /** @nullable */
  useCardPrice?: boolean | null;
  /** @nullable */
  readonly zeroCostProcessingOption?: string | null;
  zeroCostProcessingOptionId?: RiseOsV2PaymentGatewayContractsEnumsZeroCostProcessingOptionDTO;
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

export type RiseOsV2PaymentGatewayContractsEnumsCurrencyDTO =
  (typeof RiseOsV2PaymentGatewayContractsEnumsCurrencyDTO)[keyof typeof RiseOsV2PaymentGatewayContractsEnumsCurrencyDTO];

export const RiseOsV2PaymentGatewayContractsEnumsCurrencyDTO = {
  NUMBER_1: 1,
} as const;

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

export type RiseOsV2PaymentGatewayContractsEnumsZeroCostProcessingOptionDTO =
  (typeof RiseOsV2PaymentGatewayContractsEnumsZeroCostProcessingOptionDTO)[keyof typeof RiseOsV2PaymentGatewayContractsEnumsZeroCostProcessingOptionDTO];

export const RiseOsV2PaymentGatewayContractsEnumsZeroCostProcessingOptionDTO = {
  NUMBER_1: 1,
  NUMBER_2: 2,
  NUMBER_3: 3,
  NUMBER_4: 4,
} as const;

export type GetApiTransactionsCalculateAmountParams = {
  amount?: number;
  percentageOffRate?: number;
  cashDiscountRate?: number;
  surchargeRate?: number;
  tipAmount?: number;
  tipRate?: number;
  zeroCostProcessingInvoiceOption?: RiseOsV2PaymentGatewayContractsEnumsZeroCostProcessingOptionDTO;
  currencyId?: number;
  useCardPrice?: boolean;
};
