/**
 * Card masking and display constants
 */
export const CARD_DISPLAY = {
  LAST_DIGITS_COUNT: 4, // Number of last digits to show in masked PAN
  MASK_PATTERN: '**** ', // Pattern for masked digits
  MASK_SEPARATOR: ' ', // Separator between mask and visible digits
} as const;

/**
 * Card expiration date processing
 */
export const EXPIRATION_DATE = {
  YEAR_PREFIX: '20', // Prefix to add to 2-digit year (YY -> 20YY)
  PARSE_BASE: 10, // Base for parseInt operations
  DATE_SEPARATOR: '/', // Separator in MM/YY format
  MONTH_INDEX: 0, // Index of month in split array
  YEAR_INDEX: 1, // Index of year in split array
} as const;

/**
 * Default values for card processing
 */
export const CARD_DEFAULTS = {
  ZERO_VALUE: 0, // Default numeric value
  EMPTY_STRING: '', // Default string value
  MINIMUM_LENGTH: 4, // Minimum length for card operations
} as const;

/**
 * Card validation rules
 */
export const CARD_VALIDATION = {
  MIN_PAN_LENGTH: 13, // Minimum PAN length
  MAX_PAN_LENGTH: 19, // Maximum PAN length
  CVV_LENGTH_3: 3, // Standard CVV length
  CVV_LENGTH_4: 4, // American Express CVV length
  EXPIRY_MONTH_MIN: 1, // Minimum expiry month
  EXPIRY_MONTH_MAX: 12, // Maximum expiry month
} as const;

/**
 * Card input and processing rules
 * Constants for card input validation and BIN processing
 */
export const CARD_INPUT_RULES = {
  MIN_DIGITS_FOR_BIN: 12, // Minimum digits required for BIN lookup
  MAX_INPUT_LENGTH: 19, // Maximum card number input length
  CREDIT_CARD_TYPE_ID: 1, // BinDataType.Credit ID value
} as const;

/**
 * Type definitions for card validation
 */
export type CardDisplayType = (typeof CARD_DISPLAY)[keyof typeof CARD_DISPLAY];
export type ExpirationDateType =
  (typeof EXPIRATION_DATE)[keyof typeof EXPIRATION_DATE];
