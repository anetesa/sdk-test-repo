import React from 'react';
import {View} from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withRepeat,
  Easing,
  interpolate,
} from 'react-native-reanimated';
import Svg, {Circle, Defs, LinearGradient, Stop} from 'react-native-svg';

const AnimatedView = Animated.createAnimatedComponent(View);

interface SerpentSpinnerProps {
  size?: number;
  strokeWidth?: number;
  duration?: number;
  serpentPercentage?: number;
}

const SerpentSpinner: React.FC<SerpentSpinnerProps> = ({
  size = 100,
  strokeWidth = 8,
  duration = 1500,
  serpentPercentage = 0.8,
}) => {
  const radius = (size - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;
  const arcLength = circumference * serpentPercentage;
  const center = size / 2;

  const progress = useSharedValue(0);

  React.useEffect(() => {
    progress.value = withRepeat(
      withTiming(1, {duration, easing: Easing.linear}),
      -1,
    );
  }, [duration, progress]);

  // the animation is a simple rotation of the container view.
  const animatedStyle = useAnimatedStyle(() => {
    const rotation = interpolate(progress.value, [0, 1], [0, 360]);
    return {
      transform: [{rotate: `${rotation}deg`}],
    };
  });

  return (
    // The AnimatedView is the only responsible for the animation.
    <AnimatedView style={animatedStyle}>
      <Svg width={size} height={size}>
        <Defs>
          {/* KEY CHANGE IN THE GRADIENT:
              - Goes from right (x1="1") to left (x2="0").
              - The head (right) will be bright.
              - The tail (left) will be dark.
          */}
          <LinearGradient id="serpentGradient" x1="1" y1="0.5" x2="0" y2="0.5">
            {/* The tail is 100% dark */}
            <Stop offset="0" stopColor="#000d1b" />
            {/* The head is 100% bright */}
            <Stop offset="1" stopColor="#007AFF" />
          </LinearGradient>
        </Defs>

        <Circle
          cx={center}
          cy={center}
          r={radius}
          stroke="#001227"
          strokeWidth={strokeWidth}
          fill="transparent"
        />

        <Circle
          cx={center}
          cy={center}
          r={radius}
          stroke="url(#serpentGradient)"
          strokeWidth={strokeWidth}
          fill="transparent"
          strokeDasharray={`${arcLength} ${circumference}`}
          strokeLinecap="butt"
          rotation="-90"
          originX={center}
          originY={center}
        />
      </Svg>
    </AnimatedView>
  );
};

export default SerpentSpinner;
