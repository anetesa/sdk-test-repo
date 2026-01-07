import React from 'react';
import {render, screen} from '@testing-library/react-native';
import {Text} from 'react-native';
import TransactionItem from '../TransactionItem';
import {GetTransactionsResponseDTO} from '@/types/TransactionResponse';

// Mock only the date utility
jest.mock('@/utils/date', () => ({
  formatDateTime: jest.fn(),
}));

// Mock navigation
const mockNavigate = jest.fn();
jest.mock('@react-navigation/native', () => ({
  useNavigation: () => ({
    navigate: mockNavigate,
  }),
}));

// Mock transaction content mapper
jest.mock('@/utils/transactionContentMapper', () => ({
  getTransactionContent: jest.fn(),
  isAchCredit: jest.fn(() => false),
}));

const mockFormatDateTime = require('@/utils/date').formatDateTime;
const mockGetTransactionContent =
  require('@/utils/transactionContentMapper').getTransactionContent;

describe('TransactionItem', () => {
  const mockTransaction: GetTransactionsResponseDTO = {
    id: '123',
    statusId: 1,
    typeId: 1,
    totalAmount: 100.5,
    date: '2024-01-15T10:30:00Z',
    merchantId: 'merchant-123',
  };

  beforeEach(() => {
    jest.clearAllMocks();
    mockFormatDateTime.mockReturnValue('Jan 15, 2024 10:30 AM');
    mockNavigate.mockClear();
    mockGetTransactionContent.mockReturnValue({
      title: 'Sale',
      icon: <Text>Icon</Text>,
      iconBgColor: 'bg-green-500',
    });
  });

  describe('Basic rendering', () => {
    it('should render transaction item with correct props', () => {
      render(
        <TransactionItem
          transaction={mockTransaction}
          isAmountHidden={false}
          showBorder={true}
        />,
      );

      expect(screen.getByTestId('transaction-item')).toBeTruthy();
      expect(screen.getByTestId('list-item-left')).toBeTruthy();
      expect(screen.getByTestId('list-item-right')).toBeTruthy();
      expect(screen.getByTestId('transaction-icon-container')).toBeTruthy();
      expect(screen.getByTestId('transaction-title')).toBeTruthy();
      expect(screen.getByTestId('transaction-date')).toBeTruthy();
      expect(screen.getByTestId('transaction-amount')).toBeTruthy();
      expect(screen.getByText('Jan 15, 2024 10:30 AM')).toBeTruthy();
      expect(screen.getByText('$100.50')).toBeTruthy();
    });

    it('should call formatDateTime with transaction date', () => {
      render(
        <TransactionItem
          transaction={mockTransaction}
          isAmountHidden={false}
          showBorder={true}
        />,
      );

      expect(mockFormatDateTime).toHaveBeenCalledWith('2024-01-15T10:30:00Z');
    });
  });

  describe('Amount display', () => {
    it('should display formatted currency when amount is not hidden', () => {
      render(
        <TransactionItem
          transaction={mockTransaction}
          isAmountHidden={false}
          showBorder={true}
        />,
      );

      expect(screen.getByText('$100.50')).toBeTruthy();
    });

    it('should display dots when amount is hidden', () => {
      render(
        <TransactionItem
          transaction={mockTransaction}
          isAmountHidden={true}
          showBorder={true}
        />,
      );

      expect(screen.getByTestId('transaction-amount-hidden')).toBeTruthy();
      expect(screen.getByText('● ● ● ●')).toBeTruthy();
      expect(screen.queryByText('$100.50')).toBeNull();
    });

    it('should handle null totalAmount', () => {
      const transactionWithNullAmount = {
        ...mockTransaction,
        totalAmount: null,
      };

      render(
        <TransactionItem
          transaction={transactionWithNullAmount}
          isAmountHidden={false}
          showBorder={true}
        />,
      );

      expect(screen.getByText('$0.00')).toBeTruthy();
    });

    it('should handle undefined totalAmount', () => {
      const transactionWithUndefinedAmount = {
        ...mockTransaction,
        totalAmount: undefined,
      };

      render(
        <TransactionItem
          transaction={transactionWithUndefinedAmount}
          isAmountHidden={false}
          showBorder={true}
        />,
      );

      expect(screen.getByText('$0.00')).toBeTruthy();
    });
  });

  describe('Border display', () => {
    it('should pass showBorder prop to ListItem', () => {
      render(
        <TransactionItem
          transaction={mockTransaction}
          isAmountHidden={false}
          showBorder={true}
        />,
      );

      expect(screen.getByTestId('transaction-item')).toBeTruthy();
      expect(screen.getByTestId('transaction-amount')).toBeTruthy();
    });

    it('should pass false showBorder prop to ListItem', () => {
      render(
        <TransactionItem
          transaction={mockTransaction}
          isAmountHidden={false}
          showBorder={false}
        />,
      );

      expect(screen.getByTestId('transaction-item')).toBeTruthy();
      expect(screen.getByTestId('transaction-amount')).toBeTruthy();
    });
  });

  describe('Transaction content rendering', () => {
    it('should render transaction with real content', () => {
      render(
        <TransactionItem
          transaction={mockTransaction}
          isAmountHidden={false}
          showBorder={true}
        />,
      );

      // Test that the component renders with real transaction content
      expect(screen.getByTestId('transaction-title')).toBeTruthy();
      expect(screen.getByTestId('transaction-amount')).toBeTruthy();
    });
  });

  describe('Transaction rendering', () => {
    it('should render transaction with real data', () => {
      const {toJSON} = render(
        <TransactionItem
          transaction={mockTransaction}
          isAmountHidden={false}
          showBorder={true}
        />,
      );

      expect(toJSON()).toBeTruthy();
    });
  });

  describe('Transaction with null/undefined/zero values', () => {
    it('should return null when statusId and typeId are undefined', () => {
      mockGetTransactionContent.mockReturnValue(null);

      const transactionWithUndefinedIds = {
        ...mockTransaction,
        statusId: undefined,
        typeId: undefined,
      };

      const {toJSON} = render(
        <TransactionItem
          transaction={transactionWithUndefinedIds}
          isAmountHidden={false}
          showBorder={true}
        />,
      );

      expect(toJSON()).toBeNull();
    });

    it('should return null when statusId and typeId are null', () => {
      mockGetTransactionContent.mockReturnValue(null);

      const transactionWithNullIds = {
        ...mockTransaction,
        statusId: null as any,
        typeId: null as any,
      };

      const {toJSON} = render(
        <TransactionItem
          transaction={transactionWithNullIds}
          isAmountHidden={false}
          showBorder={true}
        />,
      );

      expect(toJSON()).toBeNull();
    });

    it('should return null when statusId and typeId are 0', () => {
      mockGetTransactionContent.mockReturnValue(null);

      const transactionWithZeroIds = {
        ...mockTransaction,
        statusId: 0,
        typeId: 0,
      };

      const {toJSON} = render(
        <TransactionItem
          transaction={transactionWithZeroIds}
          isAmountHidden={false}
          showBorder={true}
        />,
      );

      expect(toJSON()).toBeNull();
    });
  });

  describe('Currency formatting', () => {
    it('should format currency correctly for different amounts', () => {
      const transactionWithLargeAmount = {
        ...mockTransaction,
        totalAmount: 1234.56,
      };

      render(
        <TransactionItem
          transaction={transactionWithLargeAmount}
          isAmountHidden={false}
          showBorder={true}
        />,
      );

      expect(screen.getByText('$1,234.56')).toBeTruthy();
    });

    it('should format currency correctly for zero amount', () => {
      const transactionWithZeroAmount = {
        ...mockTransaction,
        totalAmount: 0,
      };

      render(
        <TransactionItem
          transaction={transactionWithZeroAmount}
          isAmountHidden={false}
          showBorder={true}
        />,
      );

      expect(screen.getByText('$0.00')).toBeTruthy();
    });

    it('should format currency correctly for negative amount', () => {
      const transactionWithNegativeAmount = {
        ...mockTransaction,
        totalAmount: -50.25,
      };

      render(
        <TransactionItem
          transaction={transactionWithNegativeAmount}
          isAmountHidden={false}
          showBorder={true}
        />,
      );

      expect(screen.getByText('-$50.25')).toBeTruthy();
    });
  });
});
