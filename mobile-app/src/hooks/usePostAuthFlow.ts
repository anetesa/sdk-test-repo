import {useMeProfile} from '@/hooks/queries/useMeProfile';
import {useDeviceStatus} from '@/hooks/queries/useTapToPayJWT';
import {useCloudCommerceStore} from '@/stores/cloudCommerceStore';
import {detectCountryFromDevice} from '@/stores/cloudCommerce/countryDetection';
import {ROUTES} from '@/constants/routes';
import {logger} from '@/utils/logger';
import {growthBook} from '@/utils/growthBook';
import {FEATURES} from '@/constants/features';
import {getSelectedProfile} from '@/utils/profileSelection';
import {DeviceTapToPayStatusStringEnumType} from '@/dictionaries/DeviceTapToPayStatus';
import {getTTPSplashScreenDismissed} from '@/utils/asyncStorage';
import {getMobileSdkCredentials} from '@/services/mobileSdkService';
import AriseMobileSdk from '@/native/AriseMobileSdk';
import {runtimeConfig} from '@/utils/runtimeConfig';
import {getOrCreateDeviceId} from '@/utils/deviceUtils';
import {apiClient} from '@/clients/apiClient';
import {isMerchantManagerProfile} from '@/utils/isMerchantManager';

async function linkUserProfileToDevice(params: {
  merchantId: string;
  deviceId: string;
}): Promise<void> {
  const {merchantId, deviceId} = params;
  await apiClient.post(
    `/api/Merchants/${merchantId}/devices/${deviceId}/link-user-profile`,
  );
}

interface PostAuthFlowParams {
  navigation: any;
  setIsMeProfileLoading?: (value: boolean) => void;
  errorContext?: string; // e.g., "after MFA", "during login"
}

export const usePostAuthFlow = () => {
  const {refetch: refetchMeProfile} = useMeProfile({enabled: false});
  const {refetch: refetchDeviceStatusData} = useDeviceStatus();
  const cloudCommerce = useCloudCommerceStore();

  const executePostAuthFlow = async ({
    navigation,
    setIsMeProfileLoading,
    errorContext = '',
  }: PostAuthFlowParams) => {
    try {
      const isTTPFeatureOn = growthBook.instance.isOn(
        FEATURES.TAP_TO_PAY_BASIC_TRANSACTION,
      );
      const compatibility = await AriseMobileSdk.checkCompatibility();
      const isTapToPayEnabled = isTTPFeatureOn && compatibility.isCompatible;

      const result = await refetchMeProfile();

      if (!result.error && result.data) {
        // Register device after successful profile fetch
        const selectedProfile = getSelectedProfile(result.data);
        const merchantId = selectedProfile?.merchantId;
        if (merchantId) {
          // Initialize Arise Mobile SDK
          try {
            const credentials = await getMobileSdkCredentials(merchantId);
            if (credentials.clientId && credentials.clientSecret) {
              const ariseEnvironment = runtimeConfig.getAriseEnvironment();

              if (
                !AriseMobileSdk.isConfigured() ||
                AriseMobileSdk.getConfiguredEnvironment() !== ariseEnvironment
              ) {
                // Detect device country code for SDK configuration
                const countryInfo = await detectCountryFromDevice();
                logger.info(
                  'Configuring AriseMobileSdk with country code:',
                  countryInfo.code,
                );
                // TODO: set countryInfo.code After fix from mastercard
                await AriseMobileSdk.configure(ariseEnvironment, 'USA');
              }

              const authenticationResult = await AriseMobileSdk.authenticate(
                credentials.clientId,
                credentials.clientSecret,
              );
              logger.info(
                'AriseMobileSdk authentication succeeded',
                'usePostAuthFlow',
                {
                  expiresIn: authenticationResult.expiresIn,
                  tokenType: authenticationResult.tokenType,
                },
              );
            }
          } catch (ariseError) {
            logger.error(
              ariseError,
              'AriseMobileSdk authentication failed in usePostAuthFlow',
            );
          }
        }

        const hasManagePermission = isMerchantManagerProfile(selectedProfile);

        // Link current user profile to this device (non-blocking best-effort call)
        if (merchantId) {
          (async () => {
            const deviceId = await getOrCreateDeviceId();
            if (!deviceId) {
              return;
            }
            await linkUserProfileToDevice({merchantId, deviceId});
          })().catch(error => {
            logger.error(
              error,
              `Error during link-user-profile request${
                errorContext ? ` ${errorContext}` : ''
              }`,
            );
          });
        }

        const deviceStatusData = await refetchDeviceStatusData().then(
          res => res.data,
        );
        const isTTPEnabledToBeSelected =
          hasManagePermission ||
          deviceStatusData?.tapToPayStatus ===
            DeviceTapToPayStatusStringEnumType.Approved;
        const isTTPSplashScreenDismissed = await getTTPSplashScreenDismissed(
          merchantId || '',
        );

        // Use reset instead of navigate to make Home the root screen
        // This prevents users from swiping back to Login
        navigation.reset({
          index: 0,
          routes: [{name: ROUTES.HOME}],
        });

        if (
          isTTPEnabledToBeSelected &&
          deviceStatusData?.tapToPayStatus !==
            DeviceTapToPayStatusStringEnumType.Active &&
          isTapToPayEnabled
        ) {
          if (!isTTPSplashScreenDismissed) {
            navigation.navigate(ROUTES.TAP_TO_PAY_SPLASH, {
              next_page: ROUTES.HOME,
              isComingFromLoginScreen: true,
            });
          }
        }

        if (result.data && isTapToPayEnabled) {
          cloudCommerce.prepareTerminal();
        }
      } else {
        logger.error(
          `Profile validation failed${errorContext ? ` ${errorContext}` : ''}`,
          result.error,
        );
      }
    } catch (error) {
      logger.error(
        error,
        `Error in post-auth flow${errorContext ? ` ${errorContext}` : ''}`,
      );
    } finally {
      if (setIsMeProfileLoading) {
        setIsMeProfileLoading(false);
      }
    }
  };

  return {
    executePostAuthFlow,
  };
};
