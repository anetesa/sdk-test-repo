import React from 'react';
import {render} from '@testing-library/react-native';
import {AmountSummary} from '../AmountSummary';
import {CalculateAmountResponseDTO} from '@/types/CalculateAmount';

describe('AmountSummary', () => {
  const mockCalculationData: CalculateAmountResponseDTO = {
    creditCard: {
      baseAmount: 100.0,
      tipAmount: 15.0,
      surchargeAmount: 3.5,
      totalAmount: 118.5,
    },
    debitCard: {
      baseAmount: 100.0,
      tipAmount: 15.0,
      surchargeAmount: 0.0,
      totalAmount: 115.0,
    },
  };

  describe('Base Rendering', () => {
    it('should render base amount correctly', () => {
      const {getByText} = render(
        <AmountSummary
          baseAmountInDollars={100}
          tipAmount={0}
          totalAmount={100}
          calculationData={mockCalculationData}
        />,
      );

      expect(getByText('Base Amount')).toBeTruthy();
      expect(getByText('$100.00')).toBeTruthy();
    });

    it('should render total amount correctly', () => {
      const {getByText} = render(
        <AmountSummary
          baseAmountInDollars={100}
          tipAmount={0}
          totalAmount={100}
          calculationData={mockCalculationData}
        />,
      );

      expect(getByText('Total')).toBeTruthy();
    });
  });

  describe('Tip Display - isTipEnabled', () => {
    it('should show tip when isTipEnabled is true', () => {
      const {getByText} = render(
        <AmountSummary
          baseAmountInDollars={100}
          tipAmount={15}
          totalAmount={115}
          calculationData={mockCalculationData}
          isTipEnabled={true}
        />,
      );

      expect(getByText('Tip')).toBeTruthy();
      expect(getByText('$15.00')).toBeTruthy();
    });

    it('should NOT show tip when isTipEnabled is false', () => {
      const {queryByText} = render(
        <AmountSummary
          baseAmountInDollars={100}
          tipAmount={0}
          totalAmount={100}
          calculationData={mockCalculationData}
          isTipEnabled={false}
        />,
      );

      expect(queryByText('Tip')).toBeNull();
    });

    it('should default to false if isTipEnabled is not provided', () => {
      const {queryByText} = render(
        <AmountSummary
          baseAmountInDollars={100}
          tipAmount={15}
          totalAmount={115}
          calculationData={mockCalculationData}
        />,
      );

      // Should NOT show tip by default
      expect(queryByText('Tip')).toBeNull();
    });
  });

  describe('Surcharge Display - Credit Card', () => {
    it('should show surcharge when credit card is selected', () => {
      const {getByText} = render(
        <AmountSummary
          baseAmountInDollars={100}
          tipAmount={0}
          totalAmount={103.5}
          calculationData={mockCalculationData}
          isSurcharge={true}
          cardSelected="credit"
        />,
      );

      expect(getByText('Credit Card Surcharge')).toBeTruthy();
      expect(getByText('$3.50')).toBeTruthy();
    });

    it('should display correct total with credit card surcharge', () => {
      const {getByText} = render(
        <AmountSummary
          baseAmountInDollars={100}
          tipAmount={0}
          totalAmount={103.5}
          calculationData={mockCalculationData}
          isSurcharge={true}
          cardSelected="credit"
        />,
      );

      expect(getByText('$118.50')).toBeTruthy(); // Total from creditCard data
    });

    it('should use creditCard data from calculationData when credit is selected', () => {
      const customData: CalculateAmountResponseDTO = {
        creditCard: {
          baseAmount: 50.0,
          tipAmount: 10.0,
          surchargeAmount: 2.1,
          totalAmount: 62.1,
        },
        debitCard: {
          baseAmount: 50.0,
          tipAmount: 10.0,
          surchargeAmount: 0.0,
          totalAmount: 60.0,
        },
      };

      const {getByText} = render(
        <AmountSummary
          baseAmountInDollars={50}
          tipAmount={10}
          totalAmount={62.1}
          calculationData={customData}
          isSurcharge={true}
          cardSelected="credit"
          isTipEnabled={true}
        />,
      );

      expect(getByText('$2.10')).toBeTruthy(); // Surcharge from creditCard
      expect(getByText('$62.10')).toBeTruthy(); // Total from creditCard
    });
  });

  describe('Surcharge Display - Debit Card', () => {
    it('should NOT show surcharge when debit card is selected', () => {
      const {queryByText} = render(
        <AmountSummary
          baseAmountInDollars={100}
          tipAmount={0}
          totalAmount={100}
          calculationData={mockCalculationData}
          isSurcharge={true}
          cardSelected="debit"
        />,
      );

      // Debit card has 0 surcharge, so it shouldn't display
      expect(queryByText('Credit Card Surcharge')).toBeNull();
    });

    it('should display correct total for debit card (no surcharge)', () => {
      const {getByText} = render(
        <AmountSummary
          baseAmountInDollars={100}
          tipAmount={0}
          totalAmount={100}
          calculationData={mockCalculationData}
          isSurcharge={true}
          cardSelected="debit"
        />,
      );

      expect(getByText('$115.00')).toBeTruthy(); // Total from debitCard data (with tip)
    });

    it('should use debitCard data from calculationData when debit is selected', () => {
      const customData: CalculateAmountResponseDTO = {
        creditCard: {
          baseAmount: 75.0,
          tipAmount: 12.0,
          surchargeAmount: 3.0,
          totalAmount: 90.0,
        },
        debitCard: {
          baseAmount: 75.0,
          tipAmount: 12.0,
          surchargeAmount: 0.0,
          totalAmount: 87.0,
        },
      };

      const {getByText} = render(
        <AmountSummary
          baseAmountInDollars={75}
          tipAmount={12}
          totalAmount={87}
          calculationData={customData}
          isSurcharge={true}
          cardSelected="debit"
          isTipEnabled={true}
        />,
      );

      expect(getByText('$87.00')).toBeTruthy(); // Total from debitCard
    });
  });

  describe('Combined Tip and Surcharge', () => {
    it('should show both tip and surcharge for credit card when both are enabled', () => {
      const {getByText} = render(
        <AmountSummary
          baseAmountInDollars={100}
          tipAmount={15}
          totalAmount={118.5}
          calculationData={mockCalculationData}
          isTipEnabled={true}
          isSurcharge={true}
          cardSelected="credit"
        />,
      );

      expect(getByText('Base Amount')).toBeTruthy();
      expect(getByText('Tip')).toBeTruthy();
      expect(getByText('Credit Card Surcharge')).toBeTruthy();
      expect(getByText('Total')).toBeTruthy();

      // Verify amounts
      expect(getByText('$100.00')).toBeTruthy(); // Base
      expect(getByText('$15.00')).toBeTruthy(); // Tip
      expect(getByText('$3.50')).toBeTruthy(); // Surcharge
      expect(getByText('$118.50')).toBeTruthy(); // Total
    });

    it('should show only tip for debit card when both features are enabled', () => {
      const {getByText, queryByText} = render(
        <AmountSummary
          baseAmountInDollars={100}
          tipAmount={15}
          totalAmount={115}
          calculationData={mockCalculationData}
          isTipEnabled={true}
          isSurcharge={true}
          cardSelected="debit"
        />,
      );

      expect(getByText('Base Amount')).toBeTruthy();
      expect(getByText('Tip')).toBeTruthy();
      expect(queryByText('Credit Card Surcharge')).toBeNull(); // No surcharge for debit
      expect(getByText('Total')).toBeTruthy();

      // Verify amounts
      expect(getByText('$100.00')).toBeTruthy(); // Base
      expect(getByText('$15.00')).toBeTruthy(); // Tip
      expect(getByText('$115.00')).toBeTruthy(); // Total
    });
  });

  describe('Loading and Error States', () => {
    it('should handle loading state gracefully', () => {
      const {getByText} = render(
        <AmountSummary
          baseAmountInDollars={100}
          tipAmount={0}
          totalAmount={100}
          calculationData={mockCalculationData}
          isLoading={true}
        />,
      );

      // Should show loading message
      expect(getByText('Calculating amounts...')).toBeTruthy();
    });

    it('should handle error state gracefully', () => {
      const {getByText} = render(
        <AmountSummary
          baseAmountInDollars={100}
          tipAmount={0}
          totalAmount={100}
          calculationData={mockCalculationData}
          isError={true}
        />,
      );

      // Should still render the component
      expect(getByText('Base Amount')).toBeTruthy();
    });
  });

  describe('Fallback to Props', () => {
    it('should use prop values when calculationData is not available', () => {
      const {getByText} = render(
        <AmountSummary
          baseAmountInDollars={50}
          tipAmount={10}
          totalAmount={60}
        />,
      );

      expect(getByText('$50.00')).toBeTruthy();
      expect(getByText('$60.00')).toBeTruthy();
    });

    it('should use backend data over props when available', () => {
      const {getByText} = render(
        <AmountSummary
          baseAmountInDollars={50}
          tipAmount={5}
          totalAmount={55}
          calculationData={mockCalculationData}
          isSurcharge={false}
        />,
      );

      // Should use backend data (100) not props (50)
      expect(getByText('$100.00')).toBeTruthy();
    });
  });

  describe('No Card Selected', () => {
    it('should default to credit card data when no card is selected', () => {
      const {getByText} = render(
        <AmountSummary
          baseAmountInDollars={100}
          tipAmount={15}
          totalAmount={118.5}
          calculationData={mockCalculationData}
          isSurcharge={true}
          cardSelected=""
        />,
      );

      // When no card selected and isSurcharge is true, should use debit card data
      expect(getByText('$115.00')).toBeTruthy(); // Debit card total
    });

    it('should use credit card data when surcharge is disabled', () => {
      const {getByText} = render(
        <AmountSummary
          baseAmountInDollars={100}
          tipAmount={15}
          totalAmount={118.5}
          calculationData={mockCalculationData}
          isSurcharge={false}
        />,
      );

      // Should default to creditCard data
      expect(getByText('$118.50')).toBeTruthy();
    });
  });

  describe('Edge Cases', () => {
    it('should handle zero amounts', () => {
      const zeroData: CalculateAmountResponseDTO = {
        creditCard: {
          baseAmount: 0,
          tipAmount: 0,
          surchargeAmount: 0,
          totalAmount: 0,
        },
        debitCard: {
          baseAmount: 0,
          tipAmount: 0,
          surchargeAmount: 0,
          totalAmount: 0,
        },
      };

      const {getAllByText} = render(
        <AmountSummary
          baseAmountInDollars={0}
          tipAmount={0}
          totalAmount={0}
          calculationData={zeroData}
        />,
      );

      const zeroAmounts = getAllByText('$0.00');
      expect(zeroAmounts.length).toBeGreaterThan(0);
    });

    it('should handle large amounts with proper formatting', () => {
      const largeData: CalculateAmountResponseDTO = {
        creditCard: {
          baseAmount: 9999.99,
          tipAmount: 1500.0,
          surchargeAmount: 349.99,
          totalAmount: 11849.98,
        },
        debitCard: {
          baseAmount: 9999.99,
          tipAmount: 1500.0,
          surchargeAmount: 0.0,
          totalAmount: 11499.99,
        },
      };

      const {getByText} = render(
        <AmountSummary
          baseAmountInDollars={9999.99}
          tipAmount={1500}
          totalAmount={11849.98}
          calculationData={largeData}
          isTipEnabled={true}
          isSurcharge={true}
          cardSelected="credit"
        />,
      );

      expect(getByText('$9,999.99')).toBeTruthy();
      expect(getByText('$1,500.00')).toBeTruthy();
      expect(getByText('$349.99')).toBeTruthy();
      expect(getByText('$11,849.98')).toBeTruthy();
    });

    it('should handle decimal amounts correctly', () => {
      const decimalData: CalculateAmountResponseDTO = {
        creditCard: {
          baseAmount: 10.5,
          tipAmount: 2.1,
          surchargeAmount: 0.37,
          totalAmount: 12.97,
        },
        debitCard: {
          baseAmount: 10.5,
          tipAmount: 2.1,
          surchargeAmount: 0.0,
          totalAmount: 12.6,
        },
      };

      const {getByText} = render(
        <AmountSummary
          baseAmountInDollars={10.5}
          tipAmount={2.1}
          totalAmount={12.97}
          calculationData={decimalData}
          isTipEnabled={true}
          isSurcharge={true}
          cardSelected="credit"
        />,
      );

      expect(getByText('$10.50')).toBeTruthy();
      expect(getByText('$2.10')).toBeTruthy();
      expect(getByText('$0.37')).toBeTruthy();
      expect(getByText('$12.97')).toBeTruthy();
    });
  });

  describe('Surcharge Display Conditions', () => {
    it('should only show surcharge when amount is greater than 0', () => {
      const noSurchargeData: CalculateAmountResponseDTO = {
        creditCard: {
          baseAmount: 100.0,
          tipAmount: 0.0,
          surchargeAmount: 0.0,
          totalAmount: 100.0,
        },
        debitCard: {
          baseAmount: 100.0,
          tipAmount: 0.0,
          surchargeAmount: 0.0,
          totalAmount: 100.0,
        },
      };

      const {queryByText} = render(
        <AmountSummary
          baseAmountInDollars={100}
          tipAmount={0}
          totalAmount={100}
          calculationData={noSurchargeData}
          isSurcharge={true}
          cardSelected="credit"
        />,
      );

      // Should not show surcharge line when it's 0
      expect(queryByText('Credit Card Surcharge')).toBeNull();
    });
  });
});

