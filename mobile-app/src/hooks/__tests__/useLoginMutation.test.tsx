import React from 'react';
import {renderHook, act, waitFor} from '@testing-library/react-native';
import {QueryClient, QueryClientProvider} from '@tanstack/react-query';
import {useLoginMutation} from '../queries/useLoginMutation';

jest.mock('@/clients/authApi', () => ({
  post: jest.fn(),
}));

jest.mock('@/utils/tokenRefresh', () => ({
  storeTokens: jest.fn(),
}));

jest.mock('@/utils/runtimeConfig', () => ({
  runtimeConfig: {
    APP_API_AUTH_URL: 'https://auth.example.com',
    APP_FUSIONAUTH_APPLICATION_ID: 'app-1',
  },
}));

const authApi = require('@/clients/authApi');
const tokenRefresh = require('@/utils/tokenRefresh');

const createWrapper = () => {
  const client = new QueryClient({
    defaultOptions: {queries: {retry: false}, mutations: {retry: false}},
  });
  return ({children}: {children: React.ReactNode}) => (
    <QueryClientProvider client={client}>{children}</QueryClientProvider>
  );
};

describe('useLoginMutation', () => {
  beforeEach(() => jest.clearAllMocks());

  it('posts to login and stores tokens when both exist', async () => {
    const response = {
      data: {token: 't', refreshToken: 'r'},
    };
    authApi.post.mockResolvedValue(response);

    const wrapper = createWrapper();
    const {result} = renderHook(() => useLoginMutation(), {wrapper});
    await act(async () => {
      result.current.mutate({loginId: 'a', password: 'b'});
    });

    expect(authApi.post).toHaveBeenCalledWith(
      'https://auth.example.com/api/login',
      expect.objectContaining({loginId: 'a', password: 'b'}),
      expect.objectContaining({headers: {applicationId: 'app-1'}}),
    );
    expect(tokenRefresh.storeTokens).toHaveBeenCalledWith('t', 'r');
  });

  it('does not store tokens when refreshToken missing', async () => {
    authApi.post.mockResolvedValue({data: {token: 't'}});
    const wrapper = createWrapper();
    const {result} = renderHook(() => useLoginMutation(), {wrapper});
    await act(async () => {
      result.current.mutate({loginId: 'a', password: 'b'});
    });
    expect(tokenRefresh.storeTokens).not.toHaveBeenCalled();
  });

  it('throws response.data on API error with response payload', async () => {
    authApi.post.mockRejectedValue({response: {data: {error: 'bad'}}});
    const wrapper = createWrapper();
    const {result} = renderHook(() => useLoginMutation(), {wrapper});
    await act(async () => {
      result.current.mutate({loginId: 'a', password: 'b'});
    });
    await waitFor(() => expect(result.current.isError).toBe(true));
  });
});
