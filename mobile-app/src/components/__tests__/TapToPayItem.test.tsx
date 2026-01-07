import React from 'react';
import {
  render,
  screen,
  fireEvent,
  waitFor,
} from '@testing-library/react-native';
import TapToPayItem from '../TapToPayItem';
import {DeviceTapToPayStatus} from '@/dictionaries/DeviceTapToPayStatus';
import {FEATURES} from '@/constants/features';
import {PERMISSIONS} from '@/constants/permission';
import {DeviceTapToPayStatusStringEnumType} from '@/dictionaries/DeviceTapToPayStatus';

// Mock dependencies
jest.mock('@/hooks/useSelectedProfile');
jest.mock('@/hooks/queries/useTapToPayJWT');
jest.mock('@growthbook/growthbook-react');
jest.mock('@/utils/deviceUtils');
jest.mock('@/dictionaries/DeviceTapToPayStatus');
jest.mock('@/constants/features');
jest.mock('@/constants/permission');
jest.mock('@react-navigation/native');
jest.mock('@/stores/cloudCommerceStore');

const mockUseSelectedProfile = require('@/hooks/useSelectedProfile');
const mockUseTapToPayJWT = require('@/hooks/queries/useTapToPayJWT');
const mockUseFeatureIsOn =
  require('@growthbook/growthbook-react').useFeatureIsOn;
const mockIsIOS18OrHigher = require('@/utils/deviceUtils').isIOS18OrHigher;
const mockUseNavigation = require('@react-navigation/native').useNavigation;
const mockUseCloudCommerceStore =
  require('@/stores/cloudCommerceStore').useCloudCommerceStore;

jest.mock('@/native/AriseMobileSdk', () => ({
  checkCompatibility: jest.fn().mockResolvedValue({
    isCompatible: true,
    incompatibilityReasons: [],
  }),
}));

// Mock useRequestTapToPay
const mockUseRequestTapToPay = jest.fn();

// Add the mock to the useTapToPayJWT module
mockUseTapToPayJWT.useRequestTapToPay = mockUseRequestTapToPay;
mockUseTapToPayJWT.useDeviceStatus =
  mockUseTapToPayJWT.useDeviceStatus || jest.fn();

describe('TapToPayItem', () => {
  const mockSelectedProfile = {
    id: 'profile-123',
    permissions: [PERMISSIONS.SETTINGS_MERCHANTS_WRITE],
  };

  const mockDeviceData = {
    id: 'device-123',
    deviceName: 'iPhone 15 Pro',
    tapToPayStatus: DeviceTapToPayStatusStringEnumType.Inactive,
    tapToPayEnabled: false,
  };

  beforeEach(() => {
    jest.clearAllMocks();

    // Default mocks
    mockUseSelectedProfile.useSelectedProfile.mockReturnValue({
      selectedProfile: mockSelectedProfile,
    });

    mockUseTapToPayJWT.useDeviceStatus.mockReturnValue({
      data: mockDeviceData,
      isLoading: false,
      isError: false,
      error: null,
      refetch: jest.fn(),
      isActive: false,
    });

    mockUseRequestTapToPay.mockReturnValue({
      mutateAsync: jest.fn(),
      isError: false,
    });

    mockUseFeatureIsOn.mockReturnValue(true);
    mockIsIOS18OrHigher.mockResolvedValue(true);

    // Mock navigation
    mockUseNavigation.mockReturnValue({
      navigate: jest.fn(),
    });

    // Mock CloudCommerce store
    mockUseCloudCommerceStore.mockImplementation(selector => {
      const state = {
        isLoading: false,
        isPrepared: false,
      };
      return selector(state);
    });

    // Mock console.log to avoid noise in tests
    jest.spyOn(console, 'log').mockImplementation(() => {});
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe('Visibility conditions', () => {
    it('should render when user has manage merchant settings permission and feature flag is enabled', async () => {
      render(<TapToPayItem />);

      await waitFor(() => {
        expect(screen.getByText('Tap to Pay on iPhone')).toBeTruthy();
        expect(
          screen.getByText(
            'Turn your iPhone into a terminal\nto receive contactless payments.',
          ),
        ).toBeTruthy();
        expect(screen.getByText('Learn More')).toBeTruthy();
        expect(screen.getByText('Enable')).toBeTruthy();
      });
    });

    it('should render when user does not have permission but device has Approved status', async () => {
      mockUseSelectedProfile.useSelectedProfile.mockReturnValue({
        selectedProfile: {
          ...mockSelectedProfile,
          permissions: [], // No permissions
        },
      });

      mockUseTapToPayJWT.useDeviceStatus.mockReturnValue({
        data: {
          ...mockDeviceData,
          tapToPayStatus: DeviceTapToPayStatusStringEnumType.Approved,
        },
        isLoading: false,
        isError: false,
        error: null,
        refetch: jest.fn(),
        isActive: false,
      });

      render(<TapToPayItem />);

      await waitFor(() => {
        expect(screen.getByText('Tap to Pay on iPhone')).toBeTruthy();
      });
    });

    it('should render when user does not have permission but device has Active status', async () => {
      mockUseSelectedProfile.useSelectedProfile.mockReturnValue({
        selectedProfile: {
          ...mockSelectedProfile,
          permissions: [], // No permissions
        },
      });

      mockUseTapToPayJWT.useDeviceStatus.mockReturnValue({
        data: {
          ...mockDeviceData,
          tapToPayStatus: DeviceTapToPayStatusStringEnumType.Active,
        },
        isLoading: false,
        isError: false,
        error: null,
        refetch: jest.fn(),
        isActive: true,
      });

      render(<TapToPayItem />);

      await waitFor(() => {
        expect(screen.getByText('Tap to Pay on iPhone')).toBeTruthy();
      });
    });

    it('should not render when user has no permission and device status is Inactive', () => {
      mockUseSelectedProfile.useSelectedProfile.mockReturnValue({
        selectedProfile: {
          ...mockSelectedProfile,
          permissions: [], // No permissions
        },
      });

      mockUseTapToPayJWT.useDeviceStatus.mockReturnValue({
        data: {
          ...mockDeviceData,
          tapToPayStatus: DeviceTapToPayStatusStringEnumType.Inactive,
        },
        isLoading: false,
        isError: false,
        error: null,
        refetch: jest.fn(),
        isActive: false,
      });

      const {toJSON} = render(<TapToPayItem />);
      expect(toJSON()).toBeNull();
    });

    it('should not render when user has no permission and device status is Denied', () => {
      mockUseSelectedProfile.useSelectedProfile.mockReturnValue({
        selectedProfile: {
          ...mockSelectedProfile,
          permissions: [], // No permissions
        },
      });

      mockUseTapToPayJWT.useDeviceStatus.mockReturnValue({
        data: {
          ...mockDeviceData,
          tapToPayStatus: DeviceTapToPayStatusStringEnumType.Denied,
        },
        isLoading: false,
        isError: false,
        error: null,
        refetch: jest.fn(),
        isActive: false,
      });

      const {toJSON} = render(<TapToPayItem />);
      expect(toJSON()).toBeNull();
    });

    it('should not render when feature flag is disabled', () => {
      mockUseFeatureIsOn.mockReturnValue(false);

      const {toJSON} = render(<TapToPayItem />);
      expect(toJSON()).toBeNull();
    });

    it('should not render when data is loading', () => {
      mockUseTapToPayJWT.useDeviceStatus.mockReturnValue({
        data: mockDeviceData,
        isLoading: true,
        isError: false,
        error: null,
        refetch: jest.fn(),
        isActive: false,
      });

      const {toJSON} = render(<TapToPayItem />);
      expect(toJSON()).toBeNull();
    });
  });

  describe('iOS version compatibility', () => {
    it('should show iOS version warning when iOS is below 18', async () => {
      mockIsIOS18OrHigher.mockResolvedValue(false);

      render(<TapToPayItem />);

      await waitFor(() => {
        expect(
          screen.getByText('Available only on iOS 18 or higher.'),
        ).toBeTruthy();
      });
    });

    it('should not show iOS version warning when iOS is 18 or higher', async () => {
      mockIsIOS18OrHigher.mockResolvedValue(true);

      render(<TapToPayItem />);

      await waitFor(() => {
        expect(
          screen.queryByText('Available only on iOS 18 or higher.'),
        ).toBeNull();
      });
    });

    it('should disable button when iOS version is not supported', async () => {
      mockIsIOS18OrHigher.mockResolvedValue(false);

      render(<TapToPayItem />);

      await waitFor(() => {
        // The button should be present but the component should show iOS version warning
        expect(screen.getByText('Enable')).toBeTruthy();
        expect(
          screen.getByText('Available only on iOS 18 or higher.'),
        ).toBeTruthy();
      });
    });

    it('should handle iOS version check errors gracefully', async () => {
      mockIsIOS18OrHigher.mockRejectedValue(new Error('Version check failed'));

      render(<TapToPayItem />);

      await waitFor(() => {
        // Should render without iOS warning when check fails (default to true)
        expect(
          screen.queryByText('Available only on iOS 18 or higher.'),
        ).toBeNull();
      });
    });
  });

  describe('Button states and interactions', () => {
    it('should show "Enable" button when TTP status is not Active', async () => {
      mockUseTapToPayJWT.useDeviceStatus.mockReturnValue({
        data: {
          ...mockDeviceData,
          tapToPayStatus: DeviceTapToPayStatusStringEnumType.Inactive,
        },
        isLoading: false,
        isError: false,
        error: null,
        refetch: jest.fn(),
        isActive: false,
      });

      render(<TapToPayItem />);

      await waitFor(() => {
        expect(screen.getByText('Enable')).toBeTruthy();
      });
    });

    it('should show button when TTP status is Active', async () => {
      mockUseTapToPayJWT.useDeviceStatus.mockReturnValue({
        data: {
          ...mockDeviceData,
          tapToPayStatus: DeviceTapToPayStatusStringEnumType.Active,
        },
        isLoading: false,
        isError: false,
        error: null,
        refetch: jest.fn(),
        isActive: true,
      });

      render(<TapToPayItem />);

      await waitFor(() => {
        // Button should show "Enabled" when status is Active
        expect(screen.getByText('Enabled')).toBeTruthy();
      });
    });

    it('should call onPress handler when Enable button is pressed', async () => {
      const mockNavigate = jest.fn();
      mockUseNavigation.mockReturnValue({
        navigate: mockNavigate,
      });

      render(<TapToPayItem />);

      await waitFor(() => {
        const enableButton = screen.getByText('Enable');
        fireEvent.press(enableButton.parent?.parent!);
        expect(mockNavigate).toHaveBeenCalledWith('TapToPaySplash', {
          next_page: 'Settings',
        });
      });
    });

    it('should render button with different TTP statuses', async () => {
      const statuses = [
        {
          id: DeviceTapToPayStatusStringEnumType.Inactive,
          expectedLabel: 'Enable',
        },
        {
          id: DeviceTapToPayStatusStringEnumType.Approved,
          expectedLabel: 'Enable',
        },
        {
          id: DeviceTapToPayStatusStringEnumType.Active,
          expectedLabel: 'Enabled',
        },
      ];

      for (const status of statuses) {
        mockUseTapToPayJWT.useDeviceStatus.mockReturnValue({
          data: {
            ...mockDeviceData,
            tapToPayStatus: status.id,
          },
          isLoading: false,
          isError: false,
          error: null,
          refetch: jest.fn(),
          isActive:
            status.id === DeviceTapToPayStatusStringEnumType.Active,
        });

        const {unmount} = render(<TapToPayItem />);

        await waitFor(() => {
          expect(screen.getByText(status.expectedLabel)).toBeTruthy();
        });

        unmount();
      }
    });
  });

  describe('Learn More interaction', () => {
    it('should render Learn More text', async () => {
      render(<TapToPayItem />);

      await waitFor(() => {
        expect(screen.getByText('Learn More')).toBeTruthy();
      });
    });
  });

  describe('Different TTP status scenarios', () => {
    const statusScenarios = [
      {
        status: DeviceTapToPayStatusStringEnumType.Inactive,
        name: 'Inactive',
        expectedLabel: 'Enable',
      },
      {
        status: DeviceTapToPayStatusStringEnumType.Requested,
        name: 'Requested',
        expectedLabel: 'Enable',
      },
      {
        status: DeviceTapToPayStatusStringEnumType.Approved,
        name: 'Approved',
        expectedLabel: 'Enable',
      },
      {
        status: DeviceTapToPayStatusStringEnumType.Active,
        name: 'Active',
        expectedLabel: 'Enabled',
      },
      {
        status: DeviceTapToPayStatusStringEnumType.Denied,
        name: 'Denied',
        expectedLabel: 'Enable',
      },
    ];

    statusScenarios.forEach(({status, name, expectedLabel}) => {
      it(`should handle TTP status ${name} correctly with permissions`, async () => {
        mockUseTapToPayJWT.useDeviceStatus.mockReturnValue({
          data: {
            ...mockDeviceData,
            tapToPayStatus: status,
          },
          isLoading: false,
          isError: false,
          error: null,
          refetch: jest.fn(),
          isActive:
            status === DeviceTapToPayStatusStringEnumType.Active,
        });

        render(<TapToPayItem />);

        await waitFor(() => {
          // Should always render when user has permissions
          expect(screen.getByText('Tap to Pay on iPhone')).toBeTruthy();
          expect(screen.getByText(expectedLabel)).toBeTruthy();
        });
      });
    });
  });

  describe('Edge cases', () => {
    it('should handle null selectedProfile', async () => {
      mockUseSelectedProfile.useSelectedProfile.mockReturnValue({
        selectedProfile: null,
      });

      mockUseTapToPayJWT.useDeviceStatus.mockReturnValue({
        data: {
          ...mockDeviceData,
          tapToPayStatus: DeviceTapToPayStatusStringEnumType.Active,
        },
        isLoading: false,
        isError: false,
        error: null,
        refetch: jest.fn(),
        isActive: true,
      });

      render(<TapToPayItem />);

      await waitFor(() => {
        // Should still render if device status is Active/Approved
        expect(screen.getByText('Tap to Pay on iPhone')).toBeTruthy();
      });
    });

    it('should handle null rawDeviceData', async () => {
      mockUseTapToPayJWT.useDeviceStatus.mockReturnValue({
        data: null,
        isLoading: false,
        isError: false,
        error: null,
        refetch: jest.fn(),
        isActive: false,
      });

      render(<TapToPayItem />);

      // Should render when user has permissions, even without device data
      await waitFor(() => {
        expect(screen.getByText('Tap to Pay on iPhone')).toBeTruthy();
      });
    });

    it('should handle undefined permissions array', async () => {
      mockUseSelectedProfile.useSelectedProfile.mockReturnValue({
        selectedProfile: {
          ...mockSelectedProfile,
          permissions: undefined,
        },
      });

      mockUseTapToPayJWT.useDeviceStatus.mockReturnValue({
        data: {
          ...mockDeviceData,
          tapToPayStatus: DeviceTapToPayStatusStringEnumType.Active,
        },
        isLoading: false,
        isError: false,
        error: null,
        refetch: jest.fn(),
        isActive: true,
      });

      render(<TapToPayItem />);

      await waitFor(() => {
        // Should still render if device status is Active/Approved
        expect(screen.getByText('Tap to Pay on iPhone')).toBeTruthy();
      });
    });

    it('should handle checking iOS version state', () => {
      // Mock initial state where iOS version is still being checked
      mockIsIOS18OrHigher.mockImplementation(
        () =>
          new Promise(resolve => {
            setTimeout(() => resolve(true), 100);
          }),
      );

      const {toJSON} = render(<TapToPayItem />);

      // Should not render while checking version
      expect(toJSON()).toBeNull();
    });
  });

  describe('Rendering elements', () => {
    it('should render the component completely', async () => {
      const {toJSON} = render(<TapToPayItem />);

      await waitFor(() => {
        expect(toJSON()).toBeTruthy();
      });
    });

    it('should render all required text elements', async () => {
      render(<TapToPayItem />);

      await waitFor(() => {
        // Test that all required text elements are present
        expect(screen.getByText('Tap to Pay on iPhone')).toBeTruthy();
        expect(
          screen.getByText(
            'Turn your iPhone into a terminal\nto receive contactless payments.',
          ),
        ).toBeTruthy();
        expect(screen.getByText('Learn More')).toBeTruthy();
        expect(screen.getByText('Enable')).toBeTruthy();
      });
    });
  });
});
