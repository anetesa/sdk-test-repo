import {useMutation} from '@tanstack/react-query';
import {
  CaptureTransactionPayload,
  TransactionCaptureError,
} from '@/types/TransactionCaptured';
import {captureTransaction} from '@/services/nativeTransactionActionsService';

export interface CaptureResponse {
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

async function transactionCaptureFn(
  payload: CaptureTransactionPayload,
): Promise<CaptureResponse> {
  const response = await captureTransaction(payload);
  return response as unknown as CaptureResponse;
}

export function useTransactionCaptureMutation() {
  return useMutation<
    CaptureResponse,
    TransactionCaptureError,
    CaptureTransactionPayload
  >({
    mutationFn: transactionCaptureFn,
    retry: false,
  });
}
