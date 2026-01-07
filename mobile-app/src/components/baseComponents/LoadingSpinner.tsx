import React from 'react';
import {View, Text, ActivityIndicator} from 'react-native';
import {UI_MESSAGES} from '@/constants/messages';
import {COLORS} from '@/constants/colors';

interface LoadingSpinnerProps {
  message?: string;
  size?: 'small' | 'large';
  color?: string;
  showSpinner?: boolean;
  className?: string;
}

const LoadingSpinner = ({
  message = UI_MESSAGES.LOADING,
  size = 'large',
  color = COLORS.INFO_LIGHT,
  showSpinner = false,
  className = 'pt-6 pl-4 pr-4 pb-8 flex justify-center items-center',
}: LoadingSpinnerProps): React.JSX.Element => {
  return (
    <View className={className}>
      {showSpinner && <ActivityIndicator size={size} color={color} />}
      <Text className={showSpinner ? 'mt-4 text-gray-600 text-base' : ''}>
        {message}
      </Text>
    </View>
  );
};

export default LoadingSpinner;
