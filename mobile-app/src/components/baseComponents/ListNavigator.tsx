import React from 'react';
import {View, Text, TouchableOpacity} from 'react-native';
import {useNavigation} from '@react-navigation/native';
import ArrowEnter from '../../../assets/arrow-enter.svg';

interface ListNavigatorItem {
  title: string;
  destination: string;
  textColor?: string;
}

interface ListNavigatorProps {
  items: ListNavigatorItem[];
  containerClassName?: string;
}

const ListNavigator = ({
  items,
  containerClassName = 'bg-white rounded-lg border border-gray-200 overflow-hidden',
}: ListNavigatorProps): React.JSX.Element => {
  const navigation = useNavigation();

  return (
    <View className={containerClassName}>
      {items.map((item, index) => (
        <View
          key={index}
          className={`flex-row items-center justify-between py-4 px-4 ${
            index > 0 ? 'border-t border-gray-200' : ''
          }`}>
          <TouchableOpacity
            activeOpacity={0.7}
            accessibilityLabel={item.title}
            onPress={() => navigation.navigate(item.destination as never)}
            className="flex-1 flex-row items-center justify-between">
            <Text
              className={`text-[18px] ${
                item.textColor || 'text-text-primary'
              }`}>
              {item.title}
            </Text>
            <View className="pr-2">
              <ArrowEnter width={10} height={15} />
            </View>
          </TouchableOpacity>
        </View>
      ))}
    </View>
  );
};

export default ListNavigator;
