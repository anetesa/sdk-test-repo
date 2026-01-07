import React, {useEffect} from 'react';
import {View, Text} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';
import {useTransactionStore} from '@/stores/transactionStore';
import {KEYED_TRANSACTION_MESSAGES} from '@/constants/messages';
import AriseButton from '@/components/baseComponents/AriseButton';
import PaymentDetailsSection from '@/components/newTransaction/PaymentDetailsSection';
import {NativeStackScreenProps} from '@react-navigation/native-stack';
import {NewTransactionStackParamList} from '@/types/navigation';
import {SCREEN_NAMES} from '@/constants/routes';
import {COLORS} from '@/constants/colors';
import {CircleX} from 'lucide-react-native';
import {useQueryClient} from '@tanstack/react-query';
import {invalidateTransactionsTodayQuery} from '@/hooks/queries/useTransactionsTodayQuery';
import {invalidateInfiniteDashboardTransactions} from '@/hooks/queries/useGetTransactions';
import {getErrorMessage} from '@/utils/getErrorMessage';

type PaymentDeclinedScreenProps = NativeStackScreenProps<
  NewTransactionStackParamList,
  'PaymentDeclined'
>;

const PaymentDeclinedScreen = ({
  navigation,
  route,
}: PaymentDeclinedScreenProps) => {
  const {retryTransaction} = useTransactionStore();
  const {response, details} = route.params;

  const queryClient = useQueryClient();
  useEffect(() => {
    setTimeout(() => {
      invalidateTransactionsTodayQuery(queryClient);
      invalidateInfiniteDashboardTransactions(queryClient);
    }, 300); // BE don't refresh the previous updated transaction immediately.
  }, [queryClient]);

  const handleHome = () => {
    navigation.navigate('Home' as never);
  };

  const handleRetry = () => {
    retryTransaction();
    navigation.navigate(SCREEN_NAMES.CHOOSE_METHOD);
  };

  return (
    <SafeAreaView edges={['top']} className="flex-1 bg-white">
      <View className="flex-1 ">
        <View className="flex flex-1 items-center justify-center">
          <View className="w-20 h-20 bg-red-100 rounded-full items-center justify-center mb-4">
            <CircleX color={COLORS.ERROR} size={40} strokeWidth={1.25} />
          </View>
          <Text className="text-2xl font-medium leading-7 text-primary-01 mb-2">
            {KEYED_TRANSACTION_MESSAGES.DECLINED}
          </Text>
          <Text className="text-lg font-light leading-7 text-text-secondary text-center pl-10 pr-10">
            {response?.avsResponse?.codeDescription ||
              response?.details?.message ||
              getErrorMessage(details?.responseCode, '') ||
              ''}
          </Text>
          {details?.responseCode && (
            <Text className="text-xs font-semibold text-text-secondary mt-[12px]">
              {KEYED_TRANSACTION_MESSAGES.ERROR_CODE_LABEL}&nbsp;
              {response?.avsResponse?.responseCode || details?.responseCode}
            </Text>
          )}
        </View>
      </View>

      <PaymentDetailsSection
        height={280}
        response={response}
        details={details}
      />

      <View className="p-5 h-[196px]">
        <AriseButton
          title={KEYED_TRANSACTION_MESSAGES.RETRY_BUTTON}
          className="mb-3 h-[56px]"
          type="primary"
          onPress={handleRetry}
        />
        <AriseButton
          type="outline"
          title={KEYED_TRANSACTION_MESSAGES.CANCEL_BUTTON}
          className="h-[56px]"
          onPress={handleHome}
        />
      </View>
    </SafeAreaView>
  );
};

export default PaymentDeclinedScreen;
