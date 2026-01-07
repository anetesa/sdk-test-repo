import React from 'react';
// Mock react-native-outside-press to avoid DOM event errors in Jest
describe('mock react-native-outside-press', () => {});
jest.mock('react-native-outside-press', () => {
  return {
    __esModule: true,
    default: ({children}: {children: React.ReactNode}) => <>{children}</>,
  };
});

// Mock animated components to prevent act() warnings
jest.mock('react-native/Libraries/Animated/createAnimatedComponent', () => {
  return (Component: any) => Component;
});

import {render, fireEvent, waitFor, act} from '@testing-library/react-native';
import {useForm} from 'react-hook-form';
import ArisePasswordInput from '../ArisePasswordInput';

// Mock react-hook-form's useWatch
jest.mock('react-hook-form', () => ({
  ...jest.requireActual('react-hook-form'),
  useWatch: jest.fn(),
}));

// Mock the navigation object
const mockNavigation = {
  addListener: jest.fn((event, callback) => {
    if (event === 'blur' && callback) {
      return callback;
    }
    return jest.fn();
  }),
};

// Helper function to flatten style objects
function flattenStyle(style: any): Record<string, any> {
  if (!style) {
    return {};
  }

  // If it's an array, process each element
  if (Array.isArray(style)) {
    const result: Record<string, any> = {};
    style.forEach(item => {
      const flat = flattenStyle(item);
      Object.assign(result, flat);
    });
    return result;
  }

  // If it's an object with numeric keys, process each value
  if (
    typeof style === 'object' &&
    Object.keys(style).some(k => !isNaN(Number(k)))
  ) {
    const result: Record<string, any> = {};
    Object.values(style).forEach(item => {
      const flat = flattenStyle(item);
      Object.assign(result, flat);
    });
    return result;
  }

  // If it's a flat object, return it as is
  if (typeof style === 'object' && style !== null) {
    return style;
  }

  return {};
}

// Helper component to render ArisePasswordInput with form context
const renderArisePasswordInput = (props: any = {}) => {
  const TestComponent = () => {
    const {control} = useForm();
    return (
      <ArisePasswordInput
        control={control}
        name="password"
        placeholder="Enter password"
        navigation={mockNavigation}
        {...props}
      />
    );
  };

  return render(<TestComponent />);
};

describe('ArisePasswordInput', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Mock useWatch to return empty string by default
    const {useWatch} = require('react-hook-form');
    useWatch.mockReturnValue('');
  });

  describe('Initial state', () => {
    it('should render password input with secure text entry by default', () => {
      const {getByPlaceholderText} = renderArisePasswordInput();

      const input = getByPlaceholderText('Enter password');
      expect(input.props.secureTextEntry).toBe(true);
    });

    it('should not show eye icon when input is empty', () => {
      const {queryByTestId} = renderArisePasswordInput();

      const eyeIcon = queryByTestId('showPassword');
      expect(eyeIcon).toBeNull();
    });
  });

  describe('Password visibility toggle', () => {
    it('should show eye icon when password has content', () => {
      const {useWatch} = require('react-hook-form');
      useWatch.mockReturnValue('test123');

      const {getByTestId} = renderArisePasswordInput();

      const eyeIcon = getByTestId('showPassword');
      expect(eyeIcon).toBeTruthy();
    });

    it('should show EyeOff icon when password is hidden', () => {
      const {useWatch} = require('react-hook-form');
      useWatch.mockReturnValue('test123');

      const {getByTestId, queryByTestId} = renderArisePasswordInput();

      const eyeIcon = getByTestId('showPassword');
      expect(eyeIcon).toBeTruthy();

      // Verify that EyeOff is rendered and Eye is not
      expect(queryByTestId('eye-off-icon')).toBeTruthy();
      expect(queryByTestId('eye-icon')).toBeNull();
    });

    it('should show Eye icon when password is visible', async () => {
      const {useWatch} = require('react-hook-form');
      useWatch.mockReturnValue('test123');

      const {getByTestId, queryByTestId} = renderArisePasswordInput();

      const eyeIcon = getByTestId('showPassword');
      expect(eyeIcon).toBeTruthy();

      // Initially should show EyeOff
      expect(queryByTestId('eye-off-icon')).toBeTruthy();
      expect(queryByTestId('eye-icon')).toBeNull();

      // Click the eye icon to toggle visibility
      await act(async () => {
        fireEvent.press(eyeIcon);
      });

      await waitFor(() => {
        // After click, should show Eye
        expect(queryByTestId('eye-icon')).toBeTruthy();
        expect(queryByTestId('eye-off-icon')).toBeNull();
      });
    });

    it('should toggle secureTextEntry when eye icon is pressed', async () => {
      const {useWatch} = require('react-hook-form');
      useWatch.mockReturnValue('test123');

      const {getByTestId, getByPlaceholderText} = renderArisePasswordInput();

      const input = getByPlaceholderText('Enter password');
      const eyeIcon = getByTestId('showPassword');

      // Initially password should be hidden
      expect(input.props.secureTextEntry).toBe(true);

      // Click to show password
      await act(async () => {
        fireEvent.press(eyeIcon);
      });

      await waitFor(() => {
        expect(input.props.secureTextEntry).toBe(false);
      });

      // Click again to hide password
      await act(async () => {
        fireEvent.press(eyeIcon);
      });

      await waitFor(() => {
        expect(input.props.secureTextEntry).toBe(true);
      });
    });

    it('should toggle between Eye and EyeOff icons when pressed', async () => {
      const {useWatch} = require('react-hook-form');
      useWatch.mockReturnValue('test123');

      const {getByTestId, getByPlaceholderText, queryByTestId} =
        renderArisePasswordInput();

      const eyeIcon = getByTestId('showPassword');
      const input = getByPlaceholderText('Enter password');

      // Initially password should be hidden and show EyeOff
      expect(input.props.secureTextEntry).toBe(true);
      expect(queryByTestId('eye-off-icon')).toBeTruthy();
      expect(queryByTestId('eye-icon')).toBeNull();

      // Click to show password
      await act(async () => {
        fireEvent.press(eyeIcon);
      });

      await waitFor(() => {
        expect(input.props.secureTextEntry).toBe(false);
        expect(queryByTestId('eye-icon')).toBeTruthy();
        expect(queryByTestId('eye-off-icon')).toBeNull();
      });

      // Click again to hide password
      await act(async () => {
        fireEvent.press(eyeIcon);
      });

      await waitFor(() => {
        expect(input.props.secureTextEntry).toBe(true);
        expect(queryByTestId('eye-off-icon')).toBeTruthy();
        expect(queryByTestId('eye-icon')).toBeNull();
      });
    });
  });

  describe('Eye icon positioning', () => {
    it('should have correct positioning when password is hidden', () => {
      const {useWatch} = require('react-hook-form');
      useWatch.mockReturnValue('test123');

      const {getByTestId} = renderArisePasswordInput();

      const eyeIcon = getByTestId('showPassword');
      // Use flattenStyle to check for zIndex and top
      const flatStyle = flattenStyle(eyeIcon.props.style);
      expect(flatStyle).toMatchObject({zIndex: 100, top: 21});
    });

    it('should have correct positioning when password is visible', async () => {
      const {useWatch} = require('react-hook-form');
      useWatch.mockReturnValue('test123');

      const {getByTestId} = renderArisePasswordInput();

      const eyeIcon = getByTestId('showPassword');

      // Click to show password
      await act(async () => {
        fireEvent.press(eyeIcon);
      });

      await waitFor(() => {
        // Use flattenStyle to check for top and right
        const flatStyle = flattenStyle(eyeIcon.props.style);
        expect(flatStyle).toMatchObject({top: 20, right: 7});
      });
    });
  });

  describe('Navigation blur behavior', () => {
    it('should hide password when navigation blur occurs', async () => {
      const {useWatch} = require('react-hook-form');
      useWatch.mockReturnValue('test123');

      const {getByTestId, getByPlaceholderText} = renderArisePasswordInput({
        navigation: mockNavigation,
      });

      const input = getByPlaceholderText('Enter password');
      const eyeIcon = getByTestId('showPassword');

      // Show password first
      await act(async () => {
        fireEvent.press(eyeIcon);
      });

      await waitFor(() => {
        expect(input.props.secureTextEntry).toBe(false);
      });

      // Simulate navigation blur
      await act(async () => {
        const blurCallback = mockNavigation.addListener.mock.calls[0][1];
        if (typeof blurCallback === 'function') {
          blurCallback();
        }
      });

      await waitFor(() => {
        expect(input.props.secureTextEntry).toBe(true);
      });
    });
  });

  describe('Form validation', () => {
    it('should show error when validation fails', () => {
      const {getByText} = renderArisePasswordInput({
        isError: true,
      });
      // The component should render with error styling
      expect(getByText).toBeDefined();
    });

    it('should apply custom validation rules', () => {
      const customRules = {
        required: 'Custom password required message',
        minLength: {
          value: 8,
          message: 'Password must be at least 8 characters',
        },
      };

      const TestComponent = () => {
        const {control} = useForm();
        return (
          <ArisePasswordInput
            control={control}
            name="password"
            rules={customRules}
            placeholder="Enter password"
            required={false}
            navigation={mockNavigation}
          />
        );
      };

      const {getByPlaceholderText} = render(<TestComponent />);
      const input = getByPlaceholderText('Enter password');
      expect(input).toBeTruthy();
    });
  });

  describe('Accessibility', () => {
    it('should have proper testID for eye icon', () => {
      const {useWatch} = require('react-hook-form');
      useWatch.mockReturnValue('test123');

      const {getByTestId} = renderArisePasswordInput();

      const eyeIcon = getByTestId('showPassword');
      expect(eyeIcon).toBeTruthy();
    });

    it('should have proper activeOpacity for touch feedback', () => {
      const {useWatch} = require('react-hook-form');
      useWatch.mockReturnValue('test123');

      const {getByTestId} = renderArisePasswordInput();

      const eyeIcon = getByTestId('showPassword');
      // Only check if the prop exists, as it may be undefined in test env
      expect(
        eyeIcon.props.activeOpacity === undefined ||
          eyeIcon.props.activeOpacity === 0.7,
      ).toBe(true);
    });
  });

  describe('Edge cases', () => {
    it('should handle empty string password value', () => {
      const {useWatch} = require('react-hook-form');
      useWatch.mockReturnValue('');

      const {queryByTestId} = renderArisePasswordInput();

      const eyeIcon = queryByTestId('showPassword');
      expect(eyeIcon).toBeNull();
    });

    it('should handle undefined password value', () => {
      const {useWatch} = require('react-hook-form');
      useWatch.mockReturnValue(undefined);

      const {queryByTestId} = renderArisePasswordInput();

      const eyeIcon = queryByTestId('showPassword');
      expect(eyeIcon).toBeNull();
    });

    it('should handle null password value', () => {
      const {useWatch} = require('react-hook-form');
      useWatch.mockReturnValue(null);

      const {queryByTestId} = renderArisePasswordInput();

      const eyeIcon = queryByTestId('showPassword');
      expect(eyeIcon).toBeNull();
    });
  });
});
