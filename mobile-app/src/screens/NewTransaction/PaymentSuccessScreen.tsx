import React, {useEffect} from 'react';
import {View, Text} from 'react-native';
import type {NativeStackScreenProps} from '@react-navigation/native-stack';
import type {NewTransactionStackParamList} from '@/types/navigation';
import AriseButton from '@/components/baseComponents/AriseButton';
import {SafeAreaView} from 'react-native-safe-area-context';
import {CircleCheckIcon} from 'lucide-react-native';
import {COLORS} from '@/constants/colors';
import {invalidateTransactionsTodayQuery} from '@/hooks/queries/useTransactionsTodayQuery';
import {useQueryClient} from '@tanstack/react-query';
import {KEYED_TRANSACTION_MESSAGES} from '@/constants/messages';
import {invalidateInfiniteDashboardTransactions} from '@/hooks/queries/useGetTransactions';
import {ROUTES} from '@/constants/routes';
import {CommonActions} from '@react-navigation/native';
import PaymentDetailsSection from '@/components/newTransaction/PaymentDetailsSection';
import {SECTION_HEIGHTS} from '@/constants/dimensions';

type PaymentSuccessScreenProps = NativeStackScreenProps<
  NewTransactionStackParamList,
  'PaymentSuccess'
>;

const PaymentSuccessScreen = ({
  navigation,
  route,
}: PaymentSuccessScreenProps) => {
  const {response, details} = route.params;

  const queryClient = useQueryClient();

  useEffect(() => {
    setTimeout(() => {
      invalidateTransactionsTodayQuery(queryClient);
      invalidateInfiniteDashboardTransactions(queryClient);
    }, 1000); // BE don't refresh the previous updated transaction immediately.
  }, [queryClient]);

  const handleViewReceipt = () => {
    // Open the root-level modal to keep presentation consistent
    navigation.dispatch(
      CommonActions.navigate({
        name: ROUTES.PAYMENT_RECEIPT,
        params: {transactionId: response?.transactionId},
      }),
    );
  };

  const handleHome = () => {
    invalidateTransactionsTodayQuery(queryClient);
    invalidateInfiniteDashboardTransactions(queryClient);
    // Navigate to home screen
    navigation.navigate(ROUTES.HOME as never);
  };

  return (
    <SafeAreaView edges={['top']} className="flex-1 bg-white">
      <View className="flex-1">
        <View className="flex flex-1 items-center justify-center">
          <View className="w-20 h-20 bg-green-100 rounded-full items-center justify-center mb-4">
            <CircleCheckIcon
              color={COLORS.SUCCESS}
              size={40}
              strokeWidth={1.25}
            />
          </View>
          <Text className="text-2xl font-medium leading-7 text-primary-01 mb-2">
            {KEYED_TRANSACTION_MESSAGES.TITLE_SUCCESS}
          </Text>
          <Text className="text-lg font-light leading-7 text-secondary-01 text-center">
            {KEYED_TRANSACTION_MESSAGES.SUBTITLE_SUCCESS}
          </Text>
        </View>
      </View>

      <PaymentDetailsSection
        response={response}
        details={details}
        height={SECTION_HEIGHTS.PAYMENT_SUCCESS_OVERVIEW}
      />

      <View className="p-5 h-[196px] border-t border-elevation-08">
        <AriseButton
          title={KEYED_TRANSACTION_MESSAGES.VIEW_RECEIPT_BUTTON}
          className="mb-3 h-[56px]"
          onPress={handleViewReceipt}
          type="primary"
        />
        <AriseButton
          type="outline"
          title={KEYED_TRANSACTION_MESSAGES.HOME_BUTTON}
          className="h-[56px]"
          onPress={handleHome}
        />
      </View>
    </SafeAreaView>
  );
};

export default PaymentSuccessScreen;
