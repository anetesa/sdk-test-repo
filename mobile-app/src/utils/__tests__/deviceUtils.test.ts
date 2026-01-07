jest.mock('@/native/AriseMobileSdk', () => ({
  __esModule: true,
  default: {
    getDeviceId: jest.fn(),
  },
}));

import {
  getOrCreateDeviceId,
  getDeviceModel,
  getDeviceInfo,
  isIOS18OrHigher,
} from '../deviceUtils';

// Mock the logger
jest.mock('../logger', () => ({
  logger: {
    info: jest.fn(),
    error: jest.fn(),
    warn: jest.fn(),
    debug: jest.fn(),
  },
}));

// Mock Platform
jest.mock('react-native', () => ({
  Platform: {
    OS: 'ios',
  },
}));

// Mock react-native-device-info
jest.mock('react-native-device-info', () => ({
  getModel: jest.fn(),
  getSystemVersion: jest.fn(),
  getUniqueId: jest.fn(),
}));

const mockedDeviceInfo = require('react-native-device-info');
const mockedAriseMobileSdk = require('@/native/AriseMobileSdk').default;

describe('deviceUtils', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('getOrCreateDeviceId', () => {
    it('should return device ID from AriseMobileSdk on iOS', async () => {
      const existingDeviceId = '123e4567-e89b-4123-a456-426614174000';
      mockedAriseMobileSdk.getDeviceId.mockResolvedValue(existingDeviceId);
      const result = await getOrCreateDeviceId();

      expect(result).toBe(existingDeviceId);
      expect(mockedAriseMobileSdk.getDeviceId).toHaveBeenCalled();
    });

    it('should return undefined if AriseMobileSdk fails', async () => {
      mockedAriseMobileSdk.getDeviceId.mockRejectedValue(
        new Error('native fail'),
      );
      const result = await getOrCreateDeviceId();

      expect(result).toBeUndefined();
    });
  });

  describe('getDeviceModel', () => {
    it('should return device model from DeviceInfo', async () => {
      const mockModel = 'iPhone 14 Pro';
      (mockedDeviceInfo.getModel as jest.Mock).mockResolvedValue(mockModel);

      const result = await getDeviceModel();

      expect(result).toBe(mockModel);
      expect(mockedDeviceInfo.getModel).toHaveBeenCalled();
    });

    it('should return "Unknown Device" when device info fails', async () => {
      const error = new Error('Device info error');
      (mockedDeviceInfo.getModel as jest.Mock).mockRejectedValue(error);

      const result = await getDeviceModel();

      expect(result).toBe('Unknown Device');
      expect(mockedDeviceInfo.getModel).toHaveBeenCalled();

      // Verify error was logged
      const {logger} = require('../logger');
      expect(logger.error).toHaveBeenCalledWith(
        error,
        'Error getting device model',
      );
    });
  });

  describe('getDeviceInfo', () => {
    it('should return both device ID and device name', async () => {
      const mockDeviceId = '123e4567-e89b-4123-a456-426614174000'; // Valid v4 UUID
      const mockDeviceName = 'iPhone 14 Pro';

      mockedAriseMobileSdk.getDeviceId.mockResolvedValue(mockDeviceId);
      (mockedDeviceInfo.getModel as jest.Mock).mockResolvedValue(
        mockDeviceName,
      );

      const result = await getDeviceInfo();

      expect(result).toEqual({
        deviceId: mockDeviceId,
        deviceName: mockDeviceName,
      });
    });
  });

  describe('isIOS18OrHigher', () => {
    beforeEach(() => {
      // Reset Platform.OS to iOS before each test
      const {Platform} = require('react-native');
      Platform.OS = 'ios';
    });

    it('should return true for iOS 18.0', async () => {
      (mockedDeviceInfo.getSystemVersion as jest.Mock).mockResolvedValue(
        '18.0',
      );

      const result = await isIOS18OrHigher();

      expect(result).toBe(true);
      expect(mockedDeviceInfo.getSystemVersion).toHaveBeenCalled();
    });

    it('should return true for iOS 18.1', async () => {
      (mockedDeviceInfo.getSystemVersion as jest.Mock).mockResolvedValue(
        '18.1',
      );

      const result = await isIOS18OrHigher();

      expect(result).toBe(true);
    });

    it('should return true for iOS 19.0', async () => {
      (mockedDeviceInfo.getSystemVersion as jest.Mock).mockResolvedValue(
        '19.0',
      );

      const result = await isIOS18OrHigher();

      expect(result).toBe(true);
    });

    it('should return false for iOS 17.6', async () => {
      (mockedDeviceInfo.getSystemVersion as jest.Mock).mockResolvedValue(
        '17.6',
      );

      const result = await isIOS18OrHigher();

      expect(result).toBe(false);
    });

    it('should return false for iOS 16.0', async () => {
      (mockedDeviceInfo.getSystemVersion as jest.Mock).mockResolvedValue(
        '16.0',
      );

      const result = await isIOS18OrHigher();

      expect(result).toBe(false);
    });

    it('should return true for non-iOS platforms', async () => {
      const {Platform} = require('react-native');
      Platform.OS = 'android';

      const result = await isIOS18OrHigher();

      expect(result).toBe(true);
      expect(mockedDeviceInfo.getSystemVersion).not.toHaveBeenCalled();
    });

    it('should return true when getSystemVersion fails', async () => {
      const error = new Error('System version error');
      (mockedDeviceInfo.getSystemVersion as jest.Mock).mockRejectedValue(error);

      const result = await isIOS18OrHigher();

      expect(result).toBe(true);
      expect(mockedDeviceInfo.getSystemVersion).toHaveBeenCalled();
    });
  });
});
