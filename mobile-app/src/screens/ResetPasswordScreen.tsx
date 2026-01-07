import React, {useEffect} from 'react';
import {View, Text} from 'react-native';
import EmailInput from '@/components/forms/EmailInput';
import AriseButton from '@/components/baseComponents/AriseButton';
import AriseHeader from '@/components/baseComponents/AriseHeader';
import {useForm} from 'react-hook-form';
import {useChangePasswordMutation} from '@/hooks/queries/useChangePassword';
import {useNavigation} from '@react-navigation/native';
import {ROUTES} from '@/constants/routes';
import {useAlertStore} from '@/stores/alertStore';

const ResetPasswordScreen = () => {
  const navigation = useNavigation<any>();
  const {control, handleSubmit} = useForm();
  const {
    mutate: changePassword,
    isLoading,
    isSuccess,
    isError,
  } = useChangePasswordMutation();
  const onSubmit = (data: any) => {
    changePassword({loginId: data.email});
  };

  const {showErrorAlert} = useAlertStore();

  useEffect(() => {
    if (isError) {
      showErrorAlert('Error sending email');
    }
  }, [isError, showErrorAlert]);

  useEffect(() => {
    if (isSuccess) {
      navigation.navigate(ROUTES.PASSWORD_LINK_SENT);
    }
  }, [isSuccess, navigation]);

  return (
    <View className="flex-1 bg-white">
      <AriseHeader title="Reset Password" />

      <View className="pt-6 pl-4 pr-4 pb-8 flex-1">
        <Text className="text-2xl font-medium text-text-primary leading-[28px] mb-6">
          Enter your email to reset your password
        </Text>

        <EmailInput control={control} name="email" />

        <AriseButton
          className="mt-8 w-full"
          title="Continue"
          onPress={handleSubmit(onSubmit)}
          type="primary"
          loading={isLoading}
        />
      </View>
    </View>
  );
};

export default ResetPasswordScreen;
