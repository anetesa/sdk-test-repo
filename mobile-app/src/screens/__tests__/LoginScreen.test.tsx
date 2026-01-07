import React from 'react';
import {render, screen, fireEvent} from '@testing-library/react-native';
import {NavigationContainer} from '@react-navigation/native';
import {GrowthBook, GrowthBookProvider} from '@growthbook/growthbook-react';
import LoginScreen from '../LoginScreen';
import * as useRememberMeHook from '@/hooks/useRememberMe';
import * as useLoginFlowHook from '@/hooks/useLoginFlow';
import {RuntimeConfigManager} from '@/utils/runtimeConfig';
import {Alert} from 'react-native';
import {ENVIRONMENTS} from '@/constants/environments';

// Mock the hooks and modules
jest.mock('@/hooks/useRememberMe');
jest.mock('@/hooks/useLoginFlow');
jest.mock('react-native-config', () => ({
  __esModule: true,
  default: {
    getConstants: () => ({
      APP_FUSIONAUTH_APPLICATION_ID: 'test-app-id',
      APP_API_AUTH_URL: 'http://localhost:9011',
    }),
  },
}));

jest.mock('react-native-test-flight', () => ({
  __esModule: true,
  default: {
    isTestFlight: true,
  },
}));

const mockRuntimeConfig = new RuntimeConfigManager({
  APP_ENV: 'uat',
  APP_API_AUTH_URL_DEV: 'http://localhost:9011',
  APP_API_AUTH_URL_UAT: 'http://uat.example.com',
  APP_API_AUTH_URL_PROD: 'http://prod.example.com',
  APP_API_MERCHANT_URL_DEV: 'http://localhost:3001',
  APP_API_MERCHANT_URL_UAT: 'http://uat-merchant.example.com',
  APP_API_MERCHANT_URL_PROD: 'http://prod-merchant.example.com',
  APP_API_PUBLIC_URL_DEV: 'http://localhost:3002',
  APP_API_PUBLIC_URL_UAT: 'http://uat-public.example.com',
  APP_API_PUBLIC_URL_PROD: 'http://prod-public.example.com',
  APP_FUSIONAUTH_APPLICATION_ID_DEV: 'dev-app-id',
  APP_FUSIONAUTH_APPLICATION_ID_UAT: 'uat-app-id',
  APP_FUSIONAUTH_APPLICATION_ID_PROD: 'prod-app-id',
});

jest.mock('@/utils/runtimeConfig', () => ({
  runtimeConfig: mockRuntimeConfig,
  RuntimeConfigManager: jest.requireActual('@/utils/runtimeConfig')
    .RuntimeConfigManager,
}));

// Mock useRuntimeConfig hook with actual toggle behavior
const mockToggleProduction = jest.fn(() => {
  if (mockRuntimeConfig.currentEnvironment === ENVIRONMENTS.PRODUCTION) {
    mockRuntimeConfig.currentEnvironment = ENVIRONMENTS.UAT;
    Alert.alert('Environment set to UAT');
  } else {
    mockRuntimeConfig.currentEnvironment = ENVIRONMENTS.PRODUCTION;
    Alert.alert('Environment set to PROD');
  }
});

jest.mock('@/hooks/useRuntimeConfig', () => ({
  useRuntimeConfig: () => ({
    runtimeConfig: mockRuntimeConfig,
    toggleProduction: mockToggleProduction,
  }),
}));

jest.mock('react-native-outside-press', () => ({
  __esModule: true,
  default: ({children}: {children: React.ReactNode}) => children,
}));

// Mock the growthBook utility
jest.mock('@/utils/growthBook', () => ({
  growthBook: {
    instance: {
      isOn: jest.fn(() => false), // Mock feature flags to return false by default
      setAttributes: jest.fn(),
      init: jest.fn(),
    },
  },
}));

const growthbook = new GrowthBook();

// Mock the navigation
const mockNavigate = jest.fn();
const mockSetParams = jest.fn();

const mockNavigation = {
  navigate: mockNavigate,
  setParams: mockSetParams,
  addListener: jest.fn(() => jest.fn()),
};

const mockRoute = {params: {}};

// Auxiliary function to render the component
const renderComponent = (
  rememberMeData: Partial<ReturnType<typeof useRememberMeHook.useRememberMe>>,
) => {
  (useRememberMeHook.useRememberMe as jest.Mock).mockReturnValue({
    email: '',
    rememberMeCheckBox: false,
    isLoading: false,
    handleRememberMeToggle: jest.fn(),
    saveEmailOnLogin: jest.fn(),
    ...rememberMeData,
  });

  (useLoginFlowHook.useLoginFlow as jest.Mock).mockReturnValue({
    login: jest.fn(),
    isError: false,
    isLoading: false,
    error: null,
  });

  return render(
    <GrowthBookProvider growthbook={growthbook}>
      <NavigationContainer>
        <LoginScreen
          navigation={mockNavigation as any}
          route={mockRoute as any}
        />
      </NavigationContainer>
    </GrowthBookProvider>,
  );
};

describe('LoginScreen', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should render all the required elements', () => {
    renderComponent({});

    // verify that the inputs and the button exist
    expect(screen.getByPlaceholderText('Email')).toBeTruthy();
    expect(screen.getByPlaceholderText('Password')).toBeTruthy();
    expect(screen.getByTestId('remember-me-checkbox')).toBeTruthy();
    expect(screen.getByTestId('arise-button-Log In')).toBeTruthy();
    expect(screen.getByText('Forgot password?')).toBeTruthy();
  });

  it('should have the email field pre-filled when remember me is true', () => {
    const testEmail = 'test@example.com';
    renderComponent({email: testEmail, rememberMeCheckBox: true});

    // verify that the email field has the correct value
    const emailInput = screen.getByPlaceholderText('Email');
    expect(emailInput.props.value).toBe(testEmail);
  });

  it('should have the email field empty when remember me is false', () => {
    renderComponent({rememberMeCheckBox: false});

    // verify that the email field is empty
    const emailInput = screen.getByPlaceholderText('Email');
    expect(emailInput.props.value).toBeFalsy();
  });

  it('should show required error messages when login is pressed with empty fields', async () => {
    renderComponent({});

    const loginButton = screen.getByTestId('arise-button-Log In');
    fireEvent.press(loginButton);

    // react-hook-form validation is async, so we wait for the errors to appear
    const emailError = await screen.findByText('Email is required');
    const passwordError = await screen.findByText('Password is required');

    expect(emailError).toBeTruthy();
    expect(passwordError).toBeTruthy();
  });

  describe('TestFlight Environment', () => {
    let alertSpy: jest.SpyInstance;

    beforeEach(() => {
      jest.useFakeTimers();
      alertSpy = jest.spyOn(Alert, 'alert').mockImplementation(() => {});
      mockToggleProduction.mockClear();
    });

    afterEach(() => {
      jest.useRealTimers();
      alertSpy.mockRestore();
    });

    it('should trigger environment switch when logo is pressed and held in TestFlight', () => {
      renderComponent({rememberMeCheckBox: true});

      // Find the logo pressable element in LoginLayout
      const logoPressable = screen.getByTestId('logo-pressable');

      // Simulate the press and hold behavior
      fireEvent(logoPressable, 'onPressIn');

      // Fast forward time to trigger the timeout
      jest.advanceTimersByTime(5000);

      expect(mockToggleProduction).toHaveBeenCalled();
      expect(alertSpy).toHaveBeenCalled();
    });
  });
});
