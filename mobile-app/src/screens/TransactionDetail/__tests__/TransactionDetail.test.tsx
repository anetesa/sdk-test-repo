import React from 'react';
import {render, screen} from '@testing-library/react-native';
import TransactionDetail from '../../TransactionDetail';
import {QueryClient, QueryClientProvider} from '@tanstack/react-query';
import {NavigationContainer} from '@react-navigation/native';

// Mock stores
jest.mock('@/stores/userStore', () => ({
  useUserStore: jest.fn(() => 'merchant-123'),
}));

jest.mock('@/stores/alertStore', () => ({
  useAlertStore: jest.fn(() => ({
    showErrorAlert: jest.fn(),
  })),
}));

// Mock hooks
jest.mock('@/hooks/queries/useTransactionDetails', () => ({
  useTransactionDetails: jest.fn(),
}));

// Mock utilities
jest.mock('@/utils/date', () => ({
  formatDateTime: jest.fn(() => 'Jan 15, 2024 10:30 AM'),
}));

jest.mock('@/utils/processingStatusShownAs', () => ({
  ProcessingStatusShownAs: jest.fn(status => status.toUpperCase()),
}));

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

jest.mock('@/dictionaries/TransactionStatuses', () => ({
  AllTransactionStatuses: {
    byId: jest.fn(() => ({name: 'Approved'})),
  },
}));

jest.mock('@/dictionaries/BinData', () => ({
  BinDataTypes: {
    byId: jest.fn(() => ({name: 'Credit'})),
  },
}));

jest.mock('@/utils/cardFlow', () => ({
  maskPan: jest.fn(pan => (pan ? '4111 **** **** 1111' : '')),
}));

jest.mock('@/utils/currency', () => ({
  formatAmountForDisplay: jest.fn(() => '100.50'),
}));

jest.mock('@/utils/card', () => ({
  CardIssuersIcons: {
    Visa: require('react-native').Text,
  },
  findDebitCardType: jest.fn(() => 'Visa'),
}));

// Mock child components
jest.mock('../Header', () => {
  const RN = require('react-native');
  return ({type, status, details, code, height}: any) => (
    <RN.View testID="transaction-header">
      <RN.Text testID="header-height">{height}</RN.Text>
      <RN.Text testID="header-type">{type}</RN.Text>
      <RN.Text testID="header-status">{status}</RN.Text>
      {details ? <RN.Text testID="header-details">{details}</RN.Text> : null}
      {code ? <RN.Text testID="header-code">Code: {code}</RN.Text> : null}
    </RN.View>
  );
});

jest.mock('../BodyFirst', () => {
  const RN = require('react-native');
  return ({transactionId}: any) => (
    <RN.View testID="transaction-body-first">
      <RN.Text>{transactionId}</RN.Text>
    </RN.View>
  );
});

jest.mock('../BodyDetail', () => {
  const RN = require('react-native');
  return ({transactionType, amount, amountLabel}: any) => (
    <RN.View testID="transaction-body-detail">
      <RN.Text testID="amount-label">{amountLabel}</RN.Text>
      <RN.Text>{transactionType}</RN.Text>
      <RN.Text>${amount}</RN.Text>
    </RN.View>
  );
});

jest.mock('../Footer', () => {
  const RN = require('react-native');
  return ({transactionId}: any) => (
    <RN.View testID="transaction-footer">
      <RN.Text>Footer for {transactionId}</RN.Text>
    </RN.View>
  );
});

const useTransactionDetails =
  require('@/hooks/queries/useTransactionDetails').useTransactionDetails;

describe('TransactionDetail', () => {
  const mockTransaction: any = {
    id: 'txn-123',
    statusId: 1,
    typeId: 1,
    type: 'Sale',
    status: 'Approved',
    totalAmount: 100.5,
    date: '2024-01-15T10:30:00Z',
    merchantId: 'merchant-123',
  };

  const mockRoute: any = {
    key: 'TransactionDetail-1',
    name: 'TransactionDetail',
    params: {
      transactionFromParams: mockTransaction,
    },
  };

  const mockNavigation: any = {
    navigate: jest.fn(),
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

  const mockTransactionDetailsData = {
    id: 'txn-123',
    authCode: 'ABC123',
    amount: {totalAmount: 100.5},
    creditDebitTypeId: 1,
    transactionReceipt: {
      customerPan: '4111111111111111',
      cardDataSource: 'Chip',
    },
  };

  beforeEach(() => {
    jest.clearAllMocks();
    useTransactionDetails.mockReturnValue({
      data: mockTransactionDetailsData,
      isLoading: false,
      isError: false,
    });
  });

  it('should render all main components', () => {
    const client = new QueryClient();
    render(
      <QueryClientProvider client={client}>
        <NavigationContainer>
          <TransactionDetail route={mockRoute} navigation={mockNavigation} />
        </NavigationContainer>
      </QueryClientProvider>,
    );

    expect(screen.getByTestId('transaction-header')).toBeTruthy();
    expect(screen.getByTestId('transaction-body-first')).toBeTruthy();
    expect(screen.getByTestId('transaction-body-detail')).toBeTruthy();
    expect(screen.getByTestId('transaction-footer')).toBeTruthy();
  });

  it('should pass correct props to child components', () => {
    const client2 = new QueryClient();
    render(
      <QueryClientProvider client={client2}>
        <NavigationContainer>
          <TransactionDetail route={mockRoute} navigation={mockNavigation} />
        </NavigationContainer>
      </QueryClientProvider>,
    );

    expect(screen.getByText('txn-123')).toBeTruthy();
    expect(screen.getByText('$100.50')).toBeTruthy();
    expect(screen.getByText('Footer for txn-123')).toBeTruthy();
  });

  it('should handle loading state', () => {
    useTransactionDetails.mockReturnValue({
      data: null,
      isLoading: true,
      isError: false,
    });

    const client9 = new QueryClient();
    render(
      <QueryClientProvider client={client9}>
        <NavigationContainer>
          <TransactionDetail route={mockRoute} navigation={mockNavigation} />
        </NavigationContainer>
      </QueryClientProvider>,
    );

    expect(screen.getByTestId('transaction-header')).toBeTruthy();
    expect(screen.getByTestId('transaction-body-first')).toBeTruthy();
    expect(screen.getByTestId('transaction-body-detail')).toBeTruthy();
    expect(screen.getByTestId('transaction-footer')).toBeTruthy();
  });

  it('should handle missing transaction data', () => {
    const incompleteRoute: any = {
      key: 'TransactionDetail-2',
      name: 'TransactionDetail',
      params: {
        transactionFromParams: {
          ...mockTransaction,
          type: undefined,
          status: undefined,
          date: undefined,
        },
      },
    };

    const client3 = new QueryClient();
    render(
      <QueryClientProvider client={client3}>
        <NavigationContainer>
          <TransactionDetail
            route={incompleteRoute}
            navigation={mockNavigation}
          />
        </NavigationContainer>
      </QueryClientProvider>,
    );

    expect(screen.getByTestId('transaction-header')).toBeTruthy();
  });

  it('should handle missing API data', () => {
    useTransactionDetails.mockReturnValue({
      data: null,
      isLoading: false,
      isError: false,
    });

    const client4 = new QueryClient();
    render(
      <QueryClientProvider client={client4}>
        <NavigationContainer>
          <TransactionDetail route={mockRoute} navigation={mockNavigation} />
        </NavigationContainer>
      </QueryClientProvider>,
    );

    expect(screen.getByTestId('transaction-header')).toBeTruthy();
    expect(screen.getByTestId('transaction-body-first')).toBeTruthy();
    expect(screen.getByTestId('transaction-body-detail')).toBeTruthy();
    expect(screen.getByTestId('transaction-footer')).toBeTruthy();
  });

  it('shows error details and code on declined/failed transactions', () => {
    const mapper = require('@/utils/transactionContentMapper');
    mapper.isFailed.mockReturnValue(true);

    useTransactionDetails.mockReturnValueOnce({
      data: {
        ...mockTransactionDetailsData,
        statusId: 0,
        type: 'Sale',
        status: 'Declined',
        avsResponse: {
          codeDescription: 'Address mismatch',
          responseCode: 'A1',
        },
        responseCode: '05',
        responseDescription: 'Do not honor',
      },
      isLoading: false,
      isError: false,
    });

    const client5 = new QueryClient();
    render(
      <QueryClientProvider client={client5}>
        <NavigationContainer>
          <TransactionDetail route={mockRoute} navigation={mockNavigation} />
        </NavigationContainer>
      </QueryClientProvider>,
    );

    expect(screen.getByTestId('transaction-header')).toBeTruthy();
    expect(screen.getByTestId('header-details').props.children).toBe(
      'Address mismatch',
    );
    expect(screen.getByText('Code: A1')).toBeTruthy();
  });

  it("maps type to 'Authorization' when original type is 'Void' and histories include Authorization", () => {
    useTransactionDetails.mockReturnValueOnce({
      data: {
        ...mockTransactionDetailsData,
        type: 'Void',
        histories: [
          {
            id: 'h1',
            transactionDateTime: '2024-01-01',
            transactionAmount: 0,
            transactionTypeId: 0,
            transactionType: 'Authorization',
            transactionStatusId: 0,
            transactionStatus: 'Approved',
          },
        ],
      },
      isLoading: false,
      isError: false,
    });

    const client6 = new QueryClient();
    render(
      <QueryClientProvider client={client6}>
        <NavigationContainer>
          <TransactionDetail route={mockRoute} navigation={mockNavigation} />
        </NavigationContainer>
      </QueryClientProvider>,
    );

    expect(screen.getByTestId('header-type').props.children).toBe(
      'Authorization',
    );
  });

  it("maps type to 'Sale' when original type is 'Void' and histories do not include Authorization", () => {
    useTransactionDetails.mockReturnValueOnce({
      data: {
        ...mockTransactionDetailsData,
        type: 'Void',
        histories: [
          {
            id: 'h2',
            transactionDateTime: '2024-01-02',
            transactionAmount: 0,
            transactionTypeId: 0,
            transactionType: 'Capture',
            transactionStatusId: 0,
            transactionStatus: 'Approved',
          },
        ],
      },
      isLoading: false,
      isError: false,
    });

    const client7 = new QueryClient();
    render(
      <QueryClientProvider client={client7}>
        <NavigationContainer>
          <TransactionDetail route={mockRoute} navigation={mockNavigation} />
        </NavigationContainer>
      </QueryClientProvider>,
    );

    expect(screen.getByTestId('header-type').props.children).toBe('Sale');
  });

  it('keeps original type when not Void', () => {
    useTransactionDetails.mockReturnValueOnce({
      data: {
        ...mockTransactionDetailsData,
        type: 'Sale',
        histories: [],
      },
      isLoading: false,
      isError: false,
    });

    const client8 = new QueryClient();
    render(
      <QueryClientProvider client={client8}>
        <NavigationContainer>
          <TransactionDetail route={mockRoute} navigation={mockNavigation} />
        </NavigationContainer>
      </QueryClientProvider>,
    );

    expect(screen.getByTestId('header-type').props.children).toBe('Sale');
  });

  it('sets header height when pending status', () => {
    const mapper = require('@/utils/transactionContentMapper');
    mapper.isPending.mockReturnValueOnce(true);

    const client10 = new QueryClient();
    render(
      <QueryClientProvider client={client10}>
        <NavigationContainer>
          <TransactionDetail route={mockRoute} navigation={mockNavigation} />
        </NavigationContainer>
      </QueryClientProvider>,
    );

    expect(screen.getByTestId('header-height').props.children).toBe(
      'h-[330px]',
    );
  });

  it('shows Amount Refunded and removes negative sign when refunded', () => {
    const mapper = require('@/utils/transactionContentMapper');
    mapper.isRefunded.mockReturnValue(true);

    const currency = require('@/utils/currency');
    currency.formatAmountForDisplay.mockReturnValue('-100.50');

    useTransactionDetails.mockReturnValueOnce({
      data: {
        ...mockTransactionDetailsData,
        statusId: 4,
        amount: {totalAmount: 100.5},
      },
      isLoading: false,
      isError: false,
    });

    const client9a = new QueryClient();
    render(
      <QueryClientProvider client={client9a}>
        <NavigationContainer>
          <TransactionDetail route={mockRoute} navigation={mockNavigation} />
        </NavigationContainer>
      </QueryClientProvider>,
    );

    expect(screen.getByTestId('amount-label').props.children).toBe(
      'Amount Refunded',
    );
    expect(screen.getByText('$100.50')).toBeTruthy();
  });

  it("maps 'RefundWORef' to header 'Refund' and body 'Refund without reference'", () => {
    useTransactionDetails.mockReturnValueOnce({
      data: {
        ...mockTransactionDetailsData,
        type: 'RefundWORef',
        histories: [],
      },
      isLoading: false,
      isError: false,
    });

    const client10a = new QueryClient();
    render(
      <QueryClientProvider client={client10a}>
        <NavigationContainer>
          <TransactionDetail route={mockRoute} navigation={mockNavigation} />
        </NavigationContainer>
      </QueryClientProvider>,
    );

    expect(screen.getByTestId('header-type').props.children).toBe('Refund');
    expect(screen.getByText('Refund without reference')).toBeTruthy();
  });
});
