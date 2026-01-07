import {useEffect} from 'react';
import {Alert} from 'react-native';
import {useLoginMutation} from '@/hooks/queries/useLoginMutation';
import {
  LOGIN_MESSAGES,
  ERROR_MESSAGES,
  ALERT_MESSAGES,
} from '@/constants/messages';
import {usePostAuthFlow} from './usePostAuthFlow';
import {useUserStore} from '@/stores/userStore';
import {runtimeConfig} from '@/utils/runtimeConfig';
import {getTwoFactorTrustId} from '@/utils/asyncStorage';
import {ROUTES} from '@/constants/routes';
import {logger} from '@/utils/logger';
import {useMeProfile} from '@/hooks/queries/useMeProfile';
import {mapProfileToMerchantItem} from '@/utils/profileSelection';
import {showErrorAlert, useAlertStore} from '@/stores/alertStore';

interface UseLoginFlowProps {
  navigation: any;
  currentLoginEmail: string;
  userPassword: string;
  isChangePasswordRequired: boolean;
  setIsChangePasswordRequired: (value: boolean) => void;
  setIsMeProfileLoading: (value: boolean) => void;
}

export const useLoginFlow = ({
  navigation,
  currentLoginEmail,
  userPassword,
  isChangePasswordRequired,
  setIsChangePasswordRequired,
  setIsMeProfileLoading,
}: UseLoginFlowProps) => {
  const {mutate: login, data, isError, isLoading, error} = useLoginMutation();
  const setUser = useUserStore(state => state.setUser);
  const {reset: resetUserStore} = useUserStore();
  const {refetch: refetchMeProfile} = useMeProfile({enabled: false});
  const {executePostAuthFlow} = usePostAuthFlow();

  const handleLogin = async (email: string, password: string) => {
    // Clear any previous alerts (e.g. from logout errors) before starting login
    useAlertStore.getState().hideAllAlerts();

    const twoFactorTrustIdData = await getTwoFactorTrustId();
    let twoFactorTrustId;

    if (twoFactorTrustIdData) {
      try {
        const trustData = JSON.parse(twoFactorTrustIdData);
        if (trustData[email]) {
          twoFactorTrustId = trustData[email];
        }
      } catch (twoFactorError) {
        console.error(
          ERROR_MESSAGES.PARSING_TWO_FACTOR_TRUST_ID,
          twoFactorError,
        );
        logger.error(twoFactorError, 'Error parsing two factor trust ID');
        twoFactorTrustId = undefined;
      }
    }

    login({
      applicationId: runtimeConfig.APP_FUSIONAUTH_APPLICATION_ID || '',
      loginId: email,
      password,
      twoFactorTrustId: isChangePasswordRequired ? undefined : twoFactorTrustId,
    });
  };

  useEffect(() => {
    setIsMeProfileLoading(false);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isError]);

  useEffect(() => {
    if (isLoading) {
      setIsMeProfileLoading(true);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isLoading]);

  useEffect(() => {
    const handleResultLoginAttempt = async () => {
      if (data?.twoFactorId && data?.methods?.length === 0) {
        Alert.alert(LOGIN_MESSAGES.TWO_FACTOR_REQUIRED);
        setIsMeProfileLoading(false);
        return;
      }

      if (data?.changePasswordId) {
        setIsChangePasswordRequired(true);
        const twoFactorTrustIdData = await getTwoFactorTrustId();
        if (twoFactorTrustIdData) {
          login({
            applicationId: runtimeConfig.APP_FUSIONAUTH_APPLICATION_ID || '',
            loginId: currentLoginEmail,
            password: userPassword,
          });
          setIsMeProfileLoading(false);
          return;
        }

        navigation.navigate(ROUTES.CHANGE_PASSWORD, {
          changePasswordId: data.changePasswordId,
        });
        return;
      }

      if (data?.twoFactorId) {
        setIsMeProfileLoading(false);
        navigation.navigate(ROUTES.MFA, {
          twoFactorId: data.twoFactorId,
          methods: data.methods,
          userEmail: currentLoginEmail,
          changePasswordId: isChangePasswordRequired,
        });
      } else if (data?.user) {
        const userState = {
          id: data.user.id,
          email: data.user.email,
          firstName: data.user.firstName,
          lastName: data.user.lastName,
        };
        setUser(userState);
        const result = await refetchMeProfile();

        if (
          result.data?.profiles?.length &&
          result.data.profiles.length === 1
        ) {
          setUser({merchantId: result.data?.profiles[0]?.merchantId || ''});
          executePostAuthFlow({
            navigation,
            setIsMeProfileLoading,
            errorContext: ', staying on login screen',
          });
        } else {
          setIsMeProfileLoading(false);

          // Check if there are any active accounts
          const merchants = result.data?.profiles
            ?.map(mapProfileToMerchantItem)
            ?.filter(
              (merchant: ReturnType<typeof mapProfileToMerchantItem>) =>
                !merchant.isSuspended && !merchant.isClosed,
            );

          if (merchants && merchants.length === 0) {
            // Show error toast
            showErrorAlert(ALERT_MESSAGES.NO_ACTIVE_ACCOUNT);

            // Clear user session
            resetUserStore();

            // Navigate back to login
            navigation.navigate(ROUTES.LOGIN);
          } else {
            if (!result.data?.profiles) {
              logger.error('No profiles found', 'useLoginFlow', result);
              showErrorAlert(ALERT_MESSAGES.GENERAL_ERROR);
              resetUserStore();
              navigation.navigate(ROUTES.LOGIN);
              return;
            }

            navigation.navigate(ROUTES.MERCHANT_SELECTION, {
              profiles: result.data?.profiles,
            });
          }
        }
      }
    };

    if (data) {
      handleResultLoginAttempt();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [data]);

  return {
    login: handleLogin,
    isError,
    isLoading,
    error,
  };
};
