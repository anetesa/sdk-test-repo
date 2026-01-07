import {useCallback, useEffect, useMemo, useRef} from 'react';
import {
  Keyboard,
  AppState,
  AppStateStatus,
  PanResponder,
  PanResponderInstance,
} from 'react-native';
import {clearSession} from '@/utils/clearSession';
import {navigationRef} from '@/utils/navigationRef';
import {SESSION_TIMING} from '@/constants/timing';
import {getLastActivityTime, setLastActivityTime} from '@/utils/asyncStorage';
import {logger} from '@/utils/logger';

/**
 * React Native implementation of the inactivity timer used in the web portal.
 *
 * @param isActive Whether the timer should be active (e.g. only if the user is authenticated).
 * @returns panHandlers – Spread these on a top-level view to detect user touches automatically.
 */
export const useInactivityTimer = (
  isActive: boolean,
): PanResponderInstance['panHandlers'] | undefined => {
  const timeoutRef = useRef<NodeJS.Timeout | null>(null);

  /**
   * Clears any running logout timeout.
   */
  const clearLogoutTimeout = () => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
      timeoutRef.current = null;
    }
  };

  /**
   * Performs a full logout and navigation reset.
   */
  const performLogout = useCallback(async () => {
    await clearSession();

    // Navigate back to the Login screen (if navigation is ready)
    if (navigationRef.isReady()) {
      navigationRef.resetRoot({
        index: 0,
        routes: [{name: 'Login' as never}],
      });
    }
  }, []);

  /**
   * Schedules / resets the inactivity timeout.
   */
  const resetTimer = useCallback(async () => {
    const currentTime = Date.now();

    try {
      const lastActivityTime = await getLastActivityTime();

      if (lastActivityTime) {
        const parsed = parseInt(lastActivityTime, 10);
        const diff = Math.abs(currentTime - parsed);
        if (diff <= SESSION_TIMING.TIME_TOLERANCE) {
          return;
        }
      }

      await setLastActivityTime(currentTime);
    } catch (e) {
      logger.error(e, 'Error saving last activity');
    }

    // Restart countdown
    clearLogoutTimeout();
    timeoutRef.current = setTimeout(() => {
      logger.info('[InactivityTimer] Timeout reached, logging out');
      performLogout();
    }, SESSION_TIMING.INACTIVITY_TIMEOUT);
  }, [performLogout]);

  /**
   * Check on mount if the last recorded activity already expired while the app
   * was closed/backgrounded.
   */
  const checkInitialExpiration = useCallback(async () => {
    try {
      const lastActivityTime = await getLastActivityTime();
      if (lastActivityTime) {
        const inactivityPeriod = Date.now() - parseInt(lastActivityTime, 10);
        if (inactivityPeriod > SESSION_TIMING.INACTIVITY_TIMEOUT) {
          logger.info('[InactivityTimer] Session expired before mount');
          await performLogout();
          return false; // Skip setting up listeners
        }
      }
    } catch (e) {
      logger.error(e, 'Error validating initial expiration');
    }
    return true;
  }, [performLogout]);

  /**
   * PanResponder captures touches across the whole screen without blocking the
   * children. We only use the *Capture* variants and return false so that the
   * gesture continues to propagate to actual UI components.
   */
  const panResponder = useMemo(
    () =>
      PanResponder.create({
        onStartShouldSetPanResponderCapture: () => {
          resetTimer();
          return false;
        },
        onMoveShouldSetPanResponderCapture: () => {
          resetTimer();
          return false;
        },
      }),
    [resetTimer],
  );

  useEffect(() => {
    if (!isActive) {
      clearLogoutTimeout();
      return;
    }

    // Validate inactivity on mount and potentially skip further setup
    let isMounted = true;
    checkInitialExpiration().then(shouldContinue => {
      if (!shouldContinue || !isMounted) {
        return;
      }
      // Initial timer setup
      resetTimer();
    });

    // Keyboard events also count as activity
    const subShow = Keyboard.addListener('keyboardDidShow', resetTimer);
    const subHide = Keyboard.addListener('keyboardDidHide', resetTimer);

    // When app returns to foreground, treat it as activity (or expiration check)
    const handleAppStateChange = (state: AppStateStatus) => {
      if (state === 'active') {
        resetTimer();
      }
    };
    const appStateSub = AppState.addEventListener(
      'change',
      handleAppStateChange,
    );

    return () => {
      isMounted = false;
      clearLogoutTimeout();
      subShow.remove();
      subHide.remove();
      appStateSub.remove();
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isActive]);

  // Expose panHandlers so they can be spread onto a top-level View.
  return isActive ? panResponder.panHandlers : undefined;
};
