import React from 'react';
import {Controller, Control, FieldError} from 'react-hook-form';
import AriseTextInput from './AriseTextInput';
import {FORM_LABELS, FORM_PLACEHOLDERS} from '@/constants/messages';

interface ExpirationDateProps {
  control: Control<any>;
  name: string;
  error?: FieldError;
  required?: boolean;
  className?: string;
  onBlur?: () => void;
}

const ExpirationDate: React.FC<ExpirationDateProps> = ({
  control,
  name,
  error,
  required = false,
  className = '',
  onBlur,
}) => {
  const formatExpirationDate = (text: string): string => {
    // Remove all non-digits
    const digits = text.replace(/\D/g, '');

    // Limit to 4 digits
    const limited = digits.slice(0, 4);

    // Format as MM/YY
    if (limited.length >= 2) {
      const month = limited.slice(0, 2);
      const year = limited.slice(2);
      return `${month}${year.length > 0 ? '/' + year : ''}`;
    }

    return limited;
  };

  const handleChangeText = (
    text: string,
    onChange: (value: string) => void,
  ) => {
    const formatted = formatExpirationDate(text);
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
          maxLength={5}
          required={required}
          label={FORM_LABELS.EXPIRATION_DATE}
          placeholder={FORM_PLACEHOLDERS.EXPIRATION_DATE}
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

export default ExpirationDate;
