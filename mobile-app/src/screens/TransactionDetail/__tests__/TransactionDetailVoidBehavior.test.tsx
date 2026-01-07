import React from 'react';
import {
  render,
  screen,
  fireEvent,
  waitFor,
} from '@testing-library/react-native';
import {NavigationContainer} from '@react-navigation/native';
import {QueryClient, QueryClientProvider} from '@tanstack/react-query';
import TransactionDetail from '../../TransactionDetail';
import * as ReactQuery from '@tanstack/react-query';

// Stable content
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

jest.mock('@/stores/userStore', () => ({
  useUserStore: jest.fn(() => 'merchant-123'),
}));

jest.mock('@/stores/alertStore', () => ({
  useAlertStore: jest.fn(() => ({showErrorAlert: jest.fn()})),
}));

const mockUseTransactionDetails = jest.fn();
jest.mock('@/hooks/queries/useTransactionDetails', () => ({
  useTransactionDetails: (args: any) => mockUseTransactionDetails(args),
}));

const mockMutate = jest.fn((_payload, opts) => {
  opts?.onSuccess?.({});
  opts?.onSettled?.();
});
jest.mock('@/hooks/queries/useTransactionVoid', () => ({
  useTransactionVoidMutation: () => ({mutate: mockMutate, isPending: false}),
}));

jest.mock('../Footer', () => {
  const RN = require('react-native');
  return ({onVoidPress}: any) => (
    <RN.TouchableOpacity onPress={onVoidPress}>
      <RN.Text>Void</RN.Text>
    </RN.TouchableOpacity>
  );
});

jest.mock('@gorhom/bottom-sheet', () => {
  const RN = require('react-native');
  const Mock = require('react').forwardRef((props: any, ref: any) => (
    <RN.View ref={ref} {...props} />
  ));
  return Object.assign(Mock, {
    __esModule: true,
    default: Mock,
    BottomSheetView: RN.View,
    BottomSheetBackdrop: (props: any) => <RN.View {...props} />,
  });
});

jest.mock('../VoidTransactionBottomSheet', () => {
  const RN = require('react-native');
  return ({onConfirm, onClose}: any) => (
    <RN.View>
      <RN.TouchableOpacity onPress={onConfirm}>
        <RN.Text>Confirm Void</RN.Text>
      </RN.TouchableOpacity>
      <RN.TouchableOpacity onPress={onClose}>
        <RN.Text>Cancel</RN.Text>
      </RN.TouchableOpacity>
    </RN.View>
  );
});

describe('TransactionDetail void behavior', () => {
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
      },
    },
  };
  const mockNavigation: any = {navigate: jest.fn(), goBack: jest.fn()};

  beforeEach(() => {
    jest.clearAllMocks();
    mockUseTransactionDetails.mockReturnValue({
      data: {id: 'txn-1', amount: {totalAmount: 10}},
      isLoading: false,
      isError: false,
    });
  });

  it('invokes void mutation with correct payload and options', async () => {
    const client = new QueryClient();
    render(
      <QueryClientProvider client={client}>
        <NavigationContainer>
          <TransactionDetail route={mockRoute} navigation={mockNavigation} />
        </NavigationContainer>
      </QueryClientProvider>,
    );

    fireEvent.press(screen.getByText('Void'));
    fireEvent.press(screen.getByText('Confirm Void'));

    await waitFor(() => {
      expect(mockMutate).toHaveBeenCalledWith(
        {transactionId: 'txn-1'},
        expect.any(Object),
      );
    });
  });

  it('shows and hides processing based on refetch state', async () => {
    let fetching = 0;
    const spy = jest
      .spyOn(ReactQuery, 'useIsFetching')
      .mockImplementation(() => fetching as any);

    const client = new QueryClient();
    const makeUI = (key: string) => (
      <QueryClientProvider client={client}>
        <NavigationContainer>
          <TransactionDetail
            key={key}
            route={mockRoute}
            navigation={mockNavigation}
          />
        </NavigationContainer>
      </QueryClientProvider>
    );

    const {rerender} = render(makeUI('a'));
    expect(screen.queryByText('Processing...')).toBeNull();

    fireEvent.press(screen.getByText('Void'));
    fetching = 1;
    fireEvent.press(screen.getByText('Confirm Void'));

    await waitFor(() => expect(screen.getByText('Processing...')).toBeTruthy());

    fetching = 0;
    rerender(makeUI('b'));
    await waitFor(() => expect(screen.queryByText('Processing...')).toBeNull());

    spy.mockRestore();
  });
});
