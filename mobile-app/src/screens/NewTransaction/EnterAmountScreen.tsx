import AriseButton from '@/components/baseComponents/AriseButton';
import Header from '@/components/Header';
import NumberPad from '@/components/numberPad/NumberPad';
import React, {useEffect} from 'react';
import {View, Text, TextInput} from 'react-native';
import {useTransactionStore} from '@/stores/transactionStore';
import {SafeAreaView} from 'react-native-safe-area-context';
import {useMerchantSettings} from '@/hooks/queries/useMerchantSettings';
import {useUserStore} from '@/stores/userStore';
import {
  ALERT_MESSAGES,
  NAVIGATION_TITLES,
  UI_MESSAGES,
} from '@/constants/messages';
import type {NativeStackScreenProps} from '@react-navigation/native-stack';
import type {NewTransactionStackParamList} from '@/types/navigation';
import {useAmountInput} from '@/hooks/useAmountInput';
import {SCREEN_NAMES} from '@/constants/routes';
import {PENDO} from '@/utils/pendo';

type Props = NativeStackScreenProps<
  NewTransactionStackParamList,
  'EnterAmount'
>;
interface AmountEntryProps {
  amount: string;
  onAmountChange: (text: string) => void;
  isMaxAmountExceeded?: boolean;
  maxTransactionAmount?: number;
  enterAmountPrompt: string;
  detailedAmount: string;
}
const EnterAmountScreen: React.FC<Props> = ({navigation, route}: Props) => {
  const {
    title = NAVIGATION_TITLES.NEW_TRANSACTION,
    enterAmountPrompt = UI_MESSAGES.ENTER_AMOUNT_PROMPT,
    maxAmount = 0,
    defaultAmount = '',
    continueButtonText = UI_MESSAGES.SELECT_PAYMENT_METHOD,
    continueFunction = () => {
      navigation.navigate(SCREEN_NAMES.CHOOSE_METHOD);
    },
    detailedAmount = '',
  } = route.params ?? {};
  const {reset} = useTransactionStore();
  const user = useUserStore(state => state);
  const {
    amount,
    displayAmount,
    isAmountEntered,
    handleNumberPress,
    handleBackspace,
    handleTextInput,
  } = useAmountInput(defaultAmount);

  useEffect(() => {
    if (PENDO && continueButtonText) {
      PENDO.screenContentChanged?.();
    }
  }, [continueButtonText]);

  const longPressTimeoutRef = React.useRef<NodeJS.Timeout | null>(null);

  const {data: merchantSettings} = useMerchantSettings(
    user.merchantId || undefined,
  );

  const maxTransactionAmount =
    maxAmount || merchantSettings?.merchantSettings?.maxTransactionAmount;

  const isMaxAmountExceeded =
    maxTransactionAmount != null &&
    maxTransactionAmount > 0 &&
    amount / 100 > maxTransactionAmount;

  const handlePaymentMethodPress = () => {
    if (isAmountEntered && !isMaxAmountExceeded) {
      continueFunction(amount);
    }
  };

  const handleBackspacePressIn = () => {
    if (longPressTimeoutRef.current) {
      clearInterval(longPressTimeoutRef.current);
    }
    handleBackspace();
    longPressTimeoutRef.current = setInterval(() => {
      handleBackspace();
    }, 200);
  };

  const handlePressOut = () => {
    if (longPressTimeoutRef.current) {
      clearInterval(longPressTimeoutRef.current);
    }
  };

  const handleBack = () => reset();
  return (
    <SafeAreaView edges={['top']} className="flex-1 bg-dark-page-bg">
      <Header showBack={true} title={title} onBack={handleBack} />
      <View className={'flex-1'}>
        <AmountEntry
          amount={displayAmount}
          onAmountChange={handleTextInput}
          isMaxAmountExceeded={isMaxAmountExceeded}
          maxTransactionAmount={maxTransactionAmount || undefined}
          enterAmountPrompt={enterAmountPrompt}
          detailedAmount={detailedAmount}
        />
      </View>
      <View
        className={'justify-between bg-surface-background items-center p-4'}
        style={{height: 452}}>
        <View className={'px-6 pb-3 pt-2'}>
          <NumberPad
            onNumberPress={(_str, num) => handleNumberPress(num)}
            onBackspacePressIn={handleBackspacePressIn}
            onBackspacePressOut={handlePressOut}
          />
        </View>
        <View className={'flex w-full pb-8'}>
          <AriseButton
            onPress={handlePaymentMethodPress}
            disabled={!isAmountEntered || isMaxAmountExceeded || amount === 0}
            title={continueButtonText}
            type="primary"
            nativeID={continueButtonText}
            accessibilityLabel={continueButtonText}
          />
        </View>
      </View>
    </SafeAreaView>
  );
};

const AmountEntry: React.FC<AmountEntryProps> = ({
  amount,
  onAmountChange,
  isMaxAmountExceeded,
  maxTransactionAmount,
  enterAmountPrompt,
  detailedAmount,
}) => {
  const isZero = amount === '0.00';

  return (
    <View className="flex flex-1 items-center justify-center">
      <Text className="text-white text-lg font-medium line-height-[28px] pb-2">
        {enterAmountPrompt}
      </Text>

      <View className="items-center">
        <View className="flex flex-row items-baseline">
          <Text
            testID="amount-dollar-sign"
            className={`${
              isZero ? 'text-white-25-alpha' : 'text-[#0EA5E9]'
            }  mr-1 text-[36px] font-light`}>
            $
          </Text>

          <TextInput
            className={'text-[48px] font-light leading-[55px] text-white'}
            style={{padding: 0, writingDirection: 'rtl', textAlign: 'right'}}
            placeholderTextColor={'#FFFFFF40'}
            value={amount === '0.00' ? '' : amount}
            placeholder="0.00"
            onChangeText={onAmountChange}
            autoFocus={true}
            selectionColor={'#0EA5E9'}
            testID="amount-text-input"
            showSoftInputOnFocus={false}
          />
        </View>
        {detailedAmount && (
          <Text className="text-text-faded text-base font-normal line-height-[20px]">
            {detailedAmount}
          </Text>
        )}

        {isMaxAmountExceeded && (
          <Text className="text-error-main mt-2 text-base font-normal">
            {ALERT_MESSAGES.MAX_AMOUNT_EXCEEDED}
            {maxTransactionAmount?.toLocaleString()}
          </Text>
        )}
      </View>
    </View>
  );
};

export default EnterAmountScreen;
