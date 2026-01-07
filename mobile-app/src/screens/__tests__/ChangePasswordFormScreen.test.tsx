import React from 'react';
import {render, screen, fireEvent, act} from '@testing-library/react-native';
import {NavigationContainer} from '@react-navigation/native';
import {GrowthBook, GrowthBookProvider} from '@growthbook/growthbook-react';
import {QueryClient, QueryClientProvider} from '@tanstack/react-query';
import ChangePasswordFormScreen from '../ChangePasswordFormScreen';

// --- Mocks ---
jest.mock('@react-navigation/native', () => {
  const actualNav = jest.requireActual('@react-navigation/native');
  return {
    ...actualNav,
    useRoute: () => ({
      params: {changePasswordId: 'test-id'},
    }),
  };
});

// Mock the native hooks and modules
jest.mock('@/hooks/queries/useChangePasswordWithId', () => ({
  useChangePasswordWithIdMutation: () => ({
    mutate: jest.fn(),
    isLoading: false,
    isSuccess: false,
    isError: false,
    error: null,
  }),
}));
jest.mock('@react-native-async-storage/async-storage', () =>
  require('@react-native-async-storage/async-storage/jest/async-storage-mock'),
);
jest.mock('react-native-config', () => ({
  __esModule: true,
  default: {},
}));
jest.mock('react-native-test-flight', () => ({
  isTestFlight: jest.fn(() => false),
}));
jest.mock('react-native-outside-press', () => ({
  __esModule: true,
  default: ({children}: {children: React.ReactNode}) => children,
}));

// --- Test Setup ---
const queryClient = new QueryClient();
const growthbook = new GrowthBook();

// Mock the navigation
const mockNavigate = jest.fn();
const mockNavigation = {
  navigate: mockNavigate,
  addListener: jest.fn(() => jest.fn()),
};

const renderComponent = () => {
  return render(
    <QueryClientProvider client={queryClient}>
      <GrowthBookProvider growthbook={growthbook}>
        <NavigationContainer>
          <ChangePasswordFormScreen navigation={mockNavigation} />
        </NavigationContainer>
      </GrowthBookProvider>
    </QueryClientProvider>,
  );
};

describe('ChangePasswordFormScreen', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should render the password input and the continue button', () => {
    renderComponent();

    expect(screen.getByTestId('password-input')).toBeTruthy();
    expect(screen.getByText('Continue')).toBeTruthy();
  });

  it('should show "Password is required" message when button is pressed with empty input', async () => {
    renderComponent();

    const continueButton = screen.getByText('Continue');
    await act(async () => {
      fireEvent.press(continueButton);
    });

    const errorMessage = await screen.findByText('Password is required');
    expect(errorMessage).toBeTruthy();
  });

  describe('Password validation rules', () => {
    it.each([
      ['short', 'shortpass', 'Password must be at least 12 characters'],
      [
        'invalid characters',
        'thisisalongpassword',
        'Password must have upper and lower case characters, symbols and numbers',
      ],
    ])(
      'should show an error for %s password',
      async (type, password, expectedMessage) => {
        renderComponent();

        const passwordInput = screen.getByTestId('password-input');
        const continueButton = screen.getByText('Continue');

        await act(async () => {
          fireEvent.changeText(passwordInput, password);
          fireEvent.press(continueButton);
        });

        const errorMessage = await screen.findByText(expectedMessage);
        expect(errorMessage).toBeTruthy();
      },
    );
  });

  it('should not show duplicated error messages on multiple invalid submissions', async () => {
    renderComponent();

    const passwordInput = screen.getByTestId('password-input');
    const continueButton = screen.getByText('Continue');

    await act(async () => {
      fireEvent.changeText(passwordInput, 'short');
      // Press the button twice
      fireEvent.press(continueButton);
      fireEvent.press(continueButton);
    });

    const errorMessages = await screen.findAllByText(
      'Password must be at least 12 characters',
    );
    expect(errorMessages.length).toBe(1);
  });
});
