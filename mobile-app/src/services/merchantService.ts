import {apiClient} from '@/clients/apiClient';
import type {MerchantIdSettings} from '@/types/MerchantIdSettings';
import type {Feature} from '@/types/Feature';

export async function fetchMerchantSettings(
  merchantId: string,
): Promise<MerchantIdSettings> {
  const response = await apiClient.get(`/api/Merchants/${merchantId}/settings`);
  return response.data;
}

export async function fetchMerchantFeatures(
  merchantId: string,
): Promise<Feature> {
  const response = await apiClient.get(`/api/Merchants/${merchantId}/features`);
  return response.data;
}
