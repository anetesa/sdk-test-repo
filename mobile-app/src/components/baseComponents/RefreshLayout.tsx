import React, {useState, useCallback, useRef} from 'react';
import {
  View,
  Text,
  PanResponder,
  ScrollView,
  ScrollViewProps,
} from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  runOnJS,
} from 'react-native-reanimated';
import {CustomSVGSpinner} from '@/components/baseComponents/CustomSpinner';
import {ANIMATION_DURATIONS} from '@/constants/timing';

const maxPullDistance = 90;

type RefreshWrapperProps = ScrollViewProps & {
  onRefresh: () => Promise<void> | void;
  children: React.ReactNode;
};

const RefreshLayout: React.FC<RefreshWrapperProps> = ({
  onRefresh,
  children,
  ...scrollProps
}) => {
  const [isRefreshing, setIsRefreshing] = useState(false);
  const pullDown = useSharedValue(0);
  const ready = useSharedValue(false);
  const scrollY = useSharedValue(0);

  const animatedStyles = useAnimatedStyle(() => ({
    height: pullDown.value,
    justifyContent: 'center',
    alignItems: 'center',
  }));

  const triggerRefresh = useCallback(async () => {
    setIsRefreshing(true);
    await onRefresh();
    setTimeout(() => {
      setIsRefreshing(false);
      pullDown.value = withTiming(0, {duration: ANIMATION_DURATIONS.NORMAL});
    }, ANIMATION_DURATIONS.REFRESH_TIMEOUT);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [onRefresh]);

  const finishPan = () => {
    if (ready.value) {
      ready.value = false;
      pullDown.value = withTiming(
        maxPullDistance,
        {duration: ANIMATION_DURATIONS.NORMAL},
        finished => finished && runOnJS(triggerRefresh)(),
      );
    } else {
      pullDown.value = withTiming(0, {duration: ANIMATION_DURATIONS.NORMAL});
    }
  };

  const panResponder = useRef(
    PanResponder.create({
      onMoveShouldSetPanResponder: (_e, gs) => scrollY.value <= 0 && gs.dy > 0,
      onPanResponderMove: (_e, gs) => {
        const d = Math.min(maxPullDistance, Math.max(0, gs.dy));
        pullDown.value = d;
        ready.value = d > maxPullDistance / 2;
      },
      onPanResponderRelease: finishPan,
      onPanResponderTerminate: finishPan,
    }),
  ).current;

  return (
    <Animated.View className="flex-1" {...panResponder.panHandlers}>
      <Animated.View style={animatedStyles} className="w-full bg-dark-page-bg">
        {isRefreshing && (
          <View className="flex items-center justify-center h-full">
            <CustomSVGSpinner size={32} />
            <Text className="text-white/75 text-xs mt-2">Loading...</Text>
          </View>
        )}
      </Animated.View>

      <ScrollView
        scrollEnabled={false}
        onScroll={e => (scrollY.value = e.nativeEvent.contentOffset.y)}
        scrollEventThrottle={16}
        showsVerticalScrollIndicator={false}
        {...scrollProps}>
        {children}
      </ScrollView>
    </Animated.View>
  );
};

export default RefreshLayout;
