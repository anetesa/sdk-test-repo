import {useQuery} from '@tanstack/react-query';
import {MerchantIdSettings} from '@/types/MerchantIdSettings';
import {useUserStore} from '@/stores/userStore';

import {createQueryKey} from '@/constants/queryKeys';
import {fetchMerchantSettings} from '@/services/merchantService';

export function useMerchantSettings(merchantId?: string) {
  const userId = useUserStore(state => state.id);

  return useQuery<MerchantIdSettings, Error>({
    queryKey: createQueryKey.merchantSettings(merchantId || ''),
    queryFn: () => fetchMerchantSettings(merchantId || ''),
    enabled: !!merchantId,
    onError: error => {
      const status = (error as any)?.response?.status;
      if (!userId && status === 401) {
        return;
      }
      console.error('Error fetching merchant settings:', error);
    },
    select: response => {
      return {
        ...response,
        merchantSettings: {
          ...response.merchantSettings,
          isSurchargeEnabled:
            typeof response?.merchantSettings?.defaultSurchargeRate ===
            'number',
          isCashDiscountEnabled:
            typeof response?.merchantSettings?.defaultCashDiscountRate ===
            'number',
          isDualPricingEnabled:
            typeof response?.merchantSettings?.defaultDualPricingRate ===
            'number',
        },
      };
    },
  });
}
