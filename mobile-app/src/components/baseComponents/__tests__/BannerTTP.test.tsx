import React from 'react';
import {render, waitFor, fireEvent} from '@testing-library/react-native';
import {NavigationContainer} from '@react-navigation/native';
import {QueryClient, QueryClientProvider} from '@tanstack/react-query';
import AsyncStorage from '@react-native-async-storage/async-storage';
import BannerTTP from '../BannerAdminTTP';
import {PERMISSIONS} from '@/constants/permission';
import {ROUTES} from '@/constants/routes';
import {DeviceTapToPayStatus} from '@/dictionaries/DeviceTapToPayStatus';
import {DeviceTapToPayStatusStringEnumType} from '@/dictionaries/DeviceTapToPayStatus';

// Mock AsyncStorage
jest.mock('@react-native-async-storage/async-storage', () =>
  require('@react-native-async-storage/async-storage/jest/async-storage-mock'),
);

// Mock lucide-react-native
jest.mock('lucide-react-native', () => ({
  X: () => 'X',
}));

// Mock navigation
const mockNavigate = jest.fn();
jest.mock('@react-navigation/native', () => {
  const actualNav = jest.requireActual('@react-navigation/native');
  return {
    ...actualNav,
    useNavigation: () => ({
      navigate: mockNavigate,
    }),
  };
});

// Mock useSelectedProfile
const mockUseSelectedProfile = jest.fn();
jest.mock('@/hooks/useSelectedProfile', () => ({
  useSelectedProfile: () => mockUseSelectedProfile(),
}));

// Mock useDeviceStatus
const mockUseDeviceStatus = jest.fn();
jest.mock('@/hooks/queries/useTapToPayJWT', () => ({
  useDeviceStatus: () => mockUseDeviceStatus(),
}));

// Mock GrowthBook
const mockUseFeatureIsOn = jest.fn();
jest.mock('@growthbook/growthbook-react', () => ({
  useFeatureIsOn: (feature: string) => mockUseFeatureIsOn(feature),
}));

// Mock useUserStore
const mockUseUserStore = jest.fn();
jest.mock('@/stores/userStore', () => ({
  useUserStore: () => mockUseUserStore(),
}));

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
        cacheTime: 0,
      },
    },
  });

  return ({children}: {children: React.ReactNode}) => (
    <QueryClientProvider client={queryClient}>
      <NavigationContainer>{children}</NavigationContainer>
    </QueryClientProvider>
  );
};

describe('BannerTTP', () => {
  const TEST_USER_ID = 'test-user-id-123';

  beforeEach(() => {
    jest.clearAllMocks();
    // Default mocks - banner should be visible by default
    mockUseSelectedProfile.mockReturnValue({
      selectedProfile: {
        permissions: [PERMISSIONS.SETTINGS_MERCHANTS_WRITE],
      },
    });
    mockUseDeviceStatus.mockReturnValue({
      data: {
        tapToPayStatus: DeviceTapToPayStatusStringEnumType.Inactive,
      },
    });
    mockUseFeatureIsOn.mockReturnValue(true);
    mockUseUserStore.mockReturnValue({
      id: TEST_USER_ID,
    });
    (AsyncStorage.getItem as jest.Mock).mockResolvedValue(null);
  });

  describe('Visibility conditions', () => {
    it('should render banner when all conditions are met', async () => {
      const Wrapper = createWrapper();
      const {getByText} = render(
        <Wrapper>
          <BannerTTP />
        </Wrapper>,
      );

      await waitFor(() => {
        expect(getByText('Get payments with Tap to Pay!')).toBeTruthy();
        expect(getByText('Enable Now')).toBeTruthy();
      });
    });

    it('should not render when feature flag is off', async () => {
      mockUseFeatureIsOn.mockReturnValue(false);

      const Wrapper = createWrapper();
      const {queryByText} = render(
        <Wrapper>
          <BannerTTP />
        </Wrapper>,
      );

      await waitFor(() => {
        expect(queryByText('Get payments with Tap to Pay!')).toBeNull();
      });
    });

    it('should not render when user does not have SETTINGS_MERCHANTS_WRITE permission', async () => {
      mockUseSelectedProfile.mockReturnValue({
        selectedProfile: {
          permissions: [], // No permissions
        },
      });

      const Wrapper = createWrapper();
      const {queryByText} = render(
        <Wrapper>
          <BannerTTP />
        </Wrapper>,
      );

      await waitFor(() => {
        expect(queryByText('Get payments with Tap to Pay!')).toBeNull();
      });
    });

    it('should not render when device is already active', async () => {
      mockUseDeviceStatus.mockReturnValue({
        data: {
          tapToPayStatus: DeviceTapToPayStatusStringEnumType.Active,
        },
      });

      const Wrapper = createWrapper();
      const {queryByText} = render(
        <Wrapper>
          <BannerTTP />
        </Wrapper>,
      );

      await waitFor(() => {
        expect(queryByText('Get payments with Tap to Pay!')).toBeNull();
      });
    });

    it('should not render when banner was previously dismissed', async () => {
      (AsyncStorage.getItem as jest.Mock).mockResolvedValue('true');

      const Wrapper = createWrapper();
      const {queryByText} = render(
        <Wrapper>
          <BannerTTP />
        </Wrapper>,
      );

      await waitFor(() => {
        expect(queryByText('Get payments with Tap to Pay!')).toBeNull();
      });
    });

    it('should check AsyncStorage for banner dismissed status on mount', async () => {
      const Wrapper = createWrapper();
      render(
        <Wrapper>
          <BannerTTP />
        </Wrapper>,
      );

      await waitFor(() => {
        expect(AsyncStorage.getItem).toHaveBeenCalledWith(
          `ttpBannerDismissed:${TEST_USER_ID}`,
        );
      });
    });
  });

  describe('User interactions', () => {
    it('should navigate to TAP_TO_PAY_SPLASH when "Enable Now" is pressed', async () => {
      const Wrapper = createWrapper();
      const {getByText} = render(
        <Wrapper>
          <BannerTTP />
        </Wrapper>,
      );

      await waitFor(() => {
        expect(getByText('Enable Now')).toBeTruthy();
      });

      fireEvent.press(getByText('Enable Now'));

      expect(mockNavigate).toHaveBeenCalledWith(ROUTES.TAP_TO_PAY_SPLASH, {
        next_page: ROUTES.HOME,
      });
    });

    it('should dismiss banner and save to AsyncStorage when X is pressed', async () => {
      const Wrapper = createWrapper();
      const {getByText, queryByText, UNSAFE_getAllByType} = render(
        <Wrapper>
          <BannerTTP />
        </Wrapper>,
      );

      // Wait for banner to appear
      await waitFor(() => {
        expect(getByText('Get payments with Tap to Pay!')).toBeTruthy();
      });

      // Find the close button (it's the second accessible Pressable in the banner)
      const pressables = UNSAFE_getAllByType(require('react-native').Pressable);
      // First Pressable is "Enable Now", second is the close button
      const closeButton = pressables[1];
      fireEvent.press(closeButton);

      // Banner should disappear
      await waitFor(() => {
        expect(queryByText('Get payments with Tap to Pay!')).toBeNull();
      });

      // AsyncStorage should be updated
      expect(AsyncStorage.setItem).toHaveBeenCalledWith(
        `ttpBannerDismissed:${TEST_USER_ID}`,
        'true',
      );
    });

    it('should handle dismiss errors gracefully', async () => {
      (AsyncStorage.setItem as jest.Mock).mockRejectedValue(
        new Error('Storage error'),
      );

      const Wrapper = createWrapper();
      const {getByText, UNSAFE_getAllByType} = render(
        <Wrapper>
          <BannerTTP />
        </Wrapper>,
      );

      await waitFor(() => {
        expect(getByText('Get payments with Tap to Pay!')).toBeTruthy();
      });

      // Find the close button (it's the second Pressable)
      const pressables = UNSAFE_getAllByType(require('react-native').Pressable);
      const closeButton = pressables[1];
      fireEvent.press(closeButton);

      // Banner should still be visible even if storage fails (no-op error handling)
      await waitFor(() => {
        expect(getByText('Get payments with Tap to Pay!')).toBeTruthy();
      });
    });

    it('should handle AsyncStorage read errors gracefully', async () => {
      (AsyncStorage.getItem as jest.Mock).mockRejectedValue(
        new Error('Storage read error'),
      );

      const Wrapper = createWrapper();
      const {getByText} = render(
        <Wrapper>
          <BannerTTP />
        </Wrapper>,
      );

      // Should still render banner on error (default behavior)
      await waitFor(() => {
        expect(getByText('Get payments with Tap to Pay!')).toBeTruthy();
      });
    });
  });

  describe('Edge cases', () => {
    it('should handle undefined selectedProfile', async () => {
      mockUseSelectedProfile.mockReturnValue({
        selectedProfile: undefined,
      });

      const Wrapper = createWrapper();
      const {queryByText} = render(
        <Wrapper>
          <BannerTTP />
        </Wrapper>,
      );

      await waitFor(() => {
        expect(queryByText('Get payments with Tap to Pay!')).toBeNull();
      });
    });

    it('should handle undefined rawDeviceData', async () => {
      mockUseDeviceStatus.mockReturnValue({
        data: undefined,
      });

      const Wrapper = createWrapper();
      const {getByText} = render(
        <Wrapper>
          <BannerTTP />
        </Wrapper>,
      );

      // Should still render when device status is undefined (not active)
      await waitFor(() => {
        expect(getByText('Get payments with Tap to Pay!')).toBeTruthy();
      });
    });

    it('should render when device is in Pending status', async () => {
      mockUseDeviceStatus.mockReturnValue({
        data: {
          tapToPayStatus: DeviceTapToPayStatusStringEnumType.Pending,
        },
      });

      const Wrapper = createWrapper();
      const {getByText} = render(
        <Wrapper>
          <BannerTTP />
        </Wrapper>,
      );

      await waitFor(() => {
        expect(getByText('Get payments with Tap to Pay!')).toBeTruthy();
      });
    });

    it('should render when device is in Rejected status', async () => {
      mockUseDeviceStatus.mockReturnValue({
        data: {
          tapToPayStatus: DeviceTapToPayStatusStringEnumType.Denied,
        },
      });

      const Wrapper = createWrapper();
      const {getByText} = render(
        <Wrapper>
          <BannerTTP />
        </Wrapper>,
      );

      await waitFor(() => {
        expect(getByText('Get payments with Tap to Pay!')).toBeTruthy();
      });
    });
  });
});
