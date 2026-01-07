import classNames from 'classnames';
import React, {ReactNode} from 'react';
import {Pressable, PressableProps, View} from 'react-native';

interface AriseListButtonProps extends PressableProps {
  type?: 'primary' | 'secondary' | 'outline';
  left: ReactNode;
  right?: ReactNode;
  loading?: boolean;
  error?: boolean;
}

const AriseListButton: React.FC<AriseListButtonProps> = ({
  type = 'primary',
  left,
  right,
  loading,
  error,
  ...props
}) => {
  const buttonClass = classNames('button', {
    'bg-black': type === 'primary',
    'bg-gray-300': type === 'secondary',
    'bg-elevation-1': type === 'outline',
  });

  return (
    <Pressable
      className={`flex flex-row justify-between w-full items-center h-20 rounded-2xl ${buttonClass} ${
        loading ? 'bg-gray-100' : ''
      }`}
      {...props}>
      <View className="ml-4 left flex items-center flex-row justify-center h-full">
        {left}
      </View>

      {right && <View className="right flex items-center mr-4 ">{right}</View>}
    </Pressable>
  );
};

export default AriseListButton;
