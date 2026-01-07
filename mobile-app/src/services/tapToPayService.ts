import {apiClient} from '@/clients/apiClient';
import AriseMobileSdk from '@/native/AriseMobileSdk';
import {getOrCreateDeviceId} from '@/utils/deviceUtils';
import {DeviceTapToPayStatusStringEnumType} from '@/dictionaries/DeviceTapToPayStatus';
import {logger} from '@/utils/logger';

export interface DeviceStatusResponse {
  tapToPayStatus?: DeviceTapToPayStatusStringEnumType | null;
}

export interface RequestTapToPayResponse {
  requestId: string;
}

export async function fetchTapToPayDeviceStatus(): Promise<DeviceStatusResponse> {
  logger.info('Fetching Tap to Pay devices from Arise TTP SDK');

  // Source of truth: server-backed device status via getDeviceInfo()
  let serverStatus: DeviceTapToPayStatusStringEnumType | null = null;

  if (AriseMobileSdk.isConfigured()) {
    try {
      const deviceId = await getOrCreateDeviceId();
      if (deviceId) {
        const deviceInfo = await AriseMobileSdk.getDeviceInfo(deviceId);
        const rawServerStatusId = deviceInfo?.tapToPayStatusId;

        // Map server IDs: Inactive=0, Requested=1, Approved=2, Active=3, Denied=4
        const mapped: Record<number, DeviceTapToPayStatusStringEnumType> = {
          0: DeviceTapToPayStatusStringEnumType.Inactive,
          1: DeviceTapToPayStatusStringEnumType.Requested,
          2: DeviceTapToPayStatusStringEnumType.Approved,
          3: DeviceTapToPayStatusStringEnumType.Active,
          4: DeviceTapToPayStatusStringEnumType.Denied,
        };

        serverStatus =
          typeof rawServerStatusId === 'number'
            ? mapped[rawServerStatusId] ?? null
            : null;
      }
      logger.info('✅ Arise SDK TTP Status (server):', serverStatus);
    } catch (error) {
      logger.error(error, 'Failed to get Arise SDK TTP Status');
    }
  } else {
    logger.info(
      'ℹ️ Arise SDK not configured yet (called before login), defaulting to Inactive',
    );
  }

  return {
    tapToPayStatus: serverStatus ?? DeviceTapToPayStatusStringEnumType.Inactive,
  };
}

export async function requestTapToPay(params: {
  merchantId: string;
  deviceId: string;
}): Promise<RequestTapToPayResponse> {
  const response = await apiClient.post<RequestTapToPayResponse>(
    `/api/merchants/${params.merchantId}/devices/${params.deviceId}/tap-to-pay/requests`,
    {deviceId: params.deviceId},
  );
  return response.data;
}

export async function activateTapToPay(): Promise<void> {
  await AriseMobileSdk.ttp.activate();
}
