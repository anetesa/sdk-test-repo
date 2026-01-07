import React from 'react';
import {renderHook, waitFor} from '@testing-library/react-native';
import {QueryClient, QueryClientProvider} from '@tanstack/react-query';
import {useMeProfile} from '../queries/useMeProfile';

jest.mock('@/clients/apiClient', () => ({
  apiClient: {
    get: jest.fn(),
  },
}));

import {Alert} from 'react-native';

jest.mock('@/utils/clearSession', () => ({
  clearSession: jest.fn(),
}));

const mockSetUser = jest.fn();
jest.mock('@/stores/userStore', () => ({
  useUserStore: (sel?: any) =>
    sel ? sel({setUser: mockSetUser}) : {setUser: mockSetUser},
}));

const {apiClient} = require('@/clients/apiClient');
const {clearSession} = require('@/utils/clearSession');

class ErrorBoundary extends React.Component<
  {children: React.ReactNode},
  {hasError: boolean}
> {
  constructor(props: any) {
    super(props);
    this.state = {hasError: false};
  }
  static getDerivedStateFromError() {
    return {hasError: true};
  }
  componentDidCatch() {}
  render() {
    if (this.state.hasError) {
      return null;
    }
    return this.props.children;
  }
}

const createWrapper = () => {
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  return ({children}: {children: React.ReactNode}) => (
    <QueryClientProvider client={client}>
      <ErrorBoundary>{children}</ErrorBoundary>
    </QueryClientProvider>
  );
};

describe('useMeProfile', () => {
  beforeEach(() => jest.clearAllMocks());

  it('calls API to fetch profile', async () => {
    (apiClient.get as jest.Mock).mockResolvedValue({
      data: {userTypeId: 2, profiles: [{merchantId: 'm-1'}]},
    });
    const wrapper = createWrapper();
    renderHook(() => useMeProfile(), {wrapper});

    // Verify the API call is made
    await waitFor(() =>
      expect(apiClient.get).toHaveBeenCalledWith('/api/Me/profile'),
    );

    // useMeProfile no longer calls setUser - that's handled in useLoginFlow
    expect(mockSetUser).not.toHaveBeenCalled();
  });

  // Note: The non-merchant onSuccess branch throws intentionally. Testing it directly
  // causes an uncaught error in the async notify cycle. We cover side-effects elsewhere.

  it('logs on query error (onError)', async () => {
    const error = new Error('boom');
    (apiClient.get as jest.Mock).mockRejectedValue(error);
    const wrapper = createWrapper();
    const consoleSpy = jest
      .spyOn(console, 'error')
      .mockImplementation(() => {});
    renderHook(() => useMeProfile(), {wrapper});
    await waitFor(() => expect(consoleSpy).toHaveBeenCalled());
    consoleSpy.mockRestore();
  });
});
