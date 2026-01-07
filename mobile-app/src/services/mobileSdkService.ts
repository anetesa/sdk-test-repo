import {apiClient} from '@/clients/apiClient';
import {logger} from '@/utils/logger';

interface MobileSdkCredentials {
  clientId: string;
  clientSecret: string;
}

export const getMobileSdkCredentials = async (
  merchantId: string,
): Promise<MobileSdkCredentials> => {
  try {
    const response = await apiClient.get<MobileSdkCredentials>(
      `/api/merchants/${merchantId}/tokens/mobile-sdk`,
    );
    return response.data;
  } catch (error) {
    logger.error(
      error,
      'Error fetching Mobile SDK credentials',
      'getMobileSdkCredentials',
    );
    throw error;
  }
};
