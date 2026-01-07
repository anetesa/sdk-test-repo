import {KEYED_TRANSACTION_MESSAGES} from '@/constants/messages';

/**
 * Transaction utility functions
 */

/**
 * Calculates the number of transactions to display based on feature flags
 *
 * Business rules:
 * - No features enabled: 5 transactions
 * - Only new transaction enabled: 4 transactions
 * - Only feedback enabled: 4 transactions (default fallback)
 * - Both features enabled: 2 transactions
 */
export const getTransactionCount = (
  isPendoFeedbackOn: boolean,
  isNewTransactionOn: boolean,
  isProMaxScreen: boolean,
): number => {
  if (!isPendoFeedbackOn && !isNewTransactionOn) {
    return isProMaxScreen ? 6 : 5;
  }
  if (!isPendoFeedbackOn && isNewTransactionOn) {
    return 4;
  }
  if (isPendoFeedbackOn && isNewTransactionOn) {
    return isProMaxScreen ? 3 : 2;
  }
  return 4; // default fallback: only feedback enabled
};

export const getFirstPartTransactionId = (transactionId: string) => {
  return (
    transactionId?.slice(0, 8) ||
    KEYED_TRANSACTION_MESSAGES.TRANSACTION_ID_FALLBACK
  );
};
