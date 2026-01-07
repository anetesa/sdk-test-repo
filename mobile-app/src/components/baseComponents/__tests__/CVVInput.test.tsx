import React from 'react';
import {render, fireEvent} from '@testing-library/react-native';
import {useForm} from 'react-hook-form';
import {yupResolver} from '@hookform/resolvers/yup';
import CVVInput from '../CVVInput';
import * as yup from 'yup';

// Mock creditcardutils
jest.mock('creditcardutils', () => ({
  parseCardType: jest.fn(digits => {
    if (digits.startsWith('34') || digits.startsWith('37')) {
      return 'amex';
    }
    if (digits.startsWith('4')) {
      return 'visa';
    }
    if (digits.startsWith('5')) {
      return 'mastercard';
    }
    return '';
  }),
}));

jest.mock('react-native-outside-press', () => {
  const OutsidePressHandler = ({children}: {children: React.ReactNode}) => (
    <>{children}</>
  );
  return {
    __esModule: true,
    default: OutsidePressHandler,
  };
});

const cvvSchema = yup.object({
  cardNumber: yup.string(),
  cvv: yup
    .string()
    .required('Security code is required')
    .test('is-valid-cvv', function (value) {
      if (!value) {
        return false;
      }

      const cardNumber = this.parent.cardNumber;
      if (!cardNumber) {
        const digitCount = value.replace(/\D/g, '').length;
        return digitCount >= 3 && digitCount <= 4;
      }

      const digitsOnly = cardNumber.replace(/\s/g, '');
      const cardType = require('creditcardutils').parseCardType(digitsOnly);
      const isAmex = cardType === 'amex';
      const digitCount = value.replace(/\D/g, '').length;

      if (isAmex) {
        return digitCount === 4;
      } else {
        return digitCount === 3;
      }
    }),
});

const TestComponent = ({defaultCardNumber = ''}) => {
  const {control} = useForm({
    resolver: yupResolver(cvvSchema),
    defaultValues: {
      cardNumber: defaultCardNumber,
      cvv: '',
    },
  });

  return (
    <CVVInput control={control} name="cvv" required={true} className="w-full" />
  );
};

describe('CVVInput', () => {
  it('renders correctly', () => {
    const {getByPlaceholderText} = render(<TestComponent />);
    expect(getByPlaceholderText('1234')).toBeTruthy();
  });

  it('formats input correctly', () => {
    const {getByPlaceholderText} = render(<TestComponent />);
    const input = getByPlaceholderText('1234');

    // Test formatting - only digits allowed
    fireEvent.changeText(input, '123');
    expect(input.props.value).toBe('123');

    fireEvent.changeText(input, '1234');
    expect(input.props.value).toBe('1234');

    fireEvent.changeText(input, '12ab34');
    expect(input.props.value).toBe('1234');
  });

  it('limits to 4 digits by default', () => {
    const {getByPlaceholderText} = render(<TestComponent />);
    const input = getByPlaceholderText('1234');

    fireEvent.changeText(input, '12345');
    expect(input.props.value).toBe('1234');
  });

  it('adjusts maxLength for AMEX cards', () => {
    const {getByPlaceholderText} = render(
      <TestComponent defaultCardNumber="341111111111111" />,
    );
    const input = getByPlaceholderText('1234');

    // Should allow 4 digits for AMEX
    fireEvent.changeText(input, '1234');
    expect(input.props.value).toBe('1234');
  });

  it('adjusts maxLength for non-AMEX cards', () => {
    const {getByPlaceholderText} = render(
      <TestComponent defaultCardNumber="4111111111111111" />,
    );
    const input = getByPlaceholderText('123');

    // Should limit to 3 digits for non-AMEX
    fireEvent.changeText(input, '1234');
    expect(input.props.value).toBe('123');
  });

  it('handles invalid characters', () => {
    const {getByPlaceholderText} = render(<TestComponent />);
    const input = getByPlaceholderText('1234');

    fireEvent.changeText(input, 'abc123def');
    expect(input.props.value).toBe('123');
  });
});
