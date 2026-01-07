import {setupAuthInterceptors, setupDeviceHeaders} from '../apiInterceptors';
import {refreshAuthToken, clearTokens, getStoredTokens} from '../tokenRefresh';
import {getOrCreateDeviceId} from '../deviceUtils';
import axios from 'axios';

jest.mock('../tokenRefresh', () => ({
  refreshAuthToken: jest.fn(),
  clearTokens: jest.fn(),
  getStoredTokens: jest.fn(),
}));

jest.mock('../deviceUtils', () => ({
  getOrCreateDeviceId: jest.fn(),
}));

jest.mock('../logger');

const mockedRefreshAuthToken = refreshAuthToken as jest.MockedFunction<
  typeof refreshAuthToken
>;
const mockedClearTokens = clearTokens as jest.MockedFunction<
  typeof clearTokens
>;
const mockedGetStoredTokens = getStoredTokens as jest.MockedFunction<
  typeof getStoredTokens
>;
const mockedGetOrCreateDeviceId = getOrCreateDeviceId as jest.MockedFunction<
  typeof getOrCreateDeviceId
>;

describe('setupDeviceHeaders', () => {
  let apiClient: any;
  let consoleSpy: jest.SpyInstance;

  beforeEach(() => {
    apiClient = axios.create({
      baseURL: 'https://test-api.com',
    });
    consoleSpy = jest.spyOn(console, 'error').mockImplementation();
    setupDeviceHeaders(apiClient);
    jest.clearAllMocks();
  });

  afterEach(() => {
    consoleSpy.mockRestore();
  });

  describe('Interceptor setup', () => {
    it('should setup device headers interceptor on axios instance', () => {
      // Verify that interceptors were added
      expect(apiClient.interceptors.request.handlers.length).toBeGreaterThan(0);
    });
  });

  describe('Request interceptor functionality', () => {
    it('should add device ID header when device ID is retrieved successfully', async () => {
      const mockDeviceId = 'ABCD1234-5678-9ABC-DEF0-123456789ABC';
      mockedGetOrCreateDeviceId.mockResolvedValue(mockDeviceId);

      // Mock the actual HTTP adapter to avoid real requests
      const mockAdapter = jest.fn().mockResolvedValue({
        data: {success: true},
        status: 200,
        headers: {},
      });

      apiClient.defaults.adapter = mockAdapter;

      await apiClient.get('/test');

      expect(mockedGetOrCreateDeviceId).toHaveBeenCalled();
      expect(mockAdapter).toHaveBeenCalledWith(
        expect.objectContaining({
          headers: expect.objectContaining({
            'X-ARISE-Trace-DeviceId': mockDeviceId,
          }),
        }),
      );
    });

    it('should preserve existing headers when adding device ID', async () => {
      const mockDeviceId = 'ABCD1234-5678-9ABC-DEF0-123456789ABC';
      mockedGetOrCreateDeviceId.mockResolvedValue(mockDeviceId);

      const mockAdapter = jest.fn().mockResolvedValue({
        data: {success: true},
        status: 200,
        headers: {},
      });

      apiClient.defaults.adapter = mockAdapter;

      // Make request with existing headers
      await apiClient.get('/test', {
        headers: {
          'Content-Type': 'application/json',
          'Custom-Header': 'custom-value',
        },
      });

      expect(mockAdapter).toHaveBeenCalledWith(
        expect.objectContaining({
          headers: expect.objectContaining({
            'Content-Type': 'application/json',
            'Custom-Header': 'custom-value',
            'X-ARISE-Trace-DeviceId': mockDeviceId,
          }),
        }),
      );
    });

    it('should handle multiple requests with the same device ID', async () => {
      const mockDeviceId = 'ABCD1234-5678-9ABC-DEF0-123456789ABC';
      mockedGetOrCreateDeviceId.mockResolvedValue(mockDeviceId);

      const mockAdapter = jest.fn().mockResolvedValue({
        data: {success: true},
        status: 200,
        headers: {},
      });

      apiClient.defaults.adapter = mockAdapter;

      // Make multiple requests
      await apiClient.get('/test1');
      await apiClient.get('/test2');
      await apiClient.post('/test3');

      // Should call getOrCreateDeviceId for each request
      expect(mockedGetOrCreateDeviceId).toHaveBeenCalledTimes(3);

      // Each request should have the device ID header
      expect(mockAdapter).toHaveBeenCalledTimes(3);
      mockAdapter.mock.calls.forEach(call => {
        expect(call[0].headers['X-ARISE-Trace-DeviceId']).toBe(mockDeviceId);
      });
    });
  });
});

describe('setupAuthInterceptors', () => {
  let apiClient: any;

  beforeEach(() => {
    apiClient = axios.create({
      baseURL: 'https://test-api.com', // Add base URL to avoid URL parsing errors
    });
    setupAuthInterceptors(apiClient);
    jest.clearAllMocks();
  });

  describe('Interceptor setup', () => {
    it('should setup interceptors on axios instance', () => {
      // Verify that interceptors were added
      expect(apiClient.interceptors.request.handlers.length).toBeGreaterThan(0);
      expect(apiClient.interceptors.response.handlers.length).toBeGreaterThan(
        0,
      );
    });
  });

  describe('Request interceptor functionality', () => {
    it('should add Authorization header when token exists', async () => {
      mockedGetStoredTokens.mockResolvedValue({
        authToken: 'test-token',
        refreshToken: 'refresh-token',
      });

      // Mock the actual HTTP adapter to avoid real requests
      const mockAdapter = jest.fn().mockResolvedValue({
        data: {success: true},
        status: 200,
        headers: {},
      });

      apiClient.defaults.adapter = mockAdapter;

      await apiClient.get('/test');

      expect(mockedGetStoredTokens).toHaveBeenCalled();
      expect(mockAdapter).toHaveBeenCalledWith(
        expect.objectContaining({
          headers: expect.objectContaining({
            Authorization: 'Bearer test-token',
          }),
        }),
      );
    });

    it('should not add Authorization header when no token exists', async () => {
      mockedGetStoredTokens.mockResolvedValue(null);

      const mockAdapter = jest.fn().mockResolvedValue({
        data: {success: true},
        status: 200,
        headers: {},
      });

      apiClient.defaults.adapter = mockAdapter;

      await apiClient.get('/test');

      expect(mockedGetStoredTokens).toHaveBeenCalled();
      expect(mockAdapter).toHaveBeenCalledWith(
        expect.objectContaining({
          headers: expect.not.objectContaining({
            Authorization: expect.anything(),
          }),
        }),
      );
    });
  });

  describe('Response interceptor functionality', () => {
    beforeEach(() => {
      mockedGetStoredTokens.mockResolvedValue({
        authToken: 'test-token',
        refreshToken: 'refresh-token',
      });
    });

    it('should handle successful responses normally', async () => {
      const mockAdapter = jest.fn().mockResolvedValue({
        data: {success: true},
        status: 200,
        headers: {},
      });

      apiClient.defaults.adapter = mockAdapter;

      const response = await apiClient.get('/test');

      expect(response.data).toEqual({success: true});
      expect(mockedRefreshAuthToken).not.toHaveBeenCalled();
    });

    it('should attempt token refresh on 401 error', async () => {
      const newToken = 'new-token';
      mockedRefreshAuthToken.mockResolvedValue(newToken);

      const mockAdapter = jest
        .fn()
        .mockRejectedValueOnce({
          response: {status: 401},
          config: {url: '/test', headers: {}},
        })
        .mockResolvedValueOnce({
          data: {success: true, retried: true},
          status: 200,
          headers: {},
        });

      apiClient.defaults.adapter = mockAdapter;

      const response = await apiClient.get('/test');

      expect(mockedRefreshAuthToken).toHaveBeenCalled();

      // Check that logger.info was called with the refresh message
      const {logger} = require('../logger');
      expect(logger.info).toHaveBeenCalledWith(
        expect.stringContaining('🔄 Attempting token refresh'),
      );

      expect(response.data).toEqual({success: true, retried: true});
    });

    it('should pass through non-auth errors', async () => {
      const mockAdapter = jest.fn().mockRejectedValue({
        response: {status: 500},
        config: {url: '/test', headers: {}},
      });

      apiClient.defaults.adapter = mockAdapter;

      try {
        await apiClient.get('/test');
      } catch (error) {
        // Expected to throw
      }

      expect(mockedRefreshAuthToken).not.toHaveBeenCalled();
      expect(mockedClearTokens).not.toHaveBeenCalled();
    });
  });
});
