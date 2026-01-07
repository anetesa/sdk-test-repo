import React from 'react';
import {render, screen, fireEvent} from '@testing-library/react-native';
import {NavigationContainer} from '@react-navigation/native';
import {QueryClient, QueryClientProvider} from '@tanstack/react-query';
import TransactionDetail from '../../TransactionDetail';
import {ROUTES, SCREEN_NAMES} from '@/constants/routes';
import {TRANSACTION_DETAIL_MESSAGES} from '@/constants/messages';

// Provide stable content mapper so header renders an icon
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
      'Sale Icon',
    ),
    iconBgColor: 'bg-surface-green',
    title: 'Sale',
    statusTextColor: 'text-green-500',
  })),
}));

// Mock stores
jest.mock('@/stores/userStore', () => ({
  useUserStore: jest.fn(() => 'merchant-123'),
}));

jest.mock('@/stores/alertStore', () => ({
  useAlertStore: jest.fn(() => ({showErrorAlert: jest.fn()})),
}));

// Mock hooks with override-able implementations per test
const mockUseTransactionDetails = jest.fn();
jest.mock('@/hooks/queries/useTransactionDetails', () => ({
  useTransactionDetails: (args: any) => mockUseTransactionDetails(args),
}));

const mockRefundHook = jest.fn();
jest.mock('@/hooks/queries/useRefundTransaction', () => ({
  useTransactionRefundMutation: () => mockRefundHook(),
}));

jest.mock('@/hooks/queries/useTransactionVoid', () => ({
  useTransactionVoidMutation: () => ({mutate: jest.fn(), isPending: false}),
}));

// Mock Footer to expose refund action easily
jest.mock('../Footer', () => {
  const RN = require('react-native');
  return ({onRefund}: any) => (
    <RN.TouchableOpacity onPress={onRefund}>
      <RN.Text>Refund</RN.Text>
    </RN.TouchableOpacity>
  );
});

describe('TransactionDetail refund flow', () => {
  const baseDetailsData = {
    id: 'txn-1',
    amount: {totalAmount: 10},
    paymentProcessorId: 'pp-1',
    transactionReceipt: {
      availableOperations: [{availableAmount: 5.75}],
      customerPan: '4111111111111111',
      cardDataSource: 'Chip',
    },
    type: 'Sale',
    statusId: 0,
  };

  const mockRoute: any = {
    key: 'TransactionDetail-1',
    name: 'TransactionDetail',
    params: {
      transactionFromParams: {
        id: 'txn-1',
        statusId: 1,
        typeId: 1,
        type: 'Sale',
        status: 'Approved',
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
    mockUseTransactionDetails.mockReturnValue({
      data: baseDetailsData,
      isLoading: false,
      isError: false,
    });
    mockRefundHook.mockReturnValue({
      mutate: jest.fn(),
      data: undefined,
      isSuccess: false,
      isError: false,
      error: undefined,
      isPending: false,
    });
  });

  it('navigates to EnterAmount with correct params when refund is triggered', () => {
    const {navigation, ui} = setup();
    render(ui);

    fireEvent.press(screen.getByText('Refund'));

    expect(navigation.navigate).toHaveBeenCalledWith(ROUTES.NEW_TRANSACTION, {
      screen: SCREEN_NAMES.ENTER_AMOUNT,
      params: expect.objectContaining({
        title: TRANSACTION_DETAIL_MESSAGES.TITLE_REFUND_TRANSACTION,
        enterAmountPrompt:
          TRANSACTION_DETAIL_MESSAGES.ENTER_AMOUNT_PROMPT_REFUND,
        continueButtonText: TRANSACTION_DETAIL_MESSAGES.CONFIRM_REFUND_BUTTON,
        defaultAmount: '575',
        detailedAmount: expect.stringContaining('$5.75'),
        continueFunction: expect.any(Function),
      }),
    });
  });

  it('continueFunction formats amount and triggers refund mutation and goBack', () => {
    const mutate = jest.fn();
    mockRefundHook.mockReturnValue({
      mutate,
      data: undefined,
      isSuccess: false,
      isError: false,
      error: undefined,
      isPending: false,
    });

    const {navigation, ui} = setup();
    render(ui);
    fireEvent.press(screen.getByText('Refund'));

    const call = (navigation.navigate as jest.Mock).mock.calls[0];
    const params = call[1].params;
    const cont = params.continueFunction as (amountSelected: number) => void;

    cont(500);

    expect(mutate).toHaveBeenCalledWith(
      {
        amount: 5,
        transactionId: 'txn-1',
        paymentProcessorId: 'pp-1',
      },
      {
        onSuccess: expect.any(Function),
      },
    );
    expect(navigation.goBack).toHaveBeenCalled();
  });

  it('shows decline message or generic fallback on refund non-approve statuses', () => {
    const {useAlertStore} = require('@/stores/alertStore');
    const showErrorAlert = jest.fn();
    (useAlertStore as jest.Mock).mockReturnValue({showErrorAlert});

    mockRefundHook.mockReturnValueOnce({
      mutate: jest.fn(),
      data: {details: {code: 'Decline', message: 'Declined by issuer'}},
      isSuccess: true,
      isError: false,
      error: undefined,
      isPending: false,
    });
    const {ui} = setup();
    render(ui);
    expect(showErrorAlert).toHaveBeenCalledWith('Declined by issuer');

    jest.clearAllMocks();
    mockRefundHook.mockReturnValueOnce({
      mutate: jest.fn(),
      data: {details: {code: 'Decline'}},
      isSuccess: true,
      isError: false,
      error: undefined,
      isPending: false,
    });
    render(ui);
    expect(showErrorAlert).toHaveBeenCalledWith(
      TRANSACTION_DETAIL_MESSAGES.FAILED_FALLBACK,
    );
  });

  it('navigates to TransactionDetail on refund approve', () => {
    const {navigation, ui} = setup();
    mockRefundHook.mockReturnValueOnce({
      mutate: jest.fn(),
      data: {
        details: {code: 'Approve'},
        transactionId: 'txn-2',
        transactionDateTime: '2024-02-02T00:00:00Z',
      },
      isSuccess: true,
      isError: false,
      error: undefined,
      isPending: false,
    });

    render(ui);

    expect(navigation.navigate).toHaveBeenCalledWith(
      ROUTES.TRANSACTION_DETAIL,
      {
        transactionFromParams: expect.objectContaining({
          id: 'txn-2',
          date: '2024-02-02T00:00:00Z',
        }),
      },
    );
  });

  it('shows PendingRequest when refund is pending', () => {
    mockRefundHook.mockReturnValueOnce({
      mutate: jest.fn(),
      data: undefined,
      isSuccess: false,
      isError: false,
      error: undefined,
      isPending: true,
    });
    const {ui} = setup();
    render(ui);
    expect(screen.getByText('Processing...')).toBeTruthy();
  });
});
