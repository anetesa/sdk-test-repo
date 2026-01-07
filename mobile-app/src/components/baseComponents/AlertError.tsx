import {Text, Pressable} from 'react-native';
import ErrorIcon from '../../../assets/error-icon.svg';
import React from 'react';

interface AlertErrorProps {
  message: string;
  onDismiss: () => void;
}

const AlertError = ({message, onDismiss}: AlertErrorProps) => {
  return (
    <Pressable
      onPress={onDismiss}
      hitSlop={{top: 10, bottom: 10, left: 10, right: 10}}
      className="mx-6 p-4 bg-surface-red rounded-2xl flex-row items-center absolute bottom-0 left-0 right-0 z-50">
      <ErrorIcon width={20} height={20} />
      <Text className="text-text-primary text-base font-medium ml-3 flex-1">
        {message}
      </Text>
    </Pressable>
  );
};

export default AlertError;
