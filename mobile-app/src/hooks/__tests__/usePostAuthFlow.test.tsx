import {renderHook, act, waitFor} from '@testing-library/react-native';
import {usePostAuthFlow} from '../usePostAuthFlow';
import {useMeProfile} from '../queries/useMeProfile';
import {getSelectedProfile} from '@/utils/profileSelection';
import {getMobileSdkCredentials} from '@/services/mobileSdkService';
import AriseMobileSdk from '@/native/AriseMobileSdk';
import {runtimeConfig} from '@/utils/runtimeConfig';
import {useFeatureIsOn} from '@growthbook/growthbook-react';
import {ROUTES} from '@/constants/routes';
import {PERMISSIONS} from '@/constants/permission';
import {apiClient} from '@/clients/apiClient';
import {getOrCreateDeviceId} from '@/utils/deviceUtils';

// Mock dependencies
jest.mock('../queries/useMeProfile');
jest.mock('@/utils/profileSelection');
jest.mock('@/services/mobileSdkService');
jest.mock('@/clients/apiClient', () => ({
  apiClient: {
    post: jest.fn(),
  },
}));
jest.mock('@/utils/deviceUtils', () => ({
  getOrCreateDeviceId: jest.fn(),
}));

// Correctly mock AriseMobileSdk as an ES module default export
jest.mock('@/native/AriseMobileSdk', () => {
  const actualApi = {
    isConfigured: jest.fn(),
    getConfiguredEnvironment: jest.fn(),
    configure: jest.fn(),
    authenticate: jest.fn(),
    checkCompatibility: jest.fn(),
  };
  return {
    __esModule: true,
    default: actualApi,
  };
});

jest.mock('@/utils/runtimeConfig', () => ({
  runtimeConfig: {
    getAriseEnvironment: jest.fn(),
  },
}));

// Correctly mock growthBook
jest.mock('@growthbook/growthbook-react');
jest.mock('@/utils/growthBook', () => ({
  growthBook: {
    instance: {
      isOn: jest.fn().mockReturnValue(true),
    },
  },
}));

jest.mock('@/utils/logger', () => ({
  logger: {
    info: jest.fn(),
    error: jest.fn(),
    warn: jest.fn(),
  },
}));
jest.mock('@/utils/asyncStorage', () => ({
  getTTPSplashScreenDismissed: jest.fn(),
  setTTPSplashScreenDismissed: jest.fn(),
}));

// Mock Tap to Pay hooks to avoid QueryClient errors
jest.mock('../queries/useTapToPayJWT', () => ({
  useDeviceStatus: () => ({
    refetch: jest.fn().mockResolvedValue({
      data: {
        tapToPayStatus: 'Active',
      },
    }),
  }),
}));

jest.mock('@/stores/cloudCommerceStore', () => ({
  useCloudCommerceStore: () => ({
    initializeAfterLogin: jest.fn(),
  }),
}));

describe('usePostAuthFlow', () => {
  const mockRefetchMeProfile = jest.fn();
  const mockSetIsMeProfileLoading = jest.fn();
  const mockNavigation = {
    replace: jest.fn(),
    navigate: jest.fn(),
    reset: jest.fn(),
  };

  beforeEach(() => {
    jest.clearAllMocks();

    (useMeProfile as jest.Mock).mockReturnValue({
      refetch: mockRefetchMeProfile,
    });

    (getSelectedProfile as jest.Mock).mockReturnValue({
      merchantId: 'merchant-123',
      permissions: [PERMISSIONS.SETTINGS_MERCHANTS_WRITE],
    });
    (useFeatureIsOn as jest.Mock).mockReturnValue(true);

    (AriseMobileSdk.checkCompatibility as jest.Mock).mockResolvedValue({
      isCompatible: true,
    });
    (AriseMobileSdk.authenticate as jest.Mock).mockResolvedValue({
      expiresIn: 3600,
      tokenType: 'Bearer',
    });
    (AriseMobileSdk.isConfigured as jest.Mock).mockReturnValue(false);
    (runtimeConfig.getAriseEnvironment as jest.Mock).mockReturnValue('uat');
  });

  it('should fetch profile, register device, and authenticate SDK', async () => {
    const mockProfile = {
      profiles: [{merchantId: 'merchant-123'}],
    };
    mockRefetchMeProfile.mockResolvedValue({data: mockProfile, error: null});
    (getMobileSdkCredentials as jest.Mock).mockResolvedValue({
      clientId: 'cid',
      clientSecret: 'csecret',
    });
    (getOrCreateDeviceId as jest.Mock).mockResolvedValue('device-abc');
    (apiClient.post as jest.Mock).mockResolvedValue({data: {}});

    const {result} = renderHook(() => usePostAuthFlow());

    await act(async () => {
      await result.current.executePostAuthFlow({
        navigation: mockNavigation,
        setIsMeProfileLoading: mockSetIsMeProfileLoading,
      });
    });

    // Wait for the full flow to complete including the final navigation
    await waitFor(() => {
      expect(mockNavigation.reset).toHaveBeenCalledWith({
        index: 0,
        routes: [{name: ROUTES.HOME}],
      });
    });

    // Now assert all side effects
    expect(mockRefetchMeProfile).toHaveBeenCalled();
    expect(getMobileSdkCredentials).toHaveBeenCalledWith('merchant-123');
    expect(AriseMobileSdk.configure).toHaveBeenCalledWith('uat', 'USA');
    expect(AriseMobileSdk.authenticate).toHaveBeenCalledWith('cid', 'csecret');

    // Best-effort call that links the user profile to this device
    await waitFor(() => {
      expect(apiClient.post).toHaveBeenCalledWith(
        '/api/Merchants/merchant-123/devices/device-abc/link-user-profile',
      );
    });
  });

  it('should handle SDK authentication failure gracefully', async () => {
    const mockProfile = {
      profiles: [{merchantId: 'merchant-123'}],
    };
    mockRefetchMeProfile.mockResolvedValue({data: mockProfile, error: null});
    (getMobileSdkCredentials as jest.Mock).mockRejectedValue(
      new Error('Auth failed'),
    );

    const {result} = renderHook(() => usePostAuthFlow());

    await act(async () => {
      await result.current.executePostAuthFlow({
        navigation: mockNavigation,
        setIsMeProfileLoading: mockSetIsMeProfileLoading,
      });
    });

    // Should still navigate to Home even if SDK auth fails
    await waitFor(() => {
      expect(mockNavigation.reset).toHaveBeenCalledWith({
        index: 0,
        routes: [{name: ROUTES.HOME}],
      });
    });
    expect(mockSetIsMeProfileLoading).toHaveBeenCalledWith(false);
  });
});
