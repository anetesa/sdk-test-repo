import {useQuery} from '@tanstack/react-query';
import type {TransactionBinData} from '@/types/TransactionBinData';

import {createQueryKey} from '@/constants/queryKeys';
import {fetchTransactionBinData} from '@/services/transactionBinDataService';

export function useTransactionBinData(binData?: string) {
  return useQuery<TransactionBinData, Error>({
    queryKey: createQueryKey.transactionBinData(binData || ''),
    queryFn: () => fetchTransactionBinData(binData || ''),
    enabled: !!binData,
    onError: error => {
      console.error('Error fetching transaction bin data:', error);
    },
  });
}
