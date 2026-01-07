import React from 'react';
import {Text, Pressable} from 'react-native';
import {CircleCheck} from 'lucide-react-native';

interface AlertSucessProps {
  message: string;
  onDismiss: () => void;
}

const AlertSuccess: React.FC<AlertSucessProps> = ({message, onDismiss}) => {
  return (
    <Pressable
      onPress={onDismiss}
      hitSlop={{top: 10, bottom: 10, left: 10, right: 10}}
      className="mx-6 p-4 bg-surface-green rounded-2xl flex-row items-center absolute bottom-0 left-0 right-0 z-50">
      <CircleCheck width={17} height={17} className="text-success-dark mr-2" />
      <Text className="text-text-primary font-medium text-base">{message}</Text>
    </Pressable>
  );
};

export default AlertSuccess;
