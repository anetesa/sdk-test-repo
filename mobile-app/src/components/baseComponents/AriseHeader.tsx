import React from 'react';
import {View, Text, TouchableOpacity, SafeAreaView} from 'react-native';
import {useNavigation} from '@react-navigation/native';
import ArrowBackLeft from '../../../assets/arrow-back-left.svg';
import AriseGradient from './AriseGradient';

const AriseHeader = ({title}: {title: string}): React.JSX.Element => {
  const navigation = useNavigation();

  return (
    <SafeAreaView className="bg-[#122C46]">
      <AriseGradient>
        <View className="flex-row items-center justify-between px-4 pt-4">
          <TouchableOpacity onPress={() => navigation.goBack()} className="p-2">
            <ArrowBackLeft width={20} height={20} color="white" />
          </TouchableOpacity>
          <Text className="text-xl text-white">{title}</Text>
          <View className="w-8" />
        </View>
      </AriseGradient>
    </SafeAreaView>
  );
};

export default AriseHeader;
