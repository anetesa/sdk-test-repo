import {GetTransactionsResponseDTO} from '@/types/TransactionResponse';
import {TransactionIdMerchantIdResponse} from '@/types/TransactionIdMerchantIdResponse';
import {
  isFailed,
  isDeclined,
  isRefunded,
  isAchCredit,
} from '@/utils/transactionContentMapper';
import {getErrorMessage} from '@/utils/getErrorMessage';
import {TRANSACTION_DETAIL_MESSAGES} from '@/constants/messages';
import {TransactionHistory} from '@/types/TransactionSale';

export const hasErrorStatus = (
  transaction: Pick<GetTransactionsResponseDTO, 'statusId' | 'typeId'>,
) => {
  const statusId = transaction.statusId || 0;
  const typeId = transaction.typeId || 0;
  return isFailed(statusId, typeId) || isDeclined(statusId);
};

export const getErrorDetails = (
  base: GetTransactionsResponseDTO,
  details: TransactionIdMerchantIdResponse | undefined,
) => {
  const source = (details as any) || base;
  if (!hasErrorStatus(source)) {
    return undefined;
  }

  const errorMessage =
    details?.avsResponse?.codeDescription ||
    getErrorMessage(
      details?.responseCode,
      details?.responseDescription || details?.responseMessage || '',
    );

  return errorMessage || undefined;
};

export const getErrorCode = (
  base: GetTransactionsResponseDTO,
  details: TransactionIdMerchantIdResponse | undefined,
) => {
  const source = (details as any) || base;
  if (!hasErrorStatus(source)) {
    return undefined;
  }
  return (
    details?.avsResponse?.responseCode || details?.responseCode || undefined
  );
};

export const getAmountLabel = (
  statusId: number | undefined,
  typeId: number | undefined,
): string => {
  const safeStatusId = statusId || 0;
  const safeTypeId = typeId || 0;

  if (isRefunded(safeStatusId)) {
    return TRANSACTION_DETAIL_MESSAGES.AMOUNT_REFUNDED;
  }

  if (isAchCredit(safeTypeId)) {
    return TRANSACTION_DETAIL_MESSAGES.AMOUNT_CREDITED;
  }

  return TRANSACTION_DETAIL_MESSAGES.TOTAL_AMOUNT;
};

export function removeNegativeSignForRefund(
  amountString: string,
  statusId: number,
  typeId: number,
) {
  if (isRefunded(statusId) || isAchCredit(typeId)) {
    return amountString.startsWith('-') ? amountString.slice(1) : amountString;
  }

  return amountString;
}

export function getTypeInfo(type: string, histories: TransactionHistory[]) {
  if (type === 'RefundWORef') {
    return {id: 'Refund', detail: 'Refund without reference'};
  }

  if (type === 'Capture') {
    return {id: 'Sale', detail: 'Sale'};
  }

  if (type === 'AchDebit') {
    return {id: 'ACH Sale', detail: 'Debit (Sale)'};
  }

  if (type === 'AchCredit') {
    return {id: 'ACH Credit', detail: 'Credit (Refund/Payout)'};
  }

  if (type === 'Void') {
    const isAuthorization = histories.some(
      tx => tx.transactionType === 'Authorization',
    );
    const base = isAuthorization ? 'Authorization' : 'Sale';
    return {id: base, detail: base};
  }

  return {id: type, detail: type};
}
