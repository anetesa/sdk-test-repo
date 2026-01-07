import React from 'react';
import {render, screen} from '@testing-library/react-native';
import {Text} from 'react-native';
import BodyFirst from '../BodyFirst';
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

// Mock transaction helpers
jest.mock('@/utils/transactionHelpers', () => ({
  getFirstPartTransactionId: jest.fn(),
}));

const mockGetFirstPartTransactionId =
  require('@/utils/transactionHelpers').getFirstPartTransactionId;

describe('BodyFirst', () => {
  const defaultProps = {
    approvalCode: 'ABC123',
    transactionId: '12345678901234567890',
    isLoading: false,
  };

  beforeEach(() => {
    jest.clearAllMocks();
    mockGetFirstPartTransactionId.mockReturnValue('12345678');
  });

  it('should render transaction ID', () => {
    render(<BodyFirst {...defaultProps} />);

    expect(
      screen.getByText(TRANSACTION_DETAIL_MESSAGES.TRANSACTION_ID),
    ).toBeTruthy();
    expect(screen.getByText('12345678')).toBeTruthy();
    expect(mockGetFirstPartTransactionId).toHaveBeenCalledWith(
      defaultProps.transactionId,
    );
  });

  it('should render approval code when provided', () => {
    render(<BodyFirst {...defaultProps} />);

    expect(
      screen.getByText(TRANSACTION_DETAIL_MESSAGES.APPROVAL_CODE),
    ).toBeTruthy();
    expect(screen.getByText('ABC123')).toBeTruthy();
  });

  it('should not render approval code when empty', () => {
    render(<BodyFirst {...defaultProps} approvalCode="" />);

    expect(
      screen.queryByText(TRANSACTION_DETAIL_MESSAGES.APPROVAL_CODE),
    ).toBeNull();
  });

  it('should show loading when isLoading is true', () => {
    render(<BodyFirst {...defaultProps} isLoading={true} />);

    expect(screen.getAllByTestId('loading-text')).toHaveLength(2);
  });

  it('should handle empty transaction ID', () => {
    mockGetFirstPartTransactionId.mockReturnValue('N/A');

    render(<BodyFirst {...defaultProps} transactionId="" />);

    expect(screen.getByText('N/A')).toBeTruthy();
  });
});
