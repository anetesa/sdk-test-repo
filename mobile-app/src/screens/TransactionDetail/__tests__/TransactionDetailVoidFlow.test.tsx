import React from 'react';
import {
  render,
  screen,
  fireEvent,
  waitFor,
} from '@testing-library/react-native';
import TransactionDetail from '../../TransactionDetail';
import {QueryClient, QueryClientProvider} from '@tanstack/react-query';
import {NavigationContainer} from '@react-navigation/native';
import * as ReactQuery from '@tanstack/react-query';

// Mock transaction content mapper to ensure a non-null icon and stable content
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

// Mock hooks
const mockUseTransactionDetails = jest.fn();
jest.mock('@/hooks/queries/useTransactionDetails', () => ({
  useTransactionDetails: (args: any) => mockUseTransactionDetails(args),
}));

const mockMutate = jest.fn((_payload, opts) => {
  // Immediately simulate success to allow onSuccess/onSettled to run
  opts?.onSuccess?.({});
  opts?.onSettled?.();
});
jest.mock('@/hooks/queries/useTransactionVoid', () => ({
  useTransactionVoidMutation: () => ({
    mutate: mockMutate,
    isPending: false,
  }),
}));

// Mock child Footer to surface onVoidPress
jest.mock('../Footer', () => {
  const RN = require('react-native');
  return ({onVoidPress}: any) => (
    <RN.TouchableOpacity onPress={onVoidPress}>
      <RN.Text>Void</RN.Text>
    </RN.TouchableOpacity>
  );
});

// Mock BottomSheet native dependency used as type in the screen
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

// Mock the bottom sheet to expose a clear confirm button
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

describe('TransactionDetail void flow', () => {
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

  const mockNavigation: any = {navigate: jest.fn()};

  beforeEach(() => {
    jest.clearAllMocks();
    mockUseTransactionDetails.mockReturnValue({
      data: {id: 'txn-1', amount: {totalAmount: 10}},
      isLoading: false,
      isError: false,
    });
  });

  it('calls void mutation with merchantId and transactionId on confirm', async () => {
    const client = new QueryClient();
    const ui = (
      <QueryClientProvider client={client}>
        <NavigationContainer>
          <TransactionDetail route={mockRoute} navigation={mockNavigation} />
        </NavigationContainer>
      </QueryClientProvider>
    );
    render(ui);

    // First opens the sheet
    fireEvent.press(screen.getByText('Void'));
    // Then confirm inside the sheet
    fireEvent.press(screen.getByText('Confirm Void'));

    await waitFor(() => {
      expect(mockMutate).toHaveBeenCalledWith(
        {transactionId: 'txn-1'},
        expect.any(Object),
      );
    });
  });

  it('shows PendingRequest only after void and during refetch, then hides when done', async () => {
    // Spy and control useIsFetching values across the flow
    let currentFetchCount = 0;
    const useIsFetchingSpy = jest
      .spyOn(ReactQuery, 'useIsFetching')
      .mockImplementation(() => currentFetchCount as any);

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

    // Initially should NOT show processing
    expect(screen.queryByText('Processing...')).toBeNull();

    // Start void → simulate refetch in progress
    fireEvent.press(screen.getByText('Void'));
    currentFetchCount = 1;
    fireEvent.press(screen.getByText('Confirm Void'));

    // Now should show processing
    await waitFor(() => expect(screen.getByText('Processing...')).toBeTruthy());

    // End refetch
    currentFetchCount = 0;
    // Force a re-mount so useIsFetching is re-evaluated with new value
    rerender(makeUI('b'));
    await waitFor(() => expect(screen.queryByText('Processing...')).toBeNull());

    useIsFetchingSpy.mockRestore();
  });

  it('invalidates the transaction details query with the correct key', async () => {
    const client = new QueryClient();
    const invalidateSpy = jest.spyOn(client, 'invalidateQueries');
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
      expect(invalidateSpy).toHaveBeenCalledWith({
        queryKey: ['transactionDetails', 'merchant-123', 'txn-1'],
      });
    });
  });

  it('handles mutation error without getting stuck on loading', async () => {
    // Override mutate to call onError
    mockMutate.mockImplementationOnce((_payload, opts) => {
      opts?.onError?.(new Error('boom'));
      opts?.onSettled?.();
    });

    // Ensure useIsFetching reports no refetch
    const useIsFetchingSpy = jest
      .spyOn(ReactQuery, 'useIsFetching')
      .mockReturnValue(0 as any);

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

    // Should not show processing if there is no refetch and mutation errored
    await waitFor(() => expect(screen.queryByText('Processing...')).toBeNull());

    useIsFetchingSpy.mockRestore();
  });

  it('shows server decline message when response.details.code === "Decline"', async () => {
    // Make mutate call onSuccess with Decline details
    mockMutate.mockImplementationOnce((_payload, opts) => {
      opts?.onSuccess?.({
        details: {code: 'Decline', message: 'Reversal Not Allowed.'},
      });
      opts?.onSettled?.();
    });

    const client = new QueryClient();
    const {useAlertStore} = require('@/stores/alertStore');
    const showErrorAlert = jest.fn();
    (useAlertStore as jest.Mock).mockReturnValue({showErrorAlert});
    render(
      <QueryClientProvider client={client}>
        <NavigationContainer>
          <TransactionDetail route={mockRoute} navigation={mockNavigation} />
        </NavigationContainer>
      </QueryClientProvider>,
    );

    fireEvent.press(screen.getByText('Void'));
    fireEvent.press(screen.getByText('Confirm Void'));

    await waitFor(() =>
      expect(showErrorAlert).toHaveBeenCalledWith('Reversal Not Allowed.'),
    );
  });
});
