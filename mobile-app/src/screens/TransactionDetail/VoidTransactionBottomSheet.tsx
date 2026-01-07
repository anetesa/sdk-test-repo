import React, {useCallback, forwardRef} from 'react';
import {View, Text, Pressable} from 'react-native';
import BSheet, {
  BottomSheetView,
  BottomSheetBackdrop,
  BottomSheetProps,
} from '@gorhom/bottom-sheet';
import {XCircle} from 'lucide-react-native';
import {TRANSACTION_DETAIL_MESSAGES} from '@/constants/messages';

const snapPoints = ['60%'];

interface VoidTransactionBottomSheetProps extends Partial<BottomSheetProps> {
  onConfirm: () => void;
  onClose: () => void;
}

const VoidTransactionBottomSheet = forwardRef<
  BSheet,
  VoidTransactionBottomSheetProps
>(({onConfirm, onClose, ...props}, ref) => {
  const renderBackdrop = useCallback(
    (backdropProps: any) => (
      <BottomSheetBackdrop
        {...backdropProps}
        appearsOnIndex={0}
        disappearsOnIndex={-1}
        opacity={0.4}
      />
    ),
    [],
  );

  return (
    <BSheet
      ref={ref}
      index={-1}
      snapPoints={snapPoints}
      enablePanDownToClose
      backdropComponent={renderBackdrop}
      backgroundStyle={{backgroundColor: 'white'}}
      handleIndicatorStyle={{backgroundColor: '#E5E7EB', width: 48}}
      style={{
        borderTopLeftRadius: 24,
        borderTopRightRadius: 24,
      }}
      {...props}>
      <BottomSheetView className="flex-1 px-6">
        <View className="items-center mt-4">
          <View className="w-[96px] h-[96px] rounded-full bg-[#FEF2F2] items-center justify-center mb-8">
            <XCircle color="#991B1B" size={32} strokeWidth={1.3} />
          </View>
          <Text className="text-xl font-medium text-center mb-4 text-text-primary">
            {TRANSACTION_DETAIL_MESSAGES.VOID_CONFIRM_TITLE}
          </Text>
          <Text className="text-lg text-text-primary text-center mb-8 px-4">
            {TRANSACTION_DETAIL_MESSAGES.VOID_CONFIRM_SUBTITLE}
          </Text>
          <View className="w-full h-[1px] bg-gray-200" />
          <View className="w-full p-[24px] mt-auto">
            <Pressable
              onPress={onConfirm}
              className="w-full rounded-xl border border-[#FECACA] bg-white py-4 mb-3">
              <Text className="text-base font-medium text-red-700 text-center">
                {TRANSACTION_DETAIL_MESSAGES.VOID_BUTTON}
              </Text>
            </Pressable>
            <Pressable
              onPress={onClose}
              className="w-full rounded-xl border border-gray-300 py-4">
              <Text className="text-base font-medium text-text-primary text-center">
                {TRANSACTION_DETAIL_MESSAGES.CANCEL_BUTTON}
              </Text>
            </Pressable>
          </View>
        </View>
      </BottomSheetView>
    </BSheet>
  );
});

export default VoidTransactionBottomSheet;
