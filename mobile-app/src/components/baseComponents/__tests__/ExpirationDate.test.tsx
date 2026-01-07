import React from 'react';
import {render, fireEvent} from '@testing-library/react-native';
import {useForm} from 'react-hook-form';
import ExpirationDate from '../ExpirationDate';

// Mock react-native-outside-press to avoid DOM event errors in Jest
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

const TestComponent = (props: any = {}) => {
  const {control} = useForm({
    defaultValues: {
      expirationDate: '',
    },
  });

  return (
    <ExpirationDate
      control={control}
      name="expirationDate"
      required={false}
      className="w-full"
      {...props}
    />
  );
};

describe('ExpirationDate', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Basic rendering', () => {
    it('should render expiration date input with default props', () => {
      const {getByPlaceholderText, getByText} = render(<TestComponent />);

      const input = getByPlaceholderText('MM/YY');
      const label = getByText('Expiration Date');

      expect(input).toBeTruthy();
      expect(label).toBeTruthy();
    });

    it('should render with custom className', () => {
      const {getByPlaceholderText} = render(
        <TestComponent className="custom-class" />,
      );

      const input = getByPlaceholderText('MM/YY');
      expect(input).toBeTruthy();
    });

    it('should show "Optional" text when required is false', () => {
      const {getByText} = render(<TestComponent required={false} />);

      expect(getByText('Optional')).toBeTruthy();
    });

    it('should not show "Optional" text when required is true', () => {
      const {queryByText} = render(<TestComponent required={true} />);

      expect(queryByText('Optional')).toBeNull();
    });
  });

  describe('Date formatting', () => {
    it('should format single digit month correctly', () => {
      const {getByPlaceholderText} = render(<TestComponent />);
      const input = getByPlaceholderText('MM/YY');

      fireEvent.changeText(input, '1');
      expect(input.props.value).toBe('1');
    });

    it('should format two digit month correctly', () => {
      const {getByPlaceholderText} = render(<TestComponent />);
      const input = getByPlaceholderText('MM/YY');

      fireEvent.changeText(input, '12');
      expect(input.props.value).toBe('12');
    });

    it('should format month and year with slash', () => {
      const {getByPlaceholderText} = render(<TestComponent />);
      const input = getByPlaceholderText('MM/YY');

      fireEvent.changeText(input, '123');
      expect(input.props.value).toBe('12/3');
    });

    it('should format complete date correctly', () => {
      const {getByPlaceholderText} = render(<TestComponent />);
      const input = getByPlaceholderText('MM/YY');

      fireEvent.changeText(input, '1234');
      expect(input.props.value).toBe('12/34');
    });

    it('should limit to 4 digits maximum', () => {
      const {getByPlaceholderText} = render(<TestComponent />);
      const input = getByPlaceholderText('MM/YY');

      fireEvent.changeText(input, '12345');
      expect(input.props.value).toBe('12/34');
    });
  });

  describe('Input validation', () => {
    it('should remove non-digit characters', () => {
      const {getByPlaceholderText} = render(<TestComponent />);
      const input = getByPlaceholderText('MM/YY');

      fireEvent.changeText(input, '12ab34');
      expect(input.props.value).toBe('12/34');
    });

    it('should handle empty input', () => {
      const {getByPlaceholderText} = render(<TestComponent />);
      const input = getByPlaceholderText('MM/YY');

      fireEvent.changeText(input, '');
      expect(input.props.value).toBe('');
    });

    it('should handle special characters', () => {
      const {getByPlaceholderText} = render(<TestComponent />);
      const input = getByPlaceholderText('MM/YY');

      fireEvent.changeText(input, '12!@#$%34');
      expect(input.props.value).toBe('12/34');
    });
  });

  describe('Keyboard properties', () => {
    it('should have numeric keyboard type', () => {
      const {getByPlaceholderText} = render(<TestComponent />);
      const input = getByPlaceholderText('MM/YY');

      expect(input.props.keyboardType).toBe('numeric');
    });

    it('should have maxLength of 5', () => {
      const {getByPlaceholderText} = render(<TestComponent />);
      const input = getByPlaceholderText('MM/YY');

      expect(input.props.maxLength).toBe(5);
    });
  });

  describe('Error handling', () => {
    it('should show error state when error prop is true', () => {
      const {getByPlaceholderText} = render(
        <TestComponent error={{message: 'Invalid date'}} />,
      );

      const input = getByPlaceholderText('MM/YY');
      expect(input).toBeTruthy();
      // The error prop is used internally by the component for styling
    });

    it('should show error message when provided', () => {
      const {getByText} = render(
        <TestComponent error={{message: 'Invalid expiration date'}} />,
      );

      expect(getByText('Invalid expiration date')).toBeTruthy();
    });

    it('should not show error when error is false', () => {
      const {queryByText} = render(<TestComponent error={false} />);

      expect(queryByText('Invalid expiration date')).toBeNull();
    });
  });

  describe('Event handling', () => {
    it('should call onBlur when input loses focus', () => {
      const mockOnBlur = jest.fn();
      const {getByPlaceholderText} = render(
        <TestComponent onBlur={mockOnBlur} />,
      );

      const input = getByPlaceholderText('MM/YY');
      fireEvent(input, 'blur');

      expect(mockOnBlur).toHaveBeenCalledTimes(1);
    });

    it('should handle text changes correctly', () => {
      const {getByPlaceholderText} = render(<TestComponent />);
      const input = getByPlaceholderText('MM/YY');

      fireEvent.changeText(input, '1234');
      expect(input.props.value).toBe('12/34');

      fireEvent.changeText(input, '5678');
      expect(input.props.value).toBe('56/78');
    });
  });

  describe('Edge cases', () => {
    it('should handle single digit input', () => {
      const {getByPlaceholderText} = render(<TestComponent />);
      const input = getByPlaceholderText('MM/YY');

      fireEvent.changeText(input, '5');
      expect(input.props.value).toBe('5');
    });

    it('should handle three digit input', () => {
      const {getByPlaceholderText} = render(<TestComponent />);
      const input = getByPlaceholderText('MM/YY');

      fireEvent.changeText(input, '123');
      expect(input.props.value).toBe('12/3');
    });

    it('should handle very long input', () => {
      const {getByPlaceholderText} = render(<TestComponent />);
      const input = getByPlaceholderText('MM/YY');

      fireEvent.changeText(input, '123456789');
      expect(input.props.value).toBe('12/34');
    });

    it('should handle mixed character input', () => {
      const {getByPlaceholderText} = render(<TestComponent />);
      const input = getByPlaceholderText('MM/YY');

      fireEvent.changeText(input, '1a2b3c4d');
      expect(input.props.value).toBe('12/34');
    });
  });
});
