import React, {useEffect, useState} from 'react';
import {Controller, Control, FieldError, useWatch} from 'react-hook-form';
import AriseTextInput from './AriseTextInput';
import creditcardutils from 'creditcardutils';
import {StyleSheet, Text, View} from 'react-native';
import {TextInputError} from './TextInputError';
import {FORM_LABELS, FORM_PLACEHOLDERS} from '@/constants/messages';

interface CVVInputProps {
  control: Control<any>;
  name: string;
  error?: FieldError;
  required?: boolean;
  className?: string;
  onBlur?: () => void;
}

const CVVInput: React.FC<CVVInputProps> = ({
  control,
  name,
  error,
  required = false,
  className = '',
  onBlur,
}) => {
  // Watch the card number to detect card type
  const cardNumber = useWatch({
    control,
    name: 'cardNumber',
  });
  const [maxLength, setMaxLength] = useState(4);

  // Detect card type and adjust maxLength
  useEffect(() => {
    if (cardNumber) {
      const digitsOnly = cardNumber.replace(/\s/g, '');
      const cardType = creditcardutils.parseCardType(digitsOnly);
      const isAmex = cardType === 'amex';
      setMaxLength(isAmex ? 4 : 3);
    } else {
      // Default to 4 for flexibility
      setMaxLength(4);
    }
  }, [cardNumber]);

  const formatCVV = (text: string): string => {
    // Remove all non-digits
    const digits = text.replace(/\D/g, '');
    // Limit based on detected card type
    return digits.slice(0, maxLength);
  };

  const handleChangeText = (
    text: string,
    onChange: (value: string) => void,
  ) => {
    const formatted = formatCVV(text);
    onChange(formatted);
  };

  /**
   * Adjusts the maxLength for the CVV input to handle an edge case.
   * If a user first enters a 4-digit CVV (e.g., for an AMEX card) and then
   * changes the card number to a type that expects a 3-digit CVV, this
   * function ensures the user can still edit the input by temporarily
   * allowing a maxLength of 4, making it possible to delete the extra digit.
   */
  const getAdjustedMaxLength = (currentValue: string, newMaxLength: number) => {
    const isCorrectingFromFourToThreeDigits =
      currentValue?.length === 4 && newMaxLength === 3;
    if (isCorrectingFromFourToThreeDigits) {
      return 4;
    }
    return newMaxLength;
  };

  return (
    <Controller
      control={control}
      name={name}
      render={({
        field: {onChange, onBlur: fieldOnBlur, value},
        fieldState: {error: fieldError},
      }) => {
        const maskedValue = (value || '').replace(/./g, '•');
        return (
          <>
            <View className="w-full relative justify-center">
              <AriseTextInput
                keyboardType="numeric"
                maxLength={getAdjustedMaxLength(value, maxLength)}
                className={`${className} text-transparent`}
                required={required}
                label={FORM_LABELS.SECURITY_CODE}
                placeholder={
                  maxLength === 4
                    ? FORM_PLACEHOLDERS.CVV_4_DIGITS
                    : FORM_PLACEHOLDERS.CVV_3_DIGITS
                }
                value={value as string}
                onChangeText={text => handleChangeText(text, onChange)}
                onBlur={() => {
                  fieldOnBlur();
                  onBlur?.();
                }}
                error={!!(error || fieldError)}
              />
              {value?.length > 0 && (
                <View
                  style={[styles.overlay, {zIndex: 50}]}
                  pointerEvents="none">
                  <Text style={styles.maskedText}>{maskedValue}</Text>
                </View>
              )}
            </View>
            {error?.message ||
              (fieldError && (
                <TextInputError
                  message={error?.message || fieldError?.message}
                />
              ))}
          </>
        );
      }}
    />
  );
};

const styles = StyleSheet.create({
  overlay: {
    ...StyleSheet.absoluteFillObject,
    justifyContent: 'center',
    paddingHorizontal: 16,
    marginTop: 30,
    backgroundColor: 'transparent',
  },
  maskedText: {
    fontSize: 16,
    lineHeight: 20,
    color: '#111827',
    fontFamily: 'Optima',
  },
});

export default CVVInput;
