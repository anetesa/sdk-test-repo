import {QueryClient} from '@tanstack/react-query';
import {CACHE_TIMES} from '@/constants/timing';
import {useUserStore} from '@/stores/userStore';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: CACHE_TIMES.DEFAULT_STALE,
      cacheTime: CACHE_TIMES.DEFAULT_CACHE,
      // Network-aware retry logic
      retry: (failureCount, error: any) => {
        // Don't retry on network errors at all (offline scenario)
        if (
          error?.message?.includes('Network Error') ||
          error?.message?.includes('Failed to fetch')
        ) {
          return false;
        }
        // If user is logged out, never retry auth errors (prevents extra calls during logout)
        const isLoggedIn = Boolean(useUserStore.getState().id);
        // Allow retry for 401/403 as they might be resolved by token refresh
        // The axios interceptor will handle the token refresh automatically
        if (
          error?.response?.status === 401 ||
          error?.response?.status === 403
        ) {
          if (!isLoggedIn) {
            return false;
          }
          return failureCount < 2; // Allow 1 retry for auth errors
        }
        // Don't retry on other 4xx client errors (except 408 Request Timeout)
        if (
          error?.response?.status >= 400 &&
          error?.response?.status < 500 &&
          error?.response?.status !== 408
        ) {
          return false;
        }
        return failureCount < 3;
      },
      retryDelay: (attemptIndex, error: any) => {
        // Shorter delay for auth errors since refresh should be quick
        if (
          error?.response?.status === 401 ||
          error?.response?.status === 403
        ) {
          return Math.min(500 * 2 ** attemptIndex, 2000);
        }
        return Math.min(1000 * 2 ** attemptIndex, 30000); // Exponential backoff
      },
      // Refetch on reconnect
      refetchOnReconnect: true,
      // Refetch when window gains focus (for web)
      refetchOnWindowFocus: false,
    },
    mutations: {
      retry: (failureCount, error: any) => {
        // Don't retry mutations on network errors (to avoid duplicate operations)
        if (
          error?.message?.includes('Network Error') ||
          error?.message?.includes('Failed to fetch')
        ) {
          return false;
        }
        const isLoggedIn = Boolean(useUserStore.getState().id);
        // Allow retry for 401/403 auth errors on mutations too
        if (
          error?.response?.status === 401 ||
          error?.response?.status === 403
        ) {
          if (!isLoggedIn) {
            return false;
          }
          return failureCount < 1; // Allow 1 retry for auth errors
        }
        // Don't retry on other 4xx client errors
        if (error?.response?.status >= 400 && error?.response?.status < 500) {
          return false;
        }
        return failureCount < 2;
      },
    },
  },
});
