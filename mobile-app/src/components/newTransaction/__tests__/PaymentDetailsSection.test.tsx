import React from 'react';
import {render, screen} from '@testing-library/react-native';
import PaymentDetailsSection from '../PaymentDetailsSection';

jest.mock('@/constants/messages', () => ({
  KEYED_TRANSACTION_MESSAGES: {
    TRANSACTION_ID: 'Transaction ID',
    PAYMENT_METHOD: 'Payment Method',
    APPROVAL_CODE: 'Approval Code',
    BASE_AMOUNT: 'Base Amount',
    CREDIT_PREFIX: 'Credit',
    TRANSACTION_ID_FALLBACK: 'N/A',
    SURCHARGE_LABEL: 'Credit Card Surcharge',
    TOTAL_AMOUNT_LABEL: 'Total Amount',
  },
}));

jest.mock('@/stores/transactionStore', () => ({
  useTransactionStore: jest.fn(() => ({
    amount: 12345, // $123.45 in cents
    cardNumber: '4111111111111111',
    binData: {type: 'Credit'},
    surchargeAmount: 3.45, // $3.45 in dollars (component uses as dollars)
  })),
}));

jest.mock('@/utils/card', () => ({
  getCardIconFromNumber: jest.fn(() => 'card-icon'),
  findDebitCardType: jest.fn(() => null), // Return null since it now returns React components or null
}));

jest.mock('@/utils/currency', () => ({
  formatAmountForDisplay: jest.fn(
    (params: {cents?: number; dollars?: number}) => {
      if (params?.cents !== undefined && !isNaN(params.cents)) {
        return (params.cents / 100).toFixed(2);
      }
      if (params?.dollars !== undefined && !isNaN(params.dollars)) {
        return params.dollars.toFixed(2);
      }
      return '0.00';
    },
  ),
}));

jest.mock('@/utils/cardFlow', () => ({
  getCardType: jest.fn(() => 'Credit'),
  maskPan: jest.fn(() => '****1111'),
}));

jest.mock('@/constants/dimensions', () => ({
  SECTION_HEIGHTS: {
    PAYMENT_DETAILS: 200,
  },
}));

describe('PaymentDetailsSection', () => {
  it('renders transaction id (first 8 chars) or fallback when missing', () => {
    const details = {
      id: 'abcdefghijklmnop', // Long ID to test slicing
      amount: {totalAmount: 0},
    } as any;

    render(<PaymentDetailsSection response={undefined} details={details} />);

    expect(screen.getByText('Transaction ID')).toBeTruthy();
    expect(screen.getByText('abcdefgh')).toBeTruthy();
  });

  it('renders payment method with card type and masked pan', () => {
    const details = {id: 'foo', amount: {totalAmount: 0}} as any;
    render(<PaymentDetailsSection response={undefined} details={details} />);

    expect(screen.getByText('Payment Method')).toBeTruthy();
    expect(screen.getByText('Credit ****1111')).toBeTruthy();
  });

  it('renders approval code only when available', () => {
    const details = {id: 'foo', amount: {totalAmount: 0}} as any;

    // Without auth code
    const {queryByText, rerender} = render(
      <PaymentDetailsSection response={undefined} details={details} />,
    );
    expect(queryByText('Approval Code')).toBeNull();

    // With auth code
    const response = {details: {authCode: 'AUTH123'}} as any;
    rerender(<PaymentDetailsSection response={response} details={details} />);
    expect(screen.getByText('Approval Code')).toBeTruthy();
    expect(screen.getByText('AUTH123')).toBeTruthy();
  });

  it('renders base amount, optional surcharge, and total amount', () => {
    const details = {
      id: 'foo',
      amount: {
        baseAmount: 123.45, // $123.45 in dollars
        totalAmount: 128.45, // $128.45 in dollars
      },
    } as any;

    render(<PaymentDetailsSection response={undefined} details={details} />);

    // Base amount from details.amount.baseAmount
    expect(screen.getByText('Base Amount')).toBeTruthy();
    expect(screen.getByText('$123.45')).toBeTruthy();

    // Surcharge amount when greater than 0 (from transaction store)
    expect(screen.getByText('Credit Card Surcharge')).toBeTruthy();
    expect(screen.getByText('$3.45')).toBeTruthy();

    // Total amount from details.amount.totalAmount
    expect(screen.getByText('Total Amount')).toBeTruthy();
    expect(screen.getByText('$128.45')).toBeTruthy();
  });
});
