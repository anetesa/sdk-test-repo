import React from 'react';
import {TouchableOpacity, Text} from 'react-native';
import {formatAmountForDisplay} from '@/utils/currency';

interface TipOptionProps {
  id: string;
  label: string;
  percentage: number;
  baseAmountInDollars: number;
  isSelected: boolean;
  onPress: (tipId: string) => void;
}

export const TipOption: React.FC<TipOptionProps> = ({
  id,
  label,
  percentage,
  baseAmountInDollars,
  isSelected,
  onPress,
}) => {
  const calculatedAmount = Math.round(baseAmountInDollars * percentage * 100);

  const containerClass = isSelected
    ? 'w-full rounded-2xl items-center justify-center py-3 px-2 min-h-16 bg-brand-main-05 border-2 border-brand-main shadow-sm'
    : 'w-full rounded-2xl items-center justify-center py-3 px-2 min-h-16 bg-surface border border-elevation-08 shadow-sm';

  const labelClass = isSelected
    ? 'text-sm font-semibold text-center text-text-primary'
    : 'text-base font-semibold text-center text-text-primary';

  return (
    <TouchableOpacity onPress={() => onPress(id)} className={containerClass}>
      <Text className={labelClass}>{label}</Text>
      <Text className="text-sm text-center text-text-secondary">
        ${formatAmountForDisplay({cents: calculatedAmount})}
      </Text>
    </TouchableOpacity>
  );
};
