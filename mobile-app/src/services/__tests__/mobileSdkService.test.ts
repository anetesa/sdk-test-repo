import {getMobileSdkCredentials} from '../mobileSdkService';
import {apiClient} from '@/clients/apiClient';
import {logger} from '@/utils/logger';

// Mock dependencies
jest.mock('@/clients/apiClient');
jest.mock('@/utils/logger');

describe('mobileSdkService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('getMobileSdkCredentials', () => {
    it('should fetch credentials successfully', async () => {
      const merchantId = 'test-merchant-id';
      const mockResponse = {
        data: {
          clientId: 'client-id',
          clientSecret: 'client-secret',
        },
      };

      (apiClient.get as jest.Mock).mockResolvedValue(mockResponse);

      const result = await getMobileSdkCredentials(merchantId);

      expect(apiClient.get).toHaveBeenCalledWith(
        `/api/merchants/${merchantId}/tokens/mobile-sdk`,
      );
      expect(result).toEqual(mockResponse.data);
    });

    it('should log error and throw when request fails', async () => {
      const merchantId = 'test-merchant-id';
      const mockError = new Error('Network error');

      (apiClient.get as jest.Mock).mockRejectedValue(mockError);

      await expect(getMobileSdkCredentials(merchantId)).rejects.toThrow(
        mockError,
      );

      expect(logger.error).toHaveBeenCalledWith(
        mockError,
        'Error fetching Mobile SDK credentials',
        'getMobileSdkCredentials',
      );
    });
  });
});

