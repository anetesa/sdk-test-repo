/**
 * Country constants
 * Centralized country identifiers and related data
 */

/**
 * Country IDs used in the API
 * These IDs correspond to the backend country identifiers
 */
export const COUNTRY_IDS = {
  USA: 1, // United States of America
  CANADA: 2, // Canada (example - add as needed)
  // Add more countries as they become supported
} as const;

/**
 * Default country settings
 */
export const COUNTRY_DEFAULTS = {
  DEFAULT_COUNTRY_ID: COUNTRY_IDS.USA, // Default country for transactions
  DEFAULT_COUNTRY_CODE: 'US', // Default country code
} as const;

/**
 * Type definitions for country usage
 */
export type CountryId = (typeof COUNTRY_IDS)[keyof typeof COUNTRY_IDS];
export type CountryCode = string;
