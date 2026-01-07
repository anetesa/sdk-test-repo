import {useQuery, useMutation, UseQueryResult} from '@tanstack/react-query';
import {useUserStore} from '@/stores/userStore';
import {getOrCreateDeviceId} from '@/utils/deviceUtils';
import {logger} from '@/utils/logger';
import {DeviceTapToPayStatusStringEnumType} from '@/dictionaries/DeviceTapToPayStatus';
import {
  activateTapToPay,
  fetchTapToPayDeviceStatus,
  requestTapToPay,
  type DeviceStatusResponse,
  type RequestTapToPayResponse,
} from '@/services/tapToPayService';

// Status is fetched locally from the SDK, but we still keep a short staleTime to avoid
// multiple refetches in quick succession when navigating/mounting.
const TAP_TO_PAY_STATUS_STALE_TIME = 500;
const TAP_TO_PAY_STATUS_RETRY = 2;

type UseDeviceStatusResult = UseQueryResult<DeviceStatusResponse, Error> & {
  isActive: boolean;
};

/**
 * Hook for checking Tap to Pay device status.
 * Exposes the full React Query result plus an isActive helper flag.
 */
export const useDeviceStatus = (): UseDeviceStatusResult => {
  const merchantId = useUserStore(state => state.merchantId);

  const query = useQuery<DeviceStatusResponse, Error>({
    queryKey: ['tap-to-pay-device-status'],
    queryFn: fetchTapToPayDeviceStatus,
    enabled: !!merchantId,
    staleTime: TAP_TO_PAY_STATUS_STALE_TIME,
    // Ensure we don't keep showing cached status when returning to a screen/component.
    refetchOnMount: true,
    retry: TAP_TO_PAY_STATUS_RETRY,
    onError: error => {
      console.error('Error fetching device status for Tap to Pay:', error);
    },
  });

  const isActive =
    query.data?.tapToPayStatus === DeviceTapToPayStatusStringEnumType.Active;

  return {
    ...query,
    isActive: !!isActive,
  };
};

/**
 * Hook to activate Tap to Pay
 */
export const useActivateTapToPay = () => {
  return useMutation<void, Error>({
    mutationFn: async () => {
      logger.info('Activating Tap to Pay');
      await activateTapToPay();
      logger.info('✅ Tap to Pay activated successfully');
    },
    onError: error => {
      logger.error(error, 'Failed to activate Tap to Pay');
    },
  });
};

/**
 * Hook to request Tap to Pay (change status to Requested)
 */
export const useRequestTapToPay = () => {
  return useMutation<RequestTapToPayResponse, Error>({
    mutationFn: async () => {
      const currentMerchantId = useUserStore.getState().merchantId;
      if (!currentMerchantId) {
        throw new Error('Merchant ID not available');
      }

      const deviceId = await getOrCreateDeviceId();
      if (!deviceId) {
        throw new Error('Device ID not available');
      }

      logger.info('Requesting Tap to Pay', {
        merchantId: currentMerchantId,
        deviceId,
      });

      const response = await requestTapToPay({
        merchantId: currentMerchantId,
        deviceId,
      });

      logger.info('✅ Tap to Pay requested successfully');
      return response;
    },
    onError: error => {
      logger.error(error, 'Failed to request Tap to Pay');
    },
  });
};
