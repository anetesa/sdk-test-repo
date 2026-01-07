import {useUserStore} from '@/stores/userStore';
import {resetAsyncStorageSession} from '@/utils/asyncStorage';
import {clearTokens} from '@/utils/tokenRefresh';
import {useTransactionStore} from '@/stores/transactionStore';
import {useAlertStore} from '@/stores/alertStore';
import {logger} from './logger';
import {useCloudCommerceStore} from '@/stores/cloudCommerceStore';
import {queryClient} from '@/utils/queryClient';

export const clearSession = async (): Promise<void> => {
  try {
    // Stop in-flight queries/mutations before clearing tokens to avoid 401->refresh loops during logout
    await queryClient.cancelQueries();
    // Clear AsyncStorage data
    await resetAsyncStorageSession();
    // Clear tokens from Keychain
    await clearTokens();

    // Clear CloudCommerce/Arise SDK native session (crucial for deviceId reset)
    try {
      await useCloudCommerceStore.getState().clearTerminal();
    } catch (e) {
      logger.error(e, 'Failed to clear terminal session during logout');
    }

    // Clear all zustand stores
    useUserStore.getState().reset();
    useTransactionStore.getState().reset();
    useCloudCommerceStore.getState().reset();
    useAlertStore.getState().hideAllAlerts();
    // Clear React Query cache
    queryClient.clear();
  } catch (error) {
    logger.error(error, 'Error during app reset');
    throw error;
  }
};
