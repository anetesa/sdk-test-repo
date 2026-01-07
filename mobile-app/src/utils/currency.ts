// Constants for currency conversion
const CENTS_PER_DOLLAR = 100;

type FormatAmountOptions = {
  cents?: number | undefined | null;
  dollars?: number | undefined | null;
};

/**
 * Formats an amount stored as cents for display to users
 * @param cents - Amount in cents (e.g., 150 represents $1.50)
 * @param dollars - Amount in dollars (e.g., 1.50 represents $1.50)
 * @returns Formatted string for display (e.g., "1.50")
 */
export const formatAmountForDisplay = ({
  cents,
  dollars,
}: FormatAmountOptions): string => {
  if (cents !== undefined && cents !== null) {
    return new Intl.NumberFormat('en-US', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    }).format(cents / CENTS_PER_DOLLAR);
  }

  if (dollars !== undefined && dollars !== null) {
    return new Intl.NumberFormat('en-US', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    }).format(dollars);
  }

  return '0.00';
};

/**
 * Converts an amount stored as cents to decimal format for server API
 * @param amountInCents - Amount in cents (e.g., 150 represents $1.50)
 * @returns Decimal number for API (e.g., 1.5)
 */
export const formatAmountForSentToTheServer = (
  amountInCents: number | undefined | null,
): number => {
  if (amountInCents === undefined || amountInCents === null) {
    return 0;
  }

  return amountInCents / CENTS_PER_DOLLAR;
};

// convert dollar amount to cents
export const convertDollarAmountToCents = (amount: number): number => {
  return amount * CENTS_PER_DOLLAR;
};
