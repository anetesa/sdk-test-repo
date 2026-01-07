import React from 'react';
import {View} from 'react-native';
import {Text} from '@/components/baseComponents/Text';
import {TRANSACTION_DETAIL_MESSAGES} from '@/constants/messages';

const BodyDetail = ({
  transactionType,
  transactionStatus,
  statusTextColor,
  IconCard,
  creditDebitType,
  maskPan,
  cardDataSource,
  amountLabel,
  amount,
  isLoading,
  isACH,
  customerAccountNumber,
}: {
  transactionType: string;
  transactionStatus: string;
  statusTextColor: string;
  IconCard: React.ReactNode;
  creditDebitType: string;
  maskPan: string;
  cardDataSource: string;
  amountLabel: string;
  amount: string;
  isLoading: boolean;
  isACH: boolean;
  customerAccountNumber: string;
}) => {
  return (
    <View className="border-elevation-08 border-t px-6 py-2 pt-3 h-[252px]">
      <View className="flex flex-row justify-between items-center py-[10px]">
        <Text className="text-text-secondary text-base font-normal">
          {TRANSACTION_DETAIL_MESSAGES.TRANSACTION_TYPE}
        </Text>
        <Text className="font-semibold text-base" isLoading={isLoading}>
          {transactionType}
        </Text>
      </View>
      <View className="flex flex-row justify-between items-center py-[10px]">
        <Text className="text-text-secondary text-base font-normal">
          {TRANSACTION_DETAIL_MESSAGES.TRANSACTION_STATUS}
        </Text>
        <Text
          className={`font-semibold text-base ${statusTextColor}`}
          isLoading={isLoading}>
          {transactionStatus}
        </Text>
      </View>
      {!isACH && (
        <View className="flex flex-row justify-between items-center py-[10px]">
          <Text className="text-text-secondary text-base font-normal">
            {TRANSACTION_DETAIL_MESSAGES.PAYMENT_METHOD}
          </Text>
          <View className="flex-row items-center">
            <Text
              className="font-semibold text-base mr-2"
              isLoading={isLoading}>
              {creditDebitType} {maskPan}
            </Text>
            {IconCard}
          </View>
        </View>
      )}
      {!isACH && (
        <View className="flex flex-row justify-between items-center py-[10px]">
          <Text className="text-text-secondary text-base font-normal">
            {TRANSACTION_DETAIL_MESSAGES.READING_METHOD}
          </Text>
          <Text className="font-semibold text-base" isLoading={isLoading}>
            {cardDataSource}
          </Text>
        </View>
      )}

      {isACH && (
        <View className="flex flex-row justify-between items-center py-[10px]">
          <Text className="text-text-secondary text-base font-normal">
            {TRANSACTION_DETAIL_MESSAGES.ACCOUNT_NUMBER}
          </Text>
          <Text className="font-semibold text-base" isLoading={isLoading}>
            {customerAccountNumber}
          </Text>
        </View>
      )}
      <View className="flex flex-row justify-between items-center py-[10px] pb-3">
        <Text className="text-primary-01 font-semibold text-lg">
          {amountLabel}
        </Text>
        <Text className="font-semibold text-lg" isLoading={isLoading}>
          ${amount}
        </Text>
      </View>
    </View>
  );
};

export default BodyDetail;
