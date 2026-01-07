/**
 * Centralized query keys for React Query
 * This helps with cache invalidation, debugging, and consistency
 */
export const QUERY_KEYS = {
  // Settings and configuration
  SETTINGS: ['settings'],
  API_SETTINGS: ['settings'],
  PAYMENT_PROCESSORS: ['paymentProcessors'],
  SETTINGS_AUTOFILL: ['settingsAutofill'],

  // User and profile related
  ME_PROFILE: ['meProfile'],

  // Transactions
  TRANSACTIONS_TODAY: ['transactions-today'],
  SALES_TODAY: ['sales-today'],
  DASHBOARD_TRANSACTIONS: ['dashboardTransactions'],
  INFINITE_DASHBOARD_TRANSACTIONS: ['infiniteDashboardTransactions'],
  TRANSACTION_BIN_DATA: 'transactionBinData',

  // Merchant related
  MERCHANT_SETTINGS: 'merchantSettings',
  MERCHANT_FEATURES: 'merchantFeatures',

  // Support
  TECH_SUPPORT: ['techSupport'],
} as const;

/**
 * Helper functions to create parameterized query keys
 */
export const createQueryKey = {
  settingsAutofill: (merchantId: string) => [
    QUERY_KEYS.SETTINGS_AUTOFILL,
    merchantId,
  ],

  paymentProcessors: (merchantId: string) => [
    QUERY_KEYS.PAYMENT_PROCESSORS,
    merchantId,
  ],

  /**
   * Creates a query key for merchant settings with merchantId
   */
  merchantSettings: (merchantId: string) => [
    QUERY_KEYS.MERCHANT_SETTINGS,
    merchantId,
  ],

  /**
   * Creates a query key for merchant features with merchantId
   */
  merchantFeatures: (merchantId: string) => [
    QUERY_KEYS.MERCHANT_FEATURES,
    merchantId,
  ],

  /**
   * Creates a query key for transaction bin data
   */
  transactionBinData: (binData: string) => [
    QUERY_KEYS.TRANSACTION_BIN_DATA,
    binData,
  ],

  /**
   * Creates a query key for dashboard transactions with parameters
   */
  dashboardTransactions: (
    page?: number,
    pageSize?: number,
    asc?: boolean,
    orderBy?: string,
  ) => [QUERY_KEYS.DASHBOARD_TRANSACTIONS, page, pageSize, asc, orderBy],

  /**
   * Creates a query key for infinite dashboard transactions with parameters
   */
  infiniteDashboardTransactions: (
    pageSize?: number,
    asc?: boolean,
    orderBy?: string,
  ) => [QUERY_KEYS.INFINITE_DASHBOARD_TRANSACTIONS, pageSize, asc, orderBy],
} as const;
