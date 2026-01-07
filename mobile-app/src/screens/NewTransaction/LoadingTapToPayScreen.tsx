import React, {useEffect, useState} from 'react';
import {View} from 'react-native';
import LoadingSpinnerBlue from '@/components/baseComponents/LoadingSpinnerBlue';
import ReaderFirmwareUpdateProgress from '@/components/ReaderFirmwareUpdateProgress';
import {useCloudCommerceStore} from '@/stores/cloudCommerceStore';
import type {NewTransactionStackParamList} from '@/types/navigation';
import type {NativeStackScreenProps} from '@react-navigation/native-stack';
import PendingRequest from '@/components/PendingRequest';
import {KEYED_TRANSACTION_MESSAGES} from '@/constants/messages';
import {useUserStore} from '@/stores/userStore';
import {useTransactionDetails} from '@/hooks/queries/useTransactionDetails';
import {SCREEN_NAMES} from '@/constants/routes';
import {useTransactionStore} from '@/stores/transactionStore';
import {convertDollarAmountToCents} from '@/utils/currency';
import {logger} from '@/utils/logger';
import {
  CardTransactionStatus,
  CommonTransactionStatus,
} from '@/dictionaries/TransactionStatuses';
import {getCloudCommerceErrorInfo} from '@/constants/cloudCommerceErrors';
import CloudCommerceErrorScreen from '@/components/CloudCommerceErrorScreen';

type LoadingTapToPayScreenProps = NativeStackScreenProps<
  NewTransactionStackParamList,
  'LoadingTapToPay'
>;

const LoadingTapToPayScreen: React.FC<LoadingTapToPayScreenProps> = ({
  route,
  navigation,
}) => {
  const {transactionDetails} = route.params;

  const cloudCommerce = useCloudCommerceStore();
  const merchantId = useUserStore(s => s.merchantId!!);

  // State for transaction management
  const [transactionId, setTransactionId] = useState('');

  const {setCardNumber, setBinData, setSurchargeAmount, setAmount} =
    useTransactionStore();

  const detailsQuery = useTransactionDetails({
    merchantId: merchantId,
    transactionId: transactionId,
    isACH: false,
  });

  useEffect(() => {
    //clear errors
    useCloudCommerceStore.setState({error: null, sdkState: null});
  }, []);

  // Cancellation signal coming from the store (e.g., ReadError 13 mapped to UI dismissal).
  useEffect(() => {
    const s = cloudCommerce.sdkState;
    const isCancelSignal =
      s === 'userInterfaceDismissed' || s === 'readCancelled';

    if (isCancelSignal) {
      useCloudCommerceStore.setState({error: null, sdkState: null});
      navigation.goBack();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [cloudCommerce.sdkState]);

  useEffect(() => {
    const performTransaction = async () => {
      await cloudCommerce.resumeTerminal();

      // Perform the transaction
      logger.info('💳 Starting transaction...');
      const transactionResult = await cloudCommerce.performTransaction(
        transactionDetails,
      );

      if (transactionResult.transactionId) {
        logger.info('✅ Transaction completed:', transactionResult);
        setTransactionId(transactionResult.transactionId);
      }
    };

    if (cloudCommerce.isPrepared) {
      performTransaction();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [cloudCommerce.isPrepared]);

  useEffect(() => {
    if (detailsQuery?.data) {
      setBinData(detailsQuery.data?.creditDebitTypeId);
      setCardNumber(detailsQuery.data?.customerPan || '');
      setSurchargeAmount(detailsQuery.data?.amount.surchargeAmount || 0);
      setAmount(
        convertDollarAmountToCents(detailsQuery.data?.amount.baseAmount || 0),
      );

      logger.info(
        '🎉 Transaction successful - navigating to PaymentSuccess and preventing further transactions',
      );

      if (detailsQuery.data?.statusId === CardTransactionStatus.Captured) {
        navigation.replace(SCREEN_NAMES.PAYMENT_SUCCESS, {
          response: {
            transactionId: transactionId,
            //@ts-ignore
            details: {authCode: detailsQuery.data?.authCode || ''},
          },
          details: detailsQuery.data as any,
        });
      } else if (
        detailsQuery.data?.statusId === CommonTransactionStatus.Declined
      ) {
        navigation.replace(SCREEN_NAMES.PAYMENT_DECLINED, {
          response: {
            transactionId: transactionId,
            //@ts-ignore
            details: detailsQuery.data as any,
          } as any,
          details: detailsQuery.data as any,
        });
      } else {
        navigation.replace(SCREEN_NAMES.PAYMENT_FAILED, {
          response: {
            transactionId: transactionId,
            //@ts-ignore
            details: detailsQuery.data as any,
          } as any,
          details: detailsQuery.data as any,
        });
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [detailsQuery?.data]);

  // Show reader progress UI if the Reader Firmware (PRF) needs to be updated
  if (cloudCommerce.sdkState === 'updateReaderFirmware') {
    const progressPercentage = cloudCommerce?.readerProgress || 0;
    return <ReaderFirmwareUpdateProgress progress={progressPercentage} />;
  }

  // Show intelligent error UI based on error type
  if (cloudCommerce.error) {
    const errorInfo = getCloudCommerceErrorInfo(cloudCommerce.error);

    const handlePrimaryAction = () => {
      // Clear error in store so it doesn't persist when coming back
      useCloudCommerceStore.setState({
        error: null,
        sdkState: null,
      });
      // Navigate back
      navigation.goBack();
    };

    return (
      <CloudCommerceErrorScreen
        error={cloudCommerce.error}
        errorInfo={errorInfo}
        onPrimaryAction={handlePrimaryAction}
      />
    );
  }

  if (transactionId) {
    return (
      <PendingRequest
        title={KEYED_TRANSACTION_MESSAGES.PROCESSING_TITLE}
        subtitle={KEYED_TRANSACTION_MESSAGES.PROCESSING_SUBTITLE}
      />
    );
  }

  return (
    <View className="flex-1 bg-[#030303] items-center justify-center">
      <LoadingSpinnerBlue />
    </View>
  );
};

export default LoadingTapToPayScreen;
