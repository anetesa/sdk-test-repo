import React from 'react';
import {View, Text, TouchableOpacity} from 'react-native';
import {TipOptionsGrid} from './TipOptionsGrid';
import {CustomTipInput} from './CustomTipInput';

interface TipOptionData {
  id: string;
  label: string;
  percentage: number;
}

interface TipAmountSectionProps {
  tipOptions: TipOptionData[];
  selectedTipId: string;
  baseAmountInDollars: number;
  showCustomValue: boolean;
  customTipAmount: number;
  onTipOptionPress: (tipId: string) => void;
  onCustomValuePress: () => void;
  onCustomTipAmountChange: (amount: number) => void;
}

export const TipAmountSection: React.FC<TipAmountSectionProps> = ({
  tipOptions,
  selectedTipId,
  baseAmountInDollars,
  showCustomValue,
  customTipAmount,
  onTipOptionPress,
  onCustomValuePress,
  onCustomTipAmountChange,
}) => {
  return (
    <View className="px-6 pb-5 pt-4 border-b border-elevation-08">
      <View className="flex-row items-center justify-between mb-4">
        <Text className="text-lg font-medium text-text-primary">
          Tip Amount
        </Text>
        <TouchableOpacity
          onPress={onCustomValuePress}
          className="px-2 py-1 rounded-lg">
          <Text className="text-base font-medium text-brand-main">
            {showCustomValue ? 'Predefined Values' : 'Custom Value'}
          </Text>
        </TouchableOpacity>
      </View>

      {!showCustomValue && tipOptions.length > 0 && (
        <TipOptionsGrid
          tipOptions={tipOptions}
          selectedTipId={selectedTipId}
          baseAmountInDollars={baseAmountInDollars}
          showCustomValue={showCustomValue}
          onTipOptionPress={onTipOptionPress}
        />
      )}

      {!showCustomValue && tipOptions.length === 0 && (
        <View className="flex-row justify-center py-8">
          <Text className="text-base text-text-secondary">
            Loading tip options...
          </Text>
        </View>
      )}

      {showCustomValue && (
        <CustomTipInput
          showCustomValue={showCustomValue}
          customTipAmount={customTipAmount}
          onCustomTipAmountChange={onCustomTipAmountChange}
        />
      )}
    </View>
  );
};
