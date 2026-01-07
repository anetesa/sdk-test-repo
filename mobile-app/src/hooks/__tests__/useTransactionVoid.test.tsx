import React from 'react';
import {renderHook, act, waitFor} from '@testing-library/react-native';
import {QueryClient, QueryClientProvider} from '@tanstack/react-query';
import {useTransactionVoidMutation} from '../queries/useTransactionVoid';

jest.mock('@/native/AriseMobileSdk', () => ({
  __esModule: true,
  default: {
    voidTransaction: jest.fn(),
  },
}));

import AriseMobileSdk from '@/native/AriseMobileSdk';

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: {queries: {retry: false}, mutations: {retry: false}},
  });
  const Wrapper = ({children}: {children: React.ReactNode}) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );
  return Wrapper;
};

describe('useTransactionVoidMutation', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('calls voidTransaction on SDK with transactionId', async () => {
    (AriseMobileSdk.voidTransaction as jest.Mock).mockResolvedValue({statusId: 3});

    const wrapper = createWrapper();
    const {result} = renderHook(() => useTransactionVoidMutation(), {wrapper});

    await act(async () => {
      result.current.mutate({merchantId: 'm-1', transactionId: 't-1'});
    });

    expect(AriseMobileSdk.voidTransaction).toHaveBeenCalledWith('t-1');
  });

  it('exposes error state when request fails', async () => {
    (AriseMobileSdk.voidTransaction as jest.Mock).mockRejectedValue(new Error('network'));

    const wrapper = createWrapper();
    const {result} = renderHook(() => useTransactionVoidMutation(), {wrapper});

    await act(async () => {
      result.current.mutate({merchantId: 'm-1', transactionId: 't-1'});
    });
    await waitFor(() => expect(result.current.isError).toBe(true));
  });
});
