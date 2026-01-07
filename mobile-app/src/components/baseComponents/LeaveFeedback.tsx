import React from 'react';
import {View, Text} from 'react-native';
import AriseButton from '@/components/baseComponents/AriseButton';
import {FEEDBACK_MESSAGES} from '@/constants/messages';

const LeaveFeedback = (): React.JSX.Element => {
  return (
    <View className="w-full items-center pt-4 px-4">
      <View className="w-full bg-brand-main-10 rounded-2xl p-4 items-center border border-[#22313C]">
        <Text className="text-[#FAFAFA] text-[18px] font-medium text-center mb-1">
          {FEEDBACK_MESSAGES.EXPERIENCE_TITLE}
        </Text>
        <Text className="text-[#D4D4D8] text-[14px] text-center mb-4">
          {FEEDBACK_MESSAGES.FEEDBACK_DESCRIPTION}
        </Text>
        <AriseButton
          title={FEEDBACK_MESSAGES.LEAVE_FEEDBACK_BUTTON}
          className="w-full rounded-xl"
          onPress={() => {}}
        />
      </View>
    </View>
  );
};

export default LeaveFeedback;
