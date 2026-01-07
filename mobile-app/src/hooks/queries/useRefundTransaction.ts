import {useMutation} from '@tanstack/react-query';
import {
  RefundTransactionPayload,
  TransactionRefundError,
} from '@/types/TransactionRefund';
import {refundTransaction} from '@/services/nativeTransactionActionsService';

export interface RefundResponse {
  transactionId?: string;
  transactionDateTime?: string;
  typeId?: number;
  type?: string;
  statusId?: number;
  status?: string;
  details?: {
    hostResponseCode?: string | null;
    hostResponseMessage?: string | null;
    hostResponseDefinition?: string | null;
    code?: string | null;
    message?: string | null;
    processorResponseCode?: string | null;
    authCode?: string | null;
    maskedPan?: string | null;
  } | null;
}

async function transactionRefundFn(
  payload: RefundTransactionPayload,
): Promise<RefundResponse> {
  const response = await refundTransaction(payload);
  return response as unknown as RefundResponse;
}

export function useTransactionRefundMutation() {
  return useMutation<
    RefundResponse,
    TransactionRefundError,
    RefundTransactionPayload
  >({
    mutationFn: transactionRefundFn,
    retry: false,
  });
}
