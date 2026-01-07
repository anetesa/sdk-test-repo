import React, {useEffect, useRef, useState} from 'react';
import {
  View,
  TouchableOpacity,
  TouchableWithoutFeedback,
  Keyboard,
} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';
import {NativeStackScreenProps} from '@react-navigation/native-stack';
import {ChevronLeft} from 'lucide-react-native';
import AriseButton from '@/components/baseComponents/AriseButton';
import {formatAmountForDisplay} from '@/utils/currency';
import {useTipCalculation} from '@/hooks/useTipCalculation';
import {SCREEN_NAMES} from '@/constants/routes';
import type {NewTransactionStackParamList} from '@/types/navigation';
import {showErrorAlert} from '@/stores/alertStore';
import {getBackendErrorMessage} from '@/utils/backendErrorMessage';
import {
  LogoAndTitle,
  TipAmountSection,
  AmountSummary,
} from '@/components/tipAnalysis';
import {SelectTheCardType} from '@/components/tipAnalysis/SelectTheCardType';

type ZCPTipsAnalysisScreenProps = NativeStackScreenProps<
  NewTransactionStackParamList,
  'ZCPTipsAnalysis'
>;

const ZCPTipsAnalysisScreen: React.FC<ZCPTipsAnalysisScreenProps> = ({
  navigation,
  route,
}) => {
  const {transactionDetails, isSurcharge, isTipEnabled, defaultSurchargeRate} =
    route.params;
  // Used only for backend calculation (calculateAmount). Do not silently coerce invalid values to 0.
  const baseAmountInDollars = Number(transactionDetails.amount);
  const [selectedCard, setSelectedCard] = useState('');
  const {
    tipOptions,
    selectedTipId,
    customTipAmount,
    showCustomValue,
    tipAmount,
    totalAmount,
    calculationData,
    isLoading,
    isError,
    error,
    hasTipSelection,
    handleTipOptionPress,
    handleCustomValuePress,
    setCustomTipAmount,
  } = useTipCalculation({baseAmountInDollars});

  const lastShownErrorKeyRef = useRef<string | null>(null);

  useEffect(() => {
    if (!error) {
      return;
    }

    const errorCode =
      (error as any)?.code ??
      (error as any)?.ErrorCode ??
      (error as any)?.userInfo?.ErrorCode ??
      (error as any)?.userInfo?.errorCode;
    const message = getBackendErrorMessage(error);

    // De-dupe: react-query and re-renders can surface the same error multiple times.
    const key = `${errorCode ?? 'UNKNOWN'}|${message}`;
    if (lastShownErrorKeyRef.current === key) {
      return;
    }
    lastShownErrorKeyRef.current = key;

    showErrorAlert(message);
  }, [error]);

  const handleTapToPay = () => {
    const backendData = isSurcharge
      ? selectedCard === 'credit'
        ? calculationData?.creditCard
        : calculationData?.debitCard
      : calculationData?.creditCard;

    const updatedTransactionDetails = {
      ...transactionDetails,
      // Keep as string for the native bridge.
      // Use our existing formatting to produce a stable "8.70" style string.
      amount: formatAmountForDisplay({dollars: backendData.totalAmount}),
      tip: formatAmountForDisplay({dollars: tipAmount}),
    };

    if (isSurcharge && selectedCard === 'credit' && defaultSurchargeRate) {
      updatedTransactionDetails.customData = {
        surchargeRate: defaultSurchargeRate.toString(),
      };
    }

    navigation.navigate(SCREEN_NAMES.LOADING_TAP_TO_PAY, {
      transactionDetails: updatedTransactionDetails,
    });
  };

  const checkIfDisabled = () => {
    if (isError || isLoading) {
      return true;
    }
    if (isTipEnabled && !isSurcharge) {
      return !hasTipSelection;
    }
    if (isSurcharge && !isTipEnabled) {
      return !selectedCard;
    }
    if (isTipEnabled && isSurcharge) {
      return !hasTipSelection || !selectedCard;
    }
    return false;
  };

  return (
    <SafeAreaView className="flex-1 bg-surface-background">
      <View className="mt-6 z-50">
        <View className="self-start pl-4">
          <TouchableOpacity
            onPress={() => navigation.goBack()}
            className="w-12 h-12 items-center justify-center"
            hitSlop={{top: 10, bottom: 10, left: 10, right: 10}}
            style={{zIndex: 50}}>
            <ChevronLeft
              width={20}
              height={20}
              strokeWidth={1.5}
              color="#3F3F46"
            />
          </TouchableOpacity>
        </View>
      </View>

      <TouchableWithoutFeedback onPress={Keyboard.dismiss}>
        <View className="flex-1">
          <LogoAndTitle isSurcharge={isSurcharge} isTipEnabled={isTipEnabled} />

          {isSurcharge && (
            <SelectTheCardType
              calculationData={calculationData}
              selectedCard={selectedCard}
              setSelectedCard={setSelectedCard}
            />
          )}

          {isTipEnabled && (
            <TipAmountSection
              tipOptions={tipOptions}
              selectedTipId={selectedTipId}
              baseAmountInDollars={baseAmountInDollars}
              showCustomValue={showCustomValue}
              customTipAmount={customTipAmount}
              onTipOptionPress={handleTipOptionPress}
              onCustomValuePress={handleCustomValuePress}
              onCustomTipAmountChange={setCustomTipAmount}
            />
          )}

          <AmountSummary
            baseAmountInDollars={baseAmountInDollars}
            tipAmount={tipAmount}
            totalAmount={totalAmount}
            calculationData={calculationData}
            isLoading={isLoading}
            isError={isError}
            isTipEnabled={isTipEnabled}
            cardSelected={selectedCard}
            isSurcharge={isSurcharge}
          />

          <View className="px-6 pb-1 pt-3">
            <AriseButton
              title="Tap to Pay on iPhone"
              onPress={handleTapToPay}
              type="primary"
              disabled={checkIfDisabled()}
            />
          </View>
        </View>
      </TouchableWithoutFeedback>
    </SafeAreaView>
  );
};

export default ZCPTipsAnalysisScreen;
