import React from 'react';
import {View} from 'react-native';
import {Text} from '@/components/baseComponents/Text';
import {TRANSACTION_DETAIL_MESSAGES} from '@/constants/messages';
import {getFirstPartTransactionId} from '@/utils/transactionHelpers';

const BodyFirst = ({
  approvalCode,
  transactionId,
  isLoading,
  externalId,
}: {
  approvalCode: string;
  transactionId: string;
  isLoading: boolean;
  externalId: string;
}) => {
  return (
    <View className="border-elevation-08 border-t px-6 py-2 pt-3">
      <View className="flex flex-row justify-between items-center py-[10px]">
        <Text className="text-text-secondary text-base font-normal">
          {TRANSACTION_DETAIL_MESSAGES.TRANSACTION_ID}
        </Text>
        <Text className="font-semibold text-base" isLoading={isLoading}>
          {getFirstPartTransactionId(transactionId)}
        </Text>
      </View>

      {externalId && (
        <View className="flex flex-row justify-between items-center py-[10px]">
          <Text className="text-text-secondary text-base font-normal">
            {TRANSACTION_DETAIL_MESSAGES.EXTERNAL_ID_LABEL}
          </Text>
          <Text className="font-semibold text-base" isLoading={isLoading}>
            {externalId}
          </Text>
        </View>
      )}

      {approvalCode && (
        <View className="flex flex-row justify-between items-center py-[10px]">
          <Text className="text-text-secondary text-base font-normal">
            {TRANSACTION_DETAIL_MESSAGES.APPROVAL_CODE}
          </Text>
          <Text className="font-semibold text-base" isLoading={isLoading}>
            {approvalCode}
          </Text>
        </View>
      )}
    </View>
  );
};

export default BodyFirst;
