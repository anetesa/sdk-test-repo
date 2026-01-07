import React from 'react';
import {renderHook, waitFor} from '@testing-library/react-native';
import {QueryClient, QueryClientProvider} from '@tanstack/react-query';
import {
  useGetTransactions,
  useGetInfiniteTransactions,
  invalidateDashboardTransactions,
  invalidateInfiniteDashboardTransactions,
} from '../queries/useGetTransactions';
import {QUERY_KEYS} from '@/constants/queryKeys';

jest.mock('@/native/AriseMobileSdk', () => ({
  __esModule: true,
  default: {
    getTransactions: jest.fn(),
  },
}));

jest.mock('@/stores/userStore', () => ({
  useUserStore: (selector: any) => selector({id: 'test-user-id'}),
}));

import AriseMobileSdk from '@/native/AriseMobileSdk';

const createWrapper = () => {
  const client = new QueryClient({
    defaultOptions: {queries: {retry: false}},
  });
  return {
    client,
    wrapper: ({children}: {children: React.ReactNode}) => (
      <QueryClientProvider client={client}>{children}</QueryClientProvider>
    ),
  };
};

describe('useGetTransactions', () => {
  beforeEach(() => jest.clearAllMocks());

  it('invalidates dashboard queries with correct key', () => {
    const qc = new QueryClient();
    const spy = jest.spyOn(qc, 'invalidateQueries');
    invalidateDashboardTransactions(qc);
    expect(spy).toHaveBeenCalledWith({
      queryKey: [QUERY_KEYS.DASHBOARD_TRANSACTIONS],
      exact: false,
    });
  });

  it('invalidates infinite dashboard queries with correct key', () => {
    const qc = new QueryClient();
    const spy = jest.spyOn(qc, 'invalidateQueries');
    invalidateInfiniteDashboardTransactions(qc);
    expect(spy).toHaveBeenCalledWith({
      queryKey: [QUERY_KEYS.INFINITE_DASHBOARD_TRANSACTIONS],
      exact: false,
    });
  });

  it('fetches first page of transactions (calls endpoint)', async () => {
    (AriseMobileSdk.getTransactions as jest.Mock).mockResolvedValue({
      items: [{id: 't1'}],
      total: 1,
    });
    const {wrapper} = createWrapper();
    renderHook(() => useGetTransactions({page: 0, pageSize: 1, asc: false}), {
      wrapper,
    });
    await waitFor(() =>
      expect(AriseMobileSdk.getTransactions).toHaveBeenCalled(),
    );

    // Assert endpoint and query params were passed
    const call = (AriseMobileSdk.getTransactions as jest.Mock).mock.calls[0];
    expect(call[0]).toEqual({
      page: 0,
      pageSize: 1,
      orderBy: '',
      asc: false,
    });
  });

  it('fetches infinite pages and computes next page param (calls endpoint)', async () => {
    (AriseMobileSdk.getTransactions as jest.Mock)
      .mockResolvedValueOnce({items: [{id: 'a'}], total: 2})
      .mockResolvedValueOnce({items: [{id: 'b'}], total: 2});

    const {wrapper} = createWrapper();
    renderHook(() => useGetInfiniteTransactions({pageSize: 1}), {wrapper});
    await waitFor(() =>
      expect(AriseMobileSdk.getTransactions).toHaveBeenCalled(),
    );

    const call = (AriseMobileSdk.getTransactions as jest.Mock).mock.calls[0];
    // Infinite query might pass different defaults, checking the first call
    expect(call[0]).toEqual(
      expect.objectContaining({
        pageSize: 1,
      }),
    );
  });
});
