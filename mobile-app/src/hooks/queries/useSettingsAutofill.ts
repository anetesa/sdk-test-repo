import {useQuery} from '@tanstack/react-query';

import {createQueryKey} from '@/constants/queryKeys';
import type {SettingsAutofill} from '@/types/SettingsAutofill';
import {fetchSettingsAutofill} from '@/services/settingsAutofillService';

export function useSettingsAutofill(merchantId: string | undefined) {
  return useQuery<SettingsAutofill, Error>({
    queryKey: createQueryKey.settingsAutofill(merchantId || ''),
    queryFn: () => fetchSettingsAutofill(merchantId || ''),
    onError: error => {
      console.error('Error fetching settings autofill:', error);
    },
  });
}
