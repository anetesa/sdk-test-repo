import {useEffect, useState} from 'react';
import {PendoSDK} from 'rn-pendo-sdk';
import {useMerchantSettings} from '@/hooks/queries/useMerchantSettings';
import {useMerchantFeatures} from '@/hooks/queries/useMerchantFeatures';
import {useApiSettings} from '@/hooks/queries/useApiSettings';
import {useMeProfile} from '@/hooks/queries/useMeProfile';
import {usePaymentsSettings} from '@/hooks/queries/usePaymentsSettings';
import {getSelectedProfile} from '@/utils/profileSelection';
import {useUserStore} from '@/stores/userStore';
import {runtimeConfig} from '@/utils/runtimeConfig';
import {initPendo} from '@/utils/pendo';
import {logger} from '@/utils/logger';
import {ZeroCostProcessingType} from '@/dictionaries/ZeroCostProcessingSettings';
import {ArisePaymentSettings} from '@/native/AriseMobileSdk';
interface AVSProfile {
  id: number;
  name: string;
}

export const usePendoSessionManagement = () => {
  const isLoggedIn = Boolean(useUserStore(state => state.id));
  const [merchantId, setMerchantId] = useState<string | undefined>(undefined);
  const {data: meProfile} = useMeProfile({enabled: isLoggedIn});
  const {data: merchantSettings} = useMerchantSettings(merchantId);
  const {data: paymentSettings} = usePaymentsSettings({
    enabled: isLoggedIn,
  });

  const {data: merchantFeatures} = useMerchantFeatures(merchantId);

  const {data: apiSettings, refetch: refetchApiSettings} =
    useApiSettings(isLoggedIn);
  const selectedProfile = getSelectedProfile(meProfile);
  useEffect(() => {
    initPendo();
  }, []);

  const getZCPMode = (settings: ArisePaymentSettings) => {
    const {
      zeroCostProcessingOptionId,
      defaultDualPricingRate,
      defaultCashDiscountRate,
      defaultSurchargeRate,
    } = settings || {};

    //TODO: create a dictionary for these values
    if (zeroCostProcessingOptionId === ZeroCostProcessingType.None) {
      return 'None';
    }
    if (
      zeroCostProcessingOptionId === ZeroCostProcessingType.DualPricing &&
      defaultDualPricingRate
    ) {
      return 'Dual Pricing';
    }
    if (
      zeroCostProcessingOptionId === ZeroCostProcessingType.CashDiscount &&
      defaultCashDiscountRate
    ) {
      return 'Cash Discount';
    }
    if (
      zeroCostProcessingOptionId === ZeroCostProcessingType.Surcharge &&
      defaultSurchargeRate
    ) {
      return 'Surcharge';
    }

    return 'None';
  };

  useEffect(() => {
    if (!isLoggedIn) {
      try {
        const isProduction = runtimeConfig.isProduction();

        PendoSDK.startSession(
          isProduction ? '' : '_staging_',
          undefined,
          undefined,
          undefined,
        );
      } catch (error) {
        logger.error(error, 'Error starting Pendo session');
      }
    }
  }, [isLoggedIn]);

  useEffect(() => {
    if (selectedProfile?.merchantId) {
      setMerchantId(selectedProfile.merchantId);
    }
  }, [selectedProfile]);

  useEffect(() => {
    if (
      isLoggedIn &&
      merchantSettings &&
      merchantFeatures &&
      apiSettings &&
      paymentSettings
    ) {
      try {
        const isProduction = runtimeConfig.isProduction();

        const visitorId = isProduction
          ? meProfile?.id
          : `_staging_${meProfile?.id}`;
        const accountId = selectedProfile?.merchantId || '';
        const visitorData = {
          userType: meProfile?.userType,
          roleName: meProfile?.selectedProfileRoleName,
          isMainContact: selectedProfile?.isMainContact,
        };
        const accountData = {
          accountType: meProfile?.userType,
          mccCode: selectedProfile?.mccCode,
          mccCodeDescription: selectedProfile?.mccCodeDescription,
          mcc: selectedProfile?.mccCode
            ? `${selectedProfile?.mccCode} - ${selectedProfile?.mccCodeDescription}`
            : '',
          isCardNetworkTokenizationEnabled:
            merchantFeatures?.isCardNetworkTokenizationEnabled,
          isACHPaymentProcessingEnabled: merchantFeatures?.isEFTEnabled,
          isEnhancedDataEnabled: merchantFeatures?.isEnhancedDataEnabled,
          isSmsNotificationsEnabled:
            merchantFeatures?.isSmsNotificationsEnabled,
          ZCPMode: getZCPMode(paymentSettings),
          ZCPDualPricingType: paymentSettings?.defaultDualPricingRate
            ? 'Card' // ARISE-1179:Transaction should always use "Card Price"
            : null,
          tipsEnabled: paymentSettings.isTipsEnabled,

          AVSEnabled: paymentSettings.avs?.isEnabled,
          AVSProfile: apiSettings?.avsMerchantProfiles?.find(
            (profile: AVSProfile) =>
              profile.id === paymentSettings.avs?.profileId,
          )?.name,
          brandingLogo: Boolean(
            merchantSettings?.customizationSettings?.logoUrl,
          ),
        };
        PendoSDK.startSession(visitorId, accountId, visitorData, accountData);
      } catch (error) {
        logger.error(error, 'Error starting Pendo session after MFA');
        // Don't block navigation if Pendo fails
      }
    }
  }, [
    isLoggedIn,
    merchantSettings,
    merchantFeatures,
    apiSettings,
    meProfile,
    paymentSettings,
    selectedProfile,
  ]);

  return {
    refetchApiSettings,
  };
};
