import {apiClient} from '@/clients/apiClient';

export type TechSupportInfo = {
  email: string;
  phone: string;
};

export async function fetchTechSupport(): Promise<TechSupportInfo> {
  const response = await apiClient.get('/api/TechSupport', {
    headers: {'Content-Type': 'application/json'},
  });
  return response.data;
}
