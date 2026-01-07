import DeviceInfo from 'react-native-device-info';
import {Platform} from 'react-native';
import {logger} from './logger';
import AriseMobileSdk from '@/native/AriseMobileSdk';

/**
  IOS: use the ARISE native SDK persistent identifier (Keychain-backed).
 */
export const getOrCreateDeviceId = async (): Promise<string | undefined> => {
  if (Platform.OS === 'ios') {
    try {
      return await AriseMobileSdk.getDeviceId();
    } catch (error) {
      logger.error(error, 'Error getting device ID from AriseMobileSdk');
      return undefined;
    }
  }
  return undefined;
};

/**
 * Get device model name (e.g., "iPhone 14 Pro")
 */
export const getDeviceModel = async (): Promise<string> => {
  try {
    const deviceModel = await DeviceInfo.getModel();
    return deviceModel;
  } catch (error) {
    logger.error(error, 'Error getting device model');
    return 'Unknown Device';
  }
};

/**
 * Get all device information needed for registration
 */
export const getDeviceInfo = async (): Promise<{
  deviceId: string | undefined;
  deviceName: string;
}> => {
  const [deviceId, deviceName] = await Promise.all([
    getOrCreateDeviceId(),
    getDeviceModel(),
  ]);

  return {
    deviceId,
    deviceName,
  };
};

/**
 * Check if iOS version is 18 or higher
 * Returns true if iOS version >= 18, false otherwise
 * For non-iOS platforms, returns true to avoid blocking
 */
export const isIOS18OrHigher = async (): Promise<boolean> => {
  try {
    // Only check version on iOS platform
    if (Platform.OS !== 'ios') {
      return true;
    }

    const systemVersion = await DeviceInfo.getSystemVersion();
    const majorVersion = parseInt(systemVersion.split('.')[0], 10);

    return majorVersion >= 18;
  } catch (error) {
    // Return true to avoid blocking functionality if version check fails
    return true;
  }
};
