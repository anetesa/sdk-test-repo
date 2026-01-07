import React, {useState, useEffect} from 'react';
import {Text, View, Keyboard, TouchableOpacity, ScrollView} from 'react-native';
import LoginLayout from '@/components/baseComponents/LoginLayout';
import CodeInput from '@/components/baseComponents/CodeInput';
import AriseButton from '@/components/baseComponents/AriseButton';
import {useRoute} from '@react-navigation/native';
import {useMfaMutation} from '@/hooks/queries/useMfaMutation';
import {useSendCodeMutation} from '@/hooks/queries/useSendCodeMutation';
import {useUserStore} from '@/stores/userStore';
import {usePostAuthFlow} from '@/hooks/usePostAuthFlow';
import AriseCheckbox from '@/components/baseComponents/AriseCheckbox';
import {CircleCheck} from 'lucide-react-native';
import {ROUTES} from '@/constants/routes';
import {logger} from '@/utils/logger';
import {useMeProfile} from '@/hooks/queries/useMeProfile';

const MFAScreen = ({navigation}: any): React.JSX.Element => {
  const setUser = useUserStore(state => state.setUser);
  const {executePostAuthFlow} = usePostAuthFlow();
  const {refetch: refetchMeProfile} = useMeProfile({enabled: false});

  const route = useRoute<any>();
  const {twoFactorId, methods, userEmail, changePasswordId} = route.params;

  const method = methods?.[0];
  const hasAuthenticator = methods?.some(
    (item: any) => item.method === 'authenticator',
  );

  const [code, setCode] = useState(['', '', '', '', '', '']);
  const [trustDevice, setTrustDevice] = useState(false);
  const {
    mutate: mfa,
    data: mfaData,
    isPending,
    isError,
    isSuccess,
  } = useMfaMutation();
  const {mutate: sendCode, isLoading: isSendingCode} = useSendCodeMutation();
  const [canResend, setCanResend] = useState(true);
  const [countdown, setCountdown] = useState(0);
  const [showSentMessage, setShowSentMessage] = useState(false);

  const methodUsed = () => {
    if (method?.method === 'authenticator') {
      return 'Code from your authenticator app';
    } else if (method?.method === 'email') {
      return 'Code sent to your email';
    } else if (method?.method === 'sms') {
      return 'Code sent by SMS';
    } else {
      return '';
    }
  };

  const handleMFA = () => {
    Keyboard.dismiss();
    const mfaPayload: {
      twoFactorId: string;
      code: string;
      trustComputer?: boolean;
      userEmail?: string;
    } = {
      twoFactorId: twoFactorId || '',
      code: code.join(''),
      userEmail: userEmail,
    };

    if (trustDevice) {
      mfaPayload.trustComputer = true;
    }

    mfa(mfaPayload);
  };

  const handleResendCode = async () => {
    if (!canResend) {
      return;
    }

    try {
      await sendCode({
        twoFactorId: twoFactorId || '',
        methodId: methods?.[0]?.id || '',
      });

      // Show success message
      setShowSentMessage(true);
      setTimeout(() => setShowSentMessage(false), 3000);

      // Start countdown (1 minute = 60 seconds)
      setCanResend(false);
      setCountdown(60);
    } catch (error) {
      logger.error(error, 'Error sending MFA code');
    }
  };

  // Countdown timer effect
  useEffect(() => {
    let timer: NodeJS.Timeout;
    if (countdown > 0) {
      timer = setTimeout(() => {
        setCountdown(countdown - 1);
      }, 1000);
    } else if (countdown === 0 && !canResend) {
      setCanResend(true);
    }
    return () => clearTimeout(timer);
  }, [countdown, canResend]);

  const formatTime = (seconds: number) => {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return `${minutes}m ${remainingSeconds}s`;
    }
    return `${remainingSeconds} seconds`;
  };

  useEffect(() => {
    const handleResultLoginAttempt = async () => {
      if (mfaData?.changePasswordId) {
        navigation.navigate(ROUTES.CHANGE_PASSWORD, {
          changePasswordId: mfaData.changePasswordId,
        });
        return; // Exit early if password change is needed
      }

      if (isSuccess && mfaData) {
        const userState = {
          id: mfaData.user.id,
          email: mfaData.user.email,
          firstName: mfaData.user.firstName,
          lastName: mfaData.user.lastName,
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
            errorContext: 'after MFA, staying on MFA screen',
          });
        } else {
          navigation.navigate(ROUTES.MERCHANT_SELECTION, {
            profiles: result.data?.profiles,
          });
        }
      }
    };
    handleResultLoginAttempt();

    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isSuccess, mfaData]);

  useEffect(() => {
    if (!hasAuthenticator) {
      sendCode({
        twoFactorId: twoFactorId || '',
        methodId: methods?.[0]?.id || '',
      });
    }
  }, [hasAuthenticator, methods, sendCode, twoFactorId]);

  return (
    <LoginLayout>
      <ScrollView
        keyboardShouldPersistTaps="handled"
        contentContainerStyle={{flexGrow: 1}}
        showsVerticalScrollIndicator={false}>
        <View className="pl-5 pr-4 pb-6 mt-6">
          <Text className="text-primary text-2xl font-medium mb-2">
            Verify Your Identity
          </Text>
          <View className="flex-row gap-1">
            <Text className="text-secondary text-base text-text-secondary">
              {methodUsed()}
            </Text>
          </View>
          <View className="mt-6">
            <CodeInput code={code} setCode={setCode} invalidCode={isError} />
          </View>

          {!changePasswordId && (
            <AriseCheckbox
              checked={trustDevice}
              onPress={() => setTrustDevice(!trustDevice)}
              label="Trust this device for 30 days"
              className="mt-4"
            />
          )}

          <View>
            <AriseButton
              className="mt-6 w-full"
              loading={isPending || isSuccess}
              onPress={handleMFA}
              title="Verify"
            />
          </View>
        </View>
        {!hasAuthenticator && (
          <View className="border-y border-slate-100 pt-3 pb-3 border-b-0">
            <View className="flex justify-center items-center">
              {!showSentMessage && (
                <Text className="text-secondary text-center text-sm pt-3 pl-4 pr-4">
                  Didn't receive the code?
                </Text>
              )}

              {showSentMessage ? (
                <View className="mt-4 pt-4 pb-4 pl-5 pr-5 bg-green-100 rounded-lg flex-row items-center">
                  <CircleCheck
                    className="text-success-dark mr-2"
                    width={16}
                    height={16}
                  />
                  <Text className="text-text-primary text-sm font-medium">
                    Verification code has been sent
                  </Text>
                </View>
              ) : (
                <TouchableOpacity
                  onPress={handleResendCode}
                  disabled={!canResend || isSendingCode}
                  className={!canResend || isSendingCode ? 'opacity-50' : ''}>
                  <Text
                    className={`font-medium text-center text-sm pt-1 mb-6 ${
                      canResend && !isSendingCode
                        ? 'text-brand-main'
                        : 'text-gray-400'
                    }`}>
                    {isSendingCode
                      ? 'Sending...'
                      : !canResend
                      ? `Resend in ${formatTime(countdown)}...`
                      : 'Resend Code'}
                  </Text>
                </TouchableOpacity>
              )}
            </View>
          </View>
        )}
      </ScrollView>
    </LoginLayout>
  );
};

export default MFAScreen;
