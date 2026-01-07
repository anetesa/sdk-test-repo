import React from 'react';
import {Pressable, View, PressableProps} from 'react-native';
import type {FC, ReactNode} from 'react';

interface ListItemProps extends PressableProps {
  left: ReactNode;
  right: ReactNode;
  onPress?: () => void;
  showBorder?: boolean;
}

const ListItem: FC<ListItemProps> = ({
  left,
  right,
  onPress,
  className,
  showBorder = true,
  testID,
  ...rest
}) => {
  return (
    <Pressable
      testID={testID}
      onPress={onPress}
      className={`flex-row py-[16px] ${
        showBorder ? 'border-b border-elevation-08' : ''
      }`}
      {...rest}>
      <View testID="list-item-left" className="flex grow shrink min-w-0">
        {left}
      </View>

      <View testID="list-item-right" className="flex shrink-0 ml-2">
        {right}
      </View>
    </Pressable>
  );
};

export default ListItem;
