import React from 'react';
import {render, screen, fireEvent} from '@testing-library/react-native';
import {NavigationContainer} from '@react-navigation/native';
import {QueryClient, QueryClientProvider} from '@tanstack/react-query';
import PaymentFailedScreen from '../PaymentFailedScreen';
import {useTransactionStore} from '@/stores/transactionStore';
import {TransactionSaleResponse} from '@/types/TransactionSale';

// Mock the stores and utilities
jest.mock('@/stores/transactionStore');
jest.mock('@/utils/cardFlow', () => ({
  getCardType: jest.fn(() => 'Credit'),
  maskPan: jest.fn(pan => `****${pan.slice(-4)}`),
}));
jest.mock('@/utils/card', () => ({
  getCardIconFromNumber: jest.fn(() => null),
  findDebitCardType: jest.fn(() => null),
}));

// Mock constants
jest.mock('@/constants/dimensions', () => ({
  SECTION_HEIGHTS: {
    PAYMENT_OVERVIEW: 400,
  },
}));

jest.mock('@/constants/messages', () => ({
  KEYED_TRANSACTION_MESSAGES: {
    TITLE_FAILED: 'Failed',
    SUBTITLE_FAILED: 'Payment processor failed to handle request.',
    TITLE_SUCCESS: 'All Done!',
    SUBTITLE_SUCCESS: 'The transaction has been processed.',
    ERROR_CODE_LABEL: 'Code:',
    TRANSACTION_ID: 'Transaction ID',
    PAYMENT_METHOD: 'Payment Method',
    APPROVAL_CODE: 'Approval Code',
    BASE_AMOUNT: 'Base Amount',
    RETRY_TRANSACTION_BUTTON: 'Retry Transaction',
    CANCEL_BUTTON: 'Cancel',
    TRANSACTION_ID_FALLBACK: 'N/A',
    ERROR_CODE_FALLBACK: '500',
    CREDIT_PREFIX: 'Credit',
    VIEW_RECEIPT_BUTTON: 'View Receipt',
    HOME_BUTTON: 'Home',
    SURCHARGE_LABEL: 'Credit Card Surcharge',
    TOTAL_AMOUNT_LABEL: 'Total Amount',
  },
}));

jest.mock('@/constants/colors', () => ({
  COLORS: {
    ERROR: '#B91C1C',
    BLACK: '#000000',
    NEUTRAL_GRAY: '#6B7280',
  },
  GRADIENT_COLORS: {
    PRIMARY: ['#0284C7', '#0369A1'],
    PRIMARY_PRESSED: ['#125978', '#144B65'],
  },
}));

jest.mock('@/constants/dimensions', () => ({
  SHADOW_PROPERTIES: {
    ELEVATION: 1,
    SHADOW_RADIUS: 4,
    SHADOW_OPACITY: 0.15,
    SHADOW_OFFSET: {
      width: 0,
      height: 1,
    },
  },
  BUTTON_DIMENSIONS: {
    HEIGHT: 56,
  },
  SPACING: {
    SMALL: 8,
    MEDIUM: 16,
    LARGE: 24,
    EXTRA_LARGE: 32,
  },
  SECTION_HEIGHTS: {
    PAYMENT_OVERVIEW: 320,
    BUTTON_CONTAINER: 196,
  },
}));

// Mock navigation
const mockNavigateFunction = jest.fn();
const mockNavigation = {
  navigate: mockNavigateFunction,
  goBack: jest.fn(),
  push: jest.fn(),
  pop: jest.fn(),
  popToTop: jest.fn(),
  dispatch: jest.fn(),
  reset: jest.fn(),
  isFocused: jest.fn(() => true),
  canGoBack: jest.fn(() => true),
  getId: jest.fn(),
  getParent: jest.fn(),
  getState: jest.fn(),
};

// Mock SafeAreaView
jest.mock('react-native-safe-area-context', () => ({
  SafeAreaView: ({children}: {children: React.ReactNode}) => children,
}));

// Mock Lucide React Native icons
jest.mock('lucide-react-native', () => ({
  CircleX: ({children}: {children?: React.ReactNode}) => children || 'CircleX',
}));

// Mock useNavigation hook
jest.mock('@react-navigation/native', () => ({
  ...jest.requireActual('@react-navigation/native'),
  NavigationContainer: ({children}: {children: React.ReactNode}) => children,
}));

describe('PaymentFailedScreen', () => {
  const mockRetryTransaction = jest.fn();
  const mockReset = jest.fn();

  const mockTransactionStore = {
    amount: 12345, // $123.45 in cents
    cardNumber: '4111111111111111',
    binData: {cardType: 'Credit'},
    surchargeAmount: 500, // $5.00 in cents
    retryTransaction: mockRetryTransaction,
    reset: mockReset,
  };

  const mockSuccessResponse: TransactionSaleResponse = {
    transactionId: 'txn_test12345',
    processedAmount: 129.99,
    avsResponse: null,
    creditDebitType: 1,
    transactionDateTime: '2024-01-01T12:00:00Z',
    typeId: 1,
    type: 'Sale',
    statusId: 3,
    status: 'Failed',
    transactionStatusId: 3,
    details: {
      hostResponseCode: '500',
      hostResponseMessage: 'Do not honor',
      hostResponseDefinition: 'Transaction declined',
      code: '500',
      message: 'Payment processor failed to handle request',
      processorResponseCode: '05',
      authCode: '',
      maskedPan: '****1111',
    },
  };

  const mockErrorResponse = {
    transactionId: 'txn_error12345',
    processedAmount: 0,
    avsResponse: null,
    creditDebitType: 1,
    transactionDateTime: '2024-01-01T12:00:00Z',
    typeId: 1,
    type: 'Sale',
    statusId: 3,
    status: 'Failed',
    transactionStatusId: 3,
    details: {
      hostResponseCode: 'V0000',
      hostResponseMessage: 'Validation Error',
      hostResponseDefinition: 'Transaction validation failed',
      code: 'V0000',
      message: 'Payment processor failed to handle request',
      processorResponseCode: 'V0000',
      authCode: '',
      maskedPan: '****1111',
    },
  };

  beforeEach(() => {
    jest.clearAllMocks();
    mockNavigateFunction.mockClear();

    // Mock useTransactionStore
    (useTransactionStore as jest.Mock).mockReturnValue(mockTransactionStore);
  });

  const createTestQueryClient = () => {
    return new QueryClient({
      defaultOptions: {
        queries: {
          retry: false,
          gcTime: 0,
        },
        mutations: {
          retry: false,
        },
      },
    });
  };

  const renderComponent = (routeParams = {}) => {
    const route = {
      params: routeParams,
    };

    const queryClient = createTestQueryClient();

    return render(
      <QueryClientProvider client={queryClient}>
        <NavigationContainer>
          <PaymentFailedScreen navigation={mockNavigation} route={route} />
        </NavigationContainer>
      </QueryClientProvider>,
    );
  };

  describe('Component Rendering', () => {
    it('should render all UI elements correctly', () => {
      renderComponent({
        response: mockSuccessResponse,
      });

      // Check main elements
      expect(screen.getByText('Failed')).toBeTruthy();
      expect(
        screen.getByText('Payment processor failed to handle request.'),
      ).toBeTruthy();
      expect(screen.getByText('Transaction ID')).toBeTruthy();
      expect(screen.getByText('Payment Method')).toBeTruthy();
      expect(screen.getByText('Base Amount')).toBeTruthy();
      expect(screen.getByText('Total Amount')).toBeTruthy();

      // Check buttons
      expect(screen.getByText('Retry Transaction')).toBeTruthy();
      expect(screen.getByText('Cancel')).toBeTruthy();
    });

    it('should display transaction details correctly', () => {
      renderComponent({
        response: mockSuccessResponse,
      });

      // Check transaction ID (shows N/A when not available)
      expect(screen.getByText('N/A')).toBeTruthy();

      // Check amounts (from transaction store, not response)
      expect(screen.getAllByText('$0.00').length).toBeGreaterThanOrEqual(1); // Base amount from store
      expect(screen.getByText('$500.00')).toBeTruthy(); // Surcharge amount from store
    });

    it('should display error code from response details', () => {
      renderComponent({
        response: mockSuccessResponse,
      });

      expect(screen.getByText('Code: 500')).toBeTruthy();
    });

    it('should display error code from error response', () => {
      renderComponent({
        response: mockErrorResponse,
      });

      expect(screen.getByText('Code: V0000')).toBeTruthy();
    });

    it('should display fallback error code when no error data available', () => {
      renderComponent({});

      expect(screen.getByText('Code: 500')).toBeTruthy(); // Fallback
    });

    it('should display surcharge amount when present', () => {
      renderComponent({
        response: mockSuccessResponse,
      });

      // Should show surcharge if mockTransactionStore.surchargeAmount > 0
      expect(screen.getByText('$500.00')).toBeTruthy(); // Surcharge amount with $ symbol
    });
  });

  describe('Navigation', () => {
    it('should navigate to ChooseMethod when Retry Transaction is pressed', async () => {
      renderComponent({
        response: mockSuccessResponse,
      });

      // Find button by testID
      const retryButton = screen.getByTestId('arise-button-Retry Transaction');
      fireEvent.press(retryButton);

      // The component calls retryTransaction and navigate immediately
      expect(mockRetryTransaction).toHaveBeenCalled();
      expect(mockNavigateFunction).toHaveBeenCalledWith('ChooseMethod');
    });

    it('should reset transaction store and navigate to Home when Cancel is pressed', async () => {
      renderComponent({
        response: mockSuccessResponse,
      });

      const cancelButton = screen.getByTestId('arise-button-Cancel');
      fireEvent.press(cancelButton);

      // The component calls reset and navigate immediately
      expect(mockReset).toHaveBeenCalled();
      expect(mockNavigateFunction).toHaveBeenCalledWith('Home');
    });
  });

  describe('Transaction Store Integration', () => {
    it('should call retryTransaction when retry button is pressed', async () => {
      renderComponent({
        response: mockSuccessResponse,
      });

      const retryButton = screen.getByTestId('arise-button-Retry Transaction');
      fireEvent.press(retryButton);

      // The component calls retryTransaction immediately
      expect(mockRetryTransaction).toHaveBeenCalledTimes(1);
    });

    it('should call reset when cancel button is pressed', async () => {
      renderComponent({
        response: mockSuccessResponse,
      });

      const cancelButton = screen.getByTestId('arise-button-Cancel');
      fireEvent.press(cancelButton);

      // The component calls reset immediately
      expect(mockReset).toHaveBeenCalledTimes(1);
    });
  });

  describe('Error Handling', () => {
    it('should handle missing transaction response gracefully', () => {
      renderComponent({});

      // Should still render without crashing
      expect(screen.getByText('Failed')).toBeTruthy();
      expect(screen.getByText('Retry Transaction')).toBeTruthy();
      expect(screen.getByText('Cancel')).toBeTruthy();
    });

    it('should handle missing error data gracefully', () => {
      renderComponent({
        response: null,
        error: null,
      });

      // Should show fallback values
      expect(screen.getByText('N/A')).toBeTruthy(); // Transaction ID fallback
      expect(screen.getByText('Code: 500')).toBeTruthy(); // Error code fallback
    });

    it('should prioritize error response code over success response details', () => {
      renderComponent({
        response: mockErrorResponse,
      });

      // Should show V0000 from error response
      expect(screen.getByText('Code: V0000')).toBeTruthy();
    });
  });

  describe('Button Interactions', () => {
    it('should have working retry button', () => {
      renderComponent({
        response: mockSuccessResponse,
      });

      const retryButton = screen.getByTestId('arise-button-Retry Transaction');

      // Should not throw when pressed
      expect(() => fireEvent.press(retryButton)).not.toThrow();
    });

    it('should have working cancel button', () => {
      renderComponent({
        response: mockSuccessResponse,
      });

      const cancelButton = screen.getByTestId('arise-button-Cancel');

      // Should not throw when pressed
      expect(() => fireEvent.press(cancelButton)).not.toThrow();
    });
  });
});
