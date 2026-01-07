import {apiClient} from '@/clients/apiClient';
import type {ApiSettings} from '@/types/ApiSettings';

export async function fetchApiSettings(): Promise<ApiSettings> {
  const response = await apiClient.get('/api/Settings');
  return response.data;
}
