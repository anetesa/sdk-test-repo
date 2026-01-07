import React, {useEffect} from 'react';
import {View, Text} from 'react-native';
import type {NativeStackScreenProps} from '@react-navigation/native-stack';
import type {NewTransactionStackParamList} from '@/types/navigation';
import AriseButton from '@/components/baseComponents/AriseButton';
import {useTransactionStore} from '@/stores/transactionStore';
import {SafeAreaView} from 'react-native-safe-area-context';
import {CircleX} from 'lucide-react-native';
import {COLORS} from '@/constants/colors';
import {KEYED_TRANSACTION_MESSAGES} from '@/constants/messages';
import {SCREEN_NAMES} from '@/constants/routes';
import PaymentDetailsSection from '@/components/newTransaction/PaymentDetailsSection';
import {invalidateTransactionsTodayQuery} from '@/hooks/queries/useTransactionsTodayQuery';
import {invalidateInfiniteDashboardTransactions} from '@/hooks/queries/useGetTransactions';
import {useQueryClient} from '@tanstack/react-query';

type PaymentFailedScreenProps = NativeStackScreenProps<
  NewTransactionStackParamList,
  'PaymentFailed'
>;

const PaymentFailedScreen = ({navigation, route}: PaymentFailedScreenProps) => {
  const {reset, retryTransaction} = useTransactionStore();
  const {response, details} = route.params;

  const queryClient = useQueryClient();
  useEffect(() => {
    setTimeout(() => {
      invalidateTransactionsTodayQuery(queryClient);
      invalidateInfiniteDashboardTransactions(queryClient);
    }, 300); // BE don't refresh the previous updated transaction immediately.
  }, [queryClient]);

  const handleRetryTransaction = () => {
    // Reset card details but preserve amount, then navigate to ChooseMethod
    retryTransaction();
    navigation.navigate(SCREEN_NAMES.CHOOSE_METHOD);
  };

  const handleCancel = () => {
    // Reset transaction and navigate to home
    reset();
    navigation.navigate('Home' as never);
  };

  return (
    <SafeAreaView edges={['top']} className="flex-1 bg-white">
      <View className="flex-1">
        <View className="flex flex-1 items-center justify-center">
          <View className="w-20 h-20 bg-red-100 rounded-full items-center justify-center mb-4">
            <CircleX color={COLORS.ERROR} size={40} strokeWidth={1.25} />
          </View>
          <Text className="text-2xl font-medium leading-7 text-primary-01 mb-2">
            {KEYED_TRANSACTION_MESSAGES.TITLE_FAILED}
          </Text>
          <View className="ml-12 mr-12">
            <Text className="text-lg font-light leading-7 text-text-secondary text-center">
              {KEYED_TRANSACTION_MESSAGES.SUBTITLE_FAILED}
            </Text>
          </View>
          <Text className="text-xs font-semibold text-text-secondary mt-[12px]">
            {KEYED_TRANSACTION_MESSAGES.ERROR_CODE_LABEL}&nbsp;
            {response?.details?.hostResponseCode ||
              KEYED_TRANSACTION_MESSAGES.ERROR_CODE_FALLBACK}
          </Text>
        </View>
      </View>

      <PaymentDetailsSection response={response} details={details} />

      <View className="p-5 h-[196px] border-t border-elevation-08">
        <AriseButton
          title={KEYED_TRANSACTION_MESSAGES.RETRY_TRANSACTION_BUTTON}
          className="mb-3 h-[56px]"
          onPress={handleRetryTransaction}
          type="primary"
        />
        <AriseButton
          type="outline"
          title={KEYED_TRANSACTION_MESSAGES.CANCEL_BUTTON}
          className="h-[56px]"
          onPress={handleCancel}
        />
      </View>
    </SafeAreaView>
  );
};

export default PaymentFailedScreen;
