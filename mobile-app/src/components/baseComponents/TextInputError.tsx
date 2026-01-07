import React from 'react';
import {Text, View} from 'react-native';
import AlertCircleIcon from '@/components/icons/AlertCircleIcon';
import {UI_MESSAGES} from '@/constants/messages';

export const TextInputError = ({message}: {message?: string}) => {
  return (
    <View className="flex-row items-start mt-2">
      <AlertCircleIcon color="#b91c1c" />
      <Text className="text-error-dark ml-2 text-[14px] flex-1">
        {message || UI_MESSAGES.ERROR_FALLBACK}
      </Text>
    </View>
  );
};
