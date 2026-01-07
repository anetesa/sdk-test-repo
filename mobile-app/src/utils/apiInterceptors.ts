import {AxiosInstance, AxiosResponse, AxiosError} from 'axios';
import {refreshAuthToken, clearTokens, getStoredTokens} from './tokenRefresh';
import {getOrCreateDeviceId} from './deviceUtils';
import {logger} from './logger';
import {getSelectedProfileId} from './profileSelection';
import {QUERY_KEYS} from '@/constants/queryKeys';
import {queryClient} from './queryClient';
import AriseMobileSdk from '@/native/AriseMobileSdk';

export const setupDeviceHeaders = (apiClient: AxiosInstance) => {
  apiClient.interceptors.request.use(async config => {
    config.headers = config.headers || {};

    try {
      // Only add device header if the SDK is configured and we can fetch a stable deviceId.
      // Avoid throwing or setting an undefined header early in app lifecycle (pre-login).
      if (AriseMobileSdk.isConfigured()) {
        const deviceId = await getOrCreateDeviceId();
        if (deviceId) {
          config.headers['X-ARISE-Trace-DeviceId'] = deviceId;
        }
      }
    } catch (error) {
      logger.error(error, 'Failed to get device ID');
    }

    return config;
  });
};

export const setupProfileHeaders = (apiClient: AxiosInstance) => {
  apiClient.interceptors.request.use(async config => {
    config.headers = config.headers || {};

    try {
      // Get profile data from React Query cache
      const profileData = queryClient.getQueryData(
        QUERY_KEYS.ME_PROFILE,
      ) as any;

      // Calculate profile ID using merchantId + find logic
      const selectedProfileId = getSelectedProfileId(profileData);
      if (selectedProfileId) {
        config.headers['x-arise-trace-userprofileid'] = selectedProfileId;
      }
    } catch (error) {
      logger.error(error, 'Failed to get selected profile ID for headers');
    }

    return config;
  });
};

export const setupAuthInterceptors = (apiClient: AxiosInstance) => {
  // Request interceptor to add auth token
  apiClient.interceptors.request.use(
    async config => {
      const tokens = await getStoredTokens();
      if (tokens?.authToken) {
        config.headers = config.headers || {};
        config.headers.Authorization = `Bearer ${tokens.authToken}`;
      }
      return config;
    },
    error => Promise.reject(error),
  );

  // Response interceptor to handle 401/403 errors
  apiClient.interceptors.response.use(
    (response: AxiosResponse) => response,
    async (error: AxiosError) => {
      const originalRequest = error.config as any;

      if (
        (error.response?.status === 401 || error.response?.status === 403) &&
        !originalRequest._retry
      ) {
        // If there's no refresh token (common right after logout), don't attempt refresh.
        // Also avoid noisy auth logs in that scenario.
        const tokens = await getStoredTokens();
        if (!tokens?.refreshToken) {
          return Promise.reject(error);
        }

        originalRequest._retry = true;

        // Log auth errors only when we can actually refresh (i.e., session likely still active)
        logger.info(
          `🔐 Auth error detected: ${error.response.status} for ${originalRequest.url}`,
        );
        logger.info(`🔄 Retry flag: ${originalRequest._retry}`);
        logger.info(
          `🔄 Attempting token refresh for ${error.response.status} error`,
        );

        try {
          const newToken = await refreshAuthToken();
          logger.info('✅ Token refreshed successfully, retrying request');
          originalRequest.headers.Authorization = `Bearer ${newToken}`;
          return apiClient(originalRequest);
        } catch (refreshError) {
          logger.error(refreshError, 'Token refresh failed');
          // Clear tokens and redirect to login
          await clearTokens();
          return Promise.reject(error);
        }
      }

      return Promise.reject(error);
    },
  );
};
