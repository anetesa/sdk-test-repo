import {View, Text, ScrollViewProps, SafeAreaView} from 'react-native';
import React from 'react';
import {ScrollView} from 'react-native-gesture-handler';
import TransactionItem from './TransactionItem';
import {TRANSACTION_MESSAGES} from '@/constants/messages';
import {FullSkeletonList} from '@/components/baseComponents/ListItemSkeleton';

interface TransactionListProps extends ScrollViewProps {
  isAmountHidden?: boolean;
  hideLastBorder?: boolean;
  transactions: any[];
  isLoading: boolean;
}

const TransactionList: React.FC<TransactionListProps> = ({
  isAmountHidden = false,
  hideLastBorder = false,
  transactions,
  isLoading,
  ...rest
}) => {
  // Flatten all pages and take only the first 5 items for the home screen
  if (isLoading) {
    return (
      <ScrollView {...rest}>
        <SafeAreaView>
          <FullSkeletonList />
        </SafeAreaView>
      </ScrollView>
    );
  }

  if (transactions && transactions.length) {
    return (
      <ScrollView {...rest}>
        <SafeAreaView>
          {transactions.map((item: any, index: number) => {
            const isLastItem = index === transactions.length - 1;
            const showBorder = !hideLastBorder || !isLastItem;

            return (
              <TransactionItem
                transaction={item}
                isAmountHidden={isAmountHidden}
                showBorder={showBorder}
                key={item.id}
              />
            );
          })}
        </SafeAreaView>
      </ScrollView>
    );
  } else {
    return (
      <View className="bg-white min-h-[250px]">
        <View className="flex-1 justify-center items-center">
          <Text className="text-xl font-medium">
            {TRANSACTION_MESSAGES.NO_RECENT_TRANSACTIONS}
          </Text>
        </View>
      </View>
    );
  }
};

export default TransactionList;
