import React from 'react';
import {renderHook, waitFor, act} from '@testing-library/react-native';
import {QueryClient, QueryClientProvider} from '@tanstack/react-query';
import {useMerchantSettings} from '../queries/useMerchantSettings';

jest.mock('@/clients/apiClient', () => ({
  apiClient: {
    get: jest.fn(),
  },
}));

const {apiClient} = require('@/clients/apiClient');

const createWrapper = () => {
  const client = new QueryClient({
    defaultOptions: {queries: {retry: false}},
  });
  return ({children}: {children: React.ReactNode}) => (
    <QueryClientProvider client={client}>{children}</QueryClientProvider>
  );
};

describe('useMerchantSettings', () => {
  beforeEach(() => jest.clearAllMocks());

  it('does not run when merchantId is undefined (enabled=false)', () => {
    const wrapper = createWrapper();
    renderHook(() => useMerchantSettings(undefined), {wrapper});
    expect(apiClient.get).not.toHaveBeenCalled();
  });

  it('calls endpoint when merchantId is provided', async () => {
    (apiClient.get as jest.Mock).mockResolvedValue({
      data: {merchantSettings: {}},
    });

    const wrapper = createWrapper();
    renderHook(() => useMerchantSettings('m-1'), {wrapper});

    await waitFor(() =>
      expect(apiClient.get).toHaveBeenCalledWith('/api/Merchants/m-1/settings'),
    );
  });
});
