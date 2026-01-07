import React from 'react';
import {View, Text, TouchableOpacity} from 'react-native';
import ArrowBackSvg from '../../../assets/arrow-back.svg';
import {useNavigation} from '@react-navigation/native';
import {ROUTES} from '@/constants/routes';
import {NAVIGATION_TITLES} from '@/constants/messages';

const BackToLogin = (): React.JSX.Element => {
  const navigation = useNavigation<any>();
  return (
    <TouchableOpacity onPress={() => navigation.navigate(ROUTES.LOGIN)}>
      <View className="flex-row gap-2">
        <ArrowBackSvg />
        <Text className="text-brand-main text-sm font-medium">
          {NAVIGATION_TITLES.BACK_TO_LOGIN}
        </Text>
      </View>
    </TouchableOpacity>
  );
};

export default BackToLogin;
