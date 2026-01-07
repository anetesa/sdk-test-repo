import Header from '@/components/Header';
import {useTransactionStore} from '@/stores/transactionStore';
import React from 'react';
import {View, Text} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';
import {ROUTES, SCREEN_NAMES} from '@/constants/routes';
import {UI_MESSAGES} from '@/constants/messages';
import {
  formatAmountForDisplay,
  formatAmountForSentToTheServer,
} from '@/utils/currency';
import {v4 as uuidv4} from 'uuid';
import ListItemCard from '@/components/baseComponents/ListItemCard';
import NfcIcon from '../../../assets/nfc-icon.svg';
import TextCursorInputIcon from '../../../assets/text-cursor-input.svg';
import {useFeatureIsOn} from '@growthbook/growthbook-react';
import {FEATURES} from '@/constants/features';
import {usePaymentsSettings} from '@/hooks/queries/usePaymentsSettings';
import {useDeviceStatus} from '@/hooks/queries/useTapToPayJWT';
import {ZeroCostProcessingType} from '@/dictionaries/ZeroCostProcessingSettings';
import {DeviceTapToPayStatusStringEnumType} from '@/dictionaries/DeviceTapToPayStatus';
import {useIsMerchantManager} from '@/hooks/useIsMerchantManager';
import AriseMobileSdk from '@/native/AriseMobileSdk';
import {useState, useEffect} from 'react';
import type {NativeStackScreenProps} from '@react-navigation/native-stack';
import type {NewTransactionStackParamList} from '@/types/navigation';

type ChooseMethodProps = NativeStackScreenProps<
  NewTransactionStackParamList,
  'ChooseMethod'
>;

export const ChooseMethod: React.FC<ChooseMethodProps> = ({navigation}) => {
  const {data: paymentSettings} = usePaymentsSettings();
  const {
    defaultSurchargeRate,
    isTipsEnabled,
    zeroCostProcessingOptionId,
    isSurchargeEnabled,
  } = paymentSettings || {};
  const amount = useTransactionStore(state => state.amount);
  const displayAmount = formatAmountForDisplay({cents: amount});

  // Check if Tap to Pay feature is enabled in GrowthBook
  const [isTapToPayEnabled, setIsTapToPayEnabled] = useState(false);
  const isTTPFeatureOn = useFeatureIsOn(FEATURES.TAP_TO_PAY_BASIC_TRANSACTION);

  useEffect(() => {
    const checkCompatibility = async () => {
      const compatibility = await AriseMobileSdk.checkCompatibility();
      setIsTapToPayEnabled(isTTPFeatureOn && compatibility.isCompatible);
    };
    checkCompatibility();
  }, [isTTPFeatureOn]);

  const {data: deviceStatusData, isActive} = useDeviceStatus();

  const hasManagePermission = useIsMerchantManager();

  const isTTPEnabledToBeSelected =
    hasManagePermission ||
    deviceStatusData?.tapToPayStatus ===
      DeviceTapToPayStatusStringEnumType.Approved ||
    isActive;

  /*
  const handleQrCode = () => {
    navigation.navigate(SCREEN_NAMES.PAY_BY_LINK);
  };
  */

  const handleTapToPay = () => {
    const amountInDollars = formatAmountForSentToTheServer(amount);
    // IMPORTANT: Pass money as a fixed 2-decimal string to native to avoid JS float precision issues.
    const amountString = amountInDollars.toFixed(2);

    let nextScreen: keyof NewTransactionStackParamList;
    if (
      isTipsEnabled ||
      (zeroCostProcessingOptionId === ZeroCostProcessingType.Surcharge &&
        defaultSurchargeRate !== null)
    ) {
      nextScreen = SCREEN_NAMES.ZCP_TIPS_ANALYSIS;
    } else {
      nextScreen = SCREEN_NAMES.LOADING_TAP_TO_PAY;
    }

    const baseTransactionDetails = {
      amount: amountString,
      currencyCode: 'USD',
      countryCode: 'USA', // TODO: set cloudCommerce.detectedCountryCode after fix from mastercard
      tip: '0.00',
      discount: '0.00',
      salesTaxAmount: '0.00',
      federalTaxAmount: '0.00',
      subTotal: formatAmountForDisplay({cents: amount}),
      orderId: uuidv4(),
    };

    if (!isActive) {
      // Prefer opening TapToPaySplash inside the NewTransaction stack so back/swipeBack
      // returns to ChooseMethod instead of potentially popping to the Root stack (Login).
      navigation.navigate(ROUTES.TAP_TO_PAY_SPLASH as any, {
        next_page: nextScreen,
        transactionDetails: baseTransactionDetails as any,
        zcp:
          nextScreen === SCREEN_NAMES.ZCP_TIPS_ANALYSIS
            ? {
                isSurcharge: Boolean(isSurchargeEnabled),
                isTipEnabled: Boolean(isTipsEnabled),
                defaultSurchargeRate: defaultSurchargeRate ?? undefined,
              }
            : undefined,
      });
    } else {
      if (nextScreen === SCREEN_NAMES.ZCP_TIPS_ANALYSIS) {
        navigation.navigate(nextScreen, {
          transactionDetails: baseTransactionDetails as any,
          isSurcharge: Boolean(isSurchargeEnabled),
          isTipEnabled: Boolean(isTipsEnabled),
          defaultSurchargeRate: defaultSurchargeRate ?? undefined,
        });
      } else {
        navigation.navigate(nextScreen, {
          transactionDetails: baseTransactionDetails as any,
        });
      }
    }
  };

  const handleKeyed = () => {
    navigation.navigate(SCREEN_NAMES.KEYED_TRANSACTION);
  };

  return (
    <SafeAreaView className="bg-dark-page-bg flex">
      <Header showBack={true} title="New Transaction" />
      <View className={'h-56 flex'}>
        <Subtotal amount={displayAmount} />
      </View>
      <View className={'flex grow  w-full  bg-white items-center p-4 h-full'}>
        <Text className="text-2xl font-medium mt-2 mb-2">
          Select payment method
        </Text>

        <View className={'flex flex-col w-full mt-4'}>
          {/* Tap to Pay option - only show if feature flag is enabled */}
          {isTapToPayEnabled && isTTPEnabledToBeSelected && (
            <View className={'mb-4'}>
              <ListItemCard
                icon={<NfcIcon width={30} height={30} />}
                title="Tap to Pay on iPhone"
                subtitle={'Contactless payment'}
                onPress={handleTapToPay}
              />
            </View>
          )}

          <ListItemCard
            icon={<TextCursorInputIcon width={30} height={30} />}
            title="Manual Entry"
            subtitle="Manually enter the card details"
            onPress={handleKeyed}
          />
        </View>
      </View>
    </SafeAreaView>
  );
};

interface SubtotalProps {
  amount: string;
}

const Subtotal: React.FC<SubtotalProps> = ({amount}) => {
  return (
    <View className="flex flex-1 items-center justify-center">
      <Text className="text-white text-lg font-medium line-height-[28px] pb-4">
        {UI_MESSAGES.SUBTOTAL}
      </Text>

      <View className="items-center">
        <View className="flex flex-row items-baseline">
          <Text className={`${'text-[#0EA5E9]'}  mr-1 text-[36px] font-light`}>
            $
          </Text>
          <Text
            className={`text-[48px] font-light leading-[48px] ${'text-white'}`}>
            {amount}
          </Text>
        </View>
      </View>
    </View>
  );
};
