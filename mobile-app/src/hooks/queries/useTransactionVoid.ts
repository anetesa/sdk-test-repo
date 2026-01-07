import {useMutation} from '@tanstack/react-query';
import {voidTransaction} from '@/services/nativeTransactionActionsService';

export type TransactionVoidPayload = {
  transactionId: string;
};

export type TransactionVoidResponse = {
  transactionId: string;
  transactionDateTime?: string;
  typeId?: number;
  type?: string;
  statusId: number;
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
  [key: string]: any;
};

async function transactionVoidFn(
  payload: TransactionVoidPayload,
): Promise<TransactionVoidResponse> {
  const response = await voidTransaction(payload.transactionId);
  return response as unknown as TransactionVoidResponse;
}

export function useTransactionVoidMutation() {
  return useMutation<TransactionVoidResponse, Error, TransactionVoidPayload>({
    mutationFn: transactionVoidFn,
    retry: false,
  });
}
