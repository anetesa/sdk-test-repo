import React from 'react';
import {render, screen, fireEvent} from '@testing-library/react-native';
import {NavigationContainer} from '@react-navigation/native';
import {QueryClient, QueryClientProvider} from '@tanstack/react-query';
import TransactionDetail from '../../TransactionDetail';
import {ROUTES, SCREEN_NAMES} from '@/constants/routes';
import {TRANSACTION_DETAIL_MESSAGES} from '@/constants/messages';

jest.mock('@/utils/transactionContentMapper', () => ({
  isRefunded: jest.fn(() => false),
  isFailed: jest.fn(() => false),
  isDeclined: jest.fn(() => false),
  isAchCredit: jest.fn(() => false),
  isPending: jest.fn(() => false),
  getTransactionContent: jest.fn(() => ({
    icon: require('react').createElement(
      require('react-native').Text,
      {testID: 'transaction-icon'},
      'Auth Icon',
    ),
    iconBgColor: 'bg-surface-green',
    title: 'Authorization',
    statusTextColor: 'text-green-500',
  })),
}));

jest.mock('@/stores/userStore', () => ({
  useUserStore: jest.fn(() => ({merchantId: 'test-merchant-id'})),
}));

// Ensure profile permissions include submit and void
jest.mock('@/hooks/useSelectedProfile', () => ({
  useSelectedProfile: () => ({
    selectedProfile: {
      permissions: ['Transactions.Submit', 'Transactions.Void'],
    },
  }),
}));

jest.mock('@/stores/alertStore', () => ({
  useAlertStore: jest.fn(() => ({showErrorAlert: jest.fn()})),
}));

const mockUseTransactionDetails = jest.fn();
jest.mock('@/hooks/queries/useTransactionDetails', () => ({
  useTransactionDetails: (args: any) => mockUseTransactionDetails(args),
}));

const mockCaptureHook = jest.fn();
jest.mock('@/hooks/queries/useCaptureTransaction', () => ({
  useTransactionCaptureMutation: () => mockCaptureHook(),
}));

jest.mock('@/hooks/queries/useTransactionVoid', () => ({
  useTransactionVoidMutation: () => ({mutate: jest.fn(), isPending: false}),
}));

// Render real Footer with its logic

describe('TransactionDetail capture flow', () => {
  const baseDetailsData = {
    id: 'txn-1',
    amount: {totalAmount: 10},
    paymentProcessorId: 'pp-1',
    transactionReceipt: {
      availableOperations: [{availableAmount: 12.34}],
      customerPan: '4111111111111111',
      cardDataSource: 'Chip',
    },
    type: 'Authorization',
    statusId: 1, // Authorized
  } as any;

  const mockRoute: any = {
    key: 'TransactionDetail-1',
    name: 'TransactionDetail',
    params: {
      transactionFromParams: {
        id: 'txn-1',
        statusId: 2,
        typeId: 2,
        type: 'Authorization',
        status: 'Authorized',
        date: '2024-01-01T00:00:00Z',
      },
    },
  };

  const makeClient = () => new QueryClient();

  const setup = (navigationOverrides: Partial<any> = {}) => {
    const navigation: any = {
      navigate: jest.fn(),
      goBack: jest.fn(),
      ...navigationOverrides,
    };
    const ui = (
      <QueryClientProvider client={makeClient()}>
        <NavigationContainer>
          <TransactionDetail route={mockRoute} navigation={navigation} />
        </NavigationContainer>
      </QueryClientProvider>
    );
    return {navigation, ui};
  };

  beforeEach(() => {
    jest.clearAllMocks();

    // Mock useUserStore to return merchant ID when called with merchantId selector
    const mockUseUserStore = require('@/stores/userStore').useUserStore;
    mockUseUserStore.mockImplementation((selector: any) => {
      if (typeof selector === 'function') {
        const state = {
          merchantId: 'merchant-123',
        };
        return selector(state);
      }
      return 'merchant-123'; // fallback
    });

    mockUseTransactionDetails.mockReturnValue({
      data: baseDetailsData,
      isLoading: false,
      isError: false,
    });
    mockCaptureHook.mockReturnValue({
      mutate: jest.fn(),
      data: undefined,
      isSuccess: false,
      isError: false,
      error: undefined,
      isPending: false,
    });
  });

  it('navigates to EnterAmount with correct params when capture is triggered', () => {
    const {navigation, ui} = setup();
    render(ui);

    // Footer should render Capture for Authorization type when permitted by profile (default mocked hook)
    expect(
      screen.getByText(TRANSACTION_DETAIL_MESSAGES.CAPTURE_BUTTON),
    ).toBeTruthy();

    // Trigger capture
    fireEvent.press(
      screen.getByText(TRANSACTION_DETAIL_MESSAGES.CAPTURE_BUTTON),
    );

    expect(navigation.navigate).toHaveBeenCalledWith(ROUTES.NEW_TRANSACTION, {
      screen: SCREEN_NAMES.ENTER_AMOUNT,
      params: expect.objectContaining({
        title: TRANSACTION_DETAIL_MESSAGES.TITLE_CAPTURE_TRANSACTION,
        enterAmountPrompt:
          TRANSACTION_DETAIL_MESSAGES.ENTER_AMOUNT_PROMPT_CAPTURE,
        continueButtonText: TRANSACTION_DETAIL_MESSAGES.CONFIRM_CAPTURE_BUTTON,
        defaultAmount: '1234',
        detailedAmount: expect.stringContaining('$12.34'),
        continueFunction: expect.any(Function),
      }),
    });
  });

  it('continueFunction formats amount, triggers capture mutation and goes back', () => {
    const mutate = jest.fn();
    mockCaptureHook.mockReturnValue({
      mutate,
      data: undefined,
      isSuccess: false,
      isError: false,
      error: undefined,
      isPending: false,
    });

    const {navigation, ui} = setup();
    render(ui);
    fireEvent.press(
      screen.getByText(TRANSACTION_DETAIL_MESSAGES.CAPTURE_BUTTON),
    );

    const call = (navigation.navigate as jest.Mock).mock.calls[0];
    const params = call[1].params;
    const cont = params.continueFunction as (amountSelected: number) => void;
    cont(999);

    expect(mutate).toHaveBeenCalledWith(
      {
        amount: 9.99,
        transactionId: 'txn-1',
      },
      {
        onSuccess: expect.any(Function),
      },
    );
    expect(navigation.goBack).toHaveBeenCalled();
  });
});
