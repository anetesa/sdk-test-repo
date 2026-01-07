/**
 * Navigation route constants
 * Centralized route names to ensure consistency and prevent typos
 */
export const ROUTES = {
  // Authentication
  LOGIN: 'Login',
  RESET_PASSWORD: 'ResetPassword',
  PASSWORD_LINK_SENT: 'PasswordLinkSent',
  CHANGE_PASSWORD: 'ChangePassword',
  CHANGE_PASSWORD_FORM: 'ChangePasswordForm',
  MFA: 'MFA',

  // Main App
  HOME: 'Home',
  SETTINGS: 'Settings',
  MERCHANT_SELECTION: 'MerchantSelection',
  TAP_TO_PAY_SPLASH: 'TapToPaySplash',

  // Transactions
  NEW_TRANSACTION: 'NewTransaction',
  TRANSACTION_LIST: 'TransactionList',
  TRANSACTION_DETAIL: 'TransactionDetail',
  PAYMENT_RECEIPT: 'PaymentReceipt',

  // Testing/Development
  TEST_MASTER_CART_TAP_TO_PAY: 'TestMasterCartTapToPayScreen',

  // Support
  CONTACT_SUPPORT: 'ContactSupport',
  UNAUTHENTICATED_CONTACT_SUPPORT: 'UnauthenticatedContactSupport',

  // Legal
  TERMS_AND_CONDITIONS: 'TermsAndConditions',
  PRIVACY_POLICY: 'PrivacyPolicy',
  LEGAL_INFORMATION: 'LegalInformation',
} as const;

/**
 * Screen names for nested navigation
 * Sub-screen identifiers within stack navigators
 */
export const SCREEN_NAMES = {
  // New Transaction screens
  ENTER_AMOUNT: 'EnterAmount',
  CHOOSE_METHOD: 'ChooseMethod',
  KEYED_TRANSACTION: 'KeyedTransaction',
  PAYMENT_OVERVIEW: 'PaymentOverview',
  PAYMENT_SUCCESS: 'PaymentSuccess',
  PAYMENT_FAILED: 'PaymentFailed',
  PAYMENT_DECLINED: 'PaymentDeclined',
  VALIDATION_ERROR: 'ValidationError',
  LOADING_TAP_TO_PAY: 'LoadingTapToPay',
  ZCP_TIPS_ANALYSIS: 'ZCPTipsAnalysis',
} as const;

/**
 * Type for route names to ensure type safety
 */
export type RouteNames = (typeof ROUTES)[keyof typeof ROUTES];
