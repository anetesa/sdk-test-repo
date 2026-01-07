import React from 'react';
import {fireEvent, render, waitFor, act} from '@testing-library/react-native';
import {NavigationContainer} from '@react-navigation/native';
import {QueryClient, QueryClientProvider} from '@tanstack/react-query';
import EnterAmountScreen from '../EnterAmountScreen';
import * as useMerchantSettings from '../../../hooks/queries/useMerchantSettings';
import * as userStore from '../../../stores/userStore';
import {UI_MESSAGES} from '../../../constants/messages';

// Mocks
const mockNavigate = jest.fn();
const mockReset = jest.fn();
const mockSetAmount = jest.fn();

jest.mock('../../../stores/transactionStore', () => ({
  useTransactionStore: (selector: (state: any) => any) => {
    const state = {
      setAmount: mockSetAmount,
      reset: mockReset,
    };
    if (typeof selector === 'function') {
      return selector(state);
    }
    return state;
  },
}));

const queryClient = new QueryClient();

const TestWrapper = ({children}: {children: React.ReactNode}) => (
  <QueryClientProvider client={queryClient}>
    <NavigationContainer>{children}</NavigationContainer>
  </QueryClientProvider>
);

describe('EnterAmountScreen', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    jest.spyOn(userStore, 'useUserStore').mockReturnValue({
      merchantId: '123',
    } as any);

    jest.spyOn(useMerchantSettings, 'useMerchantSettings').mockReturnValue({
      data: {
        merchantSettings: {
          maxTransactionAmount: 100000000,
        },
      },
      isLoading: false,
      isError: false,
      isSuccess: true,
    } as any);
  });

  it('should format the amount correctly when user types', async () => {
    const {getByTestId, getByText} = render(
      <TestWrapper>
        <EnterAmountScreen
          navigation={{navigate: mockNavigate} as any}
          route={{} as any}
        />
      </TestWrapper>,
    );

    await waitFor(() => {
      const pressNumber = (num: number) => {
        fireEvent.press(getByText(num.toString()));
      };

      // 9999999999 -> 99,999,999.99
      pressNumber(9);
      pressNumber(9);
      pressNumber(9);
      pressNumber(9);
      pressNumber(9);
      pressNumber(9);
      pressNumber(9);
      pressNumber(9);
      pressNumber(9);
      pressNumber(9);

      const amountInput = getByTestId('amount-text-input');
      expect(amountInput.props.value).toBe('99,999,999.99');
    });
  });

  it('should show error when amount exceeds maxTransactionAmount', async () => {
    jest.spyOn(useMerchantSettings, 'useMerchantSettings').mockReturnValue({
      data: {
        merchantSettings: {
          maxTransactionAmount: 100,
        },
      },
      isLoading: false,
      isError: false,
      isSuccess: true,
    } as any);

    const {getByText, getByTestId} = render(
      <TestWrapper>
        <EnterAmountScreen
          navigation={{navigate: mockNavigate} as any}
          route={{} as any}
        />
      </TestWrapper>,
    );

    await waitFor(() => {
      const pressNumber = (num: number) => {
        fireEvent.press(getByText(num.toString()));
      };

      pressNumber(1);
      pressNumber(0);
      pressNumber(1);
      pressNumber(0);
      pressNumber(0);

      const amountInput = getByTestId('amount-text-input');
      expect(amountInput.props.value).toBe('101.00');
      expect(getByText('Max. Amount - $100')).toBeTruthy();
    });
  });

  it('should not show error when amount is within maxTransactionAmount', async () => {
    jest.spyOn(useMerchantSettings, 'useMerchantSettings').mockReturnValue({
      data: {
        merchantSettings: {
          maxTransactionAmount: 100,
        },
      },
      isLoading: false,
      isError: false,
      isSuccess: true,
    } as any);

    const {queryByText, getByTestId, getByText} = render(
      <TestWrapper>
        <EnterAmountScreen
          navigation={{navigate: mockNavigate} as any}
          route={{} as any}
        />
      </TestWrapper>,
    );

    await waitFor(() => {
      const pressNumber = (num: number) => {
        fireEvent.press(getByText(num.toString()));
      };

      pressNumber(9);
      pressNumber(9);
      pressNumber(0);
      pressNumber(0);

      const amountInput = getByTestId('amount-text-input');
      expect(amountInput.props.value).toBe('99.00');
      expect(queryByText('Max. Amount - $100')).toBeNull();
    });
  });

  it('should continuously erase the value when holding backspace', async () => {
    jest.useFakeTimers();

    const {getByText, getByTestId} = render(
      <TestWrapper>
        <EnterAmountScreen
          navigation={{navigate: mockNavigate} as any}
          route={{} as any}
        />
      </TestWrapper>,
    );

    // Enter "123.45"
    fireEvent.press(getByText('1'));
    fireEvent.press(getByText('2'));
    fireEvent.press(getByText('3'));
    fireEvent.press(getByText('4'));
    fireEvent.press(getByText('5'));

    const amountInput = getByTestId('amount-text-input');
    expect(amountInput.props.value).toBe('123.45');

    const backspaceButton = getByTestId('backspace-button');

    // Hold the backspace button
    fireEvent(backspaceButton, 'pressIn');

    // Should erase one character immediately
    expect(amountInput.props.value).toBe('12.34');

    // Advance time to trigger interval
    act(() => {
      jest.advanceTimersByTime(200);
    });
    expect(amountInput.props.value).toBe('1.23');

    act(() => {
      jest.advanceTimersByTime(200);
    });
    expect(amountInput.props.value).toBe('0.12');

    // Release the backspace button
    fireEvent(backspaceButton, 'pressOut');

    // Advance time again to ensure the interval has stopped
    act(() => {
      jest.advanceTimersByTime(500);
    });
    expect(amountInput.props.value).toBe('0.12');

    jest.useRealTimers();
  });

  it('should display the amount prompt text', async () => {
    const {getByText} = render(
      <TestWrapper>
        <EnterAmountScreen
          navigation={{navigate: mockNavigate} as any}
          route={{} as any}
        />
      </TestWrapper>,
    );

    await waitFor(() => {
      expect(getByText(UI_MESSAGES.ENTER_AMOUNT_PROMPT)).toBeTruthy();
    });
  });

  it('should have isZero as false when the amount is not 0.00', async () => {
    const {getByTestId, getByText} = render(
      <TestWrapper>
        <EnterAmountScreen
          navigation={{navigate: mockNavigate} as any}
          route={{} as any}
        />
      </TestWrapper>,
    );

    await waitFor(() => {
      fireEvent.press(getByText('1'));
      const amountInput = getByTestId('amount-text-input');
      const isZero = amountInput.props.value === '0.00';
      expect(isZero).toBe(false);
    });
  });

  it('should have isZero as true when the amount is empty', async () => {
    const {getByTestId} = render(
      <TestWrapper>
        <EnterAmountScreen
          navigation={{navigate: mockNavigate} as any}
          route={{} as any}
        />
      </TestWrapper>,
    );

    await waitFor(() => {
      const amountInput = getByTestId('amount-text-input');
      const isZero =
        amountInput.props.value === '' || amountInput.props.value === '0.00';
      expect(isZero).toBe(true);
    });
  });

  it('should not navigate if no amount is entered', async () => {
    const {getByText} = render(
      <TestWrapper>
        <EnterAmountScreen
          navigation={{navigate: mockNavigate} as any}
          route={{} as any}
        />
      </TestWrapper>,
    );

    await waitFor(() => {
      const paymentButton = getByText('Select Payment Method');
      fireEvent.press(paymentButton);
      expect(mockNavigate).not.toHaveBeenCalled();
    });
  });

  it('should navigate when a valid amount is entered', async () => {
    const {getByText} = render(
      <TestWrapper>
        <EnterAmountScreen
          navigation={{navigate: mockNavigate} as any}
          route={{} as any}
        />
      </TestWrapper>,
    );

    await waitFor(() => {
      // Enter an amount
      fireEvent.press(getByText('1'));

      // Press the button
      const paymentButton = getByText('Select Payment Method');
      fireEvent.press(paymentButton);

      // Check navigation
      expect(mockNavigate).toHaveBeenCalledWith('ChooseMethod');
    });
  });
});
