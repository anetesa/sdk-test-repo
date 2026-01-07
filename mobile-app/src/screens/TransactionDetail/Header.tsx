import React from 'react';
import {View, TouchableOpacity} from 'react-native';
import {Text} from '@/components/baseComponents/Text';
import {useNavigation} from '@react-navigation/native';
import {ChevronLeft} from 'lucide-react-native';

export default function Header({
  isLoading,
  Icon,
  type,
  status,
  date,
  details,
  code,
  iconBgColor,
  height,
}: {
  isLoading: boolean;
  Icon: React.ReactElement;
  type: string;
  status: string;
  date: string;
  details: string;
  code: string;
  iconBgColor: string;
  height?: string;
}) {
  const navigation = useNavigation();

  return (
    <View className="mt-6">
      <View className="self-start pl-8 mb-[-20px]">
        <TouchableOpacity
          onPress={() => navigation.goBack()}
          className="mb-[-30px]">
          <ChevronLeft
            width={20}
            height={20}
            strokeWidth={1.5}
            color="#3F3F46"
          />
        </TouchableOpacity>
      </View>
      <View className={`h-min-fit justify-center ${height}`}>
        <View className="items-center justify-center mt-6 mb-8">
          <View
            className={`w-20 h-20 ${iconBgColor} rounded-full items-center justify-center mb-4`}>
            {React.cloneElement(Icon, {size: 40, strokeWidth: 1})}
          </View>
          <View />

          <Text
            className="text-2xl font-medium leading-6 text-text-primary mt-4"
            isLoading={isLoading}
            widthSkeleton={70}>
            {type}
          </Text>
          <Text
            className="text-lg font-medium leading-6 text-text-primary mt-3"
            isLoading={isLoading}
            widthSkeleton={150}>
            {status}
          </Text>
          <Text
            className="text-base font-normal leading-6 text-text-secondary mt-3"
            isLoading={isLoading}
            widthSkeleton={200}>
            {date}
          </Text>
          {details && (
            <Text className="text-center text-lg font-normal leading-6 text-text-secondary mt-3 tracking-[-1%] px-5">
              {details}
            </Text>
          )}
          {code && (
            <Text className="text-xs font-semibold leading-6 text-text-secondary mt-3">
              Code: {code}
            </Text>
          )}
        </View>
      </View>
    </View>
  );
}
