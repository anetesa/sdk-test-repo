import classNames from 'classnames';
import React, {useEffect, useRef, useState} from 'react';
import {
  Animated,
  TextInput,
  TextInputProps,
  View,
  Text,
  TouchableOpacity,
} from 'react-native';
import OutsidePressHandler from 'react-native-outside-press';
import {TextInputError} from '@/components/baseComponents/TextInputError';
import {logger} from '@/utils/logger';

export interface AriseTextInputProps extends TextInputProps {
  placeholder?: string;
  value?: string;
  required: boolean;
  onChangeText?: (text: string) => void;
  label?: string;
  items?: Array<{key: string; value: string}>;
  autoCompleteEnabled?: boolean;
  keyboardType?: TextInputProps['keyboardType'];
  autoCapitalize?: TextInputProps['autoCapitalize'];
  autoCorrect?: boolean;
  className?: string;
  error?: boolean;
  ref?: React.RefObject<TextInput>;
  errorMessage?: string;
  onSelect?: (val: any) => void;
}

const AriseTextInput: React.FC<AriseTextInputProps> = ({
  placeholder = 'Enter text...',
  value = '',
  required = false,
  autoCompleteEnabled = false,
  onChangeText = () => {},
  keyboardType = 'default',
  autoCapitalize = 'none',
  autoCorrect = false,
  items,
  error,
  errorMessage,
  onSelect,
  className = '',
  ref,
  label,
  ...rest
}) => {
  const inputRef = useRef<TextInput>(null);
  const containerRef = useRef<View>(null);
  const [isVisible, setIsVisible] = useState(false);
  const [dropdownPosition, setDropdownPosition] = useState(0);
  const hasMeasured = useRef(false);
  const combinedClassNames = classNames(
    'box-border overflow-hidden rounded-xl bg-elevation-0 px-4 py-4 border border-elevation-08 focus:border-brand-main focus:border-2 text-text-primary text-base leading-5',
    className,
  );

  useEffect(() => {
    if (items && autoCompleteEnabled) {
      if (items.length > 0 && value.length > 2) {
        setIsVisible(true);
      } else {
        setIsVisible(false);
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [items]);

  const shakeAnimation = useRef(new Animated.Value(0)).current;

  const startShake = () => {
    Animated.sequence([
      Animated.timing(shakeAnimation, {
        toValue: 5,
        duration: 100,
        useNativeDriver: true,
      }),
      Animated.timing(shakeAnimation, {
        toValue: -5,
        duration: 100,
        useNativeDriver: true,
      }),
      Animated.timing(shakeAnimation, {
        toValue: 5,
        duration: 100,
        useNativeDriver: true,
      }),
      Animated.timing(shakeAnimation, {
        toValue: 0,
        duration: 100,
        useNativeDriver: true,
      }),
    ]).start();
  };

  useEffect(() => {
    if (error) {
      startShake();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [error]);

  const handleFocus = () => {
    if (autoCompleteEnabled && items && value.length > 2) {
      setIsVisible(true);
    }
  };

  const measureInput = () => {
    if (inputRef.current && !hasMeasured.current) {
      try {
        inputRef.current.measure(
          (
            _x: number,
            _y: number,
            _eventwidth: number,
            height: number,
            _pageX: number,
            _pageY: number,
          ) => {
            setDropdownPosition(height);
            hasMeasured.current = true;
          },
        );
      } catch (measureError) {
        logger.error(measureError, 'Error measuring text');
        // Fallback to default height if measurement fails
        return 40;
      }
    }
    return undefined;
  };

  // Only measure once when component mounts, not on every value change
  useEffect(() => {
    if (autoCompleteEnabled && items) {
      // Delay measurement to ensure component is fully rendered
      const timer = setTimeout(() => {
        measureInput();
      }, 100);

      return () => clearTimeout(timer);
    }

    return () => {};
  }, [autoCompleteEnabled, items]);

  const handleItemSelect = (item: any) => {
    if (onSelect) {
      onSelect(item);
    }
    if (autoCompleteEnabled && isVisible) {
      setIsVisible(false);
    }
  };

  // Mounting an outside-press handler around every TextInput can interfere with
  // iOS text selection gestures (loupe/handles) under Fabric. Only enable it
  // when the autocomplete dropdown is actually visible.
  const shouldHandleOutsidePress = Boolean(
    autoCompleteEnabled && items && isVisible,
  );

  const inputBody = (
    <Animated.View style={{transform: [{translateX: shakeAnimation}]}}>
      <TextInput
        ref={inputRef}
        className={`z-20 outline-2 ${combinedClassNames}${
          error
            ? ' bg-error-1  focus:border-b-error-text  focus:border-x-error-2 focus:border-t-error-2  '
            : ''
        }`}
        placeholder={placeholder}
        value={value}
        onChangeText={onChangeText}
        keyboardType={keyboardType}
        placeholderTextColor="#A1A1AA"
        autoCapitalize={autoCapitalize}
        autoCorrect={autoCorrect}
        onFocus={handleFocus}
        {...rest}
      />

      {isVisible && items && items.length > 0 && (
        <View
          ref={containerRef}
          className="absolute bg-white border border-gray-100 z-10 w-full pt-14  rounded-xl shadow-lg"
          style={{
            top: dropdownPosition - 55,
            transform: [{scale: 1.01}],
          }}>
          {items.map((item, index) => (
            <TouchableOpacity
              key={index}
              onPress={() => handleItemSelect(item)}>
              <Text className="p-4">{item.value}</Text>
            </TouchableOpacity>
          ))}
        </View>
      )}
    </Animated.View>
  );

  return (
    <>
      <View className="flex z-40">
        {label && (
          <View className="flex  flex-row mb-2">
            <Text className="font-medium text-[14px] leading-[20px] text-text-primary">
              {label}
            </Text>
            {!required && (
              <Text className="font-medium ml-2 text-text-tretiary">
                Optional
              </Text>
            )}
          </View>
        )}
        {shouldHandleOutsidePress ? (
          <OutsidePressHandler onOutsidePress={() => setIsVisible(false)}>
            {inputBody}
          </OutsidePressHandler>
        ) : (
          inputBody
        )}
      </View>

      {errorMessage && <TextInputError message={errorMessage} />}
    </>
  );
};

export default AriseTextInput;
