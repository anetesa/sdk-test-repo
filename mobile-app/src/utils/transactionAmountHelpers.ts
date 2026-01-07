import {BinDataType} from '@/dictionaries/BinData';

export type AmountType = 'totalAmount' | 'surchargeAmount';

export interface TransactionAmountData {
  creditCard?: {
    totalAmount?: number;
    surchargeAmount?: number;
  };
  debitCard?: {
    totalAmount?: number;
    surchargeAmount?: number;
  };
}

export interface BinData {
  typeId?: BinDataType;
}

/**
 * Gets the amount for a specific type based on BIN data type
 * @param binData - The BIN data containing type information
 * @param transactionData - The transaction calculation data
 * @param amountType - The type of amount to retrieve
 * @returns The amount value or 0 if not found
 */
export function getAmountByType(
  binData: BinData | null | undefined,
  transactionData: TransactionAmountData | null | undefined,
  amountType: AmountType,
): number {
  if (!binData?.typeId || !transactionData) {
    return 0;
  }

  switch (binData.typeId) {
    case BinDataType.Credit:
      return transactionData.creditCard?.[amountType] || 0;
    case BinDataType.Debit:
      return transactionData.debitCard?.[amountType] || 0;
    default:
      return 0;
  }
}

/**
 * Gets the total amount based on BIN data type
 */
export function getTotalAmount(
  binData: BinData | null | undefined,
  transactionData: TransactionAmountData | null | undefined,
): number {
  return getAmountByType(binData, transactionData, 'totalAmount');
}

/**
 * Gets the surcharge amount based on BIN data type
 */
export function getSurchargeAmount(
  binData: BinData | null | undefined,
  transactionData: TransactionAmountData | null | undefined,
): number {
  return getAmountByType(binData, transactionData, 'surchargeAmount');
}
