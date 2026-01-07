import React, {useEffect} from 'react';
import AriseButton from '@/components/baseComponents/AriseButton';
import AriseCreditCardInput from '@/components/baseComponents/AriseCreditCardInput';
import Header from '@/components/Header';
import {
  Keyboard,
  View,
  Platform,
  KeyboardAvoidingView,
  ScrollView,
} from 'react-native';
import {Controller, useForm, FormProvider} from 'react-hook-form';
import {useTransactionBinData} from '@/hooks/queries/useTransactionBinData';
import AlertInfo from '@/components/baseComponents/AlertInfo';
import {useUserStore} from '@/stores/userStore';
import {usePaymentsSettings} from '@/hooks/queries/usePaymentsSettings';
import {getBackendErrorMessage} from '@/utils/backendErrorMessage';
import {keyedTransactionSchema} from '@/utils/validators/keyedTransaction';
import {yupResolver} from '@hookform/resolvers/yup';
import ExpirationDate from '@/components/baseComponents/ExpirationDate';
import CVVInput from '@/components/baseComponents/CVVInput';
import ZipCodeInput from '@/components/baseComponents/ZipCodeInput';
import {useTransactionStore} from '@/stores/transactionStore';
import {SafeAreaView} from 'react-native-safe-area-context';
import {ROUTES, SCREEN_NAMES} from '@/constants/routes';
import {BinDataType} from '@/dictionaries/BinData';
import {useTransactionCalculateAmount} from '@/hooks/queries/useTransactionCalculateAmount';
import {
  KEYED_TRANSACTION_MESSAGES,
  VALIDATION_MESSAGES,
} from '@/constants/messages';
import {COLORS} from '@/constants/colors';
import {CARD_INPUT_RULES} from '@/constants/cardValidation';
import {useAlertStore} from '@/stores/alertStore';
import {getPaymentProcessorCardId} from '@/utils/cardFlow';
import {useSettingsAutofill} from '@/hooks/queries/useSettingsAutofill';
import {
  getTotalAmount,
  getSurchargeAmount,
} from '@/utils/transactionAmountHelpers';
import {Currency} from '@/dictionaries/Currency';
import {formatAmountForSentToTheServer} from '@/utils/currency';

const KeyedTransaction: React.FC = ({navigation}: any) => {
  const {
    setCardNumber,
    setExpDate,
    setCvv,
    setZipCode,
    setBinData,
    setSurchargeAmount,
    setTotalAmount,
    setSurchargeRate,
    setPaymentProcessorId,
    setSettingsAutofill,
    setUseCardPrice,
    ...transactionData
  } = useTransactionStore();

  const {showErrorAlert} = useAlertStore();
  const methods = useForm({
    mode: 'onBlur',
    defaultValues: {
      cardNumber: transactionData.cardNumber,
      expDate: transactionData.expDate,
      cvv: transactionData.cvv,
      zipCode: transactionData.zipCode,
    },
    resolver: yupResolver(keyedTransactionSchema),
  });

  const {
    control,
    handleSubmit,
    getValues,
    setError,
    clearErrors,
    watch,
    formState: {errors},
  } = methods;

  const cardNumber = watch('cardNumber');

  const {data: binData} = useTransactionBinData(
    cardNumber?.replace(/\s/g, '').length > CARD_INPUT_RULES.MIN_DIGITS_FOR_BIN
      ? cardNumber?.replace(/\s/g, '')
      : undefined,
  );

  const merchantId = useUserStore(s => s.merchantId);

  const {data: settingsAutofill} = useSettingsAutofill(merchantId);

  const {data: paymentSettings} = usePaymentsSettings();

  const {isDualPricingEnabled, defaultSurchargeRate} = paymentSettings || {};

  const surchargeRate = defaultSurchargeRate || undefined;

  /*
   ARISE-1179:Transaction should always use "Card Price"
  */
  const useCardPrice = isDualPricingEnabled ? true : undefined;

  const {
    data: transactionCalculateAmount,
    isError: isErrorCalculateAmount,
    error: errorCalculateAmount,
  } = useTransactionCalculateAmount({
    amount: formatAmountForSentToTheServer(transactionData.amount) || 0,
    surchargeRate: surchargeRate,
    useCardPrice,
    currencyId: Currency.USD,
  });

  useEffect(() => {
    if (isErrorCalculateAmount) {
      const errorMessage = getBackendErrorMessage(
        errorCalculateAmount,
        'Unable to calculate amounts. Please try again.',
      );
      showErrorAlert(`An error has occurred: ${errorMessage}`);
    }
  }, [isErrorCalculateAmount, showErrorAlert, errorCalculateAmount]);

  useEffect(() => {
    const message = KEYED_TRANSACTION_MESSAGES.BIN_ERROR_MESSAGE;
    const isBinError = binData?.typeId === BinDataType.Unknown;
    const currentError = errors.cardNumber?.message;

    if (isBinError) {
      if (currentError !== message) {
        setError('cardNumber', {type: 'manual', message});
      }
    } else if (
      currentError === message &&
      (binData?.typeId === BinDataType.Debit ||
        binData?.typeId === BinDataType.Credit)
    ) {
      clearErrors('cardNumber');
    }
  }, [binData, errors.cardNumber, setError, clearErrors]);

  // Use utility functions for cleaner, DRY code
  const totalAmount = getTotalAmount(binData, transactionCalculateAmount);
  const surchargeAmountValue = getSurchargeAmount(
    binData,
    transactionCalculateAmount,
  );

  const handleContinue = async (data: {
    cardNumber: string;
    cvv: string;
    expDate: string;
    zipCode: string;
  }) => {
    Keyboard.dismiss();
    // Validate payment processor is available
    const paymentProcessorId = getPaymentProcessorCardId(paymentSettings);

    if (!paymentProcessorId) {
      showErrorAlert(KEYED_TRANSACTION_MESSAGES.PAYMENT_PROCESSOR_ERROR);
      return;
    }
    setCardNumber(data.cardNumber);
    setExpDate(data.expDate);
    setCvv(data.cvv);
    setBinData(binData?.typeId || undefined);
    setZipCode(data.zipCode);
    setSurchargeAmount(surchargeAmountValue);
    setTotalAmount(totalAmount);
    setSurchargeRate(surchargeRate || 0);
    setPaymentProcessorId(paymentProcessorId);
    setSettingsAutofill(settingsAutofill || undefined);
    setUseCardPrice(useCardPrice);
    navigation.navigate(ROUTES.NEW_TRANSACTION, {
      screen: SCREEN_NAMES.PAYMENT_OVERVIEW,
    });
  };

  const handleBack = () => {
    const {cardNumber: formCardNumber, expDate, cvv, zipCode} = getValues();
    setCardNumber(formCardNumber);
    setExpDate(expDate);
    setCvv(cvv);
    setZipCode(zipCode);
  };

  return (
    <FormProvider {...methods}>
      <View style={{flex: 1, backgroundColor: COLORS.BACKGROUND_WHITE}}>
        <View className="bg-dark-page-bg">
          <SafeAreaView edges={['top']}>
            <Header
              onBack={handleBack}
              showBack={true}
              title={KEYED_TRANSACTION_MESSAGES.TITLE}
            />
          </SafeAreaView>
        </View>
        <KeyboardAvoidingView
          style={{flex: 1}}
          behavior={Platform.OS === 'ios' ? 'padding' : 'height'}>
          <ScrollView
            contentContainerStyle={{flexGrow: 1}}
            keyboardShouldPersistTaps="handled">
            <View className="p-6 w-full">
              <Controller
                control={control}
                name="cardNumber"
                render={({
                  field: {onChange, onBlur, value},
                  fieldState: {error},
                }) => (
                  <AriseCreditCardInput
                    className="mb-5"
                    rules={{
                      required: VALIDATION_MESSAGES.FIELD_REQUIRED,
                    }}
                    onBlur={onBlur}
                    required={true}
                    value={value as string}
                    maxLength={CARD_INPUT_RULES.MAX_INPUT_LENGTH}
                    label={KEYED_TRANSACTION_MESSAGES.CARD_NUMBER_LABEL}
                    placeholder={
                      KEYED_TRANSACTION_MESSAGES.CARD_NUMBER_PLACEHOLDER
                    }
                    onChangeText={onChange}
                    error={!!error}
                    errorMessage={error?.message}
                  />
                )}
              />
              {surchargeRate &&
                binData?.typeId === CARD_INPUT_RULES.CREDIT_CARD_TYPE_ID && (
                  <View className="mt-3 pb-0 mb-0">
                    <AlertInfo
                      message={KEYED_TRANSACTION_MESSAGES.SURCHARGE_ALERT_MESSAGE(
                        surchargeRate,
                      )}
                    />
                  </View>
                )}

              <View className="flex flex-row gap-2 mt-6">
                <View className="basis-1/2 shrink">
                  <ExpirationDate
                    control={control}
                    name="expDate"
                    required={true}
                    className="w-full"
                  />
                </View>

                <View className="basis-1/2 shrink">
                  <CVVInput
                    control={control}
                    name="cvv"
                    required={true}
                    className="w-full"
                  />
                </View>
              </View>

              <View className="flex w-full mt-6">
                <ZipCodeInput
                  control={control}
                  name="zipCode"
                  required={true}
                  className="w-full"
                />
              </View>

              <AriseButton
                title={KEYED_TRANSACTION_MESSAGES.CONTINUE_BUTTON}
                className="mt-6"
                disabled={
                  isErrorCalculateAmount || Object.keys(errors).length > 0
                }
                onPress={handleSubmit(handleContinue)}
              />
            </View>
          </ScrollView>
        </KeyboardAvoidingView>
      </View>
    </FormProvider>
  );
};

export default KeyedTransaction;
