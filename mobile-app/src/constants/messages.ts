export const LOGIN_MESSAGES = {
  ACCOUNT_LOCKED: 'Your account has been locked.',
  INVALID_CREDENTIALS: 'Invalid login credentials',
  TWO_FACTOR_REQUIRED:
    'To use the app, you first need to activate two-factor authentication.',
  PASSWORD_UPDATED: 'Password updated!',
  PROFILE_VALIDATION_FAILED:
    'Profile validation failed, staying on login screen',
  LOADING_REMEMBER_ME: 'Loading...',
} as const;

export const ERROR_MESSAGES = {
  PARSING_TWO_FACTOR_TRUST_ID: 'Error parsing twoFactorTrustId data:',
} as const;

/**
 * Validation messages for form inputs
 * Centralized to ensure consistency across the app
 */
export const VALIDATION_MESSAGES = {
  // Required field messages
  EMAIL_REQUIRED: 'Email is required',
  PASSWORD_REQUIRED: 'Password is required',
  FIELD_REQUIRED: 'This field is Required',

  // Email validation
  EMAIL_INVALID: 'Invalid email formatting.',

  // Password validation
  PASSWORD_MIN_LENGTH: 'Password must be at least 12 characters',
  PASSWORD_MIN_LENGTH_8: 'Password must be at least 8 characters',
  PASSWORD_MIN_LENGTH_3: 'Minimum 3 characters',
  PASSWORD_PREVIOUS: 'The password must not match your 4 previous passwords',

  // Generic error fallback
  CHANGE_PASSWORD_FAILED: 'Failed to change password. Please try again.',
} as const;

/**
 * UI messages for loading states, empty states, etc.
 */
export const UI_MESSAGES = {
  // Loading states
  LOADING: 'Loading...',
  LOADING_SUPPORT: 'Loading support information...',

  // Transaction states
  NO_TRANSACTIONS: 'No recent transactions',
  TRANSACTIONS_TODAY: 'Transactions Today',
  SALES_TODAY: 'Sales Today',

  // Amount visibility
  SHOW_AMOUNTS: 'Show Amounts',
  HIDE_AMOUNTS: 'Hide Amounts',

  // HomeScreen
  LAST_TRANSACTIONS: 'Last Transactions',
  SHOW_ALL: 'Show All',
  NEW_TRANSACTION: 'New Transaction',

  // Common UI actions
  CLOSE: 'Close',

  // Password expiration
  PASSWORD_EXPIRED_TITLE: 'Your password has expired',
  PASSWORD_EXPIRED_MESSAGE:
    'Please create a new password before logging into the ARISE Merchant app.',
  CREATE_NEW_PASSWORD_BUTTON: 'Create a new password',

  ENTER_AMOUNT_PROMPT: 'Amount:',
  SUBTOTAL: 'Subtotal:',

  // Generic fallback
  ERROR_FALLBACK: 'error',
  SELECT_PAYMENT_METHOD: 'Select Payment Method',
} as const;

/**
 * Form labels for consistent input labeling
 */
export const FORM_LABELS = {
  SECURITY_CODE: 'Security Code',
  EXPIRATION_DATE: 'Expiration Date',
  BILLING_ZIP_CODE: 'Billing Address Zip Code',
  EMAIL: 'Email',
} as const;

/**
 * Form placeholders for consistent input guidance
 */
export const FORM_PLACEHOLDERS = {
  // Security code placeholders
  CVV_4_DIGITS: '1234',
  CVV_3_DIGITS: '123',

  // Date placeholders
  EXPIRATION_DATE: 'MM/YY',

  // Address placeholders
  ZIP_CODE: '00000',

  // Email placeholders
  EMAIL: 'Email',
} as const;

/**
 * Additional UI error messages
 */
export const UI_ERROR_MESSAGES = {
  INVALID_CODE: 'Invalid code',
  FAILED_TO_LOAD_TRANSACTIONS: 'Failed to load transactions',
} as const;

/**
 * Navigation and screen titles
 */
export const NAVIGATION_TITLES = {
  LOGIN: 'Login',
  LEGAL_INFORMATION: 'Legal Information',
  PRIVACY_POLICY: 'Privacy Policy',
  TERMS_AND_CONDITIONS: 'Terms and Conditions',
  TRANSACTION_HISTORY: 'Transaction History',
  SUPPORT: 'Support',
  BACK_TO_LOGIN: 'Back to Login',
  NEW_TRANSACTION: 'New Transaction',
} as const;

/**
 * Support screen messages
 */
export const SUPPORT_MESSAGES = {
  QUESTIONS_TITLE: 'Do you have any questions?',
  CONTACT_DESCRIPTION: 'Contact us and we will be happy to help you.',
  EMAIL_LABEL: 'Email:',
  PHONE_LABEL: 'Phone:',
  EMAIL_US_BUTTON: 'Email Us',
  COPIED_TO_CLIPBOARD: 'Copied to clipboard',
  UNABLE_TO_LOAD_SUPPORT:
    'Unable to load current support information. Using default contact details.',
} as const;

/**
 * Feedback and experience messages
 */
export const FEEDBACK_MESSAGES = {
  EXPERIENCE_TITLE: 'How has been your experience?',
  FEEDBACK_DESCRIPTION: 'Tell us what went well — or what could be better.',
  LEAVE_FEEDBACK_BUTTON: 'Leave Feedback',
} as const;

/**
 * Transaction related messages
 */
export const TRANSACTION_MESSAGES = {
  NO_RECENT_TRANSACTIONS: 'No recent transactions',
  NO_MORE_TRANSACTIONS: 'No more transactions to load',
} as const;

/**
 * Alert and notification messages
 */
export const ALERT_MESSAGES = {
  // Access control
  ACCESS_DENIED: 'Access Denied',
  MERCHANT_ONLY: 'This application is intended for merchant users only',
  NO_ACTIVE_ACCOUNT: 'You are not associated with any active account',
  GENERAL_ERROR: 'An error occurred. Please try again.',

  // Error states
  EMAIL_APP_ERROR: 'Unable to open email app',
  PHONE_CALL_ERROR: 'Unable to make phone call',
  SUPPORT_INFO_ERROR:
    'Unable to load current support information. Using default contact details.',

  // Transaction errors
  INVALID_AMOUNT: 'Please enter a valid dollar amount',
  MAX_AMOUNT_EXCEEDED: 'Max. Amount - $',
  MAX_AMOUNT_EXCEEDED_CODE: '(AT2-3301)',

  // Success messages
  COPIED_TO_CLIPBOARD: 'Copied to clipboard',
} as const;

/**
 * Keyed transaction screen messages
 * Text constants for the manual card entry screen
 */
export const KEYED_TRANSACTION_MESSAGES = {
  // Screen titles
  TITLE: 'Manual Entry',
  TITLE_DECLINED: 'Payment Declined',
  DECLINED: 'Declined',
  TITLE_SUCCESS: 'All Done!',
  TITLE_FAILED: 'Failed',

  // Screen subtitles
  SUBTITLE_SUCCESS: 'The transaction has been processed.',
  SUBTITLE_FAILED: 'Payment processor failed to handle request.',

  // Form labels and placeholders
  CARD_NUMBER_LABEL: 'Card Number',
  CARD_NUMBER_PLACEHOLDER: '1234 5678 9987 6543',

  // Field labels (common across success/failed screens)
  TRANSACTION_ID: 'Transaction ID',
  PAYMENT_METHOD: 'Payment Method',
  APPROVAL_CODE: 'Approval Code',
  BASE_AMOUNT: 'Base Amount',

  // Payment method text
  CREDIT_PREFIX: 'Credit',

  // Error messages
  BIN_ERROR_MESSAGE:
    'The inputted BIN cannot be identified as either debit or credit. Please use a different card.',
  PAYMENT_PROCESSOR_ERROR: 'Please add a card processor.',

  // Alert messages - using function for dynamic content
  SURCHARGE_ALERT_MESSAGE: (rate: number) =>
    `Additional ${rate}% Credit Card Surcharge will be added to this payment.`,

  // Fallback values
  TRANSACTION_ID_FALLBACK: 'N/A',
  ERROR_CODE_LABEL: 'Code:',
  ERROR_CODE_FALLBACK: '500',

  // Button labels
  BACK_BUTTON: 'Back',
  CONFIRM_BUTTON: 'Confirm Payment',
  CONTINUE_BUTTON: 'Continue',
  VIEW_RECEIPT_BUTTON: 'View Receipt',
  HOME_BUTTON: 'Home',
  RETRY_TRANSACTION_BUTTON: 'Retry Transaction',
  RETRY_BUTTON: 'Try Again',
  CANCEL_BUTTON: 'Cancel',

  // Payment Overview messages (from PAYMENT_OVERVIEW_MESSAGES)
  PAYMENT_OVERVIEW_TITLE: 'Payment Overview',
  PAYMENT_OVERVIEW_SUBTITLE: 'Please check and confirm',
  PROCESSING_TITLE: 'Processing...',
  PROCESSING_SUBTITLE: "Just a moment — we're almost there.",
  EXPIRATION_DATE_LABEL: 'Exp. Date',
  ZIP_CODE_LABEL: 'Zip Code',
  AMOUNT_LABEL: 'Amount',
  SURCHARGE_LABEL: 'Credit Card Surcharge',
  TOTAL_AMOUNT_LABEL: 'Total Amount',
  TIP_LABEL: 'Tip',
  EXTERNAL_ID_LABEL: 'External ID',
} as const;

export const TRANSACTION_DETAIL_MESSAGES = {
  TRANSACTION_ID: 'Transaction ID',
  APPROVAL_CODE: 'Approval Code',
  TRANSACTION_TYPE: 'Transaction Type',
  TRANSACTION_STATUS: 'Status',
  PAYMENT_METHOD: 'Payment Method',
  READING_METHOD: 'Reading Method',
  TOTAL_AMOUNT: 'Total Amount',
  AMOUNT_REFUNDED: 'Amount Refunded',
  VIEW_RECEIPT_BUTTON: 'View Receipt',
  CAPTURE_BUTTON: 'Capture',
  VOID_BUTTON: 'Void',
  REFUND_BUTTON: 'Refund',
  CANCEL_BUTTON: 'Cancel',
  VOID_CONFIRM_TITLE: 'Void Transaction?',
  VOID_CONFIRM_SUBTITLE: 'Customer will not be charged for this payment.',
  VOID_ERROR: 'Unable to void transaction. Please try again',
  TRANSACTION_DETAILS_ERROR:
    'Unable to load transaction details. Please try again.',
  REFUNDED_TRANSACTION: 'Transaction is already refunded.',
  TITLE_REFUND_TRANSACTION: 'Refund',
  ENTER_AMOUNT_PROMPT_REFUND: 'Amount to Refund:',
  CONFIRM_REFUND_BUTTON: 'Confirm Refund',
  FAILED_TO_REFUND: 'Failed to refund transaction.',
  TITLE_CAPTURE_TRANSACTION: 'Capture',
  ENTER_AMOUNT_PROMPT_CAPTURE: 'Amount to Capture:',
  CONFIRM_CAPTURE_BUTTON: 'Capture',
  FAILED_FALLBACK: 'Failed to perform transaction.',
  ACCOUNT_NUMBER: 'Account Number',
  AMOUNT_CREDITED: 'Amount Credited',
  EXTERNAL_ID_LABEL: 'External ID',
} as const;

/**
 * Tap to Pay messages
 */
export const TAP_TO_PAY_MESSAGES = {
  SPLASH_DISCLAIMER_MANAGER:
    'Tap to Pay fee: $0.10 per transaction. Some contactless cards may not be accepted. Transaction limits may apply. The Contactless Symbol is a trademark owned by and used with permission of EMVCo, LLC.',
  SPLASH_DISCLAIMER_NON_MANAGER:
    'Some contactless cards may not be accepted. Transaction limits may apply. The Contactless Symbol is a trademark owned by and used with permission of EMVCo, LLC.',
} as const;
