import React, {useEffect, useRef, useCallback} from 'react';
import {Animated} from 'react-native';
import AlertError from './baseComponents/AlertError';
import AlertSuccess from './baseComponents/AlertSuccess';
import {AlertType} from '@/stores/alertStore';
import {ANIMATION_DURATIONS} from '@/constants/timing';

interface AnimatedAlertProps {
  id: string;
  type: AlertType;
  message: string;
  isVisible: boolean;
  duration?: number;
  onHide: () => void;
}

const AnimatedAlert: React.FC<AnimatedAlertProps> = ({
  id,
  type,
  message,
  isVisible,
  duration = ANIMATION_DURATIONS.TOAST,
  onHide,
}) => {
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const translateY = useRef(new Animated.Value(50)).current;

  const hideWithAnimation = useCallback(() => {
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 0,
        duration: ANIMATION_DURATIONS.FADE,
        useNativeDriver: true,
      }),
      Animated.timing(translateY, {
        toValue: 50,
        duration: ANIMATION_DURATIONS.FADE,
        useNativeDriver: true,
      }),
    ]).start(() => {
      onHide();
    });
  }, [fadeAnim, translateY, onHide]);

  useEffect(() => {
    if (isVisible) {
      // Show animation
      Animated.parallel([
        Animated.timing(fadeAnim, {
          toValue: 1,
          duration: ANIMATION_DURATIONS.SLOW,
          useNativeDriver: true,
        }),
        Animated.timing(translateY, {
          toValue: 0,
          duration: ANIMATION_DURATIONS.SLOW,
          useNativeDriver: true,
        }),
      ]).start();

      // Auto hide all alerts after duration
      const timer = setTimeout(() => {
        hideWithAnimation();
      }, duration);

      return () => clearTimeout(timer);
    } else {
      return () => {};
    }
  }, [
    isVisible,
    fadeAnim,
    translateY,
    duration,
    type,
    hideWithAnimation,
    onHide,
  ]);

  const handleDismiss = () => {
    hideWithAnimation();
  };

  if (!isVisible) {
    return null;
  }

  return (
    <Animated.View
      id={id}
      style={{
        opacity: fadeAnim,
        transform: [{translateY}],
      }}>
      {type === 'error' ? (
        <AlertError message={message} onDismiss={handleDismiss} />
      ) : (
        <AlertSuccess message={message} onDismiss={handleDismiss} />
      )}
    </Animated.View>
  );
};

export default AnimatedAlert;
