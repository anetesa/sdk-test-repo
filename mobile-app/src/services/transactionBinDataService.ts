import {apiClient} from '@/clients/apiClient';
import type {TransactionBinData} from '@/types/TransactionBinData';

export async function fetchTransactionBinData(
  binData: string,
): Promise<TransactionBinData> {
  const response = await apiClient.get(
    `/api/bin-data?accountNumber=${binData}`,
  );
  return response.data;
}
