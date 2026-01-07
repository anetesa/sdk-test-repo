import React, {useEffect} from 'react';

import Svg, {Path, Defs, LinearGradient, Stop} from 'react-native-svg';
import {ANIMATION_DURATIONS} from '@/constants/timing';
import Animated, {
  useAnimatedProps,
  useSharedValue,
  withRepeat,
  withTiming,
} from 'react-native-reanimated';

const AnimatedStop = Animated.createAnimatedComponent(Stop);

const AnimatedLogo = () => {
  const offset1 = useSharedValue(0);
  const offset2 = useSharedValue(0.5);
  const offset3 = useSharedValue(1);

  // Animate the gradient stops
  useEffect(() => {
    offset1.value = withRepeat(
      withTiming(1, {duration: ANIMATION_DURATIONS.LOGO_ANIMATION}),
      -1,
      false,
    );
    offset2.value = withRepeat(
      withTiming(1.5, {duration: ANIMATION_DURATIONS.LOGO_ANIMATION}),
      -1,
      false,
    );
    offset3.value = withRepeat(
      withTiming(2, {duration: ANIMATION_DURATIONS.LOGO_ANIMATION}),
      -1,
      false,
    );
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Create animated props for each stop
  const animatedProps1 = useAnimatedProps(() => ({
    offset: `${offset1.value}`,
  }));

  const animatedProps2 = useAnimatedProps(() => ({
    offset: `${offset2.value}`,
  }));

  const animatedProps3 = useAnimatedProps(() => ({
    offset: `${offset3.value}`,
  }));

  return (
    <Svg height="200" width="200">
      <Defs>
        <LinearGradient
          id="paint0_linear_12_13"
          x1="153"
          y1="44"
          x2="0"
          y2="44"
          gradientUnits="userSpaceOnUse">
          <AnimatedStop animatedProps={animatedProps1} stop-color="#00A3CC" />
          <AnimatedStop animatedProps={animatedProps2} stop-color="#A9EEFF" />
          <AnimatedStop animatedProps={animatedProps3} stop-color="#00A3CC" />
        </LinearGradient>
      </Defs>
      <Path
        d="M152.738 82.3334C144.196 74.3458 126.056 59.9769 100.419 53.9308L97.0042 45.5574L79.2986 2.13446C78.1412 -0.711488 74.1347 -0.711488 72.9711 2.13446L55.2654 45.5574L51.825 53.9877C26.3767 60.0211 8.74653 74.1687 0.255381 82.2449C-0.430201 82.9026 0.393754 83.9967 1.20513 83.516C10.8284 77.7799 26.5528 69.9314 47.0448 65.6941C51.6803 64.7391 56.5674 63.9612 61.681 63.4426C65.8637 63.0125 70.2036 62.7532 74.6882 62.7027C80.1854 62.6394 85.4751 62.8861 90.5446 63.3857C95.6393 63.8853 100.508 64.6316 105.137 65.5739C126.075 69.8049 142.108 77.8368 151.775 83.6046C152.612 84.0916 153.436 82.9848 152.738 82.3334ZM71.0904 51.2556C69.5495 51.3315 68.0273 51.439 66.5304 51.5781L73.0591 35.5649C74.185 32.7949 78.0909 32.7949 79.2231 35.5649L85.7392 51.5402C81.0471 51.1291 76.16 51.0089 71.0904 51.2556ZM112.351 83.1935C113.288 85.4829 111.609 87.9937 109.15 87.9937H102.005C101.155 87.9937 100.382 87.4751 100.061 86.6845L97.0042 79.1902L93.4568 70.4942C98.6269 71.1203 103.552 71.9994 108.219 73.0619L112.351 83.1935ZM44.0823 73.0176C48.743 71.9615 53.6679 71.0951 58.8317 70.4753L55.278 79.1965L52.2212 86.6909C51.9004 87.4814 51.1331 88 50.2777 88H43.1325C40.667 88 38.9939 85.4892 39.9311 83.1998L44.0823 73.0176Z"
        fill="url(#paint0_linear_12_13)"
      />
    </Svg>
  );
};

export default AnimatedLogo;
