import React, {useEffect} from 'react';
import {View} from 'react-native';
import AriseButton from '@/components/baseComponents/AriseButton';
import {CardTransactionStatus} from '@/dictionaries/TransactionStatuses';
import {TRANSACTION_DETAIL_MESSAGES} from '@/constants/messages';
import {ROUTES} from '@/constants/routes';
import {TransactionTypeNames} from '@/dictionaries/TransactionTypes';
import type {NativeStackScreenProps} from '@react-navigation/native-stack';
import type {RootStackParamList} from '@/types/navigation';
import {PENDO} from '@/utils/pendo';

type TransactionDetailNav = NativeStackScreenProps<
  RootStackParamList,
  'TransactionDetail'
>['navigation'];

export function Footer({
  isACH,
  statusId,
  navigation,
  transactionId,
  onVoidPress,
  onRefund,
  canVoidOrRefund = true,
  canRefund = false,
  isLoading = false,
  transactionType,
  onCapture,
  canSubmitTransaction,
}: {
  isACH: boolean;
  statusId: number | undefined;
  navigation: TransactionDetailNav;
  transactionId: string;
  onVoidPress?: () => void;
  onRefund?: () => void;
  canVoidOrRefund?: boolean;
  canRefund?: boolean;
  isLoading: boolean;
  transactionType: string;
  canSubmitTransaction: boolean;
  onCapture?: () => void;
}) {
  const handleViewReceipt = () => {
    navigation.navigate(ROUTES.PAYMENT_RECEIPT, {
      transactionId: transactionId,
      isACH: isACH,
    });
  };

  useEffect(() => {
    if (statusId || !isLoading) {
      PENDO.screenContentChanged?.();
    }
  }, [statusId, isLoading]);

  return (
    <View className="p-5 border-t border-elevation-08">
      {statusId === CardTransactionStatus.Authorized && (
        <>
          {canSubmitTransaction &&
            transactionType === TransactionTypeNames.Authorization && (
              <AriseButton
                title={TRANSACTION_DETAIL_MESSAGES.CAPTURE_BUTTON}
                className="mb-3 h-[56px]"
                onPress={onCapture}
                type="primary"
                accessibilityLabel={TRANSACTION_DETAIL_MESSAGES.CAPTURE_BUTTON}
                nativeID={TRANSACTION_DETAIL_MESSAGES.CAPTURE_BUTTON}
              />
            )}

          {canVoidOrRefund && (
            <AriseButton
              title={TRANSACTION_DETAIL_MESSAGES.VOID_BUTTON}
              className="mb-3 h-[56px]"
              onPress={onVoidPress}
              type="danger"
              nativeID={TRANSACTION_DETAIL_MESSAGES.VOID_BUTTON}
              accessibilityLabel={TRANSACTION_DETAIL_MESSAGES.VOID_BUTTON}
            />
          )}
        </>
      )}

      {statusId === CardTransactionStatus.Settled &&
        canVoidOrRefund &&
        transactionType === TransactionTypeNames.Sale && (
          <AriseButton
            title={
              !isLoading && !canRefund
                ? TRANSACTION_DETAIL_MESSAGES.REFUNDED_TRANSACTION
                : TRANSACTION_DETAIL_MESSAGES.REFUND_BUTTON
            }
            className="mb-3 h-[56px]"
            onPress={onRefund}
            type={canRefund ? 'danger' : 'outline'}
            loading={isLoading}
            disabled={!canRefund || isLoading}
            nativeID={TRANSACTION_DETAIL_MESSAGES.REFUND_BUTTON}
            accessibilityLabel={
              !isLoading && !canRefund
                ? TRANSACTION_DETAIL_MESSAGES.REFUNDED_TRANSACTION
                : TRANSACTION_DETAIL_MESSAGES.REFUND_BUTTON
            }
          />
        )}

      {statusId === CardTransactionStatus.Captured &&
        (transactionType === TransactionTypeNames.Sale ||
          transactionType === TransactionTypeNames.Capture) &&
        canVoidOrRefund && (
          <AriseButton
            title={TRANSACTION_DETAIL_MESSAGES.VOID_BUTTON}
            className="mb-3 h-[56px]"
            onPress={onVoidPress}
            type="danger"
            nativeID={TRANSACTION_DETAIL_MESSAGES.VOID_BUTTON}
            accessibilityLabel={TRANSACTION_DETAIL_MESSAGES.VOID_BUTTON}
          />
        )}

      <AriseButton
        title={TRANSACTION_DETAIL_MESSAGES.VIEW_RECEIPT_BUTTON}
        className="mb-3 h-[56px]"
        onPress={handleViewReceipt}
        type="outline"
        accessibilityLabel={TRANSACTION_DETAIL_MESSAGES.VIEW_RECEIPT_BUTTON}
        nativeID={TRANSACTION_DETAIL_MESSAGES.VIEW_RECEIPT_BUTTON}
      />
    </View>
  );
}

export default Footer;
