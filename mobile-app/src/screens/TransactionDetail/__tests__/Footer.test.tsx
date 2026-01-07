import React from 'react';
import {render, screen, fireEvent} from '@testing-library/react-native';
import Footer from '../Footer';
import {CardTransactionStatus} from '../../../dictionaries/TransactionStatuses';
import {TRANSACTION_DETAIL_MESSAGES} from '../../../constants/messages';
import {ROUTES} from '../../../constants/routes';

// Mock AriseButton component
jest.mock('@/components/baseComponents/AriseButton', () => {
  const {TouchableOpacity, Text} = require('react-native');
  return ({title, onPress, type, testID}: any) => (
    <TouchableOpacity
      testID={testID || `button-${title.toLowerCase().replace(/\s+/g, '-')}`}
      onPress={onPress}>
      <Text testID={`button-text-${type}`}>{title}</Text>
    </TouchableOpacity>
  );
});

describe('Footer', () => {
  const mockNavigation = {
    navigate: jest.fn(),
  };

  const defaultProps = {
    statusId: CardTransactionStatus.Authorized,
    transactionType: 'Sale',
    navigation: mockNavigation,
    transactionId: 'txn-123',
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders Void button for Authorized only when canVoidOrRefund is true', () => {
    const {getByText} = render(
      <Footer
        statusId={CardTransactionStatus.Authorized}
        navigation={{navigate: jest.fn()}}
        transactionId="id-1"
        onVoidPress={jest.fn()}
        canVoidOrRefund={true}
        transactionType="Sale"
      />,
    );

    expect(getByText(TRANSACTION_DETAIL_MESSAGES.VOID_BUTTON)).toBeTruthy();

    const view = render(
      <Footer
        statusId={CardTransactionStatus.Authorized}
        navigation={{navigate: jest.fn()}}
        transactionId="id-1"
        onVoidPress={jest.fn()}
        canVoidOrRefund={false}
        transactionType="Sale"
      />,
    );
    expect(
      view.queryByText(TRANSACTION_DETAIL_MESSAGES.VOID_BUTTON),
    ).toBeNull();
  });

  it('renders Void button for Captured only when canVoidOrRefund is true', () => {
    const withPermission = render(
      <Footer
        statusId={CardTransactionStatus.Captured}
        navigation={{navigate: jest.fn()}}
        transactionId="id-2"
        onVoidPress={jest.fn()}
        canVoidOrRefund={true}
        transactionType="Sale"
      />,
    );
    expect(
      withPermission.getByText(TRANSACTION_DETAIL_MESSAGES.VOID_BUTTON),
    ).toBeTruthy();

    const withoutPermission = render(
      <Footer
        statusId={CardTransactionStatus.Captured}
        navigation={{navigate: jest.fn()}}
        transactionId="id-2"
        onVoidPress={jest.fn()}
        canVoidOrRefund={false}
        transactionType="Sale"
      />,
    );
    expect(
      withoutPermission.queryByText(TRANSACTION_DETAIL_MESSAGES.VOID_BUTTON),
    ).toBeNull();
  });

  it('should render Capture and Void buttons for Authorized Authorization-type when submit is allowed', () => {
    render(
      <Footer
        {...defaultProps}
        statusId={CardTransactionStatus.Authorized}
        transactionType="Authorization"
        canSubmitTransaction={true}
      />,
    );

    expect(
      screen.getByText(TRANSACTION_DETAIL_MESSAGES.CAPTURE_BUTTON),
    ).toBeTruthy();
    expect(
      screen.getByText(TRANSACTION_DETAIL_MESSAGES.VOID_BUTTON),
    ).toBeTruthy();
    expect(
      screen.getByText(TRANSACTION_DETAIL_MESSAGES.VIEW_RECEIPT_BUTTON),
    ).toBeTruthy();
  });

  it('should render Refund button for Settled status', () => {
    render(
      <Footer
        {...defaultProps}
        statusId={CardTransactionStatus.Settled}
        canRefund={true}
      />,
    );

    expect(
      screen.getByText(TRANSACTION_DETAIL_MESSAGES.REFUND_BUTTON),
    ).toBeTruthy();
    expect(
      screen.getByText(TRANSACTION_DETAIL_MESSAGES.VIEW_RECEIPT_BUTTON),
    ).toBeTruthy();
    expect(
      screen.queryByText(TRANSACTION_DETAIL_MESSAGES.CAPTURE_BUTTON),
    ).toBeNull();
  });

  it('does not render Capture for Authorized Sale even with submit permission', () => {
    render(
      <Footer
        {...defaultProps}
        statusId={CardTransactionStatus.Authorized}
        transactionType="Sale"
        canSubmitTransaction={true}
      />,
    );

    expect(
      screen.queryByText(TRANSACTION_DETAIL_MESSAGES.CAPTURE_BUTTON),
    ).toBeNull();
    expect(
      screen.getByText(TRANSACTION_DETAIL_MESSAGES.VIEW_RECEIPT_BUTTON),
    ).toBeTruthy();
  });

  it('does not render Capture for Authorized Authorization when submit permission is false', () => {
    render(
      <Footer
        {...defaultProps}
        statusId={CardTransactionStatus.Authorized}
        transactionType="Authorization"
        canSubmitTransaction={false}
      />,
    );

    expect(
      screen.queryByText(TRANSACTION_DETAIL_MESSAGES.CAPTURE_BUTTON),
    ).toBeNull();
    expect(
      screen.getByText(TRANSACTION_DETAIL_MESSAGES.VIEW_RECEIPT_BUTTON),
    ).toBeTruthy();
  });

  it('should render Void button for Captured status', () => {
    render(
      <Footer
        {...defaultProps}
        statusId={CardTransactionStatus.Captured}
        transactionType="Sale"
      />,
    );

    expect(
      screen.getByText(TRANSACTION_DETAIL_MESSAGES.VOID_BUTTON),
    ).toBeTruthy();
    expect(
      screen.getByText(TRANSACTION_DETAIL_MESSAGES.VIEW_RECEIPT_BUTTON),
    ).toBeTruthy();
    expect(
      screen.queryByText(TRANSACTION_DETAIL_MESSAGES.CAPTURE_BUTTON),
    ).toBeNull();
  });

  it('should navigate to receipt screen when View Receipt button is pressed', () => {
    render(<Footer {...defaultProps} />);

    const viewReceiptButton = screen.getByTestId('button-view-receipt');
    fireEvent.press(viewReceiptButton);

    expect(mockNavigation.navigate).toHaveBeenCalledWith(
      ROUTES.PAYMENT_RECEIPT,
      {
        transactionId: 'txn-123',
        isACH: undefined,
      },
    );
  });

  it('should handle unknown statusId', () => {
    render(<Footer {...defaultProps} statusId={999} />);

    expect(
      screen.getByText(TRANSACTION_DETAIL_MESSAGES.VIEW_RECEIPT_BUTTON),
    ).toBeTruthy();
    expect(
      screen.queryByText(TRANSACTION_DETAIL_MESSAGES.CAPTURE_BUTTON),
    ).toBeNull();
    expect(
      screen.queryByText(TRANSACTION_DETAIL_MESSAGES.VOID_BUTTON),
    ).toBeNull();
    expect(
      screen.queryByText(TRANSACTION_DETAIL_MESSAGES.REFUND_BUTTON),
    ).toBeNull();
  });

  it('should handle empty transactionId', () => {
    render(<Footer {...defaultProps} transactionId="" />);

    const viewReceiptButton = screen.getByTestId('button-view-receipt');
    fireEvent.press(viewReceiptButton);

    expect(mockNavigation.navigate).toHaveBeenCalledWith(
      ROUTES.PAYMENT_RECEIPT,
      {
        transactionId: '',
        isACH: undefined,
      },
    );
  });
});
