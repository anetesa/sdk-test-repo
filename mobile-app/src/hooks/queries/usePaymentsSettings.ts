import {useQuery} from '@tanstack/react-query';
import type {ArisePaymentSettings} from '@/native/AriseMobileSdk';
import {logger} from '@/utils/logger';
import {fetchPaymentSettings} from '@/services/paymentSettingsService';

export const PAYMENT_SETTINGS_QUERY_KEY = ['arise', 'payment-settings'];

type UsePaymentsSettingsOptions = {
  enabled?: boolean;
};

export const usePaymentsSettings = (options?: UsePaymentsSettingsOptions) => {
  return useQuery<ArisePaymentSettings>({
    queryKey: PAYMENT_SETTINGS_QUERY_KEY,
    enabled: options?.enabled ?? true,
    queryFn: async () => {
      const result = await fetchPaymentSettings();
      logger.info(
        'AriseMobileSdk getPaymentSettings succeeded',
        'usePaymentsSettings',
      );
      return result;
    },
    select: response => {
      return {
        ...response,
        isSurchargeEnabled: typeof response?.defaultSurchargeRate === 'number',
        isCashDiscountEnabled:
          typeof response?.defaultCashDiscountRate === 'number',
        isDualPricingEnabled:
          typeof response?.defaultDualPricingRate === 'number',
      };
    },
  });
};
