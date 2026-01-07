import React from 'react';
import {render, screen} from '@testing-library/react-native';
import TapToPaySplashScreen from '../TapToPaySplashScreen';
import {PERMISSIONS} from '@/constants/permission';
import {TAP_TO_PAY_MESSAGES} from '@/constants/messages';

const mockUseSelectedProfile = jest.fn();
jest.mock('@/hooks/useSelectedProfile', () => ({
  useSelectedProfile: () => mockUseSelectedProfile(),
}));

const mockUseCloudCommerceStore = jest.fn();
jest.mock('@/stores/cloudCommerceStore', () => ({
  useCloudCommerceStore: (selector?: any) => mockUseCloudCommerceStore(selector),
}));

const mockUseUserStore = jest.fn();
jest.mock('@/stores/userStore', () => ({
  useUserStore: (selector: any) => mockUseUserStore(selector),
}));

const mockNavigation = {
  addListener: jest.fn(() => jest.fn()),
  replace: jest.fn(),
  reset: jest.fn(),
  goBack: jest.fn(),
  canGoBack: jest.fn(() => true),
  getState: jest.fn(() => ({routeNames: []})),
  getParent: jest.fn(() => null),
};

jest.mock('@react-navigation/native', () => {
  const actualNav = jest.requireActual('@react-navigation/native');
  return {
    ...actualNav,
    useNavigation: () => mockNavigation,
    useRoute: () => ({params: {}}),
    useIsFocused: () => true,
  };
});

describe('TapToPaySplashScreen disclaimers', () => {
  beforeEach(() => {
    jest.clearAllMocks();

    // Zustand-like stores: support selector + no-selector usage.
    const cloudCommerceState = {
      isLoading: false,
      isPrepared: false,
      activateTapToPay: jest.fn().mockResolvedValue({activated: false}),
    };
    mockUseCloudCommerceStore.mockImplementation((selector?: any) =>
      typeof selector === 'function' ? selector(cloudCommerceState) : cloudCommerceState,
    );

    const userState = {merchantId: 'merchant-123'};
    mockUseUserStore.mockImplementation((selector: any) =>
      typeof selector === 'function' ? selector(userState) : userState,
    );
  });

  it('shows the fee disclaimer for merchant manager users', () => {
    mockUseSelectedProfile.mockReturnValue({
      selectedProfile: {
        permissions: [PERMISSIONS.SETTINGS_MERCHANTS_WRITE],
      },
    });

    render(<TapToPaySplashScreen />);

    expect(
      screen.getByText(TAP_TO_PAY_MESSAGES.SPLASH_DISCLAIMER_MANAGER),
    ).toBeTruthy();
    expect(
      screen.queryByText(TAP_TO_PAY_MESSAGES.SPLASH_DISCLAIMER_NON_MANAGER),
    ).toBeNull();
  });

  it('shows the existing disclaimer for non-merchant manager users', () => {
    mockUseSelectedProfile.mockReturnValue({
      selectedProfile: {
        permissions: [],
      },
    });

    render(<TapToPaySplashScreen />);

    expect(
      screen.getByText(TAP_TO_PAY_MESSAGES.SPLASH_DISCLAIMER_NON_MANAGER),
    ).toBeTruthy();
    expect(
      screen.queryByText(TAP_TO_PAY_MESSAGES.SPLASH_DISCLAIMER_MANAGER),
    ).toBeNull();
  });

  it('defaults to the existing disclaimer when selectedProfile is undefined', () => {
    mockUseSelectedProfile.mockReturnValue({
      selectedProfile: undefined,
    });

    render(<TapToPaySplashScreen />);

    expect(
      screen.getByText(TAP_TO_PAY_MESSAGES.SPLASH_DISCLAIMER_NON_MANAGER),
    ).toBeTruthy();
  });
});


