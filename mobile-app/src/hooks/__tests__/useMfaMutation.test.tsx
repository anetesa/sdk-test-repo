import {renderHook, act} from '@testing-library/react-native';
import {QueryClient, QueryClientProvider} from '@tanstack/react-query';
import React from 'react';
import {useMfaMutation} from '../queries/useMfaMutation';
import {TwoFactorRequest, TwoFactorResponse} from '../../types/Login';

// Mock dependencies
jest.mock('@/clients/authApi', () => ({
  post: jest.fn(),
}));

jest.mock('@/utils/tokenRefresh', () => ({
  storeTokens: jest.fn(),
}));

jest.mock('@/utils/asyncStorage', () => ({
  getTwoFactorTrustId: jest.fn(),
  setTwoFactorTrustId: jest.fn(),
}));

jest.mock('@/utils/runtimeConfig', () => ({
  runtimeConfig: {
    APP_API_AUTH_URL: 'https://auth-api.test.com',
  },
}));

const mockAuthApi = require('@/clients/authApi');
const mockTokenRefresh = require('@/utils/tokenRefresh');
const mockAsyncStorage = require('@/utils/asyncStorage');

// Test wrapper component
const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: {retry: false},
      mutations: {retry: false},
    },
  });

  return ({children}: {children: React.ReactNode}) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );
};

describe('useMfaMutation', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Token storage (first if condition)', () => {
    it('should store tokens when both token and refreshToken exist', async () => {
      const mockResponse: TwoFactorResponse = {
        token: 'auth-token-123',
        refreshToken: 'refresh-token-456',
        refreshTokenId: 'refresh-id-789',
        tokenExpirationInstant: 1234567890,
        trustToken: 'trust-token-abc',
        user: {} as TwoFactorResponse['user'],
      };

      mockAuthApi.post.mockResolvedValue({data: mockResponse});

      const wrapper = createWrapper();
      const {result} = renderHook(() => useMfaMutation(), {wrapper});

      const payload: TwoFactorRequest = {
        twoFactorId: 'test-2fa-id',
        code: '123456',
      };

      await act(async () => {
        result.current.mutate(payload);
      });

      // Should store tokens when both exist
      expect(mockTokenRefresh.storeTokens).toHaveBeenCalledWith(
        'auth-token-123',
        'refresh-token-456',
      );
      expect(mockTokenRefresh.storeTokens).toHaveBeenCalledTimes(1);
    });

    it('should NOT store tokens when token is missing', async () => {
      const mockResponse: Partial<TwoFactorResponse> = {
        // token is missing
        refreshToken: 'refresh-token-456',
        refreshTokenId: 'refresh-id-789',
        tokenExpirationInstant: 1234567890,
        trustToken: 'trust-token-abc',
        user: {} as TwoFactorResponse['user'],
      };

      mockAuthApi.post.mockResolvedValue({data: mockResponse});

      const wrapper = createWrapper();
      const {result} = renderHook(() => useMfaMutation(), {wrapper});

      const payload: TwoFactorRequest = {
        twoFactorId: 'test-2fa-id',
        code: '123456',
      };

      await act(async () => {
        result.current.mutate(payload);
      });

      // Should NOT store tokens when token is missing
      expect(mockTokenRefresh.storeTokens).not.toHaveBeenCalled();
    });

    it('should NOT store tokens when refreshToken is missing', async () => {
      const mockResponse: Partial<TwoFactorResponse> = {
        token: 'auth-token-123',
        // refreshToken is missing
        refreshTokenId: 'refresh-id-789',
        tokenExpirationInstant: 1234567890,
        trustToken: 'trust-token-abc',
        user: {} as TwoFactorResponse['user'],
      };

      mockAuthApi.post.mockResolvedValue({data: mockResponse});

      const wrapper = createWrapper();
      const {result} = renderHook(() => useMfaMutation(), {wrapper});

      const payload: TwoFactorRequest = {
        twoFactorId: 'test-2fa-id',
        code: '123456',
      };

      await act(async () => {
        result.current.mutate(payload);
      });

      // Should NOT store tokens when refreshToken is missing
      expect(mockTokenRefresh.storeTokens).not.toHaveBeenCalled();
    });
  });

  describe('Trust computer (second if condition)', () => {
    it('should store trust data when all conditions are met and no existing data', async () => {
      const mockResponse: TwoFactorResponse = {
        token: 'auth-token-123',
        refreshToken: 'refresh-token-456',
        refreshTokenId: 'refresh-id-789',
        twoFactorTrustId: 'trust-id-xyz', // Required for trust logic
        tokenExpirationInstant: 1234567890,
        trustToken: 'trust-token-abc',
        user: {} as TwoFactorResponse['user'],
      };

      mockAuthApi.post.mockResolvedValue({data: mockResponse});
      mockAsyncStorage.getTwoFactorTrustId.mockResolvedValue(null); // No existing data

      const wrapper = createWrapper();
      const {result} = renderHook(() => useMfaMutation(), {wrapper});

      const payload: TwoFactorRequest = {
        twoFactorId: 'test-2fa-id',
        code: '123456',
        trustComputer: true, // Required for trust logic
        userEmail: 'test@example.com', // Required for trust logic
      };

      await act(async () => {
        result.current.mutate(payload);
      });

      // Should create new trust data object
      expect(mockAsyncStorage.getTwoFactorTrustId).toHaveBeenCalled();
      expect(mockAsyncStorage.setTwoFactorTrustId).toHaveBeenCalledWith(
        JSON.stringify({
          'test@example.com': 'trust-id-xyz',
        }),
      );
    });

    it('should merge with existing trust data when all conditions are met', async () => {
      const mockResponse: TwoFactorResponse = {
        token: 'auth-token-123',
        refreshToken: 'refresh-token-456',
        refreshTokenId: 'refresh-id-789',
        twoFactorTrustId: 'trust-id-new',
        tokenExpirationInstant: 1234567890,
        trustToken: 'trust-token-abc',
        user: {} as TwoFactorResponse['user'],
      };

      const existingTrustData = {
        'old@example.com': 'old-trust-id',
        'another@example.com': 'another-trust-id',
      };

      mockAuthApi.post.mockResolvedValue({data: mockResponse});
      mockAsyncStorage.getTwoFactorTrustId.mockResolvedValue(
        JSON.stringify(existingTrustData),
      ); // Existing data

      const wrapper = createWrapper();
      const {result} = renderHook(() => useMfaMutation(), {wrapper});

      const payload: TwoFactorRequest = {
        twoFactorId: 'test-2fa-id',
        code: '123456',
        trustComputer: true,
        userEmail: 'new@example.com',
      };

      await act(async () => {
        result.current.mutate(payload);
      });

      // Should merge with existing data
      expect(mockAsyncStorage.setTwoFactorTrustId).toHaveBeenCalledWith(
        JSON.stringify({
          'old@example.com': 'old-trust-id',
          'another@example.com': 'another-trust-id',
          'new@example.com': 'trust-id-new', // New entry added
        }),
      );
    });

    it('should NOT store trust data when twoFactorTrustId is missing', async () => {
      const mockResponse: TwoFactorResponse = {
        token: 'auth-token-123',
        refreshToken: 'refresh-token-456',
        refreshTokenId: 'refresh-id-789',
        // twoFactorTrustId is missing
        tokenExpirationInstant: 1234567890,
        trustToken: 'trust-token-abc',
        user: {} as TwoFactorResponse['user'],
      };

      mockAuthApi.post.mockResolvedValue({data: mockResponse});

      const wrapper = createWrapper();
      const {result} = renderHook(() => useMfaMutation(), {wrapper});

      const payload: TwoFactorRequest = {
        twoFactorId: 'test-2fa-id',
        code: '123456',
        trustComputer: true,
        userEmail: 'test@example.com',
      };

      await act(async () => {
        result.current.mutate(payload);
      });

      // Should NOT handle trust data
      expect(mockAsyncStorage.getTwoFactorTrustId).not.toHaveBeenCalled();
      expect(mockAsyncStorage.setTwoFactorTrustId).not.toHaveBeenCalled();
    });

    it('should NOT store trust data when trustComputer is false', async () => {
      const mockResponse: TwoFactorResponse = {
        token: 'auth-token-123',
        refreshToken: 'refresh-token-456',
        refreshTokenId: 'refresh-id-789',
        twoFactorTrustId: 'trust-id-xyz',
        tokenExpirationInstant: 1234567890,
        trustToken: 'trust-token-abc',
        user: {} as TwoFactorResponse['user'],
      };

      mockAuthApi.post.mockResolvedValue({data: mockResponse});

      const wrapper = createWrapper();
      const {result} = renderHook(() => useMfaMutation(), {wrapper});

      const payload: TwoFactorRequest = {
        twoFactorId: 'test-2fa-id',
        code: '123456',
        trustComputer: false, // Trust computer disabled
        userEmail: 'test@example.com',
      };

      await act(async () => {
        result.current.mutate(payload);
      });

      // Should NOT handle trust data
      expect(mockAsyncStorage.getTwoFactorTrustId).not.toHaveBeenCalled();
      expect(mockAsyncStorage.setTwoFactorTrustId).not.toHaveBeenCalled();
    });

    it('should NOT store trust data when userEmail is missing', async () => {
      const mockResponse: TwoFactorResponse = {
        token: 'auth-token-123',
        refreshToken: 'refresh-token-456',
        refreshTokenId: 'refresh-id-789',
        twoFactorTrustId: 'trust-id-xyz',
        tokenExpirationInstant: 1234567890,
        trustToken: 'trust-token-abc',
        user: {} as TwoFactorResponse['user'],
      };

      mockAuthApi.post.mockResolvedValue({data: mockResponse});

      const wrapper = createWrapper();
      const {result} = renderHook(() => useMfaMutation(), {wrapper});

      const payload: TwoFactorRequest = {
        twoFactorId: 'test-2fa-id',
        code: '123456',
        trustComputer: true,
        // userEmail is missing
      };

      await act(async () => {
        result.current.mutate(payload);
      });

      // Should NOT handle trust data
      expect(mockAsyncStorage.getTwoFactorTrustId).not.toHaveBeenCalled();
      expect(mockAsyncStorage.setTwoFactorTrustId).not.toHaveBeenCalled();
    });
  });

  describe('Combined scenarios', () => {
    it('should handle both token storage AND trust data when all conditions are met', async () => {
      const mockResponse: TwoFactorResponse = {
        token: 'auth-token-123',
        refreshToken: 'refresh-token-456',
        refreshTokenId: 'refresh-id-789',
        twoFactorTrustId: 'trust-id-xyz',
        tokenExpirationInstant: 1234567890,
        trustToken: 'trust-token-abc',
        user: {} as TwoFactorResponse['user'],
      };

      mockAuthApi.post.mockResolvedValue({data: mockResponse});
      mockAsyncStorage.getTwoFactorTrustId.mockResolvedValue(null);

      const wrapper = createWrapper();
      const {result} = renderHook(() => useMfaMutation(), {wrapper});

      const payload: TwoFactorRequest = {
        twoFactorId: 'test-2fa-id',
        code: '123456',
        trustComputer: true,
        userEmail: 'test@example.com',
      };

      await act(async () => {
        result.current.mutate(payload);
      });

      // Should handle BOTH token storage AND trust data
      expect(mockTokenRefresh.storeTokens).toHaveBeenCalledWith(
        'auth-token-123',
        'refresh-token-456',
      );
      expect(mockAsyncStorage.setTwoFactorTrustId).toHaveBeenCalledWith(
        JSON.stringify({
          'test@example.com': 'trust-id-xyz',
        }),
      );
    });

    it('should call API with correct parameters', async () => {
      const mockResponse: TwoFactorResponse = {
        token: 'auth-token-123',
        refreshToken: 'refresh-token-456',
        refreshTokenId: 'refresh-id-789',
        tokenExpirationInstant: 1234567890,
        trustToken: 'trust-token-abc',
        user: {
          active: true,
          email: 'test@example.com',
          firstName: 'Test',
          lastName: 'User',
        } as TwoFactorResponse['user'],
      };

      mockAuthApi.post.mockResolvedValue({data: mockResponse});

      const wrapper = createWrapper();
      const {result} = renderHook(() => useMfaMutation(), {wrapper});

      const payload: TwoFactorRequest = {
        twoFactorId: 'test-2fa-id',
        code: '123456',
        trustComputer: true,
        userEmail: 'test@example.com',
      };

      await act(async () => {
        result.current.mutate(payload);
      });

      // Should call API with correct parameters
      expect(mockAuthApi.post).toHaveBeenCalledWith(
        'https://auth-api.test.com/api/two-factor/login',
        payload,
      );
    });
  });
});
