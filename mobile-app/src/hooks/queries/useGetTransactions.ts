import {useQuery, useInfiniteQuery, QueryClient} from '@tanstack/react-query';
import {createQueryKey} from '@/constants/queryKeys';
import {QUERY_KEYS} from '@/constants/queryKeys';
import {PAGINATION} from '@/constants/timing';
import {useUserStore} from '@/stores/userStore';
import {fetchTransactionsPage} from '@/services/nativeTransactionsService';

// Invalidate functions for query cache management
export function invalidateDashboardTransactions(queryClient: QueryClient) {
  queryClient.invalidateQueries({
    queryKey: [QUERY_KEYS.DASHBOARD_TRANSACTIONS],
    exact: false, // This will invalidate all queries that start with this key
  });
}

export function invalidateInfiniteDashboardTransactions(
  queryClient: QueryClient,
) {
  queryClient.invalidateQueries({
    queryKey: [QUERY_KEYS.INFINITE_DASHBOARD_TRANSACTIONS],
    exact: false, // This will invalidate all queries that start with this key
  });
}

// Hook for single page transactions query
export function useGetTransactions({
  page = 0,
  pageSize = PAGINATION.DEFAULT_PAGE_SIZE,
  asc = false,
  orderBy = '',
  enabled = true,
}: {
  page?: number;
  pageSize?: number;
  asc?: boolean;
  orderBy?: string;
  enabled?: boolean;
} = {}) {
  const userId = useUserStore(state => state.id);

  return useQuery({
    queryKey: createQueryKey.dashboardTransactions(
      page,
      pageSize,
      asc,
      orderBy,
    ),
    queryFn: () =>
      fetchTransactionsPage({
        page,
        pageSize,
        asc,
        orderBy,
      }),
    enabled: enabled && Boolean(userId),
  });
}

// Hook for infinite scroll transactions query
export function useGetInfiniteTransactions({
  pageSize = 20,
  asc = false,
  orderBy = '',
  enabled = true,
}: {
  pageSize?: number;
  asc?: boolean;
  orderBy?: string;
  enabled?: boolean;
} = {}) {
  const userId = useUserStore(state => state.id);

  return useInfiniteQuery({
    queryKey: createQueryKey.infiniteDashboardTransactions(
      pageSize,
      asc,
      orderBy,
    ),
    queryFn: ({pageParam = 0}) =>
      fetchTransactionsPage({
        page: pageParam,
        pageSize,
        asc,
        orderBy,
      }),
    getNextPageParam: (lastPage, allPages) => {
      // Check if there are more pages based on the response
      if (lastPage?.items?.length < pageSize) {
        return undefined; // No more pages
      }
      return allPages.length; // Next page number
    },
    enabled: enabled && Boolean(userId),
  });
}
