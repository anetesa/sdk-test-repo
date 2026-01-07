import {useQuery} from '@tanstack/react-query';
import {fetchTransactionDetails} from '@/services/transactionDetailsService';

type TransactionDetailsQueryProps = {
  merchantId: string;
  transactionId?: string;
  isACH: boolean;
};

export function useTransactionDetails({
  merchantId,
  transactionId,
  isACH,
}: TransactionDetailsQueryProps) {
  return useQuery({
    queryKey: ['transactionDetails', merchantId, transactionId],
    queryFn: () =>
      fetchTransactionDetails({
        merchantId,
        transactionId: transactionId!,
        isACH,
      }),
    staleTime: 0,
    enabled: !!merchantId && !!transactionId,
    // After a Tap-to-Pay approval, the transaction may take a moment to be available in the API.
    // Some backends respond 400/404 while the transaction is still being processed.
    // We retry briefly so the UI doesn't get stuck on "Processing...".
    retry: (failureCount, error: any) => {
      const status = error?.response?.status;
      if (status === 400 || status === 404) {
        return failureCount < 10; // ~10 seconds with the delay below
      }
      return false;
    },
    retryDelay: () => 1000,
  });
}
