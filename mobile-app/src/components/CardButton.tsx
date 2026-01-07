import React from 'react';
import {Text, Pressable, View, PressableProps} from 'react-native';
import type {FC, ReactNode} from 'react';
import AriseCard from './baseComponents/AriseCard';

interface CardButtonProps extends PressableProps {
  icon: ReactNode;
  name: string;
  onPress?: () => void;
}

const CardButton: FC<CardButtonProps> = ({
  icon,
  name,
  onPress,
  className,
  ...rest
}) => {
  return (
    <Pressable onPress={onPress} {...rest}>
      <AriseCard className="py-3 px-4">
        <View className="flex justify-center items-center my-5">
          <View className="items-center justify-center flex bg-dark-elavation-1  w-10 h-10 rounded-full mb-2">
            {icon}
          </View>
          <Text className="text-white font-medium">{name}</Text>
        </View>
      </AriseCard>
    </Pressable>
  );
};

export default CardButton;
