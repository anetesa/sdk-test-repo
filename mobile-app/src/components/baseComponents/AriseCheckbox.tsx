import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  TouchableOpacityProps,
} from 'react-native';
import {Check} from 'lucide-react-native';

export interface AriseCheckboxProps extends TouchableOpacityProps {
  checked: boolean;
  onPress: () => void;
  label?: string;
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  nativeID?: string;
}

const AriseCheckbox: React.FC<AriseCheckboxProps> = ({
  checked,
  onPress,
  label,
  size = 'md',
  disabled = false,
  className = '',
  nativeID,
  ...props
}) => {
  const sizeClasses = {
    sm: 'w-3 h-3',
    md: 'w-4 h-4',
    lg: 'w-5 h-5',
  };

  const iconSizes = {
    sm: 8,
    md: 10,
    lg: 12,
  };

  return (
    <TouchableOpacity
      onPress={onPress}
      className={`flex-row items-center ${className}`}
      activeOpacity={0.7}
      disabled={disabled}
      // @ts-ignore - nativeID is supported but not in types
      nativeID={nativeID}
      {...props}>
      <View
        className={`${
          sizeClasses[size]
        } border mr-2 items-center justify-center ${
          checked
            ? 'bg-brand-main border-brand-main'
            : disabled
            ? 'border-gray-300 bg-gray-100'
            : 'border-elevation-24 bg-elevation-02'
        }`}
        style={{borderRadius: 4}}>
        {checked && (
          <Check
            size={iconSizes[size]}
            color={disabled ? '#9CA3AF' : 'white'}
            strokeWidth={3}
          />
        )}
      </View>
      {label && (
        <Text
          className={`text-base font-medium ${
            disabled ? 'text-gray-400' : 'text-text-primary'
          }`}>
          {label}
        </Text>
      )}
    </TouchableOpacity>
  );
};

export default AriseCheckbox;
