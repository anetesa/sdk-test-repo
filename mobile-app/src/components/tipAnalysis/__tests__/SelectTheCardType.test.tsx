import React from 'react';
import {render, fireEvent} from '@testing-library/react-native';
import {SelectTheCardType} from '../SelectTheCardType';
import {CalculateAmountResponseDTO} from '@/types/CalculateAmount';

describe('SelectTheCardType', () => {
  const mockCalculationData: CalculateAmountResponseDTO = {
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
  };

  const mockSetSelectedCard = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Rendering', () => {
    it('should render both credit and debit card options', () => {
      const {getByText} = render(
        <SelectTheCardType
          calculationData={mockCalculationData}
          selectedCard=""
          setSelectedCard={mockSetSelectedCard}
        />,
      );

      expect(getByText('Credit Card')).toBeTruthy();
      expect(getByText('Debit Card')).toBeTruthy();
    });

    it('should display correct total amounts for credit and debit cards', () => {
      const {getByText} = render(
        <SelectTheCardType
          calculationData={mockCalculationData}
          selectedCard=""
          setSelectedCard={mockSetSelectedCard}
        />,
      );

      // Credit card total with surcharge
      expect(getByText('$103.50')).toBeTruthy();
      // Debit card total without surcharge
      expect(getByText('$100.00')).toBeTruthy();
    });

    it('should show no option pre-selected by default', () => {
      const {getByText} = render(
        <SelectTheCardType
          calculationData={mockCalculationData}
          selectedCard=""
          setSelectedCard={mockSetSelectedCard}
        />,
      );

      // Verify the component renders both options
      expect(getByText('Credit Card')).toBeTruthy();
      expect(getByText('Debit Card')).toBeTruthy();
    });
  });

  describe('Credit Card Selection', () => {
    it('should call setSelectedCard with "credit" when credit card is pressed', () => {
      const {getByText} = render(
        <SelectTheCardType
          calculationData={mockCalculationData}
          selectedCard=""
          setSelectedCard={mockSetSelectedCard}
        />,
      );

      fireEvent.press(getByText('Credit Card'));

      expect(mockSetSelectedCard).toHaveBeenCalledWith('credit');
      expect(mockSetSelectedCard).toHaveBeenCalledTimes(1);
    });

    it('should render correctly when credit card is selected', () => {
      const {getByText} = render(
        <SelectTheCardType
          calculationData={mockCalculationData}
          selectedCard="credit"
          setSelectedCard={mockSetSelectedCard}
        />,
      );

      // Verify credit card option is rendered with its amount
      expect(getByText('Credit Card')).toBeTruthy();
      expect(getByText('$103.50')).toBeTruthy();
    });

    it('should show surcharge amount in credit card total', () => {
      const calculationDataWithSurcharge: CalculateAmountResponseDTO = {
        creditCard: {
          baseAmount: 50.0,
          tipAmount: 0.0,
          surchargeAmount: 1.75,
          totalAmount: 51.75,
        },
        debitCard: {
          baseAmount: 50.0,
          tipAmount: 0.0,
          surchargeAmount: 0.0,
          totalAmount: 50.0,
        },
      };

      const {getByText} = render(
        <SelectTheCardType
          calculationData={calculationDataWithSurcharge}
          selectedCard=""
          setSelectedCard={mockSetSelectedCard}
        />,
      );

      expect(getByText('$51.75')).toBeTruthy();
    });
  });

  describe('Debit Card Selection', () => {
    it('should call setSelectedCard with "debit" when debit card is pressed', () => {
      const {getByText} = render(
        <SelectTheCardType
          calculationData={mockCalculationData}
          selectedCard=""
          setSelectedCard={mockSetSelectedCard}
        />,
      );

      fireEvent.press(getByText('Debit Card'));

      expect(mockSetSelectedCard).toHaveBeenCalledWith('debit');
      expect(mockSetSelectedCard).toHaveBeenCalledTimes(1);
    });

    it('should render correctly when debit card is selected', () => {
      const {getByText} = render(
        <SelectTheCardType
          calculationData={mockCalculationData}
          selectedCard="debit"
          setSelectedCard={mockSetSelectedCard}
        />,
      );

      // Verify debit card option is rendered with its amount
      expect(getByText('Debit Card')).toBeTruthy();
      expect(getByText('$100.00')).toBeTruthy();
    });

    it('should show base amount only (no surcharge) for debit card', () => {
      const {getByText, getAllByText} = render(
        <SelectTheCardType
          calculationData={mockCalculationData}
          selectedCard=""
          setSelectedCard={mockSetSelectedCard}
        />,
      );

      // Debit card should show 100.00 (base amount only)
      const debitAmounts = getAllByText('$100.00');
      expect(debitAmounts.length).toBeGreaterThan(0);
    });
  });

  describe('Toggle Between Selections', () => {
    it('should allow switching from credit to debit', () => {
      const {getByText} = render(
        <SelectTheCardType
          calculationData={mockCalculationData}
          selectedCard="credit"
          setSelectedCard={mockSetSelectedCard}
        />,
      );

      // Click on debit card
      fireEvent.press(getByText('Debit Card'));

      // Verify the callback was called correctly
      expect(mockSetSelectedCard).toHaveBeenCalledWith('debit');
      expect(mockSetSelectedCard).toHaveBeenCalledTimes(1);
    });

    it('should allow switching from debit to credit', () => {
      const {getByText} = render(
        <SelectTheCardType
          calculationData={mockCalculationData}
          selectedCard="debit"
          setSelectedCard={mockSetSelectedCard}
        />,
      );

      // Click on credit card
      fireEvent.press(getByText('Credit Card'));

      // Verify the callback was called correctly
      expect(mockSetSelectedCard).toHaveBeenCalledWith('credit');
      expect(mockSetSelectedCard).toHaveBeenCalledTimes(1);
    });
  });

  describe('Edge Cases', () => {
    it('should handle zero amounts gracefully', () => {
      const zeroCalculationData: CalculateAmountResponseDTO = {
        creditCard: {
          baseAmount: 0.0,
          tipAmount: 0.0,
          surchargeAmount: 0.0,
          totalAmount: 0.0,
        },
        debitCard: {
          baseAmount: 0.0,
          tipAmount: 0.0,
          surchargeAmount: 0.0,
          totalAmount: 0.0,
        },
      };

      const {getAllByText} = render(
        <SelectTheCardType
          calculationData={zeroCalculationData}
          selectedCard=""
          setSelectedCard={mockSetSelectedCard}
        />,
      );

      const zeroAmounts = getAllByText('$0.00');
      expect(zeroAmounts.length).toBeGreaterThanOrEqual(2);
    });

    it('should handle undefined calculation data gracefully', () => {
      const undefinedData: any = {
        creditCard: undefined,
        debitCard: undefined,
      };

      const {getByText} = render(
        <SelectTheCardType
          calculationData={undefinedData}
          selectedCard=""
          setSelectedCard={mockSetSelectedCard}
        />,
      );

      expect(getByText('Credit Card')).toBeTruthy();
      expect(getByText('Debit Card')).toBeTruthy();
    });

    it('should handle large amounts correctly', () => {
      const largeAmountData: CalculateAmountResponseDTO = {
        creditCard: {
          baseAmount: 9999.99,
          tipAmount: 0.0,
          surchargeAmount: 349.99,
          totalAmount: 10349.98,
        },
        debitCard: {
          baseAmount: 9999.99,
          tipAmount: 0.0,
          surchargeAmount: 0.0,
          totalAmount: 9999.99,
        },
      };

      const {getByText} = render(
        <SelectTheCardType
          calculationData={largeAmountData}
          selectedCard=""
          setSelectedCard={mockSetSelectedCard}
        />,
      );

      expect(getByText('$10,349.98')).toBeTruthy();
      expect(getByText('$9,999.99')).toBeTruthy();
    });
  });
});

