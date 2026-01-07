import {CalculateAmountResponseDTO} from '@/types/CalculateAmount';
import {formatAmountForDisplay} from '@/utils/currency';
import React from 'react';
import {View, Text, TouchableOpacity} from 'react-native';

export const SelectTheCardType: React.FC<{
  calculationData: CalculateAmountResponseDTO;
  selectedCard: string;
  setSelectedCard: (card: string) => void;
}> = ({calculationData, selectedCard, setSelectedCard}) => {
  return (
    <View className="w-full px-6 pt-5 pb-5 border-b border-elevation-08">
      <View className="flex-row gap-2">
        {/* Credit Card */}
        <TouchableOpacity
          onPress={() => setSelectedCard('credit')}
          className={
            selectedCard === 'credit'
              ? 'flex-1 rounded-2xl items-center justify-center py-3 px-8 bg-brand-main-05 border-2 border-brand-main shadow-sm'
              : 'flex-1 rounded-2xl items-center justify-center py-3 px-8 bg-surface border border-elevation-08 shadow-sm'
          }>
          <Text className="text-base font-medium text-center text-text-primary">
            Credit Card
          </Text>
          <Text className="text-sm text-center text-text-secondary">
            $
            {formatAmountForDisplay({
              dollars: calculationData?.creditCard?.totalAmount ?? 0,
            })}
          </Text>
        </TouchableOpacity>

        {/* Debit Card */}
        <TouchableOpacity
          onPress={() => setSelectedCard('debit')}
          className={
            selectedCard === 'debit'
              ? 'flex-1 rounded-2xl items-center justify-center py-3 px-8 bg-brand-main-05 border-2 border-brand-main shadow-sm'
              : 'flex-1 rounded-2xl items-center justify-center py-3 px-8 bg-surface border border-elevation-08 shadow-sm'
          }>
          <Text className="text-base font-medium text-center text-text-primary">
            Debit Card
          </Text>
          <Text className="text-sm text-center text-text-secondary">
            $
            {formatAmountForDisplay({
              dollars: calculationData?.debitCard?.totalAmount ?? 0,
            })}
          </Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

export default SelectTheCardType;
