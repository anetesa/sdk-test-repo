import React, {useEffect, useRef, useCallback, useState} from 'react';
import {View, ScrollView} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';
import {formatDateTime} from '@/utils/date';
import {isPending} from '@/utils/transactionContentMapper';
import Header from './TransactionDetail/Header';
import BodyFirst from './TransactionDetail/BodyFirst';
import BodyDetail from './TransactionDetail/BodyDetail';
import Footer from './TransactionDetail/Footer';
import VoidTransactionBottomSheet from './TransactionDetail/VoidTransactionBottomSheet';
import {useUserStore} from '@/stores/userStore';
import {useTransactionDetails} from '@/hooks/queries/useTransactionDetails';
import {AllTransactionStatuses} from '@/dictionaries/TransactionStatuses';
import {BinDataTypes} from '@/dictionaries/BinData';
import {maskPan} from '@/utils/cardFlow';
import {TRANSACTION_DETAIL_MESSAGES} from '@/constants/messages';
import {getTransactionContent} from '@/utils/transactionContentMapper';
import {
  formatAmountForDisplay,
  formatAmountForSentToTheServer,
} from '@/utils/currency';
import {ProcessingStatusShownAs} from '@/utils/processingStatusShownAs';
import {findDebitCardType} from '@/utils/card';
import {useAlertStore} from '@/stores/alertStore';
import type {NativeStackScreenProps} from '@react-navigation/native-stack';
import type {RootStackParamList} from '@/types/navigation';
import BSheet from '@gorhom/bottom-sheet';
import {useTransactionVoidMutation} from '@/hooks/queries/useTransactionVoid';
import PendingRequest from '@/components/PendingRequest';
import {KEYED_TRANSACTION_MESSAGES} from '@/constants/messages';
import {useQueryClient, useIsFetching} from '@tanstack/react-query';
import {
  invalidateDashboardTransactions,
  invalidateInfiniteDashboardTransactions,
} from '@/hooks/queries/useGetTransactions';
import {useSelectedProfile} from '@/hooks/useSelectedProfile';
import {PERMISSIONS} from '@/constants/permission';
import {
  useTransactionRefundMutation,
  RefundResponse,
} from '@/hooks/queries/useRefundTransaction';
import {
  getAmountLabel,
  getErrorCode,
  getErrorDetails,
  getTypeInfo,
  removeNegativeSignForRefund,
  hasErrorStatus,
} from './TransactionDetail/helpers';
import {ROUTES, SCREEN_NAMES} from '@/constants/routes';
import {useTransactionCaptureMutation} from '@/hooks/queries/useCaptureTransaction';

type TransactionDetailProps = NativeStackScreenProps<
  RootStackParamList,
  'TransactionDetail'
>;
import {PaymentProcessorType} from '@/dictionaries/PaymentProcessorType';

// Function to format customer account number with space after 4th character
const formatCustomerAccountNumber = (accountNumber: string): string => {
  if (!accountNumber || accountNumber.length < 5) {
    return accountNumber;
  }
  return accountNumber.slice(0, 4) + ' ' + accountNumber.slice(4);
};

const TransactionDetail: React.FC<TransactionDetailProps> = ({
  route,
  navigation,
}) => {
  const {transactionFromParams} = route.params;
  const isACH =
    transactionFromParams.paymentMethodTypeId === PaymentProcessorType.Ach;
  const merchantId = useUserStore(s => s.merchantId!!);
  const {selectedProfile} = useSelectedProfile();

  const {data, isLoading, isError} = useTransactionDetails({
    merchantId: merchantId,
    transactionId: transactionFromParams.id,
    isACH: isACH,
  });

  const {
    mutate: refundMutation,
    data: refundMutationData,
    isSuccess: refundMutationSuccess,
    isError: isRefundMutationError,
    error: refundError,
    isPending: isRefundMutationPending,
  } = useTransactionRefundMutation();

  const {
    mutate: captureMutation,
    data: captureMutationData,
    isSuccess: captureMutationSuccess,
    isError: isCaptureMutationError,
    error: captureError,
    isPending: isCaptureMutationPending,
  } = useTransactionCaptureMutation();

  const transaction = (data as any) ?? transactionFromParams;
  const transactionContent = getTransactionContent({
    statusId: transaction?.statusId || 0,
    typeId: transaction?.typeId || 0,
  })!;
  const typeInfo = getTypeInfo(
    transaction?.type || '',
    transaction?.histories || [],
  );

  const {showErrorAlert} = useAlertStore();
  const voidSheetRef = useRef<BSheet>(null);
  const queryClient = useQueryClient();
  const voidMutation = useTransactionVoidMutation();
  const [hasTriggeredRequest, setHasTriggeredRequest] = useState(false);
  const isRefreshingDetails =
    useIsFetching({
      queryKey: ['transactionDetails', merchantId, transactionFromParams.id],
    }) > 0;

  const openVoidSheet = useCallback(() => {
    voidSheetRef.current?.expand();
  }, []);

  const closeVoidSheet = useCallback(() => {
    voidSheetRef.current?.close();
  }, []);

  const handleConfirmVoid = useCallback(() => {
    setHasTriggeredRequest(true);
    voidMutation.mutate(
      {
        transactionId: transactionFromParams.id!,
      },
      {
        onSuccess: response => {
          // If API returns a Decline code in details, surface its message
          const declineCode = response?.details?.code;
          const declineMessage = response?.details?.message;
          if (declineCode === 'Decline' && declineMessage) {
            showErrorAlert(declineMessage);
          }
          // Refresh the transaction details query
          queryClient.invalidateQueries({
            queryKey: [
              'transactionDetails',
              merchantId,
              transactionFromParams.id,
            ],
          });
          // Also refresh dashboard lists
          setTimeout(() => {
            invalidateDashboardTransactions(queryClient);
            invalidateInfiniteDashboardTransactions(queryClient);
          }, 200);
        },
        onSettled: () => {
          // Close the bottom sheet regardless of success/error
          voidSheetRef.current?.close();
        },
      },
    );
  }, [
    merchantId,
    transactionFromParams.id,
    queryClient,
    voidMutation,
    showErrorAlert,
  ]);

  const onRefund = useCallback(() => {
    const availableAmount =
      data?.transactionReceipt?.availableOperations.at(0)?.availableAmount || 0;

    const cents = Math.round(availableAmount * 100);

    navigation.navigate(ROUTES.NEW_TRANSACTION, {
      screen: SCREEN_NAMES.ENTER_AMOUNT,
      params: {
        title: TRANSACTION_DETAIL_MESSAGES.TITLE_REFUND_TRANSACTION,
        enterAmountPrompt:
          TRANSACTION_DETAIL_MESSAGES.ENTER_AMOUNT_PROMPT_REFUND,
        maxAmount: availableAmount || 0,
        defaultAmount: cents.toString(), // int to string
        continueButtonText: TRANSACTION_DETAIL_MESSAGES.CONFIRM_REFUND_BUTTON,
        continueFunction: (amountSelected: number) => {
          const formattedAmount =
            formatAmountForSentToTheServer(amountSelected);
          setHasTriggeredRequest(true);
          refundMutation(
            {
              amount: formattedAmount || 0,
              transactionId: transactionFromParams.id!,
              paymentProcessorId: data?.paymentProcessorId || '',
            },
            {
              onSuccess: () => {
                refreshTransactionsRequest();
              },
            },
          );
          //navigation back
          navigation.goBack();
        },
        detailedAmount: `($${
          formatAmountForDisplay({
            dollars: availableAmount,
          }) || ''
        } available)`,
      },
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [navigation, data, transactionFromParams.id, merchantId]);

  const onCapture = useCallback(() => {
    const availableAmount =
      data?.transactionReceipt?.availableOperations.at(0)?.availableAmount || 0;

    const cents = Math.round(availableAmount * 100);

    navigation.navigate(ROUTES.NEW_TRANSACTION, {
      screen: SCREEN_NAMES.ENTER_AMOUNT,
      params: {
        title: TRANSACTION_DETAIL_MESSAGES.TITLE_CAPTURE_TRANSACTION,
        enterAmountPrompt:
          TRANSACTION_DETAIL_MESSAGES.ENTER_AMOUNT_PROMPT_CAPTURE,
        maxAmount: availableAmount || 0,
        defaultAmount: cents.toString(), // int to string
        continueButtonText: TRANSACTION_DETAIL_MESSAGES.CONFIRM_CAPTURE_BUTTON,
        continueFunction: (amountSelected: number) => {
          const formattedAmount =
            formatAmountForSentToTheServer(amountSelected);
          setHasTriggeredRequest(true);
          captureMutation(
            {
              amount: formattedAmount || 0,
              transactionId: transactionFromParams.id!,
            },
            {
              onSuccess: () => {
                refreshTransactionsRequest();
              },
            },
          );
          //navigation back
          navigation.goBack();
        },
        detailedAmount: `($${
          formatAmountForDisplay({
            dollars: availableAmount,
          }) || ''
        } authorized)`,
      },
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [navigation, data, transactionFromParams.id, merchantId]);

  const handleIsError = useCallback(
    (error: any) => {
      const errors = error?.response?.data?.Errors;
      const errorName = errors ? Object.keys(errors)[0] : undefined;
      const errorMessage = errorName ? errors?.[errorName]?.[0] : undefined;
      if (errorMessage) {
        showErrorAlert(errorMessage);
      }
    },
    [showErrorAlert],
  );

  useEffect(() => {
    if (isRefundMutationError) {
      handleIsError(refundError);
    }
  }, [isRefundMutationError, refundError, handleIsError]);

  useEffect(() => {
    if (isCaptureMutationError) {
      handleIsError(captureError);
    }
  }, [isCaptureMutationError, captureError, handleIsError]);

  useEffect(() => {
    if (voidMutation.isError) {
      showErrorAlert(TRANSACTION_DETAIL_MESSAGES.VOID_ERROR);
    }
  }, [voidMutation.isError, showErrorAlert]);

  const handleErrorPostRequest = useCallback(
    (dataResponse: RefundResponse) => {
      if (
        dataResponse?.details?.code === 'Decline' ||
        dataResponse?.details?.code === 'Error'
      ) {
        showErrorAlert(
          dataResponse?.details?.message ||
            TRANSACTION_DETAIL_MESSAGES.FAILED_FALLBACK,
        );
      }
    },
    [showErrorAlert],
  );

  const refreshTransactionsRequest = useCallback(() => {
    queryClient.invalidateQueries({
      queryKey: ['transactionDetails', merchantId, transactionFromParams.id],
    });
    // Also refresh dashboard lists
    setTimeout(() => {
      invalidateDashboardTransactions(queryClient);
      invalidateInfiniteDashboardTransactions(queryClient);
    }, 200); // BE don't refresh the previous updated transaction immediately.
  }, [queryClient, merchantId, transactionFromParams.id]);

  const goToNewTransaction = useCallback(
    (dataResponse: RefundResponse) => {
      if (dataResponse?.details?.code === 'Approve') {
        navigation.navigate(ROUTES.TRANSACTION_DETAIL, {
          transactionFromParams: {
            id: dataResponse?.transactionId,
            date: dataResponse?.transactionDateTime,
            ...dataResponse,
          },
        });
      }
    },
    [navigation],
  );

  useEffect(() => {
    if (refundMutationSuccess) {
      handleErrorPostRequest(refundMutationData);

      goToNewTransaction(refundMutationData);
    }
  }, [
    refundMutationSuccess,
    refundMutationData,
    handleErrorPostRequest,
    refreshTransactionsRequest,
    goToNewTransaction,
  ]);

  useEffect(() => {
    if (captureMutationSuccess) {
      handleErrorPostRequest(captureMutationData);

      goToNewTransaction(captureMutationData);
    }
  }, [
    captureMutationSuccess,
    captureMutationData,
    handleErrorPostRequest,
    refreshTransactionsRequest,
    goToNewTransaction,
    isCaptureMutationPending,
  ]);

  useEffect(() => {
    if (
      hasTriggeredRequest &&
      !isRefreshingDetails &&
      !voidMutation.isPending &&
      !isRefundMutationPending &&
      !isCaptureMutationPending
    ) {
      setHasTriggeredRequest(false);
    }
  }, [
    hasTriggeredRequest,
    isRefreshingDetails,
    voidMutation.isPending,
    isRefundMutationPending,
    isCaptureMutationPending,
  ]);

  const formattedDate = transactionFromParams?.date
    ? formatDateTime(transactionFromParams.date)
    : '';

  const canVoidOrRefund =
    selectedProfile?.permissions?.includes(PERMISSIONS.TRANSACTIONS_VOID) ===
    true;

  const canSubmitTransaction =
    selectedProfile?.permissions?.includes(PERMISSIONS.TRANSACTIONS_SUBMIT) ===
    true;

  useEffect(() => {
    if (isError) {
      showErrorAlert(TRANSACTION_DETAIL_MESSAGES.TRANSACTION_DETAILS_ERROR);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isError]);
  if (
    voidMutation.isPending ||
    (hasTriggeredRequest && isRefreshingDetails) ||
    isRefundMutationPending ||
    isCaptureMutationPending
  ) {
    return (
      <PendingRequest
        title={KEYED_TRANSACTION_MESSAGES.PROCESSING_TITLE}
        subtitle={KEYED_TRANSACTION_MESSAGES.PROCESSING_SUBTITLE}
      />
    );
  }

  return (
    <>
      <View className="flex-1 bg-white">
        <SafeAreaView edges={['top']} className="flex-1 bg-white">
          <ScrollView
            className="flex-1"
            showsVerticalScrollIndicator={false}
            bounces={true}>
            <Header
              isLoading={isLoading}
              Icon={transactionContent.icon}
              type={typeInfo.id || ''}
              status={ProcessingStatusShownAs(
                transaction?.status || '',
                transaction?.type || '',
              )}
              date={formattedDate || ''}
              details={getErrorDetails(transactionFromParams, data) || ''}
              code={getErrorCode(transactionFromParams, data) || ''}
              iconBgColor={transactionContent.iconBgColor}
              height={
                isPending(transaction?.statusId || 0) ? 'h-[330px]' : undefined
              }
            />
            <BodyFirst
              approvalCode={
                hasErrorStatus(transaction) ? '' : data?.authCode || ''
              }
              transactionId={data?.id || ''}
              isLoading={isLoading}
              externalId={data?.externalReferenceId || ''}
            />
            <BodyDetail
              customerAccountNumber={formatCustomerAccountNumber(
                data?.customerAccountNumber || '',
              )}
              isACH={isACH}
              isLoading={isLoading}
              transactionType={typeInfo.detail || ''}
              transactionStatus={
                AllTransactionStatuses.byId(data?.statusId || 0)?.name || ''
              }
              statusTextColor={transactionContent.statusTextColor}
              creditDebitType={
                BinDataTypes.byId(data?.creditDebitTypeId || 0)?.name || ''
              }
              maskPan={maskPan(data?.transactionReceipt?.customerPan || '')}
              IconCard={findDebitCardType(
                data?.transactionReceipt?.customerPan || '',
              )}
              cardDataSource={data?.transactionReceipt?.cardDataSource || ''}
              amountLabel={getAmountLabel(data?.statusId, data?.typeId)}
              amount={removeNegativeSignForRefund(
                formatAmountForDisplay({
                  dollars: data?.amount?.totalAmount,
                }) || '',
                data?.statusId || 0,
                data?.typeId || 0,
              )}
            />

            <Footer
              isACH={isACH}
              statusId={transaction?.statusId || transactionFromParams.statusId}
              navigation={navigation}
              transactionId={transaction?.id || transactionFromParams.id || ''}
              transactionType={
                transaction?.type || transactionFromParams.type || ''
              }
              onVoidPress={openVoidSheet}
              onRefund={onRefund}
              isLoading={isLoading}
              canRefund={
                (data?.transactionReceipt?.availableOperations?.length ?? 0) > 0
              }
              canVoidOrRefund={canVoidOrRefund}
              onCapture={onCapture}
              canSubmitTransaction={canSubmitTransaction}
            />
          </ScrollView>
        </SafeAreaView>
      </View>
      <VoidTransactionBottomSheet
        ref={voidSheetRef}
        onConfirm={handleConfirmVoid}
        onClose={closeVoidSheet}
      />
    </>
  );
};

export default TransactionDetail;
