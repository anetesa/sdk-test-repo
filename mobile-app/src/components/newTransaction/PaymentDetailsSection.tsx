import React from 'react';
import {View, Text} from 'react-native';
import {findDebitCardType} from '@/utils/card';
import {formatAmountForDisplay} from '@/utils/currency';
import {SECTION_HEIGHTS} from '@/constants/dimensions';
import {getCardType, maskPan} from '@/utils/cardFlow';
import {KEYED_TRANSACTION_MESSAGES} from '@/constants/messages';
import {
  TransactionDetailsResponse,
  TransactionSaleResponse,
} from '@/types/TransactionSale';
import {useTransactionStore} from '@/stores/transactionStore';

interface PaymentDetailsSectionProps {
  response: TransactionSaleResponse | undefined;
  details: TransactionDetailsResponse | undefined;
  height?: number;
}

const PaymentDetailsSection: React.FC<PaymentDetailsSectionProps> = ({
  response,
  details,
  height,
}) => {
  const transaction = useTransactionStore();
  return (
    <View style={{height: height || SECTION_HEIGHTS.PAYMENT_OVERVIEW}}>
      <View className="border-elevation-08 border-t px-6 py-2 pt-3">
        <View className="flex flex-row justify-between items-center py-[10px]">
          <Text className="text-text-secondary text-base font-normal">
            {KEYED_TRANSACTION_MESSAGES.TRANSACTION_ID}
          </Text>
          <Text className="font-semibold text-base">
            {details?.id?.slice(0, 8) ||
              KEYED_TRANSACTION_MESSAGES.TRANSACTION_ID_FALLBACK}
          </Text>
        </View>
        <View className="flex flex-row justify-between items-center py-[10px]">
          <Text className="text-text-secondary text-base">
            {KEYED_TRANSACTION_MESSAGES.PAYMENT_METHOD}
          </Text>
          <View className="flex-row items-center">
            <Text className="font-semibold text-base mr-2">
              {getCardType(transaction.binData)}{' '}
              {maskPan(transaction.cardNumber)}
            </Text>
            {findDebitCardType(transaction.cardNumber)}
          </View>
        </View>
        {!!response?.details?.authCode && (
          <View className="flex flex-row justify-between items-center py-[10px] pb-3">
            <Text className="text-text-secondary text-base">
              {KEYED_TRANSACTION_MESSAGES.APPROVAL_CODE}
            </Text>
            <Text className="font-semibold text-base">
              {response?.details?.authCode || ''}
            </Text>
          </View>
        )}
      </View>

      {/* Amount Details */}
      <View className="border-elevation-08 border-t px-6 py-2 pt-3">
        <View className="flex flex-row justify-between items-center py-[10px]">
          <Text className="text-text-secondary text-base font-normal">
            {KEYED_TRANSACTION_MESSAGES.BASE_AMOUNT}
          </Text>
          <Text className="font-semibold text-base">
            ${formatAmountForDisplay({dollars: details?.amount?.baseAmount})}
          </Text>
        </View>

        {!!details?.amount?.tipAmount && (
          <View className="flex flex-row justify-between items-center py-[10px]">
            <Text className="text-text-secondary text-base">
              {KEYED_TRANSACTION_MESSAGES.TIP_LABEL}
            </Text>
            <Text className="font-semibold text-base">
              ${formatAmountForDisplay({dollars: details?.amount?.tipAmount})}
            </Text>
          </View>
        )}

        {!!transaction.surchargeAmount && (
          <View className="flex flex-row justify-between items-center py-[10px]">
            <Text className="text-text-secondary text-base">
              {KEYED_TRANSACTION_MESSAGES.SURCHARGE_LABEL}
            </Text>
            <Text className="font-semibold text-base">
              ${formatAmountForDisplay({dollars: transaction.surchargeAmount})}
            </Text>
          </View>
        )}
        <View className="flex flex-row justify-between items-center py-[10px] pb-3">
          <Text className="text-primary-01 font-semibold text-lg">
            {KEYED_TRANSACTION_MESSAGES.TOTAL_AMOUNT_LABEL}
          </Text>
          <Text className="font-semibold text-lg">
            ${formatAmountForDisplay({dollars: details?.amount?.totalAmount})}
          </Text>
        </View>
      </View>
    </View>
  );
};

export default PaymentDetailsSection;
