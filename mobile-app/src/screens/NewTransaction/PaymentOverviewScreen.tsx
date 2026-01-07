import {View, Text} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';
import React, {useEffect} from 'react';
import {useTransactionStore} from '@/stores/transactionStore';
import AriseButton from '@/components/baseComponents/AriseButton';
import ClipboardIcon from '../../../assets/clipboard.svg';
import {maskPan} from '@/utils/cardFlow';
import {
  formatAmountForDisplay,
  formatAmountForSentToTheServer,
} from '@/utils/currency';
import {useTransactionSaleMutation} from '@/hooks/queries/useTransactionSale';
import {useUserStore} from '@/stores/userStore';
import {Currency} from '@/dictionaries/Currency';
import PendingRequest from '@/components/PendingRequest';
import {KEYED_TRANSACTION_MESSAGES} from '@/constants/messages';
import {COLORS} from '@/constants/colors';
import {SECTION_HEIGHTS} from '@/constants/dimensions';
import {EXPIRATION_DATE, CARD_DEFAULTS} from '@/constants/cardValidation';
import {COUNTRY_DEFAULTS} from '@/constants/countries';
import {NativeStackScreenProps} from '@react-navigation/native-stack';
import {NewTransactionStackParamList} from '@/types/navigation';
import {SCREEN_NAMES} from '@/constants/routes';
import {
  CardTransactionStatus,
  CommonTransactionStatus,
} from '@/dictionaries/TransactionStatuses';
import {useTransactionDetails} from '@/hooks/queries/useTransactionDetails';
import {logger} from '@/utils/logger';
import {ZeroCostProcessingType} from '@/dictionaries/ZeroCostProcessingSettings';
import {useMerchantSettings} from '@/hooks/queries/useMerchantSettings';
import {usePaymentsSettings} from '@/hooks/queries/usePaymentsSettings';
import {TransactionSalePayload} from '@/types/TransactionSale';
import {CardDataSource} from '@/dictionaries/CardDataSource';

import {v4 as uuidv4} from 'uuid';

type PaymentOverviewScreenProps = NativeStackScreenProps<
  NewTransactionStackParamList,
  'PaymentOverview'
>;

export const PaymentOverviewScreen: React.FC<PaymentOverviewScreenProps> = ({
  navigation,
}) => {
  const transaction = useTransactionStore();
  const merchantId = useUserStore(s => s.merchantId!!);
  const {data: merchantSettings} = useMerchantSettings(merchantId);
  const {data: paymentSettings} = usePaymentsSettings();
  const {isDualPricingEnabled, zeroCostProcessingOptionId} =
    paymentSettings || {};

  const transactionSale = useTransactionSaleMutation();
  const detailsQuery = useTransactionDetails({
    merchantId: merchantId,
    transactionId: transactionSale.data?.transactionId,
    isACH: false,
  });

  useEffect(() => {
    const transactionStatusId = transactionSale.data?.statusId;
    const shouldWaitForDetails =
      transactionSale.data?.transactionId &&
      !detailsQuery.data &&
      !detailsQuery.isError;

    if (!transactionStatusId || shouldWaitForDetails) {
      return;
    }

    if (transactionStatusId === CardTransactionStatus.Captured) {
      navigation.navigate(SCREEN_NAMES.PAYMENT_SUCCESS, {
        response: transactionSale.data,
        details: detailsQuery.data as any,
      });
    } else if (transactionStatusId === CommonTransactionStatus.Declined) {
      navigation.navigate(SCREEN_NAMES.PAYMENT_DECLINED, {
        response: transactionSale.data,
        details: detailsQuery.data as any,
      });
    } else {
      navigation.navigate(SCREEN_NAMES.PAYMENT_FAILED, {
        response: transactionSale.data,
        details: detailsQuery.data as any,
      });
    }
  }, [transactionSale, detailsQuery, navigation]);

  useEffect(() => {
    if (transactionSale.isError && transactionSale.error) {
      navigation.navigate(SCREEN_NAMES.VALIDATION_ERROR, {
        error: transactionSale.error,
      });
    }
  }, [navigation, transactionSale]);

  const processTransaction = () => {
    try {
      const payload: TransactionSalePayload = {
        merchantId: merchantId as string,
        amount: formatAmountForSentToTheServer(transaction.amount),
        surchargeRate: transaction.surchargeRate,
        accountNumber: transaction.cardNumber.replace(/\s/g, ''),
        expirationMonth: parseInt(
          transaction.expDate.split(EXPIRATION_DATE.DATE_SEPARATOR)[
            EXPIRATION_DATE.MONTH_INDEX
          ],
          EXPIRATION_DATE.PARSE_BASE,
        ) as number,
        expirationYear: parseInt(
          EXPIRATION_DATE.YEAR_PREFIX +
            transaction.expDate.split(EXPIRATION_DATE.DATE_SEPARATOR)[
              EXPIRATION_DATE.YEAR_INDEX
            ],
          EXPIRATION_DATE.PARSE_BASE,
        ) as number,
        securityCode: transaction.cvv,
        currencyId: Currency.USD,
        l2: {
          salesTax:
            transaction.settingsAutofill?.l2Settings.taxRate ||
            CARD_DEFAULTS.ZERO_VALUE,
        },
        l3: {
          shippingCharges:
            transaction.settingsAutofill?.l3Settings.shippingCharge ||
            CARD_DEFAULTS.ZERO_VALUE,
          dutyCharges:
            transaction.settingsAutofill?.l3Settings.dutyChargeRate ||
            CARD_DEFAULTS.ZERO_VALUE,
          products: transaction.settingsAutofill?.l3Settings.product
            ? [transaction.settingsAutofill?.l3Settings.product]
            : [],
        },
        shippingAddress: {
          countryId: COUNTRY_DEFAULTS.DEFAULT_COUNTRY_ID,
          postalCode: transaction.zipCode as string,
        },
        billingAddress: {
          postalCode: transaction.zipCode as string,
          countryId: COUNTRY_DEFAULTS.DEFAULT_COUNTRY_ID,
        },
        paymentProcessorId: transaction.paymentProcessorId,
        cardDataSource: CardDataSource.Internet,
        referenceId: uuidv4(),
      };

      if (
        ZeroCostProcessingType.Surcharge !== zeroCostProcessingOptionId ||
        !merchantSettings?.merchantSettings?.allowOverrideSurcharge
      ) {
        delete payload.surchargeRate;
      }

      if (isDualPricingEnabled) {
        // ARISE-1179:Transaction should always use "Card Price"
        payload.useCardPrice = true;
      }

      transactionSale.mutate(payload);
    } catch (error) {
      logger.error(error, 'Error processing transaction');
    }
  };

  if (transactionSale.isPending || transactionSale.isSuccess) {
    return (
      <PendingRequest
        title={KEYED_TRANSACTION_MESSAGES.PROCESSING_TITLE}
        subtitle={KEYED_TRANSACTION_MESSAGES.PROCESSING_SUBTITLE}
      />
    );
  }

  return (
    <SafeAreaView edges={['top']} className="flex-1 bg-white">
      <View className={'flex-1'}>
        <View className="flex flex-1 items-center justify-center">
          <View className="rounded-full bg-brand-tint-1 w-[96px] h-[96px] flex items-center justify-center">
            <ClipboardIcon color={COLORS.INFO_BLUE} />
          </View>
          <Text className="mt-6 text-2xl font-medium text-text-primary">
            {KEYED_TRANSACTION_MESSAGES.PAYMENT_OVERVIEW_TITLE}
          </Text>
          <Text className="text-lg mt-3 font-normal text-text-secondary">
            {KEYED_TRANSACTION_MESSAGES.PAYMENT_OVERVIEW_SUBTITLE}
          </Text>
        </View>
      </View>

      <View style={{height: SECTION_HEIGHTS.PAYMENT_OVERVIEW}}>
        <View className="border-elevation-08 border-t px-6 py-2 pt-3">
          <View className="flex flex-row justify-between items-center py-[10px]">
            <Text className="text-text-secondary text-base font-normal">
              {KEYED_TRANSACTION_MESSAGES.CARD_NUMBER_LABEL}
            </Text>
            <Text className="font-semibold text-base">
              {maskPan(transaction.cardNumber)}
            </Text>
          </View>
          <View className="flex flex-row justify-between items-center py-[10px]">
            <Text className="text-text-secondary text-base">
              {KEYED_TRANSACTION_MESSAGES.EXPIRATION_DATE_LABEL}
            </Text>
            <Text className="font-semibold text-base">
              {transaction.expDate}
            </Text>
          </View>
          <View className="flex flex-row justify-between items-center py-[10px] pb-3">
            <Text className="text-text-secondary text-base">
              {KEYED_TRANSACTION_MESSAGES.ZIP_CODE_LABEL}
            </Text>
            <Text className="font-semibold text-base">
              {transaction.zipCode}
            </Text>
          </View>
        </View>

        <View className="border-elevation-08 border-t border-b px-6 py-2 pt-3">
          {transaction.surchargeAmount > 0 && (
            <View className="flex flex-row justify-between items-center py-[10px]">
              <Text className="text-text-secondary text-base font-normal">
                {KEYED_TRANSACTION_MESSAGES.AMOUNT_LABEL}
              </Text>
              <Text className="font-semibold text-base">
                ${formatAmountForDisplay({cents: transaction.amount})}
              </Text>
            </View>
          )}

          {transaction.surchargeAmount > 0 && (
            <View className="flex flex-row justify-between items-center py-[10px]">
              <Text className="text-text-secondary text-base">
                {KEYED_TRANSACTION_MESSAGES.SURCHARGE_LABEL}
              </Text>
              <Text className="font-semibold text-base">
                $
                {formatAmountForDisplay({dollars: transaction.surchargeAmount})}
              </Text>
            </View>
          )}

          <View className="flex flex-row justify-between items-center py-[10px] pb-3">
            <Text className="text-text-secondary font-semibold text-lg">
              {KEYED_TRANSACTION_MESSAGES.TOTAL_AMOUNT_LABEL}
            </Text>
            <Text className="font-semibold text-lg">
              ${formatAmountForDisplay({dollars: transaction.totalAmount})}
            </Text>
          </View>
        </View>
      </View>

      <View className="p-5 h-[196px]">
        <AriseButton
          title={KEYED_TRANSACTION_MESSAGES.CONFIRM_BUTTON}
          className="mb-3 h-[56px]"
          onPress={processTransaction}
          loading={transaction?.status === 'loading'}
        />
        <AriseButton
          type="outline"
          title={KEYED_TRANSACTION_MESSAGES.BACK_BUTTON}
          className="h-[56px]"
          onPress={() => navigation.goBack()}
        />
      </View>
    </SafeAreaView>
  );
};
