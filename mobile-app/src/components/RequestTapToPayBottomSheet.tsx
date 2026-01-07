import React, {forwardRef, useImperativeHandle, useState} from 'react';
import {View, Text, Pressable, Modal, StyleSheet} from 'react-native';
import {Gesture, GestureDetector} from 'react-native-gesture-handler';
import {runOnJS} from 'react-native-reanimated';
import NfcIcon from '../../assets/Nfc.svg';
import AriseButton from './baseComponents/AriseButton';

interface RequestTapToPayBottomSheetProps {
  onConfirm: () => void;
  onClose: () => void;
}

export interface RequestTapToPayBottomSheetRef {
  present: () => void;
  dismiss: () => void;
}

const RequestTapToPayBottomSheet = forwardRef<
  RequestTapToPayBottomSheetRef,
  RequestTapToPayBottomSheetProps
>(({onConfirm, onClose}, ref) => {
  const [visible, setVisible] = useState(false);

  useImperativeHandle(ref, () => ({
    present: () => setVisible(true),
    dismiss: () => setVisible(false),
  }));

  const handleConfirm = () => {
    setVisible(false);
    onConfirm();
  };

  const handleClose = () => {
    setVisible(false);
    onClose();
  };

  const panGesture = Gesture.Pan().onEnd(event => {
    if (event.translationY > 100 || event.velocityY > 500) {
      runOnJS(handleClose)();
    }
  });

  return (
    <Modal
      visible={visible}
      transparent
      animationType="none"
      onRequestClose={handleClose}>
      {/* Backdrop */}
      <Pressable style={styles.backdrop} onPress={handleClose}>
        <GestureDetector gesture={panGesture}>
          <Pressable
            style={styles.container}
            onPress={e => e.stopPropagation()}>
            {/* Handle bar */}
            <View style={styles.handleBar} />

            <View className="px-6 pb-8 pt-2">
              <View className="items-center mt-4 mb-4">
                {/* Icon */}
                <View className="w-[96px] h-[96px] rounded-full bg-blue-50 items-center justify-center mb-8">
                  <NfcIcon color="#1D4ED8" width={40} height={40} />
                </View>

                {/* Message */}
                <Text className="text-xl font-medium text-text-primary text-center px-5 leading-5">
                  Send request to the account manager to enable Tap to Pay on
                  iPhone?
                </Text>
              </View>
              <View className="mb-5 mt-5 border-t border-gray-200 mx-[-24px]" />

              {/* Action Buttons */}
              <View className="w-full mt-2">
                <AriseButton
                  title={'Yes'}
                  onPress={handleConfirm}
                  className="h-14 mb-6"
                />
                <AriseButton
                  title={'Cancel'}
                  onPress={handleClose}
                  type="outline"
                  className="h-14 mb-6"
                />
              </View>
            </View>
          </Pressable>
        </GestureDetector>
      </Pressable>
    </Modal>
  );
});

const styles = StyleSheet.create({
  backdrop: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.4)',
    justifyContent: 'flex-end',
  },
  container: {
    backgroundColor: 'white',
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
    paddingTop: 8,
    minHeight: '60%',
  },
  handleBar: {
    width: 48,
    height: 4,
    backgroundColor: '#E5E7EB',
    borderRadius: 2,
    alignSelf: 'center',
    marginBottom: 8,
  },
});

RequestTapToPayBottomSheet.displayName = 'RequestTapToPayBottomSheet';

export default RequestTapToPayBottomSheet;
