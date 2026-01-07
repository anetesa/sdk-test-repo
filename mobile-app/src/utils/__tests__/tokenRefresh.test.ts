import {
  getStoredTokens,
  storeTokens,
  clearTokens,
  refreshAuthToken,
} from '../tokenRefresh';

// Mock the logger
jest.mock('../logger');

// Mock react-native-keychain
jest.mock('react-native-keychain', () => ({
  getGenericPassword: jest.fn(),
  setGenericPassword: jest.fn(),
  resetGenericPassword: jest.fn(),
}));

// Mock fetch
global.fetch = jest.fn();

// Mock runtimeConfig
jest.mock('../runtimeConfig', () => ({
  runtimeConfig: {
    APP_API_AUTH_URL: 'https://api.example.com',
    APP_FUSIONAUTH_TENANT_ID: 'test-tenant-id',
  },
}));

const mockFetch = global.fetch as jest.MockedFunction<typeof fetch>;

describe('tokenRefresh', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('getStoredTokens', () => {
    const mockKeychain = require('react-native-keychain');

    it('should return tokens when they exist', async () => {
      mockKeychain.getGenericPassword.mockResolvedValue({
        password: JSON.stringify({
          authToken: 'test-auth-token',
          refreshToken: 'test-refresh-token',
        }),
        username: 'tokens',
      });

      const result = await getStoredTokens();

      expect(result).toEqual({
        authToken: 'test-auth-token',
        refreshToken: 'test-refresh-token',
      });
    });

    it('should return null when no tokens exist', async () => {
      mockKeychain.getGenericPassword.mockResolvedValue(null);

      const result = await getStoredTokens();

      expect(result).toBeNull();
    });

    it('should return null on error', async () => {
      mockKeychain.getGenericPassword.mockRejectedValue(
        new Error('Keychain error'),
      );

      const result = await getStoredTokens();

      expect(result).toBeNull();

      // Get the mocked logger
      const {logger} = require('../logger');
      expect(logger.error).toHaveBeenCalledWith(
        expect.any(Error),
        'Error getting stored tokens',
      );
    });
  });

  describe('storeTokens', () => {
    const mockKeychain = require('react-native-keychain');

    it('should store tokens successfully', async () => {
      mockKeychain.setGenericPassword.mockResolvedValue(true);

      await storeTokens('auth-token', 'refresh-token');

      expect(mockKeychain.setGenericPassword).toHaveBeenCalledWith(
        'tokens',
        JSON.stringify({
          authToken: 'auth-token',
          refreshToken: 'refresh-token',
        }),
      );
    });

    it('should throw error when storage fails', async () => {
      const error = new Error('Storage failed');
      mockKeychain.setGenericPassword.mockRejectedValue(error);

      await expect(storeTokens('auth-token', 'refresh-token')).rejects.toThrow(
        'Storage failed',
      );

      // Get the mocked logger
      const {logger} = require('../logger');
      expect(logger.error).toHaveBeenCalledWith(error, 'Error storing tokens');
    });
  });

  describe('clearTokens', () => {
    const mockKeychain = require('react-native-keychain');

    it('should clear tokens successfully', async () => {
      mockKeychain.getGenericPassword.mockResolvedValue({
        password: JSON.stringify({
          authToken: 'test-auth-token',
          refreshToken: 'test-refresh-token',
        }),
        username: 'tokens',
      });
      mockKeychain.resetGenericPassword.mockResolvedValue(true);

      await clearTokens();

      expect(mockKeychain.getGenericPassword).toHaveBeenCalled();
      expect(mockKeychain.resetGenericPassword).toHaveBeenCalled();
    });

    it('should throw error when clearing fails', async () => {
      const error = new Error('Clear failed');
      mockKeychain.getGenericPassword.mockResolvedValue({
        password: JSON.stringify({
          authToken: 'test-auth-token',
          refreshToken: 'test-refresh-token',
        }),
        username: 'tokens',
      });
      mockKeychain.resetGenericPassword.mockRejectedValue(error);

      await expect(clearTokens()).rejects.toThrow('Clear failed');

      // Get the mocked logger
      const {logger} = require('../logger');
      expect(logger.error).toHaveBeenCalledWith(error, 'Error clearing tokens');
    });
  });

  describe('refreshAuthToken', () => {
    const mockKeychain = require('react-native-keychain');

    beforeEach(() => {
      // Mock existing tokens
      mockKeychain.getGenericPassword.mockResolvedValue({
        password: JSON.stringify({
          authToken: 'old-auth-token',
          refreshToken: 'valid-refresh-token',
        }),
        username: 'tokens',
      });
    });

    it('should successfully refresh tokens', async () => {
      const mockResponse = {
        token: 'new-auth-token',
        refreshToken: 'new-refresh-token',
        refreshTokenId: 'new-refresh-id',
      };

      mockFetch.mockResolvedValue({
        ok: true,
        json: () => Promise.resolve(mockResponse),
      } as Response);

      mockKeychain.setGenericPassword.mockResolvedValue(true);

      const result = await refreshAuthToken();

      expect(result).toBe('new-auth-token');
      expect(mockFetch).toHaveBeenCalledWith(
        'https://api.example.com/api/jwt/refresh',
        expect.objectContaining({
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-FusionAuth-TenantId': 'test-tenant-id',
          },
          body: JSON.stringify({
            refreshToken: 'valid-refresh-token',
            token: 'old-auth-token',
          }),
        }),
      );
    });

    it('should throw error when no refresh token is available', async () => {
      mockKeychain.getGenericPassword.mockResolvedValue(null);

      await expect(refreshAuthToken()).rejects.toThrow(
        'No refresh token available',
      );
    });

    it('should throw error when refresh request fails', async () => {
      mockFetch.mockResolvedValue({
        ok: false,
        status: 401,
        json: () => Promise.reject(new Error('Bad Request')),
      } as Response);

      await expect(refreshAuthToken()).rejects.toThrow('Bad Request');
    });

    it('should handle network errors', async () => {
      const networkError = new Error('Network error');
      mockFetch.mockRejectedValue(networkError);

      await expect(refreshAuthToken()).rejects.toThrow('Network error');
    });
  });
});
