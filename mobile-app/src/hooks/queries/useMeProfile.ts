import {useQuery} from '@tanstack/react-query';
import {MeProfileResponse} from '@/types/Login';
import {Alert} from 'react-native';
import {clearSession} from '@/utils/clearSession';
import {useUserStore} from '@/stores/userStore';

import {QUERY_KEYS} from '@/constants/queryKeys';
import {ALERT_MESSAGES} from '@/constants/messages';
import {CACHE_TIMES} from '@/constants/timing';
import {fetchMeProfile} from '@/services/profileService';

export function useMeProfile({
  enabled = true,
  forceFresh = false,
}: {
  enabled?: boolean;
  forceFresh?: boolean;
} = {}) {
  const userId = useUserStore(state => state.id);

  return useQuery<MeProfileResponse, Error>({
    queryKey: QUERY_KEYS.ME_PROFILE,
    queryFn: fetchMeProfile,
    enabled,
    staleTime: forceFresh ? CACHE_TIMES.NO_CACHE : CACHE_TIMES.PROFILE_STALE,
    cacheTime: forceFresh ? CACHE_TIMES.NO_CACHE : CACHE_TIMES.PROFILE_CACHE,
    refetchOnMount: forceFresh ? true : false, // Always refetch on mount if forceFresh
    onSuccess: data => {
      if (data.userTypeId !== 2) {
        clearSession();
        Alert.alert(
          ALERT_MESSAGES.ACCESS_DENIED,
          ALERT_MESSAGES.MERCHANT_ONLY,
          [{text: 'OK'}],
        );
        throw new Error('User is not a merchant');
      }
    },
    onError: error => {
      const status = (error as any)?.response?.status;
      if (!userId && status === 401) {
        // Common after logout: in-flight queries finish with 401. Avoid noisy logs.
        return;
      }
      console.error('Error fetching profile:', error);
    },
  });
}
