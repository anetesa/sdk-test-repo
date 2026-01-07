import {useTransactionStore} from '@/stores/transactionStore';
import {useEffect, useState} from 'react';
import {formatAmountForDisplay} from '../utils/currency';

const MAX_AMOUNT_LENGTH = 10;

export const useAmountInput = (defaultAmount = '') => {
  const setAmount = useTransactionStore(state => state.setAmount);
  const [amount, setInternalAmount] = useState(defaultAmount);

  const handleNumberPress = (number: number) => {
    setInternalAmount(prevAmount => {
      if (prevAmount.length >= MAX_AMOUNT_LENGTH) {
        return prevAmount;
      }
      return prevAmount + number;
    });
  };

  const handleBackspace = () => {
    setInternalAmount(prevAmount => prevAmount.slice(0, -1));
  };

  const handleTextInput = (input: string) => {
    const newAmount = input.replace(/[^0-9]/g, '');
    if (newAmount.length <= MAX_AMOUNT_LENGTH) {
      setInternalAmount(newAmount);
    } else {
      setInternalAmount(newAmount.slice(0, MAX_AMOUNT_LENGTH));
    }
  };

  const isAmountEntered = amount.length > 0;
  const numericAmount = parseInt(amount, 10) || 0;
  const displayAmount = formatAmountForDisplay({cents: numericAmount});

  // set amount in transaction store
  useEffect(() => {
    setAmount(numericAmount);
  }, [numericAmount, setAmount]);

  return {
    amount: numericAmount,
    rawAmount: amount,
    displayAmount,
    isAmountEntered,
    handleNumberPress,
    handleBackspace,
    handleTextInput,
  };
};
