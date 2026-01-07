import React from 'react';
import {View, Text} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';
import {CircleAlert} from 'lucide-react-native';

import AriseButton from '@/components/baseComponents/AriseButton';
import {COLORS} from '@/constants/colors';
import {CloudCommerceErrorInfo} from '@/constants/cloudCommerceErrors';

interface CloudCommerceErrorScreenProps {
  error: any;
  errorInfo: CloudCommerceErrorInfo;
  onPrimaryAction: () => void;
}

const CloudCommerceErrorScreen: React.FC<CloudCommerceErrorScreenProps> = ({
  errorInfo,
  onPrimaryAction,
}) => {
  return (
    <SafeAreaView edges={['top']} className="flex-1 bg-white">
      <View className="flex-1 items-center justify-center px-6">
        {/* Alert Icon */}
        <View className="w-20 h-20 bg-orange-100 rounded-full items-center justify-center mb-6">
          <CircleAlert color={COLORS.WARNING} size={40} strokeWidth={1.25} />
        </View>

        {/* Error Title */}
        <Text className="text-xl font-semibold text-gray-900 mb-4 text-center">
          {errorInfo.title}
        </Text>

        {/* Error Message */}
        <Text className="text-base text-gray-600 mb-6 text-center leading-6 px-4">
          {errorInfo.message}
        </Text>

        {/* Error Code */}
        <Text className="text-sm text-gray-400 mb-8 text-center">
          Code: {errorInfo?.errorCodeMessage}
        </Text>
      </View>

      {/* Action Buttons */}
      <View className="p-6 border-t border-gray-200">
        <View className="space-y-3">
          {/* Primary Action Button */}
          <AriseButton
            title={'Back'}
            onPress={onPrimaryAction}
            type="outline"
            className="h-14 mb-6"
          />
        </View>
      </View>
    </SafeAreaView>
  );
};

export default CloudCommerceErrorScreen;
