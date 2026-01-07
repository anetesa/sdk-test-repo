import React from 'react';
import {
  render,
  screen,
  fireEvent,
  waitFor,
} from '@testing-library/react-native';
import {ActivityIndicator} from 'react-native';
import {PaymentOverviewScreen} from '../PaymentOverviewScreen';
import {useTransactionStore} from '@/stores/transactionStore';
import {useUserStore} from '@/stores/userStore';
import {useTransactionSaleMutation} from '@/hooks/queries/useTransactionSale';
import {useTransactionDetails} from '@/hooks/queries/useTransactionDetails';
import {useMerchantSettings} from '@/hooks/queries/useMerchantSettings';
import {usePaymentsSettings} from '@/hooks/queries/usePaymentsSettings';
import {ZeroCostProcessingType} from '@/dictionaries/ZeroCostProcessingSettings';

// Mock the stores and hooks
jest.mock('@/stores/transactionStore');
jest.mock('@/stores/userStore');
jest.mock('@/hooks/queries/useTransactionSale');
jest.mock('@/hooks/queries/useTransactionDetails');
jest.mock('@/hooks/queries/useMerchantSettings');
jest.mock('@/hooks/queries/usePaymentsSettings');

// Create mock functions
const mockShowErrorAlert = jest.fn();
const mockShowSuccessAlert = jest.fn();
const mockUseAlertStore = jest.fn();

// Mock the alert store module
jest.mock('@/stores/alertStore', () => {
  const mockFn = jest.fn();
  return {
    showErrorAlert: mockFn,
    showSuccessAlert: jest.fn(),
    useAlertStore: jest.fn(() => ({
      showErrorAlert: mockFn,
      showSuccessAlert: jest.fn(),
      hideAlert: jest.fn(),
      alerts: [],
    })),
  };
});

// Import the mock after mocking the module
import {showErrorAlert} from '@/stores/alertStore';
const mockShowErrorAlertImported = showErrorAlert as jest.MockedFunction<
  typeof showErrorAlert
>;

// Create shared mock navigation functions
const mockNavigateFunction = jest.fn();
const mockGoBackFunction = jest.fn();

// Mock navigation object for props
const mockNavigation = {
  navigate: mockNavigateFunction,
  goBack: mockGoBackFunction,
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

// Mock useNavigation hook
jest.mock('@react-navigation/native', () => ({
  ...jest.requireActual('@react-navigation/native'),
}));

// Mock SVG components
jest.mock('../../../../assets/clipboard.svg', () => 'ClipboardIcon');

// Mock utility functions
jest.mock('@/utils/cardFlow', () => ({
  maskPan: jest.fn(pan => `****${pan.slice(-4)}`),
}));

// Mock currency utility
jest.mock('@/utils/currency', () => ({
  formatAmountForDisplay: ({
    cents,
    dollars,
  }: {
    cents?: number;
    dollars?: number;
  }) => {
    if (cents !== undefined && cents !== null) {
      return (cents / 100).toFixed(2);
    }
    if (dollars !== undefined && dollars !== null) {
      return new Intl.NumberFormat('en-US', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
      }).format(dollars);
    }
    return '0.00';
  },
  formatAmountForSentToTheServer: (amountInCents: number) =>
    amountInCents / 100,
}));

// Mock dictionaries
jest.mock('@/dictionaries/Currency', () => ({
  Currency: {
    USD: 1,
  },
}));

describe('PaymentOverviewScreen', () => {
  const mockTransactionStore = {
    cardNumber: '4111111111111111',
    expDate: '12/25',
    zipCode: '12345',
    amount: 100,
    surchargeAmount: 3,
    totalAmount: 103,
    surchargeRate: 0.025,
    cvv: '123',
    paymentProcessorId: 'pp1',
    settingsAutofill: {
      l2Settings: {taxRate: 0.08},
      l3Settings: {
        shippingCharge: 5.0,
        dutyChargeRate: 0.02,
        product: {name: 'Test Product', price: 100},
      },
    },
    status: 'idle',
    setResponse: jest.fn(),
  };

  const mockUserStore = {
    merchantId: 'merchant123',
  };

  const mockTransactionSaleMutation = {
    mutate: jest.fn(),
    data: null,
    isPending: false,
    isError: false,
    error: null,
  };

  beforeEach(() => {
    jest.clearAllMocks();
    mockNavigateFunction.mockClear();
    mockGoBackFunction.mockClear();
    mockShowErrorAlertImported.mockClear();

    (useTransactionStore as jest.Mock).mockImplementation((selector?: any) => {
      if (selector) {
        return selector(mockTransactionStore);
      }
      return mockTransactionStore;
    });

    (useUserStore as jest.Mock).mockImplementation((selector: any) =>
      selector(mockUserStore),
    );

    (useTransactionSaleMutation as jest.Mock).mockReturnValue(
      mockTransactionSaleMutation,
    );

    // Default: merchant configured for Surcharge so payload includes surchargeRate
    (useMerchantSettings as jest.Mock).mockReturnValue({
      data: {
        merchantSettings: {
          zeroCostProcessingOptionId: ZeroCostProcessingType.Surcharge,
          allowOverrideSurcharge: true,
        },
      },
      isLoading: false,
      isError: false,
      isSuccess: true,
    });

    (usePaymentsSettings as jest.Mock).mockReturnValue({
      data: {
        availableCurrencies: [],
        zeroCostProcessingOptionId: ZeroCostProcessingType.Surcharge,
        zeroCostProcessingOption: null,
        defaultSurchargeRate: 0.03,
        defaultCashDiscountRate: null,
        defaultDualPricingRate: null,
        isTipsEnabled: true,
        defaultTipsOptions: [],
        availableCardTypes: [],
        availableTransactionTypes: [],
        availablePaymentProcessors: [],
        avs: null,
        isCustomerCardSavingByTerminalEnabled: false,
        isDualPricingEnabled: false,
      },
      isLoading: false,
      isError: false,
      error: null,
    });

    mockUseAlertStore.mockReturnValue({
      showErrorAlert: mockShowErrorAlert,
      showSuccessAlert: mockShowSuccessAlert,
      hideAlert: jest.fn(),
      alerts: [],
    });
  });

  describe('Transaction Success Navigation', () => {
    it('should navigate to PaymentSuccess when useTransactionSaleMutation succeeds', async () => {
      const mockSuccessData = {
        transactionId: 'txn_12345',
        status: 'approved',
        processedAmount: 10250,
        statusId: 2, // CardTransactionStatus.Captured
        details: {
          authCode: 'AUTH123',
          maskedPan: '****1111',
        },
      };

      // Mock the mutation hook to return success data
      const mockMutate = jest.fn();
      (useTransactionSaleMutation as jest.Mock).mockReturnValue({
        mutate: mockMutate,
        data: mockSuccessData, // This will trigger the useEffect
        isPending: false,
        isError: false,
        error: null,
      });

      // Mock useTransactionDetails to return data to pass shouldWaitForDetails check
      (useTransactionDetails as jest.Mock).mockReturnValue({
        data: {id: 'details_123'},
        isLoading: false,
        error: null,
      });

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      await waitFor(() => {
        expect(mockNavigateFunction).toHaveBeenCalledWith('PaymentSuccess', {
          response: mockSuccessData,
          details: {id: 'details_123'},
        });
      });
    });

    it('should navigate to PaymentFailed when useTransactionSaleMutation fails with status', async () => {
      const mockErrorData = {
        statusId: 1, // Not captured status
        status: 'failed',
        transactionId: 'txn_failed',
      };

      // Mock the mutation hook to return data with failed status but NOT isError (to avoid ValidationError navigation)
      const mockMutate = jest.fn();
      (useTransactionSaleMutation as jest.Mock).mockReturnValue({
        mutate: mockMutate,
        data: mockErrorData,
        isPending: false,
        isError: false, // Important: Set to false to test status-based navigation
        error: null,
      });

      // Mock useTransactionDetails to return data to avoid blocking
      (useTransactionDetails as jest.Mock).mockReturnValue({
        data: {id: 'details_failed'},
        isLoading: false,
        error: null,
      });

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      await waitFor(() => {
        expect(mockNavigateFunction).toHaveBeenCalledWith('PaymentFailed', {
          response: mockErrorData,
          details: {id: 'details_failed'},
        });
      });
    });

    it('should navigate to PaymentDeclined when status is Declined', async () => {
      const mockDeclinedData = {
        transactionId: 'txn_declined',
        status: 'declined',
        processedAmount: 10250,
        statusId: 91, // CommonTransactionStatus.Declined
      };

      const mockMutate = jest.fn();
      (useTransactionSaleMutation as jest.Mock).mockReturnValue({
        mutate: mockMutate,
        data: mockDeclinedData,
        isPending: false,
        isError: false,
        error: null,
      });

      (useTransactionDetails as jest.Mock).mockReturnValue({
        data: {id: 'details_declined'},
        isLoading: false,
        error: null,
      });

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      await waitFor(() => {
        expect(mockNavigateFunction).toHaveBeenCalledWith('PaymentDeclined', {
          response: mockDeclinedData,
          details: {id: 'details_declined'},
        });
      });
    });

    it('should call transactionSale mutation when Confirm Payment button is pressed', async () => {
      const mockMutate = jest.fn();

      (useTransactionSaleMutation as jest.Mock).mockReturnValue({
        mutate: mockMutate,
        data: null,
        isPending: false,
        isError: false,
        error: null,
      });

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      const confirmButton = screen.getByText('Confirm Payment');
      fireEvent.press(confirmButton);

      await waitFor(() => {
        expect(mockMutate).toHaveBeenCalledWith(
          expect.objectContaining({
            merchantId: 'merchant123',
            amount: 1.0,
            accountNumber: '4111111111111111',
            expirationMonth: 12,
            expirationYear: 2025,
            securityCode: '123',
            paymentProcessorId: 'pp1',
          }),
        );
      });
    });
  });

  describe('Loading State', () => {
    it('should show loading state when transaction is pending', async () => {
      (useTransactionSaleMutation as jest.Mock).mockReturnValue({
        mutate: jest.fn(),
        data: null,
        isPending: true,
        isError: false,
        error: null,
      });

      const storeWithLoadingStatus = {
        ...mockTransactionStore,
        status: 'loading',
      };

      (useTransactionStore as jest.Mock).mockImplementation(
        (selector?: any) => {
          if (selector) {
            return selector(storeWithLoadingStatus);
          }
          return storeWithLoadingStatus;
        },
      );

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      // Should show loading text
      // Note: We use queryByText since PendingRequest implementation might vary
      // If PendingRequest uses the constants we mocked, this should pass.
      // If it fails, we might need to inspect PendingRequest component.
      await waitFor(() => {
        expect(screen.queryByText('Processing...')).toBeTruthy();
      });
    });
  });

  describe('Button Interactions', () => {
    it('should call navigation.goBack when Back button is pressed', () => {
      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      const backButton = screen.getByText('Back');
      fireEvent.press(backButton);

      expect(mockNavigation.goBack).toHaveBeenCalled();
    });
  });

  describe('Display Values', () => {
    it('displays all card information correctly', () => {
      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      // Check card information section
      expect(screen.getByText('Card Number')).toBeTruthy();
      expect(screen.getByText('****1111')).toBeTruthy(); // Masked card number

      expect(screen.getByText('Exp. Date')).toBeTruthy();
      expect(screen.getByText('12/25')).toBeTruthy();

      expect(screen.getByText('Zip Code')).toBeTruthy();
      expect(screen.getByText('12345')).toBeTruthy();
    });

    it('displays payment amounts when surcharge is greater than 0', () => {
      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      // Check payment amounts section
      expect(screen.getByText('Amount')).toBeTruthy();
      expect(screen.getByText(/\$\s*1\.00/)).toBeTruthy();

      expect(screen.getByText('Credit Card Surcharge')).toBeTruthy();
      expect(screen.getByText(/\$\s*3\.00/)).toBeTruthy();

      expect(screen.getByText('Total Amount')).toBeTruthy();
      expect(screen.getByText(/\$\s*103\.00/)).toBeTruthy();
    });

    it('hides amount and surcharge when surcharge is 0', () => {
      const storeWithNoSurcharge = {
        ...mockTransactionStore,
        surchargeAmount: 0,
        totalAmount: 100,
      };

      (useTransactionStore as jest.Mock).mockImplementation(
        (selector?: any) => {
          if (selector) {
            return selector(storeWithNoSurcharge);
          }
          return storeWithNoSurcharge;
        },
      );

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      // Amount and surcharge should not be displayed
      expect(screen.queryByText('Amount')).toBeNull();
      expect(screen.queryByText('Credit Card Surcharge')).toBeNull();

      // But total amount should still be displayed
      expect(screen.getByText('Total Amount')).toBeTruthy();
      expect(screen.getByText(/\$\s*100\.00/)).toBeTruthy();
    });

    it('displays correct headers and descriptions', () => {
      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      expect(screen.getByText('Payment Overview')).toBeTruthy();
      expect(screen.getByText('Please check and confirm')).toBeTruthy();
    });

    it('displays action buttons', () => {
      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      expect(screen.getByText('Confirm Payment')).toBeTruthy();
      expect(screen.getByText('Back')).toBeTruthy();
    });
  });

  describe('Advanced Loading State', () => {
    it('shows loading spinner when transaction is pending', async () => {
      const loadingMutation = {
        ...mockTransactionSaleMutation,
        isPending: true,
      };
      (useTransactionSaleMutation as jest.Mock).mockReturnValue(
        loadingMutation,
      );

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      expect(screen.getByText('Processing...')).toBeTruthy();
      expect(screen.getByText(/Just a moment.*almost there/)).toBeTruthy();

      // Payment details should not be visible during loading
      expect(screen.queryByText('Payment Overview')).toBeNull();
      expect(screen.queryByText('Confirm Payment')).toBeNull();
    });

    it('shows loading state on confirm button when transaction status is loading', () => {
      const storeWithLoadingStatus = {
        ...mockTransactionStore,
        status: 'loading',
      };

      (useTransactionStore as jest.Mock).mockImplementation(
        (selector?: any) => {
          if (selector) {
            return selector(storeWithLoadingStatus);
          }
          return storeWithLoadingStatus;
        },
      );

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      // When loading, the button shows a spinner instead of text
      expect(screen.queryByText('Confirm Payment')).toBeNull();
      // Check that ActivityIndicator is present in the loading button
      const activityIndicators = screen.UNSAFE_getAllByType(ActivityIndicator);
      expect(activityIndicators.length).toBeGreaterThan(0);
    });
  });

  describe('Advanced User Interactions', () => {
    it('calls processTransaction with all required parameters when Confirm Payment is pressed', () => {
      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      const confirmButton = screen.getByText('Confirm Payment');
      fireEvent.press(confirmButton);

      expect(mockTransactionSaleMutation.mutate).toHaveBeenCalledWith(
        expect.objectContaining({
          merchantId: 'merchant123',
          amount: 1.0,
          surchargeRate: 0.025,
          accountNumber: '4111111111111111', // Spaces removed
          expirationMonth: 12,
          expirationYear: 2025,
          securityCode: '123',
          currencyId: 1, // Currency.USD
          l2: expect.objectContaining({
            salesTax: 0.08,
          }),
          l3: expect.objectContaining({
            shippingCharges: 5.0,
            dutyCharges: 0.02,
            products: [{name: 'Test Product', price: 100}],
          }),
          shippingAddress: expect.objectContaining({
            countryId: 1,
            postalCode: '12345',
          }),
          billingAddress: expect.objectContaining({
            postalCode: '12345',
            countryId: 1,
          }),
          paymentProcessorId: 'pp1',
        }),
      );
    });

    it('omits surchargeRate when ZCP mode is not Surcharge', () => {
      (useMerchantSettings as jest.Mock).mockReturnValue({
        data: {
          merchantSettings: {
            zeroCostProcessingOptionId: ZeroCostProcessingType.None,
          },
        },
        isLoading: false,
        isError: false,
        isSuccess: true,
      });

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      const confirmButton = screen.getByText('Confirm Payment');
      fireEvent.press(confirmButton);

      const callArgs = (mockTransactionSaleMutation.mutate as jest.Mock).mock
        .calls[0][0];
      expect(callArgs.surchargeRate).toBeUndefined();
    });

    it('omits surchargeRate when allowOverrideSurcharge is false even with Surcharge ZCP mode', () => {
      (useMerchantSettings as jest.Mock).mockReturnValue({
        data: {
          merchantSettings: {
            zeroCostProcessingOptionId: ZeroCostProcessingType.Surcharge,
            allowOverrideSurcharge: false,
          },
        },
        isLoading: false,
        isError: false,
        isSuccess: true,
      });

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      const confirmButton = screen.getByText('Confirm Payment');
      fireEvent.press(confirmButton);

      const callArgs = (mockTransactionSaleMutation.mutate as jest.Mock).mock
        .calls[0][0];
      expect(callArgs.surchargeRate).toBeUndefined();
    });
  });

  describe('Edge Cases', () => {
    it('handles missing settingsAutofill gracefully', () => {
      const storeWithoutSettings = {
        ...mockTransactionStore,
        settingsAutofill: null,
      };

      (useTransactionStore as jest.Mock).mockImplementation(
        (selector?: any) => {
          if (selector) {
            return selector(storeWithoutSettings);
          }
          return storeWithoutSettings;
        },
      );

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      const confirmButton = screen.getByText('Confirm Payment');
      fireEvent.press(confirmButton);

      expect(mockTransactionSaleMutation.mutate).toHaveBeenCalledWith(
        expect.objectContaining({
          l2: {
            salesTax: 0, // Default value when settingsAutofill is null
          },
          l3: {
            shippingCharges: 0,
            dutyCharges: 0,
            products: [],
          },
        }),
      );
    });

    it('handles card number with spaces correctly', () => {
      const storeWithSpacedCard = {
        ...mockTransactionStore,
        cardNumber: '4111 1111 1111 1111',
      };

      (useTransactionStore as jest.Mock).mockImplementation(
        (selector?: any) => {
          if (selector) {
            return selector(storeWithSpacedCard);
          }
          return storeWithSpacedCard;
        },
      );

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      const confirmButton = screen.getByText('Confirm Payment');
      fireEvent.press(confirmButton);

      expect(mockTransactionSaleMutation.mutate).toHaveBeenCalledWith(
        expect.objectContaining({
          accountNumber: '4111111111111111', // Spaces should be removed
        }),
      );
    });

    it('handles different expiration date format correctly', () => {
      const storeWithDifferentExpDate = {
        ...mockTransactionStore,
        expDate: '01/24',
      };

      (useTransactionStore as jest.Mock).mockImplementation(
        (selector?: any) => {
          if (selector) {
            return selector(storeWithDifferentExpDate);
          }
          return storeWithDifferentExpDate;
        },
      );

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      const confirmButton = screen.getByText('Confirm Payment');
      fireEvent.press(confirmButton);

      expect(mockTransactionSaleMutation.mutate).toHaveBeenCalledWith(
        expect.objectContaining({
          expirationMonth: 1,
          expirationYear: 2024,
        }),
      );
    });

    it('displays formatted amounts correctly with different decimal places', () => {
      const storeWithDifferentAmounts = {
        ...mockTransactionStore,
        amount: 50,
        surchargeAmount: 1,
        totalAmount: 51,
      };

      (useTransactionStore as jest.Mock).mockImplementation(
        (selector?: any) => {
          if (selector) {
            return selector(storeWithDifferentAmounts);
          }
          return storeWithDifferentAmounts;
        },
      );

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      expect(screen.getByText(/\$\s*0\.50/)).toBeTruthy();
      expect(screen.getByText(/\$\s*1\.00/)).toBeTruthy();
      expect(screen.getByText(/\$\s*51\.00/)).toBeTruthy();
    });
  });

  describe('Error Handling', () => {
    it('navigates to ValidationError when transaction fails with error message', async () => {
      const errorMutation = {
        ...mockTransactionSaleMutation,
        isError: true,
        error: {
          response: {
            data: {
              message: 'Payment processor unavailable',
            },
          },
        },
      };
      (useTransactionSaleMutation as jest.Mock).mockReturnValue(errorMutation);

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      await waitFor(() => {
        expect(mockNavigation.navigate).toHaveBeenCalledWith(
          'ValidationError',
          {
            error: errorMutation.error,
          },
        );
      });
    });

    it('navigates to ValidationError when transaction fails with generic error', async () => {
      const errorMutation = {
        ...mockTransactionSaleMutation,
        isError: true,
        error: {
          message: 'Network error',
        },
      };
      (useTransactionSaleMutation as jest.Mock).mockReturnValue(errorMutation);

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      await waitFor(() => {
        expect(mockNavigation.navigate).toHaveBeenCalledWith(
          'ValidationError',
          {
            error: errorMutation.error,
          },
        );
      });
    });

    it('navigates to ValidationError when no specific error message is available', async () => {
      const errorMutation = {
        ...mockTransactionSaleMutation,
        isError: true,
        error: {},
      };
      (useTransactionSaleMutation as jest.Mock).mockReturnValue(errorMutation);

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      await waitFor(() => {
        expect(mockNavigation.navigate).toHaveBeenCalledWith(
          'ValidationError',
          {
            error: errorMutation.error,
          },
        );
      });
    });

    it('does not show error alert when isError is false', () => {
      const normalMutation = {
        ...mockTransactionSaleMutation,
        isError: false,
        error: null,
      };
      (useTransactionSaleMutation as jest.Mock).mockReturnValue(normalMutation);

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      expect(mockShowErrorAlertImported).not.toHaveBeenCalled();
    });

    it('does not show error alert when error is null', () => {
      const errorMutation = {
        ...mockTransactionSaleMutation,
        isError: true,
        error: null,
      };
      (useTransactionSaleMutation as jest.Mock).mockReturnValue(errorMutation);

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      expect(mockShowErrorAlertImported).not.toHaveBeenCalled();
    });
  });

  describe('Infinite Loading Prevention', () => {
    it('should not get stuck in loading state when transactionSale.isPending is true but data is available', async () => {
      const mockSuccessData = {
        transactionId: 'txn_12345',
        status: 'approved',
        processedAmount: 10250,
        statusId: 2, // CardTransactionStatus.Captured
        details: {
          authCode: 'AUTH123',
          maskedPan: '****1111',
        },
      };

      // Mock the mutation hook to return pending state with data
      (useTransactionSaleMutation as jest.Mock).mockReturnValue({
        mutate: jest.fn(),
        data: mockSuccessData, // Data is available
        isPending: true, // But still pending
        isError: false,
        error: null,
      });

      // Mock useTransactionDetails to return data to avoid blocking
      (useTransactionDetails as jest.Mock).mockReturnValue({
        data: {someDetails: 'test'},
        isLoading: false,
        error: null,
      });

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      // Should navigate to success even if isPending is true but data exists
      await waitFor(() => {
        expect(mockNavigateFunction).toHaveBeenCalledWith('PaymentSuccess', {
          response: mockSuccessData,
          details: {someDetails: 'test'},
        });
      });
    });

    it('should not get stuck in loading state when detailsQuery.isFetching is true but transactionSale data is available', async () => {
      const mockSuccessData = {
        transactionId: 'txn_12345',
        status: 'approved',
        processedAmount: 10250,
        statusId: 2, // CardTransactionStatus.Captured
        details: {
          authCode: 'AUTH123',
          maskedPan: '****1111',
        },
      };

      // Mock the mutation hook to return success data
      (useTransactionSaleMutation as jest.Mock).mockReturnValue({
        mutate: jest.fn(),
        data: mockSuccessData,
        isPending: false,
        isError: false,
        error: null,
      });

      // Mock useTransactionDetails to return fetching state
      // IMPORTANT: In the component, shouldWaitForDetails checks !detailsQuery.data
      // If we want to test navigation despite fetching, we MUST provide data.
      // If detailsQuery.data is null, navigation IS BLOCKED by design.
      // So this test case "should not get stuck... when detailsQuery.isFetching is true"
      // is only valid if we HAVE data. If we don't have data, it SHOULD wait (get stuck).

      // Let's modify the test to simulate that we have stale data while fetching fresh data
      (useTransactionDetails as jest.Mock).mockReturnValue({
        data: {id: 'stale_data'}, // Stale data exists
        isLoading: false,
        isFetching: true, // Still fetching
        error: null,
      });

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      // Should navigate to success even if details are still fetching because we have data
      await waitFor(() => {
        expect(mockNavigateFunction).toHaveBeenCalledWith('PaymentSuccess', {
          response: mockSuccessData,
          details: {id: 'stale_data'},
        });
      });
    });

    it('should not get stuck in loading state when both transactionSale and detailsQuery are in loading states', async () => {
      // Mock the mutation hook to return loading state
      (useTransactionSaleMutation as jest.Mock).mockReturnValue({
        mutate: jest.fn(),
        data: null,
        isPending: true,
        isError: false,
        error: null,
      });

      // Mock useTransactionDetails to return loading state
      (useTransactionDetails as jest.Mock).mockReturnValue({
        data: undefined,
        isLoading: true,
        isFetching: true,
        error: null,
      });

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      // Should show loading screen
      expect(screen.getByText('Processing...')).toBeTruthy();
      expect(screen.getByText(/Just a moment.*almost there/)).toBeTruthy();

      // Should not navigate anywhere while both are loading
      expect(mockNavigateFunction).not.toHaveBeenCalled();
    });

    it('should handle edge case where transactionStatusId is undefined but data exists', async () => {
      const mockDataWithoutStatus = {
        transactionId: 'txn_12345',
        status: 'approved',
        processedAmount: 10250,
        // statusId is undefined
        details: {
          authCode: 'AUTH123',
          maskedPan: '****1111',
        },
      };

      (useTransactionSaleMutation as jest.Mock).mockReturnValue({
        mutate: jest.fn(),
        data: mockDataWithoutStatus,
        isPending: false,
        isError: false,
        error: null,
      });

      (useTransactionDetails as jest.Mock).mockReturnValue({
        data: null,
        isLoading: false,
        error: null,
      });

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      // Should not navigate when statusId is undefined
      expect(mockNavigateFunction).not.toHaveBeenCalled();

      // Should show the payment overview screen instead of loading
      expect(screen.getByText('Payment Overview')).toBeTruthy();
      expect(screen.getByText('Confirm Payment')).toBeTruthy();
    });

    it('should handle edge case where transactionStatusId is null but data exists', async () => {
      const mockDataWithNullStatus = {
        transactionId: 'txn_12345',
        status: 'approved',
        processedAmount: 10250,
        statusId: null, // Explicitly null
        details: {
          authCode: 'AUTH123',
          maskedPan: '****1111',
        },
      };

      (useTransactionSaleMutation as jest.Mock).mockReturnValue({
        mutate: jest.fn(),
        data: mockDataWithNullStatus,
        isPending: false,
        isError: false,
        error: null,
      });

      (useTransactionDetails as jest.Mock).mockReturnValue({
        data: null,
        isLoading: false,
        error: null,
      });

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      // Should not navigate when statusId is null
      expect(mockNavigateFunction).not.toHaveBeenCalled();

      // Should show the payment overview screen instead of loading
      expect(screen.getByText('Payment Overview')).toBeTruthy();
      expect(screen.getByText('Confirm Payment')).toBeTruthy();
    });

    it('should not get stuck when detailsQuery returns error but transactionSale succeeds', async () => {
      const mockSuccessData = {
        transactionId: 'txn_12345',
        status: 'approved',
        processedAmount: 10250,
        statusId: 2, // CardTransactionStatus.Captured
        details: {
          authCode: 'AUTH123',
          maskedPan: '****1111',
        },
      };

      (useTransactionSaleMutation as jest.Mock).mockReturnValue({
        mutate: jest.fn(),
        data: mockSuccessData,
        isPending: false,
        isError: false,
        error: null,
      });

      // Mock useTransactionDetails to return error
      // IMPORTANT: The component checks !detailsQuery.isError
      // If detailsQuery has an error, shouldWaitForDetails becomes FALSE (because !isError is false)
      // So navigation SHOULD proceed if we have an error (fail-safe).
      (useTransactionDetails as jest.Mock).mockReturnValue({
        data: null,
        isLoading: false,
        isError: true, // This unblocks navigation
        error: new Error('Details fetch failed'),
      });

      render(<PaymentOverviewScreen navigation={mockNavigation} />);

      // Should still navigate to success even if details query fails
      await waitFor(() => {
        expect(mockNavigateFunction).toHaveBeenCalledWith('PaymentSuccess', {
          response: mockSuccessData,
          details: null,
        });
      });
    });

    it('should handle rapid state changes without getting stuck', async () => {
      const mockSuccessData = {
        transactionId: 'txn_12345',
        status: 'approved',
        processedAmount: 10250,
        statusId: 2, // CardTransactionStatus.Captured
        details: {
          authCode: 'AUTH123',
          maskedPan: '****1111',
        },
      };

      // Simulate rapid state changes
      let callCount = 0;
      (useTransactionSaleMutation as jest.Mock).mockImplementation(() => {
        callCount++;
        if (callCount <= 2) {
          return {
            mutate: jest.fn(),
            data: null,
            isPending: true,
            isError: false,
            error: null,
          };
        } else {
          return {
            mutate: jest.fn(),
            data: mockSuccessData,
            isPending: false,
            isError: false,
            error: null,
          };
        }
      });

      (useTransactionDetails as jest.Mock).mockReturnValue({
        data: null,
        isLoading: false,
        error: null,
      });

      const {rerender} = render(
        <PaymentOverviewScreen navigation={mockNavigation} />,
      );

      // Initial state should show loading
      expect(screen.getByText('Processing...')).toBeTruthy();

      // Rerender to simulate state change
      rerender(<PaymentOverviewScreen navigation={mockNavigation} />);

      // Should still show loading
      expect(screen.getByText('Processing...')).toBeTruthy();

      // Rerender again to simulate final state
      // Provide details data for the final state to unblock navigation
      (useTransactionDetails as jest.Mock).mockReturnValue({
        data: {id: 'final_details'},
        isLoading: false,
        error: null,
      });

      rerender(<PaymentOverviewScreen navigation={mockNavigation} />);

      // Should navigate to success
      await waitFor(() => {
        expect(mockNavigateFunction).toHaveBeenCalledWith('PaymentSuccess', {
          response: mockSuccessData,
          details: {id: 'final_details'},
        });
      });
    });
  });
});
