import React from 'react';
import {render, screen} from '@testing-library/react-native';
import {Text} from 'react-native';
import BodyDetail from '../BodyDetail';
import {TRANSACTION_DETAIL_MESSAGES} from '@/constants/messages';

// Mock the Text component to avoid NativeWind issues
jest.mock('@/components/baseComponents/Text', () => {
  const {Text: RNText} = require('react-native');
  return {
    Text: ({children, isLoading, ...props}: any) => {
      if (isLoading) {
        return (
          <RNText testID="loading-text" {...props}>
            Loading...
          </RNText>
        );
      }
      return <RNText {...props}>{children}</RNText>;
    },
  };
});

describe('BodyDetail', () => {
  const mockIconCard = <Text testID="mock-card-icon">Card Icon</Text>;

  const defaultProps = {
    transactionType: 'Sale',
    transactionStatus: 'Approved',
    statusTextColor: 'text-green-500',
    IconCard: mockIconCard,
    creditDebitType: 'Credit',
    maskPan: '4111 **** **** 1111',
    cardDataSource: 'Chip',
    amountLabel: 'Total Amount',
    amount: '100.50',
    isLoading: false,
  };

  it('should render all transaction detail fields', () => {
    render(<BodyDetail {...defaultProps} />);

    // Check labels
    expect(
      screen.getByText(TRANSACTION_DETAIL_MESSAGES.TRANSACTION_TYPE),
    ).toBeTruthy();
    expect(
      screen.getByText(TRANSACTION_DETAIL_MESSAGES.TRANSACTION_STATUS),
    ).toBeTruthy();
    expect(
      screen.getByText(TRANSACTION_DETAIL_MESSAGES.PAYMENT_METHOD),
    ).toBeTruthy();
    expect(
      screen.getByText(TRANSACTION_DETAIL_MESSAGES.READING_METHOD),
    ).toBeTruthy();
    expect(screen.getByText('Total Amount')).toBeTruthy();

    // Check values
    expect(screen.getByText('Sale')).toBeTruthy();
    expect(screen.getByText('Approved')).toBeTruthy();
    expect(screen.getByText('Credit 4111 **** **** 1111')).toBeTruthy();
    expect(screen.getByText('Chip')).toBeTruthy();
    expect(screen.getByText('$100.50')).toBeTruthy();
  });

  it('should render card icon', () => {
    render(<BodyDetail {...defaultProps} />);

    expect(screen.getByTestId('mock-card-icon')).toBeTruthy();
  });

  it('should show loading when isLoading is true', () => {
    render(<BodyDetail {...defaultProps} isLoading={true} />);

    expect(screen.getAllByTestId('loading-text')).toHaveLength(5);
  });

  it('should render different amount labels', () => {
    render(
      <BodyDetail
        {...defaultProps}
        amountLabel={TRANSACTION_DETAIL_MESSAGES.AMOUNT_REFUNDED}
      />,
    );

    expect(
      screen.getByText(TRANSACTION_DETAIL_MESSAGES.AMOUNT_REFUNDED),
    ).toBeTruthy();
  });

  it('should handle empty values', () => {
    const emptyProps = {
      ...defaultProps,
      transactionType: '',
      transactionStatus: '',
      creditDebitType: '',
      maskPan: '',
      cardDataSource: '',
      amount: '',
    };

    render(<BodyDetail {...emptyProps} />);

    // Labels should still be present
    expect(
      screen.getByText(TRANSACTION_DETAIL_MESSAGES.TRANSACTION_TYPE),
    ).toBeTruthy();
    expect(screen.getByText('Total Amount')).toBeTruthy();
  });
});
