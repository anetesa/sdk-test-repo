import React from 'react';
import {View, Text} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';
import {CustomSVGSpinner} from '@/components/baseComponents/CustomSpinner';
import {ICON_SIZES} from '@/constants/dimensions';

type PendingRequestProps = {
  title: string;
  subtitle: string;
};

const PendingRequest: React.FC<PendingRequestProps> = ({title, subtitle}) => {
  return (
    <SafeAreaView edges={['top']} className="flex-1 bg-white">
      <View className={'flex-1'}>
        <View className="flex flex-1 items-center justify-center">
          <View className="rounded-full bg-brand-tint-1 w-[96px] h-[96px] flex items-center justify-center">
            <CustomSVGSpinner size={ICON_SIZES.SPINNER_SIZE} />
          </View>
          <Text className="mt-6 text-2xl font-medium text-text-primary">
            {title}
          </Text>
          <Text className="text-lg mt-3 font-normal text-text-secondary">
            {subtitle}
          </Text>
        </View>
      </View>
    </SafeAreaView>
  );
};

export default PendingRequest;
