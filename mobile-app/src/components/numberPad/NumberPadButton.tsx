import React, {FC} from 'react';
import {Pressable, PressableProps, Text} from 'react-native';

interface NumberPadButtonProps extends PressableProps {
  value: string;
  Width?: string;
  testID?: string;
}

const NumberPadButton: FC<NumberPadButtonProps> = ({
  value,
  Width = '',
  className,
  testID,
  ...rest
}) => {
  return (
    <Pressable
      accessibilityLabel={value}
      testID={testID}
      nativeID={value}
      className={`h-16 bg-white rounded-2xl items-center justify-center border border-elevation-08 ${
        className ? className : ''
      }`}
      style={{
        shadowColor: 'rgba(0,0,0,0.05)',
        shadowOffset: {width: 0, height: 1},
        shadowOpacity: 1,
        shadowRadius: 2,
        elevation: 1, // Android
      }}
      {...rest}>
      <Text className="text-2xl font-normal">{value}</Text>
    </Pressable>
  );
};

export default NumberPadButton;
