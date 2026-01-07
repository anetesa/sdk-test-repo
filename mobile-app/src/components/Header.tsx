import {useNavigation} from '@react-navigation/native';
import React from 'react';
import {View, Text, Pressable} from 'react-native';
import {ChevronLeft} from 'lucide-react-native';

interface HeaderProps {
  showBack: boolean;
  title: string;
  showClose?: boolean;
  onBack?: () => void;
}

const Header: React.FC<HeaderProps> = ({
  showBack,
  title,
  showClose,
  onBack,
}) => {
  const navigation = useNavigation();

  const handleGoBack = () => {
    navigation.goBack();
    if (onBack) {
      onBack();
    }
  };

  return (
    <View
      className={
        'flex flex-row justify-between space-between w-full h-20 items-center border-b border-strokes-dark'
      }>
      <View className={'shrink basis-1/3 '}>
        {showBack && (
          <Pressable className={'p-4'} onPress={handleGoBack} testID="back-btn">
            <ChevronLeft color="#FFFFFF80" width={20} height={20} />
          </Pressable>
        )}
      </View>
      <View className="grow items-center">
        <Text className={'text-white text-[20px] font-medium'}>{title}</Text>
      </View>
      <View className="shrink basis-1/3">
        {showClose && (
          <View>
            <Text>x</Text>
          </View>
        )}
      </View>
    </View>
  );
};

export default Header;
