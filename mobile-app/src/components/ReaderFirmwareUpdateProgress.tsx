import React from 'react';
import {View, Text} from 'react-native';
import CircularProgress from '@/components/baseComponents/CircularProgress';

interface ReaderFirmwareUpdateProgressProps {
  progress: number; // 0-100
}

const ReaderFirmwareUpdateProgress: React.FC<
  ReaderFirmwareUpdateProgressProps
> = ({progress}) => {
  return (
    <View className="flex-1 bg-[#030303] items-center justify-center px-6">
      <View className="items-center">
        {/* Circular Progress */}
        <CircularProgress
          progress={progress}
          size={100}
          strokeWidth={8}
          progressColor="#007AFF"
          backgroundColor="#001227"
          showPercentage={true}
        />

        {/* Progress Text */}
        <Text className="text-white text-lg font-medium mt-8 mb-1 text-center">
          We're updating Tap to Pay.
        </Text>
        <Text className="text-white text-lg font-medium text-center mb-4">
          Please hold on, the transaction will resume shortly!
        </Text>
      </View>
    </View>
  );
};

export default ReaderFirmwareUpdateProgress;
