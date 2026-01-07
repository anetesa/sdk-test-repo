import React from 'react';
import {renderHook, waitFor, act} from '@testing-library/react-native';
import {QueryClient, QueryClientProvider} from '@tanstack/react-query';
import {useTransactionDetails} from '../queries/useTransactionDetails';

jest.mock('@/clients/apiClient', () => ({
  apiClient: {
    get: jest.fn(),
  },
}));

const mockApiClient = require('@/clients/apiClient').apiClient;

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: {queries: {retry: false}},
  });
  return ({children}: {children: React.ReactNode}) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );
};

const flushMicrotasks = async () => {
  await act(async () => {
    await Promise.resolve();
    await Promise.resolve();
  });
};

describe('useTransactionDetails', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('does not run when merchantId is missing', async () => {
    const wrapper = createWrapper();

    renderHook(
      () => useTransactionDetails({merchantId: '', transactionId: 'tx-1'}),
      {wrapper},
    );

    expect(mockApiClient.get).not.toHaveBeenCalled();
  });

  it('does not run when transactionId is missing', async () => {
    const wrapper = createWrapper();

    renderHook(
      () =>
        useTransactionDetails({merchantId: 'm-1', transactionId: undefined}),
      {wrapper},
    );

    expect(mockApiClient.get).not.toHaveBeenCalled();
  });

  it('fetches transaction details with correct URL', async () => {
    const wrapper = createWrapper();
    (mockApiClient.get as jest.Mock).mockResolvedValue({data: {}});

    renderHook(
      () => useTransactionDetails({merchantId: 'm-1', transactionId: 'tx-1'}),
      {wrapper},
    );

    await waitFor(() => expect(mockApiClient.get).toHaveBeenCalled());
    await flushMicrotasks();

    expect(mockApiClient.get).toHaveBeenCalledWith(
      '/api/Merchants/m-1/transactions/tx-1',
    );
  });
});
