import React, {useState, useEffect} from 'react';
import {View, TouchableOpacity, Text, StyleSheet} from 'react-native';
import AriseTextInput, {AriseTextInputProps} from './AriseTextInput';
import Eye from '../../../assets/eye.svg';
import EyeOff from '../../../assets/eye-off.svg';
import creditcardutils from 'creditcardutils';
import {getCardIcon} from '../../utils/card';
import DefaultCardIcon from '../../../assets/defaultCard.svg';
import {TextInputError} from './TextInputError';

const AriseCreditCardInput: React.FC<
  AriseTextInputProps & {errorMessage?: string; rules?: any}
> = ({value = '', onChangeText, errorMessage, ...props}) => {
  const [showCard, setShowCard] = useState(false);
  const [cardBrand, setCardBrand] = useState('');
  const [internalValue, setInternalValue] = useState(value);

  // Detect brand and sync internal value
  useEffect(() => {
    const digitsOnly = value.replace(/\s/g, '');
    setCardBrand(creditcardutils.parseCardType(digitsOnly));
    setInternalValue(value);
  }, [value]);

  // Apply formatting without forcing cursor position
  const handleChange = (raw: string) => {
    const digits = raw.replace(/\D/g, '');
    const oldDigits = internalValue.replace(/\D/g, '');

    // If digits haven't changed (only formatting/separators changed)
    // AND length is smaller (deletion), update without reformatting
    // This allows the user to delete a space without it forcing back immediately
    if (digits === oldDigits && raw.length < internalValue.length) {
      setInternalValue(raw);
      onChangeText?.(raw);
      return;
    }

    const limitedDigits = digits.slice(0, 16);
    const formatted = creditcardutils.formatCardNumber(limitedDigits);

    setInternalValue(formatted);
    onChangeText?.(formatted);
  };

  const handleBlur = (e: any) => {
    // Force reformat on blur to ensure consistency
    const digits = internalValue.replace(/\D/g, '').slice(0, 16);
    const formatted = creditcardutils.formatCardNumber(digits);
    if (formatted !== internalValue) {
      setInternalValue(formatted);
      onChangeText?.(formatted);
    }
    props.onBlur?.(e);
  };

  // Generate mask without altering spaces
  const maskedValue = internalValue.replace(/\d/g, '•');

  const renderCardBrandIcon = () => {
    if (!cardBrand) {
      return <DefaultCardIcon />;
    }
    return getCardIcon(cardBrand);
  };

  return (
    <>
      <View className="flex w-full relative">
        {/* Input */}
        <View className="w-full justify-center">
          <AriseTextInput
            {...props}
            value={internalValue}
            onChangeText={handleChange}
            keyboardType="numeric"
            placeholder="1234 5678 9876 5432"
            placeholderTextColor="#999"
            onBlur={handleBlur}
            style={[
              {
                fontVariant: ['tabular-nums'],
              },
              styles.input,
            ]}
            className={`w-full z-0 pl-[52] pr-12 ${
              showCard ? '' : 'text-transparent'
            }`}
          />

          {/* Overlay of dots with dynamic letterSpacing */}
          {!showCard && internalValue.length > 0 && (
            <View style={[styles.overlay, {zIndex: 50}]} pointerEvents="none">
              <Text
                style={[
                  {fontFamily: showCard ? '' : 'Optima'}, // This is the font that is used to display the masked text to keep the same spacing as the input
                  styles.maskedText,
                ]}>
                {maskedValue}
              </Text>
            </View>
          )}
        </View>

        {/* Brand icon */}
        <View
          className="absolute left-4 top-1/2 -translate-y-1/2 mt-1"
          style={{zIndex: 60}}>
          {renderCardBrandIcon()}
        </View>

        {/* Toggle eye */}
        <TouchableOpacity
          onPress={() => {
            setShowCard(v => !v);
          }}
          className={`absolute right-2 p-2 ${
            showCard ? 'top-[38px] right-[7px]' : 'top-[40px]'
          }`}
          style={{zIndex: 100}}
          testID="showCard"
          activeOpacity={0.7}>
          {showCard ? (
            <Eye color="gray" width={22} height={22} />
          ) : (
            <EyeOff color="gray" width={20} height={20} />
          )}
        </TouchableOpacity>
      </View>
      {errorMessage && <TextInputError message={errorMessage} />}
    </>
  );
};

const styles = StyleSheet.create({
  input: {
    fontSize: 16,
    lineHeight: 20,
    paddingVertical: 0,
  },
  overlay: {
    ...StyleSheet.absoluteFillObject,
    justifyContent: 'center',
    marginTop: 30,
    paddingLeft: 52,
    paddingRight: 48,
    backgroundColor: 'transparent',
  },
  maskedText: {
    fontSize: 16,
    lineHeight: 20,
    color: '#111827',
  },
});

export default AriseCreditCardInput;
