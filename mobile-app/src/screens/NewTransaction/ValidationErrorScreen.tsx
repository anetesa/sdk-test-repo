import React from 'react';
import {View, Text} from 'react-native';
import type {NativeStackScreenProps} from '@react-navigation/native-stack';
import type {NewTransactionStackParamList} from '@/types/navigation';
import AriseButton from '@/components/baseComponents/AriseButton';
import {useTransactionStore} from '@/stores/transactionStore';
import {SafeAreaView} from 'react-native-safe-area-context';
import {AlertCircle} from 'lucide-react-native';
import {COLORS} from '@/constants/colors';
import {SCREEN_NAMES} from '@/constants/routes';
import {KEYED_TRANSACTION_MESSAGES} from '@/constants/messages';

type ValidationErrorScreenProps = NativeStackScreenProps<
  NewTransactionStackParamList,
  'ValidationError'
>;

// Validation Error Messages
const VALIDATION_ERROR_MESSAGES = {
  TITLE: 'Transaction Error',
  SUBTITLE: 'Possible Duplicate Transaction Detected.',
  DESCRIPTION: 'Transaction failed. Please try again.',
  ERROR_CODE: 'V0000',
} as const;

const ValidationErrorScreen = ({
  navigation,
  route,
}: ValidationErrorScreenProps) => {
  const {reset, retryTransaction} = useTransactionStore();
  const {error} = route.params;

  const getDescription = () => {
    const errors =
      (error as any)?.response?.data?.Errors ?? (error as any)?.Errors;
    if (!errors) {
      return VALIDATION_ERROR_MESSAGES.DESCRIPTION;
    }

    // Get the first error from the first field
    const firstFieldKey = Object.keys(errors)[0];

    if (!firstFieldKey || !errors[firstFieldKey]?.[0]) {
      return VALIDATION_ERROR_MESSAGES.DESCRIPTION;
    }

    return errors[firstFieldKey][0];
  };

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
          <View
            className="w-20 h-20 bg-warning-05 rounded-full items-center justify-center mb-6"
            testID="validation-error-icon">
            <AlertCircle color={COLORS.WARNING} size={40} strokeWidth={1.25} />
          </View>
          <Text className="text-2xl font-medium leading-7 text-text-primary mb-3 text-center">
            {VALIDATION_ERROR_MESSAGES.TITLE}
          </Text>
          <Text className="text-lg font-normal leading-6 text-text-secondary text-center px-6">
            {getDescription()}
          </Text>
          <Text className="text-xs font-semibold text-text-secondary mt-3">
            {KEYED_TRANSACTION_MESSAGES.ERROR_CODE_LABEL}&nbsp;
            {(() => {
              const errorCode =
                (error as any)?.response?.data?.ErrorCode ??
                (error as any)?.ErrorCode ??
                (error as any)?.userInfo?.ErrorCode ??
                (error as any)?.userInfo?.errorCode ??
                VALIDATION_ERROR_MESSAGES.ERROR_CODE;
              return errorCode;
            })()}
          </Text>
        </View>
      </View>

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

export default ValidationErrorScreen;
