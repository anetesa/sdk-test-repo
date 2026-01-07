import React from 'react';
import {render, fireEvent} from '@testing-library/react-native';
import {NavigationContainer} from '@react-navigation/native';
import {QueryClient, QueryClientProvider} from '@tanstack/react-query';
import ValidationErrorScreen from '../ValidationErrorScreen';
import {KEYED_TRANSACTION_MESSAGES} from '../../../constants/messages';
import {SCREEN_NAMES} from '../../../constants/routes';
import type {TransactionSaleError} from '../../../types/TransactionSale';

// Mocks
const mockNavigate = jest.fn();
const mockReset = jest.fn();
const mockRetryTransaction = jest.fn();

const mockNavigation = {
  navigate: mockNavigate,
  goBack: jest.fn(),
  push: jest.fn(),
  pop: jest.fn(),
  popToTop: jest.fn(),
  dispatch: jest.fn(),
  reset: jest.fn(),
  isFocused: jest.fn(),
  canGoBack: jest.fn(),
  getId: jest.fn(),
  getParent: jest.fn(),
  getState: jest.fn(),
};

jest.mock('../../../stores/transactionStore', () => ({
  useTransactionStore: () => ({
    reset: mockReset,
    retryTransaction: mockRetryTransaction,
    amount: 5000,
    currency: 'USD',
  }),
}));

const queryClient = new QueryClient();

const TestWrapper = ({children}: {children: React.ReactNode}) => (
  <QueryClientProvider client={queryClient}>
    <NavigationContainer>{children}</NavigationContainer>
  </QueryClientProvider>
);

const mockTransactionSaleError: TransactionSaleError = {
  Errors: {
    field1: ['Error message 1', 'Error message 2'],
    field2: ['Another error'],
  },
  Details: 'Transaction validation failed',
  StatusCode: 400,
  Source: 'PaymentProcessor',
  ExceptionType: 'ValidationException',
  CorrelationId: 'test-correlation-id',
  ErrorCode: 'V1001',
};

const createMockRoute = (error?: TransactionSaleError) => ({
  params: {
    error,
  },
});

describe('ValidationErrorScreen', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders correctly with default messages when no error provided', () => {
    const mockRoute = createMockRoute();

    const {getByText} = render(
      <TestWrapper>
        <ValidationErrorScreen
          navigation={mockNavigation as any}
          route={mockRoute as any}
        />
      </TestWrapper>,
    );

    expect(getByText('Transaction Error')).toBeTruthy();
    expect(getByText('Transaction failed. Please try again.')).toBeTruthy();
    expect(
      getByText(`${KEYED_TRANSACTION_MESSAGES.ERROR_CODE_LABEL}\u00A0V0000`),
    ).toBeTruthy();
    expect(
      getByText(KEYED_TRANSACTION_MESSAGES.RETRY_TRANSACTION_BUTTON),
    ).toBeTruthy();
    expect(getByText(KEYED_TRANSACTION_MESSAGES.CANCEL_BUTTON)).toBeTruthy();
  });

  it('renders correctly with error data provided', () => {
    const mockRoute = createMockRoute(mockTransactionSaleError);

    const {getByText} = render(
      <TestWrapper>
        <ValidationErrorScreen
          navigation={mockNavigation as any}
          route={mockRoute as any}
        />
      </TestWrapper>,
    );

    expect(getByText('Transaction Error')).toBeTruthy();
    expect(getByText('Error message 1')).toBeTruthy(); // First error from first field
    expect(
      getByText(`${KEYED_TRANSACTION_MESSAGES.ERROR_CODE_LABEL}\u00A0V1001`),
    ).toBeTruthy();
  });

  it('uses fallback description when error has no Errors array', () => {
    const errorWithoutErrors = {
      ...mockTransactionSaleError,
      Errors: {},
    };
    const mockRoute = createMockRoute(errorWithoutErrors);

    const {getByText} = render(
      <TestWrapper>
        <ValidationErrorScreen
          navigation={mockNavigation as any}
          route={mockRoute as any}
        />
      </TestWrapper>,
    );

    expect(getByText('Transaction failed. Please try again.')).toBeTruthy();
  });

  it('uses fallback description when error.Errors is undefined', () => {
    const errorWithUndefinedErrors = {
      ...mockTransactionSaleError,
      Errors: undefined as any,
    };
    const mockRoute = createMockRoute(errorWithUndefinedErrors);

    const {getByText} = render(
      <TestWrapper>
        <ValidationErrorScreen
          navigation={mockNavigation as any}
          route={mockRoute as any}
        />
      </TestWrapper>,
    );

    expect(getByText('Transaction failed. Please try again.')).toBeTruthy();
  });

  it('uses fallback error code when error has no ErrorCode', () => {
    const errorWithoutCode = {
      ...mockTransactionSaleError,
      ErrorCode: undefined as any,
    };
    const mockRoute = createMockRoute(errorWithoutCode);

    const {getByText} = render(
      <TestWrapper>
        <ValidationErrorScreen
          navigation={mockNavigation as any}
          route={mockRoute as any}
        />
      </TestWrapper>,
    );

    expect(
      getByText(`${KEYED_TRANSACTION_MESSAGES.ERROR_CODE_LABEL}\u00A0V0000`),
    ).toBeTruthy();
  });

  it('handles retry transaction button press correctly', () => {
    const mockRoute = createMockRoute(mockTransactionSaleError);

    const {getByText} = render(
      <TestWrapper>
        <ValidationErrorScreen
          navigation={mockNavigation as any}
          route={mockRoute as any}
        />
      </TestWrapper>,
    );

    fireEvent.press(
      getByText(KEYED_TRANSACTION_MESSAGES.RETRY_TRANSACTION_BUTTON),
    );

    expect(mockRetryTransaction).toHaveBeenCalled();
    expect(mockNavigate).toHaveBeenCalledWith(SCREEN_NAMES.CHOOSE_METHOD);
  });

  it('handles cancel button press correctly', () => {
    const mockRoute = createMockRoute(mockTransactionSaleError);

    const {getByText} = render(
      <TestWrapper>
        <ValidationErrorScreen
          navigation={mockNavigation as any}
          route={mockRoute as any}
        />
      </TestWrapper>,
    );

    fireEvent.press(getByText(KEYED_TRANSACTION_MESSAGES.CANCEL_BUTTON));

    expect(mockReset).toHaveBeenCalled();
    expect(mockNavigate).toHaveBeenCalledWith('Home');
  });

  it('displays the AlertCircle icon', () => {
    const mockRoute = createMockRoute(mockTransactionSaleError);

    const {getByTestId} = render(
      <TestWrapper>
        <ValidationErrorScreen
          navigation={mockNavigation as any}
          route={mockRoute as any}
        />
      </TestWrapper>,
    );

    // Test that the icon container is rendered
    const iconContainer = getByTestId('validation-error-icon');
    expect(iconContainer).toBeTruthy();
  });

  it('handles complex error structure with multiple fields and messages', () => {
    const complexError: TransactionSaleError = {
      Errors: {
        creditCard: ['Invalid card number', 'Card expired'],
        amount: ['Amount too large'],
        merchant: [
          'Merchant not found',
          'Merchant inactive',
          'Invalid merchant ID',
        ],
      },
      Details: 'Multiple validation errors',
      StatusCode: 400,
      Source: 'ValidationService',
      ExceptionType: 'MultipleValidationException',
      CorrelationId: 'complex-test-id',
      ErrorCode: 'V2001',
    };

    const mockRoute = createMockRoute(complexError);

    const {getByText} = render(
      <TestWrapper>
        <ValidationErrorScreen
          navigation={mockNavigation as any}
          route={mockRoute as any}
        />
      </TestWrapper>,
    );

    // Should display the first error from the first field
    expect(getByText('Invalid card number')).toBeTruthy();
    expect(
      getByText(`${KEYED_TRANSACTION_MESSAGES.ERROR_CODE_LABEL}\u00A0V2001`),
    ).toBeTruthy();
  });

  it('handles error with empty error arrays', () => {
    const errorWithEmptyArrays: TransactionSaleError = {
      Errors: {
        field1: [],
        field2: [],
      },
      Details: 'No specific errors',
      StatusCode: 400,
      Source: 'Test',
      ExceptionType: 'TestException',
      CorrelationId: 'empty-arrays-test',
      ErrorCode: 'V3001',
    };

    const mockRoute = createMockRoute(errorWithEmptyArrays);

    const {getByText} = render(
      <TestWrapper>
        <ValidationErrorScreen
          navigation={mockNavigation as any}
          route={mockRoute as any}
        />
      </TestWrapper>,
    );

    // Should fall back to default description
    expect(getByText('Transaction failed. Please try again.')).toBeTruthy();
  });

  it.each([
    [
      'SurchargeRate',
      'Surcharge override is not allowed. Default value: ',
      'V0000',
    ],
    [
      'cardType',
      'Card type is disabled for merchant: Visa, pan: 4111*',
      'V0000',
    ],
    [
      'IsLimitExceeded',
      'Transaction does not meet the maximum number of transactions limit.',
      'V0000',
    ],
    [
      'IsDuplicate',
      'Possible Duplicate Transaction Detected. A transaction with the same transaction amount, customer details, and a close timestamp has been identified in our system.',
      'V0000',
    ],
  ])(
    'renders axios-style error response for %s',
    (fieldKey: string, message: string, code: string) => {
      const axiosStyleRoute = {
        params: {
          error: {
            response: {
              data: {
                Errors: {
                  [fieldKey]: [message],
                },
                StatusCode: 400,
                Source: 'PaymentGateway',
                ExceptionType: 'ValidationException',
                CorrelationId: 'test-correlation-id',
                ErrorCode: code,
              },
            },
          },
        },
      } as any;

      const {getByText} = render(
        <TestWrapper>
          <ValidationErrorScreen
            navigation={mockNavigation as any}
            route={axiosStyleRoute}
          />
        </TestWrapper>,
      );

      expect(getByText('Transaction Error')).toBeTruthy();
      expect(getByText(message)).toBeTruthy();
      expect(
        getByText(
          `${KEYED_TRANSACTION_MESSAGES.ERROR_CODE_LABEL}\u00A0${code}`,
        ),
      ).toBeTruthy();
    },
  );
});
