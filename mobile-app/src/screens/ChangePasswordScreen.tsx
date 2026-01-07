import React from 'react';
import {View, Text, SafeAreaView} from 'react-native';
import {useRoute} from '@react-navigation/native';
import AriseButton from '@/components/baseComponents/AriseButton';
import KeyRound from '../../assets/Key.svg';
import {ROUTES} from '@/constants/routes';
import {UI_MESSAGES} from '@/constants/messages';
import {COLORS} from '@/constants/colors';

const ChangePasswordScreen = ({navigation}: any): React.JSX.Element => {
  const route = useRoute<any>();
  const {changePasswordId} = route.params;

  const handleCreateNewPassword = () => {
    navigation.navigate(ROUTES.CHANGE_PASSWORD_FORM, {
      changePasswordId,
    });
  };

  return (
    <SafeAreaView className="flex-1 bg-white">
      <View className="flex-1 justify-center items-center px-6">
        <View className="items-center mb-8">
          <View
            className="rounded-full p-7 mb-8"
            style={{backgroundColor: COLORS.LIGHT_BLUE_BG}}>
            <KeyRound color={COLORS.BRAND_MAIN} width={40} height={40} />
          </View>
          <Text className="text-[20px] font-semibold text-text-primary text-center mb-3">
            {UI_MESSAGES.PASSWORD_EXPIRED_TITLE}
          </Text>
          <Text className="text-[18px] text-text-secondary text-center font-[400] leading-7">
            {UI_MESSAGES.PASSWORD_EXPIRED_MESSAGE}
          </Text>
        </View>
      </View>
      <View
        className="w-full h-[1px] mb-5"
        style={{backgroundColor: COLORS.BORDER_GRAY}}
      />
      <View className="px-4 pb-8 bg-white">
        <AriseButton
          title={UI_MESSAGES.CREATE_NEW_PASSWORD_BUTTON}
          onPress={handleCreateNewPassword}
          className="w-full"
        />
      </View>
    </SafeAreaView>
  );
};

export default ChangePasswordScreen;
