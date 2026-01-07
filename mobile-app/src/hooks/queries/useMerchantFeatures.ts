import {useQuery} from '@tanstack/react-query';
import {Feature} from '@/types/Feature';
import {useUserStore} from '@/stores/userStore';

import {createQueryKey} from '@/constants/queryKeys';
import {fetchMerchantFeatures} from '@/services/merchantService';

export function useMerchantFeatures(merchantId?: string) {
  const userId = useUserStore(state => state.id);

  return useQuery<Feature, Error>({
    queryKey: createQueryKey.merchantFeatures(merchantId || ''),
    queryFn: () => fetchMerchantFeatures(merchantId || ''),
    enabled: !!merchantId,
    onError: error => {
      const status = (error as any)?.response?.status;
      if (!userId && status === 401) {
        return;
      }
      console.error('Error fetching merchant features:', error);
    },
  });
}
