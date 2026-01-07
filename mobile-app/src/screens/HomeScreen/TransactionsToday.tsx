import React from 'react';
import {View, Text, Pressable} from 'react-native';
import AriseCard from '@/components/baseComponents/AriseCard';
import {formatAmountShort} from '@/utils/text';
import {Eye, EyeOff} from 'lucide-react-native';
import {COLORS} from '@/constants/colors';

interface TransactionsTodayProps {
  transactionsToday: number;
  salesToday: number;
  isAmountHidden: boolean;
  onPress: () => void;
}

export const TransactionsToday: React.FC<TransactionsTodayProps> = ({
  transactionsToday,
  salesToday,
  isAmountHidden,
  onPress,
}) => {
  return (
    <View>
      <View className="px-4 mt-3 flex-row h-[28px]">
        <Pressable onPress={onPress} className="flex-row items-center gap-2 ">
          {isAmountHidden ? (
            <>
              <Eye color={COLORS.SECONDARY} size={20} />
              <Text className="text-white/60">Show Amounts</Text>
            </>
          ) : (
            <>
              <EyeOff color={COLORS.SECONDARY} size={20} />
              <Text className="text-white/60">Hide Amounts</Text>
            </>
          )}
        </Pressable>
      </View>
      <View className="flex flex-row p-4 pb-0 w-full bg-transparent h-[112px]">
        <AriseCard className="flex-row border border-[#E5F6FF0A]">
          <View className="basis-1/2 border-r border-strokes-dark flex flex-col justify-center items-center">
            <Text className="text-3xl text-text-brand-light font-medium leading-none mb-2 text-center">
              {transactionsToday}
            </Text>
            <Text className="text-white text-sm text-center">
              Transactions Today
            </Text>
          </View>
          <View className="basis-1/2 flex flex-col justify-center items-center">
            {isAmountHidden ? (
              <Text className="tracking-[-1em] text-[12px] text-green-500 font-medium text-center h-[50px] leading-[50px]">
                ● ● ● ●
              </Text>
            ) : (
              <Text className="text-3xl text-success-main font-medium text-center h-[50px] leading-[50px]">
                ${formatAmountShort(salesToday)}
              </Text>
            )}
            <Text className="text-white text-sm text-center mb-2">
              Sales Today
            </Text>
          </View>
        </AriseCard>
      </View>
    </View>
  );
};
