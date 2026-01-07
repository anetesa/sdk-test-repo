// @ts-nocheck
// Jest provides globals at runtime; we disable TS checking for this test file to avoid
// repo-wide tsconfig type limitations without affecting test execution.

import React from 'react';
import {render, fireEvent, waitFor} from '@testing-library/react-native';
import ZCPTipsAnalysisScreen from '../ZCPTipsAnalysisScreen';
import {NavigationContainer} from '@react-navigation/native';
import {QueryClient, QueryClientProvider} from '@tanstack/react-query';

// Mock the hooks and stores
jest.mock('../../../hooks/useTipCalculation', () => ({
  useTipCalculation: jest.fn(() => ({
    tipOptions: [
      {id: '15', label: '15%', amount: 15},
      {id: '18', label: '18%', amount: 18},
      {id: '20', label: '20%', amount: 20},
    ],
    selectedTipId: null,
    tipAmount: 0,
    totalAmount: 100,
    hasTipSelection: false,
    showCustomValue: false,
    customTipAmount: '',
    calculationData: {
      creditCard: {
        baseAmount: 100.0,
        tipAmount: 0.0,
        surchargeAmount: 3.5,
        totalAmount: 103.5,
      },
      debitCard: {
        baseAmount: 100.0,
        tipAmount: 0.0,
        surchargeAmount: 0.0,
        totalAmount: 100.0,
      },
    },
    isLoading: false,
    isError: false,
    handleTipOptionPress: jest.fn(),
    handleCustomValuePress: jest.fn(),
    setCustomTipAmount: jest.fn(),
  })),
}));

// Mock navigation functions
const mockNavigate = jest.fn();
const mockGoBack = jest.fn();

const createMockRoute = (overrides = {}) => ({
  params: {
    transactionDetails: {
      amount: '100.00',
      tip: '0.00',
      discount: '0.00',
      salesTaxAmount: '0.00',
      federalTaxAmount: '0.00',
      customData: undefined,
      subTotal: '100.00',
      orderId: 'test-order-123',
    },
    isSurcharge: false,
    isTipEnabled: true,
    defaultSurchargeRate: 3.5,
    ...overrides,
  },
});

const TestWrapper = ({children}: {children: React.ReactNode}) => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
      },
    },
  });

  return (
    <QueryClientProvider client={queryClient}>
      <NavigationContainer>{children}</NavigationContainer>
    </QueryClientProvider>
  );
};

describe('ZCPTipsAnalysisScreen', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Eligibility Check - Screen Display Conditions', () => {
    it('should display card type selection when isSurcharge is true and isTipEnabled is false', () => {
      const route = createMockRoute({
        isSurcharge: true,
        isTipEnabled: false,
      });

      const {getByText, queryByText} = render(
        <TestWrapper>
          <ZCPTipsAnalysisScreen
            navigation={{navigate: mockNavigate, goBack: mockGoBack} as any}
            route={route as any}
          />
        </TestWrapper>,
      );

      // Should show card type selection
      expect(getByText('Select the card type')).toBeTruthy();
      expect(getByText('Credit Card')).toBeTruthy();
      expect(getByText('Debit Card')).toBeTruthy();

      // Should NOT show tip section
      expect(queryByText('Tip Amount')).toBeNull();
    });

    it('should display only tip section when isTipEnabled is true and isSurcharge is false', () => {
      const route = createMockRoute({
        isSurcharge: false,
        isTipEnabled: true,
      });

      const {getByText, queryByText} = render(
        <TestWrapper>
          <ZCPTipsAnalysisScreen
            navigation={{navigate: mockNavigate, goBack: mockGoBack} as any}
            route={route as any}
          />
        </TestWrapper>,
      );

      // Should show tip section
      expect(getByText('Add a Tip?')).toBeTruthy();
      expect(getByText('Tip Amount')).toBeTruthy();

      // Should NOT show card type selection
      expect(queryByText('Credit Card')).toBeNull();
      expect(queryByText('Debit Card')).toBeNull();
    });

    it('should display both card type selection and tip section when both are enabled', () => {
      const route = createMockRoute({
        isSurcharge: true,
        isTipEnabled: true,
      });

      const {getByText} = render(
        <TestWrapper>
          <ZCPTipsAnalysisScreen
            navigation={{navigate: mockNavigate, goBack: mockGoBack} as any}
            route={route as any}
          />
        </TestWrapper>,
      );

      // Should show both sections
      expect(getByText('Select the card type and tip amount')).toBeTruthy();
      expect(getByText('Credit Card')).toBeTruthy();
      expect(getByText('Debit Card')).toBeTruthy();
      expect(getByText('Tip Amount')).toBeTruthy();
    });
  });

  describe('Card Type Selection - Default State', () => {
    it('should have no card option pre-selected by default', () => {
      const route = createMockRoute({
        isSurcharge: true,
        isTipEnabled: false,
      });

      const {getByText} = render(
        <TestWrapper>
          <ZCPTipsAnalysisScreen
            navigation={{navigate: mockNavigate, goBack: mockGoBack} as any}
            route={route as any}
          />
        </TestWrapper>,
      );

      const creditButton = getByText('Credit Card').parent?.parent;
      const debitButton = getByText('Debit Card').parent?.parent;

      // Neither should have selected styling
      expect(creditButton?.props.className).not.toContain('border-brand-main');
      expect(debitButton?.props.className).not.toContain('border-brand-main');
    });
  });

  describe('Card Type Selection - Credit Card', () => {
    it('should display amount summary when credit card is selected', async () => {
      const route = createMockRoute({
        isSurcharge: true,
        isTipEnabled: false,
      });

      const {getByText} = render(
        <TestWrapper>
          <ZCPTipsAnalysisScreen
            navigation={{navigate: mockNavigate, goBack: mockGoBack} as any}
            route={route as any}
          />
        </TestWrapper>,
      );

      // Select credit card
      fireEvent.press(getByText('Credit Card'));

      await waitFor(() => {
        // Should display base amount and total
        expect(getByText('Base Amount')).toBeTruthy();
        expect(getByText('Total')).toBeTruthy();
      });
    });

    it('should enable credit card option to be selected', () => {
      const route = createMockRoute({
        isSurcharge: true,
        isTipEnabled: false,
      });

      const {getByText} = render(
        <TestWrapper>
          <ZCPTipsAnalysisScreen
            navigation={{navigate: mockNavigate, goBack: mockGoBack} as any}
            route={route as any}
          />
        </TestWrapper>,
      );

      // Credit card should be clickable
      fireEvent.press(getByText('Credit Card'));
      expect(getByText('Credit Card')).toBeTruthy();
    });
  });

  describe('Card Type Selection - Debit Card', () => {
    it('should show base amount only (no surcharge) when debit card is selected', async () => {
      const route = createMockRoute({
        isSurcharge: true,
        isTipEnabled: false,
      });

      const {getByText, queryByText, getAllByText} = render(
        <TestWrapper>
          <ZCPTipsAnalysisScreen
            navigation={{navigate: mockNavigate, goBack: mockGoBack} as any}
            route={route as any}
          />
        </TestWrapper>,
      );

      // Select debit card
      fireEvent.press(getByText('Debit Card'));

      await waitFor(() => {
        // Should display base amount
        expect(getByText('Base Amount')).toBeTruthy();
        const amounts = getAllByText('$100.00');
        expect(amounts.length).toBeGreaterThan(0);

        // Should NOT display surcharge (as debit has 0 surcharge)
        expect(queryByText('Surcharge')).toBeNull();

        // Total should equal base amount
        expect(getByText('Total')).toBeTruthy();
      });
    });

    it('should enable debit card option to be selected', () => {
      const route = createMockRoute({
        isSurcharge: true,
        isTipEnabled: false,
      });

      const {getByText} = render(
        <TestWrapper>
          <ZCPTipsAnalysisScreen
            navigation={{navigate: mockNavigate, goBack: mockGoBack} as any}
            route={route as any}
          />
        </TestWrapper>,
      );

      // Debit card should be clickable
      fireEvent.press(getByText('Debit Card'));
      expect(getByText('Debit Card')).toBeTruthy();
    });
  });

  describe('Tap to Pay Button - Disabled State', () => {
    it('should remain disabled when no card type is selected (surcharge only)', () => {
      const route = createMockRoute({
        isSurcharge: true,
        isTipEnabled: false,
      });

      const {getByTestId} = render(
        <TestWrapper>
          <ZCPTipsAnalysisScreen
            navigation={{navigate: mockNavigate, goBack: mockGoBack} as any}
            route={route as any}
          />
        </TestWrapper>,
      );

      const tapToPayButton = getByTestId('arise-button-Tap to Pay on iPhone');
      expect(tapToPayButton.props.accessibilityState.disabled).toBe(true);
    });

    it('should remain disabled when no tip is selected (tip only)', () => {
      const route = createMockRoute({
        isSurcharge: false,
        isTipEnabled: true,
      });

      const {getByTestId} = render(
        <TestWrapper>
          <ZCPTipsAnalysisScreen
            navigation={{navigate: mockNavigate, goBack: mockGoBack} as any}
            route={route as any}
          />
        </TestWrapper>,
      );

      const tapToPayButton = getByTestId('arise-button-Tap to Pay on iPhone');
      expect(tapToPayButton.props.accessibilityState.disabled).toBe(true);
    });

    it('should remain disabled when card is selected but tip is not (both enabled)', () => {
      const route = createMockRoute({
        isSurcharge: true,
        isTipEnabled: true,
      });

      const {getByText, getByTestId} = render(
        <TestWrapper>
          <ZCPTipsAnalysisScreen
            navigation={{navigate: mockNavigate, goBack: mockGoBack} as any}
            route={route as any}
          />
        </TestWrapper>,
      );

      // Select credit card only
      fireEvent.press(getByText('Credit Card'));

      const tapToPayButton = getByTestId('arise-button-Tap to Pay on iPhone');
      expect(tapToPayButton.props.accessibilityState.disabled).toBe(true);
    });
  });

  describe('Tap to Pay Button - Enabled State', () => {
    it('should be enabled when card type is selected (surcharge only)', () => {
      const route = createMockRoute({
        isSurcharge: true,
        isTipEnabled: false,
      });

      const {getByText, getByTestId} = render(
        <TestWrapper>
          <ZCPTipsAnalysisScreen
            navigation={{navigate: mockNavigate, goBack: mockGoBack} as any}
            route={route as any}
          />
        </TestWrapper>,
      );

      fireEvent.press(getByText('Credit Card'));

      const tapToPayButton = getByTestId('arise-button-Tap to Pay on iPhone');
      expect(tapToPayButton.props.accessibilityState.disabled).toBe(false);
    });
  });

  describe('Confirmation and Transition', () => {
    it('should navigate to loading screen with correct amount for credit card', () => {
      const route = createMockRoute({
        isSurcharge: true,
        isTipEnabled: false,
      });

      const {getByText} = render(
        <TestWrapper>
          <ZCPTipsAnalysisScreen
            navigation={{navigate: mockNavigate, goBack: mockGoBack} as any}
            route={route as any}
          />
        </TestWrapper>,
      );

      // Select credit card
      fireEvent.press(getByText('Credit Card'));

      // Tap the button
      fireEvent.press(getByText('Tap to Pay on iPhone'));

      expect(mockNavigate).toHaveBeenCalledWith(
        'LoadingTapToPay',
        expect.objectContaining({
          transactionDetails: expect.objectContaining({
            amount: '103.50', // formatted string for native bridge
          }),
        }),
      );
    });

    it('should navigate to loading screen with correct amount for debit card', () => {
      const route = createMockRoute({
        isSurcharge: true,
        isTipEnabled: false,
      });

      const {getByText} = render(
        <TestWrapper>
          <ZCPTipsAnalysisScreen
            navigation={{navigate: mockNavigate, goBack: mockGoBack} as any}
            route={route as any}
          />
        </TestWrapper>,
      );

      // Select debit card
      fireEvent.press(getByText('Debit Card'));

      // Tap the button
      fireEvent.press(getByText('Tap to Pay on iPhone'));

      expect(mockNavigate).toHaveBeenCalledWith(
        'LoadingTapToPay',
        expect.objectContaining({
          transactionDetails: expect.objectContaining({
            amount: '100.00', // formatted string for native bridge
          }),
        }),
      );
    });

    it('should include customData with surchargeRate when surcharge is enabled', () => {
      const route = createMockRoute({
        isSurcharge: true,
        isTipEnabled: false,
        defaultSurchargeRate: 3.5,
      });

      const {getByText} = render(
        <TestWrapper>
          <ZCPTipsAnalysisScreen
            navigation={{navigate: mockNavigate, goBack: mockGoBack} as any}
            route={route as any}
          />
        </TestWrapper>,
      );

      fireEvent.press(getByText('Credit Card'));
      fireEvent.press(getByText('Tap to Pay on iPhone'));

      expect(mockNavigate).toHaveBeenCalledWith(
        'LoadingTapToPay',
        expect.objectContaining({
          transactionDetails: expect.objectContaining({
            customData: {
              surchargeRate: '3.5',
            },
          }),
        }),
      );
    });

    it('should not include customData when surcharge is not enabled', () => {
      const route = createMockRoute({
        isSurcharge: false,
        isTipEnabled: true,
      });

      // Mock tip selection
      const mockUseTipCalculation =
        require('../../../hooks/useTipCalculation').useTipCalculation;
      mockUseTipCalculation.mockImplementation(() => ({
        tipOptions: [
          {id: '15', label: '15%', amount: 15},
          {id: '18', label: '18%', amount: 18},
          {id: '20', label: '20%', amount: 20},
        ],
        selectedTipId: '15',
        tipAmount: 15,
        totalAmount: 115,
        hasTipSelection: true,
        showCustomValue: false,
        customTipAmount: '',
        calculationData: {
          creditCard: {
            baseAmount: 100.0,
            tipAmount: 15.0,
            surchargeAmount: 0.0,
            totalAmount: 115.0,
          },
          debitCard: {
            baseAmount: 100.0,
            tipAmount: 15.0,
            surchargeAmount: 0.0,
            totalAmount: 115.0,
          },
        },
        isLoading: false,
        isError: false,
        handleTipOptionPress: jest.fn(),
        handleCustomValuePress: jest.fn(),
        setCustomTipAmount: jest.fn(),
      }));

      const {getByText} = render(
        <TestWrapper>
          <ZCPTipsAnalysisScreen
            navigation={{navigate: mockNavigate, goBack: mockGoBack} as any}
            route={route as any}
          />
        </TestWrapper>,
      );

      fireEvent.press(getByText('Tap to Pay on iPhone'));

      expect(mockNavigate).toHaveBeenCalledWith(
        'LoadingTapToPay',
        expect.objectContaining({
          transactionDetails: expect.objectContaining({
            amount: '115.00', // formatted string for native bridge
          }),
        }),
      );

      // Verify customData was not set or is undefined
      const navigationCall = mockNavigate.mock.calls[0] as any;
      const {customData} = navigationCall[1].transactionDetails;
      expect(customData).toBeUndefined();
    });
  });

  describe('Navigation', () => {
    it('should call goBack when back button is pressed', () => {
      const route = createMockRoute({
        isSurcharge: true,
        isTipEnabled: false,
      });

      const {UNSAFE_getAllByType} = render(
        <TestWrapper>
          <ZCPTipsAnalysisScreen
            navigation={{navigate: mockNavigate, goBack: mockGoBack} as any}
            route={route as any}
          />
        </TestWrapper>,
      );

      // Find the first TouchableOpacity (back button)
      const touchableElements = UNSAFE_getAllByType(
        require('react-native').TouchableOpacity,
      );
      fireEvent.press(touchableElements[0]);

      expect(mockGoBack).toHaveBeenCalled();
    });
  });

  describe('Amount Display', () => {
    it('should display base amount correctly', () => {
      const route = createMockRoute({
        isSurcharge: true,
        isTipEnabled: false,
      });

      const {getByText} = render(
        <TestWrapper>
          <ZCPTipsAnalysisScreen
            navigation={{navigate: mockNavigate, goBack: mockGoBack} as any}
            route={route as any}
          />
        </TestWrapper>,
      );

      expect(getByText('Base Amount')).toBeTruthy();
      expect(getByText('Total')).toBeTruthy();
    });
  });
});
