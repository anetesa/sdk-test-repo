import AriseMobileSdk from '@/native/AriseMobileSdk';
import type {
  TransactionSalePayload,
  TransactionSaleResponse,
} from '@/types/TransactionSale';
import type {RefundTransactionPayload} from '@/types/TransactionRefund';
import type {CaptureTransactionPayload} from '@/types/TransactionCaptured';
import type {GetApiTransactionsCalculateAmountParams} from '@/types/CalculateAmount';

export async function submitSaleTransaction(
  payload: TransactionSalePayload,
): Promise<TransactionSaleResponse> {
  const response = await AriseMobileSdk.submitSaleTransaction(payload);
  return response as unknown as TransactionSaleResponse;
}

export async function voidTransaction(transactionId: string): Promise<any> {
  return await AriseMobileSdk.voidTransaction(transactionId);
}

export async function refundTransaction(
  payload: RefundTransactionPayload,
): Promise<any> {
  return await AriseMobileSdk.refundTransaction(payload);
}

export async function captureTransaction(
  payload: CaptureTransactionPayload,
): Promise<any> {
  return await AriseMobileSdk.captureTransaction(
    payload.transactionId,
    payload.amount,
  );
}

export async function calculateAmount(
  params: GetApiTransactionsCalculateAmountParams,
): Promise<any> {
  return await AriseMobileSdk.calculateAmount(params);
}
