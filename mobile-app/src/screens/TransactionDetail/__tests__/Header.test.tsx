import React from 'react';
import {render, screen, fireEvent} from '@testing-library/react-native';
import {Text} from 'react-native';
import Header from '../Header';

// Mock navigation
const mockGoBack = jest.fn();
jest.mock('@react-navigation/native', () => ({
  useNavigation: () => ({
    goBack: mockGoBack,
  }),
}));

// Mock lucide-react-native
jest.mock('lucide-react-native', () => ({
  ChevronLeft: ({testID, ...props}: any) => {
    const RN = require('react-native');
    return <RN.View testID={testID || 'chevron-left-icon'} {...props} />;
  },
}));

describe('Header', () => {
  const mockIcon = <Text testID="mock-icon">Transaction Icon</Text>;

  const defaultProps = {
    Icon: mockIcon,
    type: 'Sale',
    status: 'APPROVED',
    date: 'Jan 15, 2024 10:30 AM',
    details: '',
    code: '',
    iconBgColor: 'bg-surface-green',
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should render all required elements', () => {
    render(<Header {...defaultProps} />);

    expect(screen.getByTestId('chevron-left-icon')).toBeTruthy();
    expect(screen.getByTestId('mock-icon')).toBeTruthy();
    expect(screen.getByText('Sale')).toBeTruthy();
    expect(screen.getByText('APPROVED')).toBeTruthy();
    expect(screen.getByText('Jan 15, 2024 10:30 AM')).toBeTruthy();
  });

  it('should handle back button press', () => {
    render(<Header {...defaultProps} />);

    const backButton = screen.getByTestId('chevron-left-icon').parent as any;
    fireEvent.press(backButton);

    expect(mockGoBack).toHaveBeenCalledTimes(1);
  });

  it('should render details when provided', () => {
    const propsWithDetails = {
      ...defaultProps,
      details: 'Transaction failed due to insufficient funds',
    };

    render(<Header {...propsWithDetails} />);

    expect(
      screen.getByText('Transaction failed due to insufficient funds'),
    ).toBeTruthy();
  });

  it('should render error code when provided', () => {
    const propsWithCode = {
      ...defaultProps,
      code: '05',
    };

    render(<Header {...propsWithCode} />);

    expect(screen.getByText('Code: 05')).toBeTruthy();
  });

  it('should not render details when empty', () => {
    render(<Header {...defaultProps} details="" />);

    expect(screen.queryByText('Transaction failed')).toBeNull();
  });

  it('should render different transaction types', () => {
    const types = ['Sale', 'Authorization', 'Refund', 'Void'];

    types.forEach(type => {
      const {rerender} = render(<Header {...defaultProps} type={type} />);
      expect(screen.getByText(type)).toBeTruthy();
      rerender(<Header {...defaultProps} type="Sale" />);
    });
  });

  it('should handle empty values gracefully', () => {
    const emptyProps = {
      ...defaultProps,
      type: '',
      status: '',
      date: '',
    };

    render(<Header {...emptyProps} />);

    // Component should still render without errors
    expect(screen.getByTestId('chevron-left-icon')).toBeTruthy();
    expect(screen.getByTestId('mock-icon')).toBeTruthy();
  });
});
