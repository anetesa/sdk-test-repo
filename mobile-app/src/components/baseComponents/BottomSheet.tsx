import React, {useEffect} from 'react';
import {View, TouchableOpacity} from 'react-native';
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withTiming,
} from 'react-native-reanimated';

interface BottomSheetProps {
  isVisible: boolean;
  isOverlay: boolean;
  overlayOpacity?: number;
  height: string | number; // You can use a string for Tailwind CSS heights like 'h-64' or a number for specific heights.
  onClose?: () => void;
  children: React.ReactNode;
}

const BottomSheet: React.FC<BottomSheetProps> = ({
  isVisible,
  isOverlay,
  height,
  onClose,
  children,
}) => {
  const translateY = useSharedValue(300);

  useEffect(() => {
    if (isVisible) {
      translateY.value = withTiming(0, {duration: 500});
    } else {
      translateY.value = withTiming(600, {duration: 300});
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isVisible]);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{translateY: translateY.value}],
  }));

  if (!isVisible) {
    return null;
  }

  return (
    <View
      className={`flex-1 h-full w-full  ${
        isOverlay ? 'absolute inset-0  justify-end' : ''
      }`}>
      {isOverlay && (
        <TouchableOpacity
          className="flex-1"
          activeOpacity={1}
          onPress={onClose}
          testID="overlay"
        />
      )}
      <View
        style={{
          marginTop: height === 'h-full' ? 140 : null,
        }}>
        <Animated.View
          className={`bg-white   w-full ${height} ${
            isOverlay ? 'shadow-lg' : ''
          } `}
          style={animatedStyle}>
          {children}
        </Animated.View>
      </View>
    </View>
  );
};

export default React.memo(BottomSheet);
