import * as Keychain from 'react-native-keychain';
import {runtimeConfig} from './runtimeConfig';
import {logger} from './logger';

interface RefreshTokenResponse {
  token: string;
  refreshToken: string;
  refreshTokenId: string;
}

interface TokenData {
  authToken: string;
  refreshToken: string;
}

let isRefreshing = false;
let failedQueue: Array<{
  resolve: (token: string) => void;
  reject: (error: any) => void;
}> = [];

let clearTokensPromise: Promise<void> | null = null;

const processQueue = (error: any, token: string | null = null) => {
  failedQueue.forEach(({resolve, reject}) => {
    if (error) {
      reject(error);
    } else {
      resolve(token!);
    }
  });

  failedQueue = [];
};

export const getStoredTokens = async (): Promise<TokenData | null> => {
  try {
    const credentials = await Keychain.getGenericPassword();
    if (credentials) {
      const tokens = JSON.parse(credentials.password);
      return tokens;
    }
    return null;
  } catch (error) {
    logger.error(error, 'Error getting stored tokens');
    return null;
  }
};

export const storeTokens = async (
  authToken: string,
  refreshToken: string,
): Promise<void> => {
  try {
    await Keychain.setGenericPassword(
      'tokens',
      JSON.stringify({
        authToken,
        refreshToken,
      }),
    );
  } catch (error) {
    logger.error(error, 'Error storing tokens');
    throw error;
  }
};

export const clearTokens = async (): Promise<void> => {
  if (clearTokensPromise) {
    return clearTokensPromise;
  }

  clearTokensPromise = (async () => {
    try {
      // Avoid noisy duplicate clears (e.g., many concurrent 401s during logout)
      const existing = await Keychain.getGenericPassword();
      if (!existing) {
        return;
      }

      logger.info('🗑️ Clearing all tokens from Keychain');
      await Keychain.resetGenericPassword();
      logger.info('✅ Tokens cleared successfully');
    } catch (error) {
      logger.error(error, 'Error clearing tokens');
      throw error;
    } finally {
      clearTokensPromise = null;
    }
  })();

  return clearTokensPromise;
};

export const refreshAuthToken = async (): Promise<string> => {
  const tokens = await getStoredTokens();

  if (!tokens?.refreshToken) {
    throw new Error('No refresh token available');
  }

  if (isRefreshing) {
    // If we're already refreshing, queue this request
    return new Promise((resolve, reject) => {
      failedQueue.push({resolve, reject});
    });
  }

  isRefreshing = true;

  try {
    const response = await fetch(
      `${runtimeConfig.APP_API_AUTH_URL}/api/jwt/refresh`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-FusionAuth-TenantId': runtimeConfig.APP_FUSIONAUTH_TENANT_ID || '',
        },
        body: JSON.stringify({
          refreshToken: tokens.refreshToken,
          token: tokens.authToken,
        }),
        credentials: 'omit', // Force no cookies to be sent
      },
    );

    if (!response.ok) {
      if (response.status === 400 || response.status === 403) {
        // Refresh token is expired, invalid, or forbidden
        await clearTokens();
      }
    }

    const data: RefreshTokenResponse = await response.json();

    // Store the new tokens
    await storeTokens(data.token, data.refreshToken);

    // Process the queue with the new token
    processQueue(null, data.token);

    return data.token;
  } catch (error) {
    // Process the queue with the error
    logger.error(error, 'Error refreshing auth token');
    processQueue(error, null);
    throw error;
  } finally {
    isRefreshing = false;
  }
};
