import React, {useEffect, useRef} from 'react';
import {Animated, View, Text, RefreshControl} from 'react-native';
import {
  PanGestureHandler,
  State,
  PanGestureHandlerGestureEvent,
} from 'react-native-gesture-handler';
import Spinner from '../../../assets/spinner.svg';
import {UI_MESSAGES} from '@/constants/messages';
import {COLORS} from '@/constants/colors';

interface CustomSVGSpinnerProps {
  size?: number;
}

// Custom SVG Spinner Component
export const CustomSVGSpinner = ({size = 32}: CustomSVGSpinnerProps) => {
  const spinValue = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    const spinAnimation = Animated.loop(
      Animated.timing(spinValue, {
        toValue: 1,
        duration: 1000,
        useNativeDriver: true,
      }),
    );
    spinAnimation.start();

    return () => spinAnimation.stop();
  }, [spinValue]);

  const spin = spinValue.interpolate({
    inputRange: [0, 1],
    outputRange: ['0deg', '360deg'],
  });

  return (
    <Animated.View
      style={{
        transform: [{rotate: spin}],
        width: size,
        height: size,
        alignItems: 'center',
        justifyContent: 'center',
      }}>
      <Spinner width={size} height={size} />
    </Animated.View>
  );
};

// Custom Loading Component for infinite scroll
export const CustomLoadingIndicator = () => (
  <View className="py-4 items-center">
    <CustomSVGSpinner size={32} />
    <Text className="text-text-secondary text-[12px] mt-2">
      {UI_MESSAGES.LOADING}
    </Text>
  </View>
);

// Custom Refresh Control Component that uses our SVG Spinner
export const CustomRefreshControl = ({
  refreshing,
  onRefresh,
  tintColor = COLORS.SECONDARY,
}: {
  refreshing: boolean;
  onRefresh: () => void;
  tintColor?: string;
}) => {
  return (
    <RefreshControl
      refreshing={refreshing}
      onRefresh={onRefresh}
      tintColor={tintColor}
      title={UI_MESSAGES.LOADING}
      titleColor={tintColor}
      colors={[tintColor]}
      progressBackgroundColor="#FFFFFF"
      size={1}
    />
  );
};

// Custom Pull-to-Refresh Component with our SVG Spinner
export const CustomPullToRefresh = ({
  refreshing,
  onRefresh,
  children,
}: {
  refreshing: boolean;
  onRefresh: () => void;
  children: React.ReactNode;
}) => {
  const translateY = useRef(new Animated.Value(0)).current;
  const [isRefreshing, setIsRefreshing] = React.useState(false);

  const onGestureEvent = Animated.event(
    [{nativeEvent: {translationY: translateY}}],
    {useNativeDriver: true},
  );

  const onHandlerStateChange = (event: PanGestureHandlerGestureEvent) => {
    if (event.nativeEvent.state === State.END) {
      if (event.nativeEvent.translationY > 50 && !isRefreshing) {
        setIsRefreshing(true);
        onRefresh();
        // Reset after refresh
        setTimeout(() => setIsRefreshing(false), 1000);
      }
      Animated.spring(translateY, {
        toValue: 0,
        useNativeDriver: true,
      }).start();
    }
  };

  const refreshIndicatorTranslateY = translateY.interpolate({
    inputRange: [0, 100],
    outputRange: [-50, 0],
    extrapolate: 'clamp',
  });

  return (
    <View style={{flex: 1}}>
      <Animated.View
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          alignItems: 'center',
          zIndex: 1000,
          transform: [{translateY: refreshIndicatorTranslateY}],
        }}>
        {(refreshing || isRefreshing) && (
          <View className="bg-white rounded-lg shadow-md px-4 py-2 mt-2">
            <CustomSVGSpinner size={24} />
            <Text className="text-text-secondary text-[12px] mt-1 text-center">
              {UI_MESSAGES.LOADING}
            </Text>
          </View>
        )}
      </Animated.View>
      <PanGestureHandler
        onGestureEvent={onGestureEvent}
        onHandlerStateChange={onHandlerStateChange}>
        <Animated.View style={{flex: 1}}>{children}</Animated.View>
      </PanGestureHandler>
    </View>
  );
};
