import {useState, useMemo} from 'react';
import {useTransactionCalculateAmount} from '@/hooks/queries/useTransactionCalculateAmount';
import {usePaymentsSettings} from '@/hooks/queries/usePaymentsSettings';

interface TipOption {
  id: string;
  label: string;
  percentage: number;
}

interface UseTipCalculationProps {
  baseAmountInDollars: number;
}

interface UseTipCalculationReturn {
  tipOptions: TipOption[];
  selectedTipId: string;
  customTipAmount: number;
  showCustomValue: boolean;
  tipAmount: number;
  totalAmount: number;
  calculationData: any;
  isLoading: boolean;
  isError: boolean;
  error: unknown;
  hasTipSelection: boolean;
  handleTipOptionPress: (tipId: string) => void;
  handleCustomValuePress: () => void;
  setCustomTipAmount: (amount: number) => void;
}

export const useTipCalculation = ({
  baseAmountInDollars,
}: UseTipCalculationProps): UseTipCalculationReturn => {
  const {data: paymentSettings} = usePaymentsSettings();

  const {defaultSurchargeRate, isDualPricingEnabled, defaultTipsOptions} =
    paymentSettings || {};

  const [selectedTipId, setSelectedTipId] = useState<string>('');
  const [customTipAmount, setCustomTipAmount] = useState<number>(0);
  const [showCustomValue, setShowCustomValue] = useState<boolean>(false);

  // Get merchant settings for backend calculation
  const surchargeRate = defaultSurchargeRate || undefined;
  /*
   ARISE-1179:Transaction should always use "Card Price"
  */
  const useCardPrice = isDualPricingEnabled ? true : undefined;

  // Get tip options from merchant settings only - don't show defaults
  const tipOptions = useMemo(() => {
    if (defaultTipsOptions?.length) {
      const settingsTips = defaultTipsOptions.map(
        (percentage: number, index: number) => ({
          id: `tip-${index}`,
          label: `${Math.round(percentage)}%`,
          percentage: percentage / 100, // Convert percentage to decimal for calculations
        }),
      );

      return [{id: 'no-tip', label: 'No Tip', percentage: 0}, ...settingsTips];
    }
    // Return empty array if merchant settings not loaded yet
    return [];
  }, [defaultTipsOptions]);

  // Calculate current tip amount for backend call
  const currentTipAmount = useMemo(() => {
    if (showCustomValue) {
      return customTipAmount / 100; // Convert cents to dollars for backend
    }

    const selectedOption = tipOptions.find(
      option => option.id === selectedTipId,
    );
    if (!selectedOption) {
      return 0;
    }

    return baseAmountInDollars * selectedOption.percentage; // Dollars for backend
  }, [
    selectedTipId,
    customTipAmount,
    baseAmountInDollars,
    tipOptions,
    showCustomValue,
  ]);

  // Call backend calculation service
  const {
    data: calculationData,
    isLoading,
    isError,
    error,
  } = useTransactionCalculateAmount({
    amount: baseAmountInDollars,
    surchargeRate,
    tipAmount: currentTipAmount,
    useCardPrice,
    currencyId: 1, // USD
  });

  // Extract tip amount and total from backend response (keep in dollars)
  const tipAmount = calculationData?.creditCard?.tipAmount ?? 0;
  const totalAmount =
    calculationData?.creditCard?.totalAmount ?? baseAmountInDollars;

  // Check if user has made a valid tip selection
  const hasTipSelection = useMemo(() => {
    if (showCustomValue) {
      // Custom value must be greater than 0
      return customTipAmount > 0;
    }
    // Predefined option must be selected
    return selectedTipId !== '' && selectedTipId !== null;
  }, [showCustomValue, customTipAmount, selectedTipId]);

  const handleTipOptionPress = (tipId: string) => {
    setSelectedTipId(tipId);
    setShowCustomValue(false);
    setCustomTipAmount(0);
  };

  const handleCustomValuePress = () => {
    if (showCustomValue) {
      // Switching back to predefined values
      setShowCustomValue(false);
      setSelectedTipId(''); // Clear selection - no default tip
      setCustomTipAmount(0); // Reset custom tip amount
    } else {
      // Switching to custom mode
      setShowCustomValue(true);
      setSelectedTipId(''); // Clear selected tip ID
      setCustomTipAmount(0); // Reset custom tip amount when switching to custom mode
    }
  };

  return {
    tipOptions,
    selectedTipId,
    customTipAmount,
    showCustomValue,
    tipAmount,
    totalAmount,
    calculationData,
    isLoading,
    isError,
    error,
    handleTipOptionPress,
    handleCustomValuePress,
    setCustomTipAmount,
    hasTipSelection,
  };
};
