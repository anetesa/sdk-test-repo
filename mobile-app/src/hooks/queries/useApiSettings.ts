import {useQuery} from '@tanstack/react-query';
import {ApiSettings} from '@/types/ApiSettings';
import {useUserStore} from '@/stores/userStore';

import {QUERY_KEYS} from '@/constants/queryKeys';
import {fetchApiSettings} from '@/services/settingsService';

export function useApiSettings(enabled: boolean = true) {
  const userId = useUserStore(state => state.id);

  return useQuery<ApiSettings, Error>({
    queryKey: QUERY_KEYS.API_SETTINGS,
    queryFn: () => fetchApiSettings(),
    enabled: enabled,
    onError: error => {
      const status = (error as any)?.response?.status;
      if (!userId && status === 401) {
        return;
      }
      console.error('Error fetching merchant settings:', error);
    },
  });
}
