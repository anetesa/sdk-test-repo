import React, {useCallback, forwardRef, useEffect} from 'react';
import {View, Text, Pressable} from 'react-native';
import BSheet, {
  BottomSheetView,
  BottomSheetBackdrop,
  BottomSheetProps,
} from '@gorhom/bottom-sheet';
import {LogOut} from 'lucide-react-native';
import {PENDO} from '@/utils/pendo';

const snapPoints = ['50%'];

interface LogOutBottomSheetProps extends Partial<BottomSheetProps> {
  onLogout: () => void;
  onClose: () => void;
}

const LogOutBottomSheet = forwardRef<BSheet, LogOutBottomSheetProps>(
  ({onLogout, onClose, ...props}, ref) => {
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

    useEffect(() => {
      if (PENDO) {
        PENDO.screenContentChanged?.();
      }
    }, []);

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
              <LogOut color="#991B1B" size={32} />
            </View>
            <Text className="text-[20px] font-medium text-center mb-8">
              Are you sure you want to log out?
            </Text>
            <View className="w-full h-[1px] bg-gray-200" />
            <View className="w-full p-[24px] mt-auto">
              <Pressable
                accessibilityLabel="Logout Yes"
                onPress={onLogout}
                className="w-full rounded-xl border border-[#FECACA] bg-white py-4 mb-3">
                <Text className="text-base font-medium text-red-700 text-center">
                  Yes
                </Text>
              </Pressable>
              <Pressable
                accessibilityLabel="Logout Cancel"
                onPress={onClose}
                className="w-full rounded-xl border border-gray-300 py-4">
                <Text className="text-base font-medium text-text-primary text-center">
                  Cancel
                </Text>
              </Pressable>
            </View>
          </View>
        </BottomSheetView>
      </BSheet>
    );
  },
);

export default LogOutBottomSheet;
