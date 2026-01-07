import {apiClient} from '@/clients/apiClient';
import type {SettingsAutofill} from '@/types/SettingsAutofill';

export async function fetchSettingsAutofill(
  merchantId: string,
): Promise<SettingsAutofill> {
  const response = await apiClient.get(
    `/api/Merchants/${merchantId}/transaction/settings/autofill`,
    {
      headers: {'Content-Type': 'application/json'},
    },
  );
  return response.data;
}
