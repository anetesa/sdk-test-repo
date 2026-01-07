import React from 'react';
import {View} from 'react-native';
import AriseTextInput from '@/components/baseComponents/AriseTextInput';
import {Controller, Control} from 'react-hook-form';
import {TextInputError} from '@/components/baseComponents/TextInputError';
import {VALIDATION_MESSAGES, FORM_PLACEHOLDERS} from '@/constants/messages';

interface EmailInputProps {
  control: Control<any>;
  name: string;
  placeholder?: string;
  className?: string;
  returnKeyType?: 'next' | 'done';
  onSubmitEditing?: () => void;
  required?: boolean;
  isError?: boolean;
}

const EmailInput: React.FC<EmailInputProps> = ({
  control,
  name,
  placeholder = FORM_PLACEHOLDERS.EMAIL,
  className,
  returnKeyType = 'next',
  required = true,
  isError,
}) => {
  return (
    <Controller
      control={control}
      name={name}
      rules={{
        required: VALIDATION_MESSAGES.EMAIL_REQUIRED,
        pattern: {
          value:
            /^[a-zA-Z0-9!#$%&*+\-/=?^_`{|}~.]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/,
          message: VALIDATION_MESSAGES.EMAIL_INVALID,
        },
      }}
      render={({field: {onChange, onBlur, value}, fieldState: {error}}) => (
        <View className={className}>
          <AriseTextInput
            placeholder={placeholder}
            returnKeyType={returnKeyType}
            keyboardType="email-address"
            inputMode="email"
            autoCapitalize="none"
            onBlur={onBlur}
            onChangeText={onChange}
            required={required}
            value={value}
            error={!!error || isError}
          />
          {error && <TextInputError message={error.message} />}
        </View>
      )}
    />
  );
};

export default EmailInput;
