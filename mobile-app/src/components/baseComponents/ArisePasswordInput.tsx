import React, {useState, useEffect} from 'react';
import {View, TouchableOpacity} from 'react-native';
import AriseTextInput, {AriseTextInputProps} from './AriseTextInput';
import Eye from '../../../assets/eye.svg';
import EyeOff from '../../../assets/eye-off.svg';
import {Controller, Control} from 'react-hook-form';
import {useWatch} from 'react-hook-form';
import {TextInputError} from '@/components/baseComponents/TextInputError';
import {VALIDATION_MESSAGES} from '@/constants/messages';

const ArisePasswordInput: React.FC<
  AriseTextInputProps & {
    control: Control<any>;
    name: string;
    isError?: boolean;
    navigation?: any;
    rules?: any;
  }
> = ({control, name, isError, navigation, rules, ...props}) => {
  const [showPassword, setShowPassword] = useState<boolean>(false);
  const passwordValue = useWatch({control, name});
  const togglePasswordVisibility = () => {
    setShowPassword(prevState => !prevState);
  };

  useEffect(() => {
    // clear the form when the user navigates away from the screen
    const unsubscribe = navigation.addListener('blur', () => {
      setShowPassword(false);
    });

    return unsubscribe;
  }, [navigation]);

  return (
    <View className="relative w-full">
      <Controller
        control={control}
        name={name}
        rules={
          rules || {
            required: VALIDATION_MESSAGES.PASSWORD_REQUIRED,
            minLength: {
              value: 3,
              message: VALIDATION_MESSAGES.PASSWORD_MIN_LENGTH_3,
            },
          }
        }
        render={({field: {onChange, onBlur, value}, fieldState: {error}}) => (
          <>
            <AriseTextInput
              value={value}
              onChangeText={onChange}
              secureTextEntry={!showPassword}
              onBlur={onBlur}
              error={!!error || isError}
              {...props}
            />
            {passwordValue?.length > 0 && (
              <TouchableOpacity
                onPress={togglePasswordVisibility}
                className={`absolute right-2 p-2 ${
                  showPassword ? 'top-[20px] right-[7px]' : 'top-[21px]'
                }`}
                style={{zIndex: 100}}
                activeOpacity={0.7}
                testID="showPassword">
                {showPassword ? (
                  <Eye color="gray" width={22} height={22} testID="eye-icon" />
                ) : (
                  <EyeOff
                    color="gray"
                    width={20}
                    height={20}
                    testID="eye-off-icon"
                  />
                )}
              </TouchableOpacity>
            )}
            {error && <TextInputError message={error.message} />}
          </>
        )}
      />
    </View>
  );
};

export default ArisePasswordInput;
