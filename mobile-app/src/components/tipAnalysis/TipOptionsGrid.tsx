import React from 'react';
import {View} from 'react-native';
import {TipOption} from './TipOption';

interface TipOptionData {
  id: string;
  label: string;
  percentage: number;
}

interface TipOptionsGridProps {
  tipOptions: TipOptionData[];
  selectedTipId: string;
  baseAmountInDollars: number;
  showCustomValue: boolean;
  onTipOptionPress: (tipId: string) => void;
}

export const TipOptionsGrid: React.FC<TipOptionsGridProps> = ({
  tipOptions,
  selectedTipId,
  baseAmountInDollars,
  showCustomValue,
  onTipOptionPress,
}) => {
  return (
    <View className="flex-row mb-1 -mx-1">
      {tipOptions.map(option => (
        <View key={option.id} className="flex-1 mx-1">
          <TipOption
            id={option.id}
            label={option.label}
            percentage={option.percentage}
            baseAmountInDollars={baseAmountInDollars}
            isSelected={selectedTipId === option.id && !showCustomValue}
            onPress={onTipOptionPress}
          />
        </View>
      ))}
    </View>
  );
};
