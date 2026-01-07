import {View, Text} from 'react-native';
import {Info} from 'lucide-react-native';
import React from 'react';

const AlertInfo = ({message}: {message: string}) => {
  return (
    <View className="flex-row items-center bg-brand-main-10 border border-elevation-04 rounded-lg px-4 py-4 pr-6 mb-0">
      <Info color="#075985" width={18} height={18} />
      <Text className="ml-2 text-text-primary text-sm flex-1">{message}</Text>
    </View>
  );
};

export default AlertInfo;
