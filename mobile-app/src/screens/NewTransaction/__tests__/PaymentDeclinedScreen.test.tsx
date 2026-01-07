import React from 'react';
import {render, fireEvent} from '@testing-library/react-native';
import {NavigationContainer} from '@react-navigation/native';
import {QueryClient, QueryClientProvider} from '@tanstack/react-query';
import PaymentDeclinedScreen from '../PaymentDeclinedScreen';
import {KEYED_TRANSACTION_MESSAGES} from '../../../constants/messages';

// Mocks
const mockNavigate = jest.fn();
const mockSetAmount = jest.fn();
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
    setAmount: mockSetAmount,
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

const mockRoute = {
  params: {
    response: {
      details: {
        message: 'Transaction was declined by the bank',
      },
    },
  },
};

describe('PaymentDeclinedScreen', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders correctly with title and message', () => {
    const {getByText} = render(
      <TestWrapper>
        <PaymentDeclinedScreen
          navigation={mockNavigation as any}
          route={mockRoute as any}
        />
      </TestWrapper>,
    );

    expect(getByText(KEYED_TRANSACTION_MESSAGES.DECLINED)).toBeTruthy();
    expect(getByText('Transaction was declined by the bank')).toBeTruthy();
    expect(getByText(KEYED_TRANSACTION_MESSAGES.RETRY_BUTTON)).toBeTruthy();
    expect(getByText(KEYED_TRANSACTION_MESSAGES.CANCEL_BUTTON)).toBeTruthy();
  });

  it('navigates to Home when Cancel button is pressed', () => {
    const {getByText} = render(
      <TestWrapper>
        <PaymentDeclinedScreen
          navigation={mockNavigation as any}
          route={mockRoute as any}
        />
      </TestWrapper>,
    );

    fireEvent.press(getByText(KEYED_TRANSACTION_MESSAGES.CANCEL_BUTTON));
    expect(mockNavigate).toHaveBeenCalledWith('Home');
  });

  it('navigates to ChooseMethod when Retry button is pressed', () => {
    const {getByText} = render(
      <TestWrapper>
        <PaymentDeclinedScreen
          navigation={mockNavigation as any}
          route={mockRoute as any}
        />
      </TestWrapper>,
    );

    fireEvent.press(getByText(KEYED_TRANSACTION_MESSAGES.RETRY_BUTTON));
    expect(mockRetryTransaction).toHaveBeenCalled();
    expect(mockNavigate).toHaveBeenCalledWith('ChooseMethod');
  });

  it('renders without response message when not provided', () => {
    const routeWithoutMessage = {
      params: {
        response: {},
      },
    };

    const {getByText, queryByText} = render(
      <TestWrapper>
        <PaymentDeclinedScreen
          navigation={mockNavigation as any}
          route={routeWithoutMessage as any}
        />
      </TestWrapper>,
    );

    expect(getByText(KEYED_TRANSACTION_MESSAGES.DECLINED)).toBeTruthy();
    expect(queryByText('Transaction was declined by the bank')).toBeFalsy();
  });

  it('prioritizes avs code description over response.details.message', () => {
    const routeWithAvs = {
      params: {
        response: {
          avsResponse: {
            codeDescription: 'Address verification failed',
          },
          details: {
            message: 'Some other error message',
          },
        },
        details: {},
      },
    } as any;

    const {getByText, queryByText} = render(
      <TestWrapper>
        <PaymentDeclinedScreen
          navigation={mockNavigation as any}
          route={routeWithAvs}
        />
      </TestWrapper>,
    );

    expect(getByText('Address verification failed')).toBeTruthy();
    expect(queryByText('Some other error message')).toBeFalsy();
  });

  it('shows error code label only when details.responseCode exists', () => {
    const routeNoCode = {
      params: {
        response: {
          details: {message: 'Declined'},
        },
        details: {},
      },
    } as any;

    const {queryByText} = render(
      <TestWrapper>
        <PaymentDeclinedScreen
          navigation={mockNavigation as any}
          route={routeNoCode}
        />
      </TestWrapper>,
    );

    expect(
      queryByText(`${KEYED_TRANSACTION_MESSAGES.ERROR_CODE_LABEL}`),
    ).toBeFalsy();
  });

  it('displays avs response code when available, otherwise details.responseCode', () => {
    const routeWithCodes = {
      params: {
        response: {
          avsResponse: {responseCode: 'N7'},
        },
        details: {responseCode: '05'},
      },
    } as any;

    const {getByText, rerender} = render(
      <TestWrapper>
        <PaymentDeclinedScreen
          navigation={mockNavigation as any}
          route={routeWithCodes}
        />
      </TestWrapper>,
    );

    expect(
      getByText(`${KEYED_TRANSACTION_MESSAGES.ERROR_CODE_LABEL}\u00A0N7`),
    ).toBeTruthy();

    // Remove avs, should fallback to details.responseCode
    const routeWithoutAvs = {
      params: {
        response: {},
        details: {responseCode: '05'},
      },
    } as any;

    rerender(
      <TestWrapper>
        <PaymentDeclinedScreen
          navigation={mockNavigation as any}
          route={routeWithoutAvs}
        />
      </TestWrapper>,
    );

    expect(
      getByText(`${KEYED_TRANSACTION_MESSAGES.ERROR_CODE_LABEL}\u00A005`),
    ).toBeTruthy();
  });
});
