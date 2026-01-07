import React, {useEffect} from 'react';
import {useForm} from 'react-hook-form';
import {
  View,
  Text,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
  Alert,
} from 'react-native';
import {useRoute} from '@react-navigation/native';
import AriseHeader from '@/components/baseComponents/AriseHeader';
import ArisePasswordInput from '@/components/baseComponents/ArisePasswordInput';
import AriseButton from '@/components/baseComponents/AriseButton';
import {useChangePasswordWithIdMutation} from '@/hooks/queries/useChangePasswordWithId';
import {TextInputError} from '@/components/baseComponents/TextInputError';
import {removeTwoFactorTrustId} from '@/utils/asyncStorage';
import {VALIDATION_MESSAGES} from '@/constants/messages';
import {ROUTES} from '@/constants/routes';

const ChangePasswordFormScreen = ({navigation}: any): React.JSX.Element => {
  const route = useRoute<any>();
  const {changePasswordId} = route.params;

  const {
    mutate: changePassword,
    isLoading,
    isSuccess,
    isError,
    error,
  } = useChangePasswordWithIdMutation();

  const {
    control,
    handleSubmit,
    watch,
    reset,
    setFocus,
    formState: {errors},
  } = useForm({
    mode: 'onBlur',
    defaultValues: {
      password: '',
    },
  });

  const passwordValue = watch('password');

  // Focus input on mount
  useEffect(() => {
    setTimeout(() => {
      setFocus('password');
    }, 300);
  }, [setFocus]);

  // Navigate to login on success and pass toast param
  useEffect(() => {
    const handleSuccess = async () => {
      if (isSuccess) {
        await removeTwoFactorTrustId();
        // Use reset to prevent swipe back after password change
        navigation.reset({
          index: 0,
          routes: [{name: ROUTES.LOGIN, params: {showPasswordUpdatedToast: true}}],
        });
      }
    };
    handleSuccess();
  }, [isSuccess, navigation]);

  // Redirect to login if 404 and no error message (session lost)
  useEffect(() => {
    if (
      isError &&
      error &&
      error.response &&
      error.response.status === 404 &&
      (!error.response.data || !error.response.data.message)
    ) {
      // Use reset to prevent swipe back after session lost
      navigation.reset({
        index: 0,
        routes: [{name: ROUTES.LOGIN}],
      });
    }
  }, [isError, error, navigation]);

  useEffect(() => {
    if (
      error?.response?.data?.generalErrors?.[0]?.code === '[TrustTokenRequired]'
    ) {
      Alert.alert('Please active MFA');
    }
  }, [error]);

  // Clear form when navigating away
  useEffect(() => {
    const unsubscribe = navigation.addListener('blur', () => {
      reset({
        password: '',
      });
    });

    return unsubscribe;
  }, [navigation, reset]);

  const onSubmit = (data: any) => {
    const {password} = data;
    changePassword({
      changePasswordId,
      password,
    });
  };

  const getPasswordStrengthRules = () => [
    {
      text: 'At least 12 characters',
      valid: passwordValue?.length >= 12,
    },
    {
      text: 'Must have upper and lower case characters, symbols and numbers',
      valid: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])/.test(
        passwordValue || '',
      ),
    },
    {
      text: 'Must not match your 4 previous passwords',
      valid: true, // This would need to be validated by the server
    },
  ];

  const passwordRules = getPasswordStrengthRules();

  return (
    <View className="flex-1 bg-white">
      <AriseHeader title="Expired Password" />

      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={{flex: 1}}>
        <ScrollView
          keyboardShouldPersistTaps="handled"
          contentContainerStyle={{flexGrow: 1}}
          showsVerticalScrollIndicator={false}>
          <View className="px-6 pt-6 pb-6 bg-white rounded-t-3xl flex-1">
            {/* Title */}
            <Text className="text-2xl font-medium text-text-primary mb-3">
              Create a new password
            </Text>

            {/* Password Input */}
            <ArisePasswordInput
              control={control}
              name="password"
              navigation={navigation}
              placeholder=""
              className="mt-3"
              isError={isError || !!errors.password}
              required={true}
              autoFocus={true}
              testID="password-input"
              rules={{
                required: VALIDATION_MESSAGES.PASSWORD_REQUIRED,
                minLength: {
                  value: 12,
                  message: VALIDATION_MESSAGES.PASSWORD_MIN_LENGTH,
                },
                validate: (value: string) =>
                  /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])/.test(
                    value,
                  ) ||
                  'Password must have upper and lower case characters, symbols and numbers',
              }}
            />
            {/* Server Error Message */}
            {isError && (
              <TextInputError
                message={
                  error?.response?.data?.fieldErrors?.password?.some(
                    (e: any) => e.code === '[previouslyUsed]password',
                  )
                    ? VALIDATION_MESSAGES.PASSWORD_PREVIOUS
                    : error?.response?.data?.message ||
                      VALIDATION_MESSAGES.CHANGE_PASSWORD_FAILED
                }
              />
            )}

            {/* Password Requirements */}
            <View className="mb-6 mt-6">
              {passwordRules.map((rule, index) => (
                <View key={index} className="flex-row mb-3">
                  <Text className="text-brand-main mt-[2px] mr-2">→</Text>
                  <Text className={'text-sm flex-1text-text-secondary'}>
                    {rule.text}
                  </Text>
                </View>
              ))}
            </View>

            {/* Continue Button */}
            <AriseButton
              className="w-full"
              loading={isLoading}
              onPress={handleSubmit(onSubmit)}
              title="Continue"
            />
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </View>
  );
};

export default ChangePasswordFormScreen;
