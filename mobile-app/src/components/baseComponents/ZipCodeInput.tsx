import React from 'react';
import {Controller, Control, FieldError} from 'react-hook-form';
import AriseTextInput from './AriseTextInput';
import {FORM_LABELS, FORM_PLACEHOLDERS} from '@/constants/messages';

interface ZipCodeInputProps {
  control: Control<any>;
  name: string;
  error?: FieldError;
  required?: boolean;
  className?: string;
  onBlur?: () => void;
}

const ZipCodeInput: React.FC<ZipCodeInputProps> = ({
  control,
  name,
  error,
  required = false,
  className = '',
  onBlur,
}) => {
  const formatZipCode = (text: string): string => {
    const digits = text.replace(/\D/g, '');

    if (digits.length > 5) {
      return `${digits.slice(0, 5)}-${digits.slice(5, 9)}`;
    }

    return digits;
  };

  const handleChangeText = (
    text: string,
    onChange: (value: string) => void,
  ) => {
    const formatted = formatZipCode(text);
    onChange(formatted);
  };

  return (
    <Controller
      control={control}
      name={name}
      render={({
        field: {onChange, onBlur: fieldOnBlur, value},
        fieldState: {error: fieldError},
      }) => (
        <AriseTextInput
          keyboardType="numeric"
          className={className}
          maxLength={10}
          required={required}
          label={FORM_LABELS.BILLING_ZIP_CODE}
          placeholder={FORM_PLACEHOLDERS.ZIP_CODE}
          value={value}
          onChangeText={text => handleChangeText(text, onChange)}
          onBlur={() => {
            fieldOnBlur();
            onBlur?.();
          }}
          error={!!(error || fieldError)}
          errorMessage={error?.message || fieldError?.message}
        />
      )}
    />
  );
};

export default ZipCodeInput;
