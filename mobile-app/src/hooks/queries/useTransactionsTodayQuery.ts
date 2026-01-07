import {QueryClient, useQueries} from '@tanstack/react-query';
import {QUERY_KEYS} from '@/constants/queryKeys';
import {useUserStore} from '@/stores/userStore';
import {
  fetchSalesTodayTotal,
  fetchTransactionsTodayCount,
} from '@/services/homeMetricsService';

export function invalidateTransactionsTodayQuery(queryClient: QueryClient) {
  queryClient.invalidateQueries({queryKey: QUERY_KEYS.TRANSACTIONS_TODAY});
  queryClient.invalidateQueries({queryKey: QUERY_KEYS.SALES_TODAY});
}

export function useTransactionsTodayQuery() {
  const {merchantId} = useUserStore();
  const isEnabled = !!merchantId;

  const results = useQueries({
    queries: [
      {
        queryKey: QUERY_KEYS.TRANSACTIONS_TODAY,
        queryFn: fetchTransactionsTodayCount,
        enabled: isEnabled,
      },
      {
        queryKey: QUERY_KEYS.SALES_TODAY,
        queryFn: fetchSalesTodayTotal,
        enabled: isEnabled,
      },
    ],
  });

  // Handle errors in the hook
  const transactionsError = results[0].error;
  const salesError = results[1].error;

  return {
    transactionsToday: (results[0].data as any)?.count ?? 0,
    salesToday: (results[1].data as any)?.sales ?? 0,
    isLoading: results.some(result => result.isLoading),
    isError: results.some(result => result.isError),
    errors: {
      transactions: transactionsError,
      sales: salesError,
    },
    refetch: () => results.forEach(result => result.refetch()),
  };
}
