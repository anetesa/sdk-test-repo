import {useMutation} from '@tanstack/react-query';

import {
  TransactionSaleError,
  TransactionSalePayload,
  TransactionSaleResponse,
} from '@/types/TransactionSale';
import {submitSaleTransaction} from '@/services/nativeTransactionActionsService';

export function useTransactionSaleMutation() {
  return useMutation<
    TransactionSaleResponse,
    TransactionSaleError,
    TransactionSalePayload
  >({
    mutationFn: submitSaleTransaction,
    retry: false,
  });
}
