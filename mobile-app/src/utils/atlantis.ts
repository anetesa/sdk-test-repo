/**
 * Atlantis - Network Debugger for Proxyman
 *
 * Automatically captures HTTP/HTTPS traffic without proxy or certificates
 * ⚠️ ONLY works in DEBUG mode on iOS - SAFE for production
 *
 * Security Layers:
 * 1. Pod only included in Debug configuration (Podfile)
 * 2. Swift code wrapped in #if DEBUG
 * 3. JS checks __DEV__ flag
 * 4. Graceful null checks for native module
 */

import {NativeModules, Platform} from 'react-native';

const {AtlantisManager} = NativeModules;

// Toggle this to temporarily disable Atlantis if causing issues during development
const ATLANTIS_ENABLED = true;

/**
 * Check if Atlantis is available and should be enabled
 * Returns true only in development mode on iOS with the native module available
 */
const isAtlantisAvailable = (): boolean => {
  return Boolean(
    __DEV__ &&
      ATLANTIS_ENABLED &&
      Platform.OS === 'ios' &&
      AtlantisManager &&
      typeof AtlantisManager.start === 'function',
  );
};

export const Atlantis = {
  /**
   * Start capturing network traffic
   * Make sure Proxyman app is running on your Mac
   * Both devices must be on the same WiFi network
   *
   * Safe to call in any environment - will only activate in development
   */
  start: () => {
    if (!isAtlantisAvailable()) {
      return;
    }

    try {
      AtlantisManager.start();
      console.log('🔷 Atlantis: Network debugging enabled');
    } catch (error) {
      console.warn('⚠️ Atlantis: Failed to start', error);
    }
  },

  /**
   * Stop capturing network traffic
   */
  stop: () => {
    if (!isAtlantisAvailable()) {
      return;
    }

    try {
      AtlantisManager.stop();
      console.log('🔷 Atlantis: Network debugging disabled');
    } catch (error) {
      console.warn('⚠️ Atlantis: Failed to stop', error);
    }
  },

  /**
   * Check if Atlantis is currently available
   * Useful for conditional debugging logic
   */
  isAvailable: isAtlantisAvailable,
};
