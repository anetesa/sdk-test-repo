import {apiClient} from '@/clients/apiClient';
import type {TransactionIdMerchantIdResponse} from '@/types/TransactionIdMerchantIdResponse';

export async function fetchTransactionDetails(params: {
  merchantId: string;
  transactionId: string;
  isACH: boolean;
}): Promise<TransactionIdMerchantIdResponse> {
  const transactionUrl = params.isACH ? 'transactions/ach' : 'transactions';
  const res = await apiClient.get(
    `/api/Merchants/${params.merchantId}/${transactionUrl}/${params.transactionId}`,
  );
  return res.data;
}
