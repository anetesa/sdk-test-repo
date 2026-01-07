import {View, Text} from 'react-native';
import ListItem from '../ListItem';
import React from 'react';
import {getTransactionContent} from '@/utils/transactionContentMapper';
import {formatDateTime} from '@/utils/date';
import {GetTransactionsResponseDTO} from '@/types/TransactionResponse';
import {useNavigation} from '@react-navigation/native';
import {ROUTES} from '@/constants/routes';

interface TransactionItemProps {
  transaction: GetTransactionsResponseDTO;
  isAmountHidden?: boolean;
  showBorder?: boolean;
}

const TransactionItem: React.FC<TransactionItemProps> = ({
  transaction,
  isAmountHidden = false,
  showBorder = false,
}) => {
  const navigation = useNavigation<any>();
  const {statusId, totalAmount, date, typeId} = transaction;

  const formattedDate = formatDateTime(date);

  let formattedCurrency = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(totalAmount ?? 0);

  const renderAmount = () => {
    if (isAmountHidden) {
      return (
        <Text
          testID="transaction-amount-hidden"
          className="tracking-[0.5em] text-[8px] mt-2">
          ● ● ● ●
        </Text>
      );
    }
    return (
      <Text
        testID="transaction-amount"
        className={`text-[16px] font-[600] leading-[24px] ${
          shouldShowRedAmount ? 'text-error-dark' : 'text-text-primary'
        }`}>
        {formattedCurrency}
      </Text>
    );
  };

  const transactionContent = getTransactionContent({
    statusId: statusId ?? 0,
    typeId: typeId ?? 0,
  });

  if (!transactionContent) {
    return null;
  }

  const shouldShowRedAmount =
    transactionContent.title === 'Void' ||
    transactionContent.title === 'Refund' ||
    transactionContent.title === 'ACH Void' ||
    transactionContent.title === 'ACH Credit';

  return (
    <ListItem
      testID="transaction-item"
      accessibilityLabel={transactionContent.title + ' ' + formattedCurrency}
      onPress={() =>
        navigation.navigate(ROUTES.TRANSACTION_DETAIL, {
          transactionFromParams: transaction,
        })
      }
      left={
        <View className="flex-row">
          <View
            testID="transaction-icon-container"
            className={`flex w-[44px] h-[44px] ${transactionContent.iconBgColor} rounded-full mr-3 items-center justify-center`}>
            {transactionContent.icon}
          </View>
          <View className="flex grow">
            <Text
              testID="transaction-title"
              className="text-[18px] font-medium text-text-primary leading-[24px]">
              {transactionContent.title}
            </Text>
            <Text
              testID="transaction-date"
              className="text-text-secondary text-[16px] leading-[24px] z-10 w-full">
              {formattedDate}
            </Text>
          </View>
        </View>
      }
      right={renderAmount()}
      showBorder={showBorder}
    />
  );
};

export default TransactionItem;
