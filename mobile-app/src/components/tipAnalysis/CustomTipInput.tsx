import React, {useState, useCallback, useEffect, useRef} from 'react';
import {View, Text, Keyboard, TextInput, TouchableOpacity} from 'react-native';

interface CustomTipInputProps {
  showCustomValue: boolean;
  customTipAmount: number;
  onCustomTipAmountChange: (amount: number) => void;
}

export const CustomTipInput: React.FC<CustomTipInputProps> = ({
  showCustomValue,
  customTipAmount,
  onCustomTipAmountChange,
}) => {
  // Store raw numeric string (like "1234" for $12.34)
  const [rawAmount, setRawAmount] = useState<string>('');
  const [isFocused, setIsFocused] = useState<boolean>(false);
  const inputRef = useRef<TextInput>(null);

  // Reset when customTipAmount is reset to 0 externally
  useEffect(() => {
    if (customTipAmount === 0) {
      setRawAmount('');
    }
  }, [customTipAmount]);

  // Focus input when container is pressed
  const handleContainerPress = useCallback(() => {
    inputRef.current?.focus();
  }, []);

  // Handle text input - extract numbers and update immediately
  const handleTextChange = useCallback(
    (text: string) => {
      // Extract only numbers
      const numbersOnly = text.replace(/[^0-9]/g, '');
      // Limit length (7 digits = max $999,999.99)
      const limited = numbersOnly.slice(0, 7);

      // Update state immediately - no async updates
      setRawAmount(limited);

      // Send to parent
      const centsValue = parseInt(limited, 10) || 0;
      onCustomTipAmountChange(centsValue);
    },
    [onCustomTipAmountChange],
  );

  // Simple, fast formatting function (no complex calculations)
  const formatCentsToDisplay = (cents: string): string => {
    if (!cents || cents === '0') {
      return '';
    }

    const num = parseInt(cents, 10);
    const dollars = Math.floor(num / 100);
    const remainingCents = num % 100;

    return `${dollars}.${remainingCents.toString().padStart(2, '0')}`;
  };

  const displayValue = formatCentsToDisplay(rawAmount);

  const handleSubmitEditing = useCallback(() => {
    Keyboard.dismiss();
  }, []);

  const handleFocus = useCallback(() => {
    setIsFocused(true);
  }, []);

  const handleBlur = useCallback(() => {
    setIsFocused(false);
  }, []);

  if (!showCustomValue) {
    return null;
  }

  // Show raw numbers in input, like your EnterAmountScreen

  return (
    <View className="mt-1">
      <TouchableOpacity
        activeOpacity={1}
        onPress={handleContainerPress}
        className={`flex-row bg-elevation-0 rounded-xl border px-4 py-4 ${
          isFocused ? 'border-[#0369A1] border-2' : 'border-elevation-08'
        }`}>
        <Text className="text-sm text-text-secondary mt-[3px] mr-2">$</Text>

        {/* Visible formatted text */}
        <View className="flex-1 flex-row items-center" style={{minHeight: 24}}>
          <Text
            className="text-base text-text-primary font-normal"
            style={{textAlign: 'left'}}>
            {displayValue || ''}
          </Text>
          {displayValue === '' && (
            <Text className="text-base font-medium" style={{color: '#A1A1AA'}}>
              0.00
            </Text>
          )}

          {/* Small TextInput for cursor - positioned right after text */}
          <TextInput
            ref={inputRef}
            style={{
              width: 2,
              height: 24,
              color: 'transparent',
              backgroundColor: 'transparent',
              marginLeft: 1,
            }}
            value={rawAmount}
            onChangeText={handleTextChange}
            onFocus={handleFocus}
            onBlur={handleBlur}
            keyboardType="number-pad"
            returnKeyType="done"
            onSubmitEditing={handleSubmitEditing}
            blurOnSubmit={true}
            selectionColor="#0369A1"
          />
        </View>
      </TouchableOpacity>
    </View>
  );
};
