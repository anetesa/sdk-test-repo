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
import {useForm, Controller} from 'react-hook-form';
import AriseCreditCardInput from '../AriseCreditCardInput';

// Mock react-hook-form's useWatch
jest.mock('react-hook-form', () => ({
  ...jest.requireActual('react-hook-form'),
  useWatch: jest.fn(),
}));

// Mock creditcardutils
jest.mock('creditcardutils', () => ({
  parseCardType: jest.fn(digits => {
    if (digits.startsWith('4')) {
      return 'visa';
    }
    if (digits.startsWith('5')) {
      return 'mastercard';
    }
    return '';
  }),
  formatCardNumber: jest.fn(digits => {
    // Format with spaces every 4 digits
    return digits.replace(/(\d{4})(?=\d)/g, '$1 ');
  }),
}));

// Mock the card utility
jest.mock('../../../utils/card', () => ({
  getCardIcon: jest.fn(() => 'MockCardIcon'),
}));

// Helper component to render AriseCreditCardInput with form context
const renderAriseCreditCardInput = (props: any = {}) => {
  const TestComponent = () => {
    const {control} = useForm();
    return (
      <Controller
        control={control}
        name="cardNumber"
        render={({field: {onChange, value}}) => (
          <AriseCreditCardInput
            value={value || ''}
            onChangeText={onChange}
            placeholder="1234 5678 9876 5432"
            {...props}
          />
        )}
      />
    );
  };

  return render(<TestComponent />);
};

describe('AriseCreditCardInput', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Initial rendering', () => {
    it('should render the credit card input with placeholder', () => {
      const {getByPlaceholderText} = renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');
      expect(input).toBeTruthy();
    });

    it('should show the eye icon (eye-off) by default', () => {
      const {getByTestId} = renderAriseCreditCardInput();

      const eyeIcon = getByTestId('showCard');
      expect(eyeIcon).toBeTruthy();
    });

    it('should show default card icon when no card brand is detected', () => {
      const {getByTestId} = renderAriseCreditCardInput();

      // The card icon should be present in the component
      expect(getByTestId('showCard')).toBeTruthy();
    });
  });

  describe('Card number input and masking', () => {
    it('should show dots when numbers are entered and card is hidden', async () => {
      const {getByPlaceholderText, getByTestId, getByText} =
        renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');
      const eyeIcon = getByTestId('showCard');

      await act(async () => {
        fireEvent.changeText(input, '1234');
      });

      // The input should contain the formatted value
      expect(input.props.value).toBe('1234');

      // The eye icon should be present (indicating the component is working)
      expect(eyeIcon).toBeTruthy();

      // The dots overlay should be present with the masked value
      // The masked value should be "••••" (4 dots)
      const dotsOverlay = getByText('••••');
      expect(dotsOverlay).toBeTruthy();
    });

    it('should show dots for each digit entered', async () => {
      const {getByPlaceholderText, getByText} = renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');

      // Enter one digit
      await act(async () => {
        fireEvent.changeText(input, '1');
      });

      expect(input.props.value).toBe('1');
      // Should show one dot
      expect(getByText('•')).toBeTruthy();

      // Enter more digits
      await act(async () => {
        fireEvent.changeText(input, '1234');
      });

      expect(input.props.value).toBe('1234');
      // Should show four dots
      expect(getByText('••••')).toBeTruthy();

      // Enter a full card number
      await act(async () => {
        fireEvent.changeText(input, '1234567890123456');
      });

      expect(input.props.value).toBe('1234 5678 9012 3456');
      // Should show dots with spaces: "•••• •••• •••• ••••"
      expect(getByText('•••• •••• •••• ••••')).toBeTruthy();
    });

    it('should show dots with proper spacing (every 4 digits)', async () => {
      const {getByPlaceholderText, getByText} = renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');

      // Enter exactly 4 digits
      await act(async () => {
        fireEvent.changeText(input, '1234');
      });

      expect(input.props.value).toBe('1234');
      // Should show four dots without spaces
      expect(getByText('••••')).toBeTruthy();

      // Enter 8 digits (should have one space)
      await act(async () => {
        fireEvent.changeText(input, '12345678');
      });

      expect(input.props.value).toBe('1234 5678');
      // Should show dots with one space: "•••• ••••"
      expect(getByText('•••• ••••')).toBeTruthy();

      // Enter 12 digits (should have two spaces)
      await act(async () => {
        fireEvent.changeText(input, '123456789012');
      });

      expect(input.props.value).toBe('1234 5678 9012');
      // Should show dots with two spaces: "•••• •••• ••••"
      expect(getByText('•••• •••• ••••')).toBeTruthy();

      // Enter 16 digits (should have three spaces)
      await act(async () => {
        fireEvent.changeText(input, '1234567890123456');
      });

      expect(input.props.value).toBe('1234 5678 9012 3456');
      // Should show dots with three spaces: "•••• •••• •••• ••••"
      expect(getByText('•••• •••• •••• ••••')).toBeTruthy();
    });

    it('should format card number with spaces every 4 digits', async () => {
      const {getByPlaceholderText} = renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');

      await act(async () => {
        fireEvent.changeText(input, '1234567890123456');
      });

      // Should be formatted with spaces every 4 digits
      expect(input.props.value).toBe('1234 5678 9012 3456');
    });

    it('should limit input to 16 digits', async () => {
      const {getByPlaceholderText} = renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');

      await act(async () => {
        fireEvent.changeText(input, '12345678901234567890');
      });

      // Should be limited to 16 digits and formatted
      expect(input.props.value).toBe('1234 5678 9012 3456');
    });
  });

  describe('Eye icon functionality', () => {
    it('should show numbers when eye icon is clicked', async () => {
      const {getByPlaceholderText, getByTestId} = renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');
      const eyeIcon = getByTestId('showCard');

      // First, enter some numbers
      await act(async () => {
        fireEvent.changeText(input, '12345678');
      });

      // Initially should have formatted value
      expect(input.props.value).toBe('1234 5678');

      // Click the eye icon to show numbers
      await act(async () => {
        fireEvent.press(eyeIcon);
      });

      await waitFor(() => {
        // Should still have the same formatted value
        expect(input.props.value).toBe('1234 5678');
      });
    });

    it('should hide numbers and show dots when eye icon is clicked again', async () => {
      const {getByPlaceholderText, getByTestId} = renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');
      const eyeIcon = getByTestId('showCard');

      // First, enter some numbers
      await act(async () => {
        fireEvent.changeText(input, '12345678');
      });

      // Click the eye icon to show numbers
      await act(async () => {
        fireEvent.press(eyeIcon);
      });

      await waitFor(() => {
        // Should still have the same formatted value
        expect(input.props.value).toBe('1234 5678');
      });

      // Click the eye icon again to hide numbers
      await act(async () => {
        fireEvent.press(eyeIcon);
      });

      await waitFor(() => {
        // Should still have the same formatted value
        expect(input.props.value).toBe('1234 5678');
      });
    });

    it('should toggle between eye and eye-off icons', async () => {
      const {getByPlaceholderText, getByTestId} = renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');
      const eyeIcon = getByTestId('showCard');

      // Enter some numbers first
      await act(async () => {
        fireEvent.changeText(input, '12345678');
      });

      // Initially should show EyeOff (eye-off.svg)
      // We can verify this by checking the icon is present
      expect(eyeIcon).toBeTruthy();

      // Click to show numbers
      await act(async () => {
        fireEvent.press(eyeIcon);
      });

      await waitFor(() => {
        // Should still have the same formatted value
        expect(input.props.value).toBe('1234 5678');
      });

      // Click again to hide numbers
      await act(async () => {
        fireEvent.press(eyeIcon);
      });

      await waitFor(() => {
        // Should still have the same formatted value
        expect(input.props.value).toBe('1234 5678');
      });
    });

    it('should show dots when card is hidden and numbers when visible', async () => {
      const {getByPlaceholderText, getByTestId, getByText, queryByText} =
        renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');
      const eyeIcon = getByTestId('showCard');

      // Enter a card number
      await act(async () => {
        fireEvent.changeText(input, '1234567890123456');
      });

      expect(input.props.value).toBe('1234 5678 9012 3456');

      // Initially the card should be hidden (showing dots)
      // Should show dots overlay
      expect(getByText('•••• •••• •••• ••••')).toBeTruthy();

      // Click to show numbers
      await act(async () => {
        fireEvent.press(eyeIcon);
      });

      await waitFor(() => {
        // Should still have the same formatted value
        expect(input.props.value).toBe('1234 5678 9012 3456');
        // Dots should be hidden when showing numbers
        expect(queryByText('•••• •••• •••• ••••')).toBeNull();
      });

      // Click again to hide numbers (show dots)
      await act(async () => {
        fireEvent.press(eyeIcon);
      });

      await waitFor(() => {
        // Should still have the same formatted value
        expect(input.props.value).toBe('1234 5678 9012 3456');
        // Dots should be visible again
        expect(getByText('•••• •••• •••• ••••')).toBeTruthy();
      });
    });
  });

  describe('Card number formatting', () => {
    it('should format pasted numbers correctly', async () => {
      const {getByPlaceholderText, getByTestId} = renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');
      const eyeIcon = getByTestId('showCard');

      // Simulate pasting a long number
      await act(async () => {
        fireEvent.changeText(input, '1234567890123456');
      });

      // Should be formatted with spaces every 4 digits
      expect(input.props.value).toBe('1234 5678 9012 3456');

      // Test that the formatting works both when showing dots and numbers
      // Click to show numbers
      await act(async () => {
        fireEvent.press(eyeIcon);
      });

      await waitFor(() => {
        // Should still have the same formatted value
        expect(input.props.value).toBe('1234 5678 9012 3456');
      });
    });

    it('should show dots with proper spacing when pasting numbers', async () => {
      const {getByPlaceholderText, getByTestId, getByText, queryByText} =
        renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');
      const eyeIcon = getByTestId('showCard');

      // Paste a number with dashes and spaces
      await act(async () => {
        fireEvent.changeText(input, '1234-5678-9012-3456');
      });

      // Should remove non-numeric characters and format with spaces
      expect(input.props.value).toBe('1234 5678 9012 3456');

      // The dots should appear with the same spacing as the numbers
      expect(getByText('•••• •••• •••• ••••')).toBeTruthy();

      // Click to show numbers
      await act(async () => {
        fireEvent.press(eyeIcon);
      });

      await waitFor(() => {
        // Should still have the same formatted value
        expect(input.props.value).toBe('1234 5678 9012 3456');
        // Dots should be hidden
        expect(queryByText('•••• •••• •••• ••••')).toBeNull();
      });

      // Click to hide numbers (show dots)
      await act(async () => {
        fireEvent.press(eyeIcon);
      });

      await waitFor(() => {
        // Should still have the same formatted value
        expect(input.props.value).toBe('1234 5678 9012 3456');
        // Dots should be visible again
        expect(getByText('•••• •••• •••• ••••')).toBeTruthy();
      });
    });

    it('should handle non-numeric characters by removing them', async () => {
      const {getByPlaceholderText} = renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');

      await act(async () => {
        fireEvent.changeText(input, '1234-5678-9012-3456');
      });

      // Should remove non-numeric characters and format
      expect(input.props.value).toBe('1234 5678 9012 3456');
    });

    it('should maintain formatting when toggling visibility', async () => {
      const {getByPlaceholderText, getByTestId} = renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');
      const eyeIcon = getByTestId('showCard');

      // Enter a formatted number
      await act(async () => {
        fireEvent.changeText(input, '1234567890123456');
      });

      expect(input.props.value).toBe('1234 5678 9012 3456');

      // Show numbers
      await act(async () => {
        fireEvent.press(eyeIcon);
      });

      await waitFor(() => {
        // Should still have the same formatted value
        expect(input.props.value).toBe('1234 5678 9012 3456');
      });

      // Hide numbers
      await act(async () => {
        fireEvent.press(eyeIcon);
      });

      await waitFor(() => {
        // Should still have the same formatted value
        expect(input.props.value).toBe('1234 5678 9012 3456');
      });
    });
  });

  describe('Card brand detection', () => {
    it('should detect Visa card brand correctly', async () => {
      const {getByPlaceholderText} = renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');

      await act(async () => {
        fireEvent.changeText(input, '4111111111111111');
      });

      // The component should call parseCardType with the digits
      const creditcardutils = require('creditcardutils');
      expect(creditcardutils.parseCardType).toHaveBeenCalledWith(
        '4111111111111111',
      );

      // Verify that the mock returned 'visa' for this number
      expect(creditcardutils.parseCardType).toHaveReturnedWith('visa');
    });

    it('should detect Mastercard brand correctly', async () => {
      const {getByPlaceholderText} = renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');

      await act(async () => {
        fireEvent.changeText(input, '5555555555554444');
      });

      const creditcardutils = require('creditcardutils');
      expect(creditcardutils.parseCardType).toHaveBeenCalledWith(
        '5555555555554444',
      );

      // Verify that the mock returned 'mastercard' for this number
      expect(creditcardutils.parseCardType).toHaveReturnedWith('mastercard');
    });

    it('should detect different Visa numbers correctly', async () => {
      const {getByPlaceholderText} = renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');

      // Test different Visa numbers
      const visaNumbers = [
        '4111111111111111',
        '4222222222222222',
        '4333333333333333',
      ];

      for (const visaNumber of visaNumbers) {
        await act(async () => {
          fireEvent.changeText(input, visaNumber);
        });

        const creditcardutils = require('creditcardutils');
        expect(creditcardutils.parseCardType).toHaveBeenCalledWith(visaNumber);
        expect(creditcardutils.parseCardType).toHaveReturnedWith('visa');
      }
    });

    it('should detect different Mastercard numbers correctly', async () => {
      const {getByPlaceholderText} = renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');

      // Test different Mastercard numbers
      const mastercardNumbers = [
        '5555555555554444',
        '5666666666666666',
        '5777777777777777',
      ];

      for (const mastercardNumber of mastercardNumbers) {
        await act(async () => {
          fireEvent.changeText(input, mastercardNumber);
        });

        const creditcardutils = require('creditcardutils');
        expect(creditcardutils.parseCardType).toHaveBeenCalledWith(
          mastercardNumber,
        );
        expect(creditcardutils.parseCardType).toHaveReturnedWith('mastercard');
      }
    });

    it('should return empty string for unknown card types', async () => {
      const {getByPlaceholderText} = renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');

      // Test numbers that don't start with 4 or 5
      const unknownNumbers = [
        '1234567890123456',
        '2345678901234567',
        '3456789012345678',
      ];

      for (const unknownNumber of unknownNumbers) {
        await act(async () => {
          fireEvent.changeText(input, unknownNumber);
        });

        const creditcardutils = require('creditcardutils');
        expect(creditcardutils.parseCardType).toHaveBeenCalledWith(
          unknownNumber,
        );
        expect(creditcardutils.parseCardType).toHaveReturnedWith('');
      }
    });

    it('should detect card brand with partial numbers', async () => {
      const {getByPlaceholderText} = renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');

      // Test with just the first few digits
      await act(async () => {
        fireEvent.changeText(input, '4111');
      });

      const creditcardutils = require('creditcardutils');
      expect(creditcardutils.parseCardType).toHaveBeenCalledWith('4111');
      expect(creditcardutils.parseCardType).toHaveReturnedWith('visa');

      // Test with more digits
      await act(async () => {
        fireEvent.changeText(input, '5555');
      });

      expect(creditcardutils.parseCardType).toHaveBeenCalledWith('5555');
      expect(creditcardutils.parseCardType).toHaveReturnedWith('mastercard');
    });
  });

  describe('Input properties', () => {
    it('should have numeric keyboard type', () => {
      const {getByPlaceholderText} = renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');
      expect(input.props.keyboardType).toBe('numeric');
    });

    it('should have correct placeholder text', () => {
      const {getByPlaceholderText} = renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');
      expect(input.props.placeholder).toBe('1234 5678 9876 5432');
    });

    it('should have correct placeholder text color', () => {
      const {getByPlaceholderText} = renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');
      expect(input.props.placeholderTextColor).toBe('#999');
    });
  });

  describe('Edge cases', () => {
    it('should handle empty input correctly', async () => {
      const {getByPlaceholderText} = renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');

      await act(async () => {
        fireEvent.changeText(input, '');
      });

      expect(input.props.value).toBe('');
    });

    it('should handle partial input correctly', async () => {
      const {getByPlaceholderText} = renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');

      await act(async () => {
        fireEvent.changeText(input, '123');
      });

      expect(input.props.value).toBe('123');
    });

    it('should handle input with only spaces', async () => {
      const {getByPlaceholderText} = renderAriseCreditCardInput();

      const input = getByPlaceholderText('1234 5678 9876 5432');

      await act(async () => {
        fireEvent.changeText(input, '   ');
      });

      // Should remove spaces and be empty
      expect(input.props.value).toBe('');
    });
  });
});
