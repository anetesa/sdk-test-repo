import React from 'react';
import {renderHook, act, waitFor} from '@testing-library/react-native';
import {QueryClient, QueryClientProvider} from '@tanstack/react-query';
import {useLoginFlow} from '../useLoginFlow';
import {Alert} from 'react-native';

// Controlled mocks
const mockMutate = jest.fn();
let mockData: any = null;
let mockIsLoading = false;
let mockIsError = false;
let mockError: any = null;

jest.mock('../queries/useLoginMutation', () => ({
  useLoginMutation: () => ({
    mutate: mockMutate,
    data: mockData,
    isError: mockIsError,
    isLoading: mockIsLoading,
    error: mockError,
  }),
}));

const mockRefetch = jest.fn();
jest.mock('../queries/useMeProfile', () => ({
  useMeProfile: () => ({refetch: mockRefetch}),
}));

const mockExecutePostAuthFlow = jest.fn();
jest.mock('../usePostAuthFlow', () => ({
  usePostAuthFlow: () => ({executePostAuthFlow: mockExecutePostAuthFlow}),
}));

jest.mock('@/utils/runtimeConfig', () => ({
  runtimeConfig: {APP_FUSIONAUTH_APPLICATION_ID: 'app-1'},
}));

const mockGetTwoFactorTrustId = jest.fn();
jest.mock('@/utils/asyncStorage', () => ({
  getTwoFactorTrustId: (...args: any[]) => mockGetTwoFactorTrustId(...args),
}));

jest.mock('@/utils/logger', () => ({
  logger: {error: jest.fn()},
}));

jest.mock('@/stores/userStore', () => ({
  useUserStore: (sel?: any) =>
    sel ? sel({setUser: jest.fn()}) : {setUser: jest.fn()},
}));

jest.spyOn(Alert, 'alert').mockImplementation(() => {});

const createWrapper = () => {
  const client = new QueryClient({
    defaultOptions: {queries: {retry: false}, mutations: {retry: false}},
  });
  return ({children}: {children: React.ReactNode}) => (
    <QueryClientProvider client={client}>{children}</QueryClientProvider>
  );
};

describe('useLoginFlow', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockData = null;
    mockIsLoading = false;
    mockIsError = false;
    mockError = null;
    mockRefetch.mockResolvedValue({data: null, error: undefined});
    mockGetTwoFactorTrustId.mockResolvedValue(null);
    mockExecutePostAuthFlow.mockClear();
  });

  it('parses twoFactorTrustId and passes it to login', async () => {
    const nav = {navigate: jest.fn()};
    const setIsChange = jest.fn();
    const setIsMeProfileLoading = jest.fn();
    mockGetTwoFactorTrustId.mockResolvedValue(
      JSON.stringify({'a@b.com': 'trust-1'}),
    );
    const {result} = renderHook(
      () =>
        useLoginFlow({
          navigation: nav,
          currentLoginEmail: 'a@b.com',
          userPassword: 'p',
          isChangePasswordRequired: false,
          setIsChangePasswordRequired: setIsChange,
          setIsMeProfileLoading,
        }),
      {wrapper: createWrapper()},
    );
    await act(async () => {
      await result.current.login('a@b.com', 'p');
    });
    expect(mockMutate).toHaveBeenCalledWith(
      expect.objectContaining({twoFactorTrustId: 'trust-1'}),
    );
  });

  it('logs parse error and omits twoFactorTrustId', async () => {
    const nav = {navigate: jest.fn()};
    const setIsChange = jest.fn();
    const setIsMeProfileLoading = jest.fn();
    mockGetTwoFactorTrustId.mockResolvedValue('not-json');
    const consoleSpy = jest
      .spyOn(console, 'error')
      .mockImplementation(() => {});
    const {result} = renderHook(
      () =>
        useLoginFlow({
          navigation: nav,
          currentLoginEmail: 'a@b.com',
          userPassword: 'p',
          isChangePasswordRequired: false,
          setIsChangePasswordRequired: setIsChange,
          setIsMeProfileLoading,
        }),
      {wrapper: createWrapper()},
    );
    await act(async () => {
      await result.current.login('a@b.com', 'p');
    });
    expect(mockMutate).toHaveBeenCalledWith(
      expect.objectContaining({twoFactorTrustId: undefined}),
    );
    expect(consoleSpy).toHaveBeenCalled();
    consoleSpy.mockRestore();
  });

  it('sets loading true when mutation is loading', async () => {
    mockIsLoading = true;
    const nav = {navigate: jest.fn()};
    const setIsChange = jest.fn();
    const setIsMeProfileLoading = jest.fn();
    renderHook(
      () =>
        useLoginFlow({
          navigation: nav,
          currentLoginEmail: 'a@b.com',
          userPassword: 'p',
          isChangePasswordRequired: false,
          setIsChangePasswordRequired: setIsChange,
          setIsMeProfileLoading,
        }),
      {wrapper: createWrapper()},
    );
    await waitFor(() =>
      expect(setIsMeProfileLoading).toHaveBeenCalledWith(true),
    );
  });

  it('alerts when twoFactorId has zero methods', async () => {
    mockData = {twoFactorId: 'id', methods: []};
    const nav = {navigate: jest.fn()};
    const setIsChange = jest.fn();
    const setIsMeProfileLoading = jest.fn();
    renderHook(
      () =>
        useLoginFlow({
          navigation: nav,
          currentLoginEmail: 'a@b.com',
          userPassword: 'p',
          isChangePasswordRequired: false,
          setIsChangePasswordRequired: setIsChange,
          setIsMeProfileLoading,
        }),
      {wrapper: createWrapper()},
    );
    await waitFor(() => expect(Alert.alert).toHaveBeenCalled());
    expect(setIsMeProfileLoading).toHaveBeenCalledWith(false);
  });

  it('navigates to Change Password when changePasswordId and no trust id', async () => {
    mockData = {changePasswordId: 'cpid'};
    const nav = {navigate: jest.fn()};
    const setIsChange = jest.fn();
    const setIsMeProfileLoading = jest.fn();
    renderHook(
      () =>
        useLoginFlow({
          navigation: nav,
          currentLoginEmail: 'a@b.com',
          userPassword: 'p',
          isChangePasswordRequired: false,
          setIsChangePasswordRequired: setIsChange,
          setIsMeProfileLoading,
        }),
      {wrapper: createWrapper()},
    );
    await waitFor(() => expect(nav.navigate).toHaveBeenCalled());
  });

  it('re-logins when changePasswordId and trust id exists', async () => {
    mockData = {changePasswordId: 'cpid'};
    mockGetTwoFactorTrustId.mockResolvedValue('anything');
    const nav = {navigate: jest.fn()};
    const setIsChange = jest.fn();
    const setIsMeProfileLoading = jest.fn();
    renderHook(
      () =>
        useLoginFlow({
          navigation: nav,
          currentLoginEmail: 'a@b.com',
          userPassword: 'p',
          isChangePasswordRequired: false,
          setIsChangePasswordRequired: setIsChange,
          setIsMeProfileLoading,
        }),
      {wrapper: createWrapper()},
    );
    await waitFor(() => expect(mockMutate).toHaveBeenCalled());
    expect(setIsMeProfileLoading).toHaveBeenCalledWith(false);
  });

  it('navigates to MFA when twoFactorId with methods', async () => {
    mockData = {twoFactorId: 'id', methods: ['sms']};
    const nav = {navigate: jest.fn()};
    const setIsChange = jest.fn();
    const setIsMeProfileLoading = jest.fn();
    renderHook(
      () =>
        useLoginFlow({
          navigation: nav,
          currentLoginEmail: 'a@b.com',
          userPassword: 'p',
          isChangePasswordRequired: false,
          setIsChangePasswordRequired: setIsChange,
          setIsMeProfileLoading,
        }),
      {wrapper: createWrapper()},
    );
    await waitFor(() => expect(nav.navigate).toHaveBeenCalled());
  });
});
