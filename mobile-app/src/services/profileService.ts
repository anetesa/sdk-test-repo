import {apiClient} from '@/clients/apiClient';
import type {MeProfileResponse} from '@/types/Login';

export async function fetchMeProfile(): Promise<MeProfileResponse> {
  const response = await apiClient.get('/api/Me/profile');
  return response.data;
}
