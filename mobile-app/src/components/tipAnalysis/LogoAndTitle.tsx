import React from 'react';
import {View, Text} from 'react-native';
import {CircleDollarSign, WalletCards} from 'lucide-react-native';

export const LogoAndTitle: React.FC<{
  isSurcharge: boolean;
  isTipEnabled: boolean;
}> = ({isSurcharge, isTipEnabled}) => {
  return (
    <View className="items-center mt-[-40px] pb-6 px-6  border-b border-elevation-08">
      <View className="w-[96px] h-[96px] rounded-full bg-brand-main-05 items-center justify-center mb-6">
        {isTipEnabled && !isSurcharge ? (
          <CircleDollarSign size={48} color="#0A6E94" strokeWidth={1.25} />
        ) : (
          <WalletCards size={48} color="#0A6E94" strokeWidth={1.25} />
        )}
      </View>
      <Text className="text-2xl px-9 font-medium tracking-tight text-center text-text-primary">
        {isTipEnabled && !isSurcharge ? 'Add a Tip?' : ''}
        {!isTipEnabled && isSurcharge ? 'Select the card type' : ''}
        {isTipEnabled && isSurcharge
          ? 'Select the card type and tip amount '
          : ''}
      </Text>
    </View>
  );
};
