import {apiClient} from '@/clients/apiClient';

export async function fetchTransactionsTodayCount(): Promise<{count: number}> {
  const response = await apiClient.get('/api/transactions/today-count');
  return response.data;
}

export async function fetchSalesTodayTotal(): Promise<{sales: number}> {
  const response = await apiClient.get('/api/transactions/sales/total-today');
  return response.data;
}
