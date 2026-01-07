import React from 'react';
import {View, Text, ActivityIndicator} from 'react-native';
import {formatAmountForDisplay} from '@/utils/currency';

interface AmountSummaryProps {
  baseAmountInDollars: number;
  tipAmount: number;
  totalAmount: number;
  calculationData?: any;
  isLoading?: boolean;
  isError?: boolean;
  isTipEnabled?: boolean;
  cardSelected?: string;
  isSurcharge?: boolean;
}

export const AmountSummary: React.FC<AmountSummaryProps> = ({
  baseAmountInDollars,
  tipAmount,
  totalAmount,
  calculationData,
  isLoading = false,
  isTipEnabled = false,
  cardSelected = '',
  isSurcharge = false,
}) => {
  // Use backend data if available (all values in dollars from backend)
  const backendData = isSurcharge
    ? cardSelected === 'credit'
      ? calculationData?.creditCard
      : calculationData?.debitCard
    : calculationData?.creditCard;

  const displayBaseAmount = backendData?.baseAmount ?? baseAmountInDollars;
  const displayTipAmount = backendData?.tipAmount ?? tipAmount;
  const displayTotalAmount = backendData?.totalAmount ?? totalAmount;
  const displaySurchargeAmount = backendData?.surchargeAmount ?? 0;

  if (isLoading) {
    return (
      <View className="px-6 pt-6 flex-1 justify-center items-center">
        <ActivityIndicator size="small" color="#3B82F6" />
        <Text className="text-sm text-text-secondary mt-2">
          Calculating amounts...
        </Text>
      </View>
    );
  }

  return (
    <View className="px-6 pt-5 flex-1">
      <View className="flex-row justify-between items-center mb-4">
        <Text className="text-base text-text-secondary">Base Amount</Text>
        <Text className="text-base font-semibold text-text-primary">
          ${formatAmountForDisplay({dollars: displayBaseAmount})}
        </Text>
      </View>

      {isTipEnabled && (
        <View className="flex-row justify-between items-center mb-4">
          <Text className="text-base text-text-secondary">Tip</Text>
          <Text className="text-base font-semibold text-text-primary">
            ${formatAmountForDisplay({dollars: displayTipAmount})}
          </Text>
        </View>
      )}

      {displaySurchargeAmount > 0 && (
        <View className="flex-row justify-between items-center mb-4">
          <Text className="text-base text-text-secondary">
            Credit Card Surcharge
          </Text>
          <Text className="text-base font-semibold text-text-primary">
            ${formatAmountForDisplay({dollars: displaySurchargeAmount})}
          </Text>
        </View>
      )}

      <View className="flex-row justify-between items-center">
        <Text className="text-lg font-semibold text-text-primary">Total</Text>
        <Text className="text-lg font-semibold text-text-primary">
          ${formatAmountForDisplay({dollars: displayTotalAmount})}
        </Text>
      </View>
    </View>
  );
};
