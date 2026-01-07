import React, {useEffect, useState} from 'react';
import {View, Text, Keyboard, TouchableOpacity} from 'react-native';
import ArisePasswordInput from '@/components/baseComponents/ArisePasswordInput';
import AriseButton from '@/components/baseComponents/AriseButton';
import LoginLayout from '@/components/baseComponents/LoginLayout';
import LoadingSpinner from '@/components/baseComponents/LoadingSpinner';
import {useRememberMe} from '@/hooks/useRememberMe';
import AriseCheckbox from '@/components/baseComponents/AriseCheckbox';
import EmailInput from '@/components/forms/EmailInput';
import {useForm} from 'react-hook-form';
import {TextInputError} from '@/components/baseComponents/TextInputError';
import {useLoginFlow} from '@/hooks/useLoginFlow';
import {LOGIN_MESSAGES} from '@/constants/messages';
import {LoginScreenProps} from '@/types/navigation';
import {ROUTES} from '@/constants/routes';
import {useAlertStore} from '@/stores/alertStore';
import {growthBook} from '@/utils/growthBook';
import {FEATURES} from '@/constants/features';
import AriseMobileSdk from '@/native/AriseMobileSdk';

const LoginScreen = ({
  navigation,
  route,
}: LoginScreenProps): React.JSX.Element => {
  const {email: emailTextFromRememberMe, isLoading: isRememberMeLoading} =
    useRememberMe();
  if (isRememberMeLoading) {
    return (
      <LoginLayout>
        <LoadingSpinner message={LOGIN_MESSAGES.LOADING_REMEMBER_ME} />
      </LoginLayout>
    );
  }

  return (
    <LoginScreenForm
      navigation={navigation}
      route={route}
      emailTextFromRememberMe={emailTextFromRememberMe}
    />
  );
};

export default LoginScreen;

const LoginScreenForm = ({
  navigation,
  route,
  emailTextFromRememberMe,
}: {
  navigation: any;
  route: any;
  emailTextFromRememberMe: string;
}): React.JSX.Element => {
  const [isMeProfileLoading, setIsMeProfileLoading] = useState(false);
  const [currentLoginEmail, setCurrentLoginEmail] = useState('');
  const [isChangePasswordRequired, setIsChangePasswordRequired] =
    useState(false);

  const [isTapToPayEnabled, setIsTapToPayEnabled] = useState(false);
  const isTTPFeatureOn = growthBook.instance.isOn(
    FEATURES.TAP_TO_PAY_BASIC_TRANSACTION,
  );

  useEffect(() => {
    const checkCompatibility = async () => {
      const compatibility = await AriseMobileSdk.checkCompatibility();
      setIsTapToPayEnabled(isTTPFeatureOn && compatibility.isCompatible);
    };
    checkCompatibility();
  }, [isTTPFeatureOn]);

  const {
    rememberMeCheckBox,
    isLoading: isRememberMeLoading,
    handleRememberMeToggle,
    saveEmailOnLogin,
  } = useRememberMe();

  const {control, handleSubmit, reset, watch} = useForm({
    mode: 'onBlur',
    defaultValues: {
      email: emailTextFromRememberMe,
      password: '',
    },
  });

  const userPassword = watch('password');
  const userEmail = watch('email');

  const {login, isError, isLoading, error} = useLoginFlow({
    navigation,
    currentLoginEmail,
    userPassword,
    isChangePasswordRequired,
    setIsChangePasswordRequired,
    setIsMeProfileLoading,
  });

  useEffect(() => {
    const unsubscribe = navigation.addListener('blur', () => {
      reset({
        email: rememberMeCheckBox ? userEmail : '',
        password: '',
      });
      setIsChangePasswordRequired(false);
    });

    return unsubscribe;
  }, [
    emailTextFromRememberMe,
    navigation,
    rememberMeCheckBox,
    reset,
    userEmail,
  ]);

  const onSubmit = async (data: {email: string; password: string}) => {
    const {email, password} = data;
    saveEmailOnLogin(email);
    setCurrentLoginEmail(email);
    await login(email, password);
    Keyboard.dismiss();
  };

  const {showSuccessAlert} = useAlertStore();

  useEffect(() => {
    if (route?.params?.showPasswordUpdatedToast) {
      showSuccessAlert(LOGIN_MESSAGES.PASSWORD_UPDATED);
      navigation.setParams({showPasswordUpdatedToast: false});
    }
  }, [route?.params?.showPasswordUpdatedToast, navigation, showSuccessAlert]);

  return (
    <LoginLayout keyValue={isRememberMeLoading.toString()}>
      {isRememberMeLoading ? (
        <LoadingSpinner message={LOGIN_MESSAGES.LOADING_REMEMBER_ME} />
      ) : (
        <View className="p-6">
          <EmailInput control={control} name="email" isError={isError} />

          <ArisePasswordInput
            navigation={navigation}
            required={true}
            placeholder="Password"
            keyboardType="default"
            enablesReturnKeyAutomatically={true}
            control={control}
            className="mt-3"
            name="password"
            isError={isError}
          />

          {isError && (
            <TextInputError
              message={
                error?.actions?.[0]?.localizedName?.includes('Lock user')
                  ? LOGIN_MESSAGES.ACCOUNT_LOCKED
                  : LOGIN_MESSAGES.INVALID_CREDENTIALS
              }
            />
          )}

          <View className="flex flex-row items-center justify-between w-full mt-6">
            <AriseCheckbox
              checked={rememberMeCheckBox}
              onPress={handleRememberMeToggle}
              label="Remember Me"
              testID="remember-me-checkbox"
            />

            <TouchableOpacity
              onPress={() => navigation.navigate(ROUTES.RESET_PASSWORD)}
              onLongPress={() => {
                if (rememberMeCheckBox && isTapToPayEnabled) {
                  navigation.navigate(ROUTES.TEST_MASTER_CART_TAP_TO_PAY);
                }
              }}
              testID="forgot-password-button">
              <Text className="text-brand-main font-medium text-base">
                Forgot password?
              </Text>
            </TouchableOpacity>
          </View>

          <View className="flex justify-center items-center w-full">
            <AriseButton
              className="mt-10 w-full"
              loading={isLoading || isMeProfileLoading}
              onPress={handleSubmit(onSubmit)}
              type="primary"
              title="Log In"
              testID="login-button"
            />
          </View>
        </View>
      )}
    </LoginLayout>
  );
};
