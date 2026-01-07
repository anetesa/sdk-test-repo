import React from 'react';
import {renderHook, act, waitFor} from '@testing-library/react-native';
import {QueryClient, QueryClientProvider} from '@tanstack/react-query';
import {useTransactionSaleMutation} from '../queries/useTransactionSale';

jest.mock('@/native/AriseMobileSdk', () => ({
  __esModule: true,
  default: {
    submitSaleTransaction: jest.fn(),
  },
}));

import AriseMobileSdk from '@/native/AriseMobileSdk';

const createWrapper = () => {
  const client = new QueryClient({
    defaultOptions: {queries: {retry: false}, mutations: {retry: false}},
  });
  return ({children}: {children: React.ReactNode}) => (
    <QueryClientProvider client={client}>{children}</QueryClientProvider>
  );
};

describe('useTransactionSaleMutation', () => {
  beforeEach(() => jest.clearAllMocks());

  it('calls sale endpoint and returns data', async () => {
    (AriseMobileSdk.submitSaleTransaction as jest.Mock).mockResolvedValue({
      id: 'tx1',
    });
    const wrapper = createWrapper();
    const {result} = renderHook(() => useTransactionSaleMutation(), {wrapper});
    await act(async () => {
      result.current.mutate({amount: 100, card: {number: '4'}} as any);
    });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(AriseMobileSdk.submitSaleTransaction).toHaveBeenCalledWith(
      expect.any(Object),
    );
  });

  it('surfaces error from API', async () => {
    (AriseMobileSdk.submitSaleTransaction as jest.Mock).mockRejectedValue({
      response: {data: {code: 'Decline', message: 'No'}},
    });
    const wrapper = createWrapper();
    const {result} = renderHook(() => useTransactionSaleMutation(), {wrapper});
    await act(async () => {
      result.current.mutate({amount: 100} as any);
    });
    await waitFor(() => expect(result.current.isError).toBe(true));
  });
});
