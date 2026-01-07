// CloudCommerce SDK Error Mappings
// Based on CloudCommerce iOS SDK Error Codes Documentation

export interface CloudCommerceErrorInfo {
  title: string;
  message: string;
  errorCodeMessage?: string;
}

export const CLOUD_COMMERCE_ERROR_MAPPINGS: Record<
  string,
  CloudCommerceErrorInfo
> = {
  // Device and GPS Errors
  DEV003: {
    title: 'Device Not Supported',
    message:
      'This device does not support Tap to Pay on iPhone. Currently requires iPhone Xs or later.',
    errorCodeMessage: 'DEV003',
  },

  GPS003: {
    title: 'Location Service Required',
    message:
      'Device could not be located. Please move to a location where GPS signal can be received and try again.',
    errorCodeMessage: 'GPS003',
  },

  GPS004: {
    title: 'Service Not Available',
    message: 'Merchant is not allowed to operate in the current country',
    errorCodeMessage: 'GPS004',
  },

  GPS005: {
    title: 'Service Not Available',
    message: 'Partner is not allowed to operate in the current country.',
    errorCodeMessage: 'GPS005',
  },

  GPS006: {
    title: 'Location Service Required',
    message:
      'Device could not be located. Please move to a location where GPS signal can be received and try again.',
    errorCodeMessage: 'GPS006',
  },

  // General Errors
  GEN003: {
    title: 'Something went wrong',
    message:
      'There was a problem when validating the transaction information. Please verify the payment details and try again.',
    errorCodeMessage: 'V0000',
  },

  //Generic message for backend errors, like a duplicated transaction.
  UNKNOWN_ERROR: {
    title: 'Something went wrong',
    message:
      'There was a problem when validating the transaction information. Please verify the payment details and try again.',
    errorCodeMessage: 'V0000',
  },

  // Reader Errors
  READER023: {
    title: 'Connection Issue',
    message:
      'Unable to connect to the payment reader. Please try again or use a different payment method.',
    errorCodeMessage: 'READER023',
  },

  // Attestation Errors
  ATT018: {
    title: 'Connection Error',
    message:
      'Unable to connect to server. Please check your internet connection and try again later.',
    errorCodeMessage: 'ATT018',
  },

  ATT019: {
    title: 'App Configuration Error',
    message:
      'The app is missing required configuration. Please reinstall the app or contact customer support.',
    errorCodeMessage: 'ATT019',
  },

  ATT020: {
    title: 'App Configuration Error',
    message:
      'The app is missing required bundle identifier. Please reinstall the app or contact customer support.',
    errorCodeMessage: 'ATT020',
  },

  ATT021: {
    title: 'Authentication Failed',
    message:
      'Authentication failed. Please try logging out and logging back in, or reinstall the app.',
    errorCodeMessage: 'ATT021',
  },

  ATT022: {
    title: 'Authentication Failed',
    message:
      'Authentication failed. Please try logging out and logging back in, or reinstall the app.',
    errorCodeMessage: 'ATT022',
  },

  ATT023: {
    title: 'Authentication Failed',
    message:
      'Authentication failed. Please try logging out and logging back in, or reinstall the app.',
    errorCodeMessage: 'ATT023',
  },

  ATT024: {
    title: 'Authentication Failed',
    message:
      'Authentication failed. Please try logging out and logging back in, or reinstall the app.',
    errorCodeMessage: 'ATT024',
  },

  // Data Errors
  DATA001: {
    title: 'Data Not Found',
    message:
      'The requested information was not found. Please try again or contact customer support.',
    errorCodeMessage: 'DATA001',
  },

  DATA002: {
    title: 'Invalid Request',
    message:
      'There was an issue with the request. Please try again or contact customer support.',
    errorCodeMessage: 'DATA002',
  },

  DATA003: {
    title: 'Invalid Request',
    message:
      'There was an issue with the request format. Please try again or contact customer support.',
    errorCodeMessage: 'DATA003',
  },

  DATA005: {
    title: 'Access Denied',
    message:
      'Access to this feature is denied. Please contact customer support for assistance.',
    errorCodeMessage: 'DATA005',
  },

  DATA008: {
    title: 'Storage Error',
    message: 'Error storing information. Please try again after some time.',
    errorCodeMessage: 'DATA008',
  },

  DATA009: {
    title: 'Storage Error',
    message: 'Error removing information. Please try again after some time.',
    errorCodeMessage: 'DATA009',
  },

  DATA010: {
    title: 'System Error',
    message: 'An unexpected error occurred. Please try again after some time.',
    errorCodeMessage: 'DATA010',
  },

  DATA011: {
    title: 'Invalid Data',
    message:
      'Missing required information. Please try again or contact customer support.',
    errorCodeMessage: 'DATA011',
  },

  DATA012: {
    title: 'Invalid Data',
    message:
      'Unexpected data format encountered. Please try again or contact customer support.',
    errorCodeMessage: 'DATA012',
  },

  // Cryptography Errors
  CRYPTO001: {
    title: 'System Error',
    message:
      'Something went wrong on our end. Please try again after some time.',
    errorCodeMessage: 'CRYPTO001',
  },

  CRYPTO002: {
    title: 'System Error',
    message:
      'Something went wrong on our end. Please try again after some time.',
    errorCodeMessage: 'CRYPTO002',
  },

  CRYPTO003: {
    title: 'System Error',
    message:
      'Something went wrong on our end. Please try again after some time.',
    errorCodeMessage: 'CRYPTO003',
  },

  CRYPTO004: {
    title: 'System Error',
    message:
      'Something went wrong on our end. Please try again after some time.',
    errorCodeMessage: 'CRYPTO004',
  },

  CRYPTO005: {
    title: 'System Error',
    message:
      'Something went wrong on our end. Please try again after some time.',
    errorCodeMessage: 'CRYPTO005',
  },

  CRYPTO006: {
    title: 'System Error',
    message:
      'Something went wrong on our end. Please try again after some time.',
    errorCodeMessage: 'CRYPTO006',
  },

  // Security Errors
  SEC005: {
    title: 'System Error',
    message:
      'Sorry, something went wrong at our end. Please try again after some time.',
    errorCodeMessage: 'SEC005',
  },

  SEC008: {
    title: 'Security Concern',
    message:
      'A potential security concern has been identified. Please install the application on another device or contact customer support.',
    errorCodeMessage: 'SEC008',
  },

  SEC001: {
    title: 'Session Expired',
    message: 'Your authentication session has expired. Please log in again.',
    errorCodeMessage: 'SEC001',
  },

  DEC_04: {
    title: 'Validation Error',
    message: 'We could not validate information. Please try again.',
    errorCodeMessage: 'DEC_04',
  },

  // Merchant Errors
  MER003: {
    title: 'Configuration Error',
    message:
      'Merchant configuration not found. Please contact customer support for assistance.',
    errorCodeMessage: 'MER003',
  },

  MER004: {
    title: 'Configuration Error',
    message:
      'Merchant display name not found. Please contact customer support for assistance.',
    errorCodeMessage: 'MER004',
  },

  // Server Errors
  EC_02: {
    title: 'Server Error',
    message:
      'Some error occurred. Please try again later. If the problem persists, contact customer support.',
    errorCodeMessage: 'EC_02',
  },

  EC_500: {
    title: 'Internal Server Error',
    message:
      'Internal server error occurred. Please try again after some time.',
    errorCodeMessage: 'EC_500',
  },

  EC_502: {
    title: 'Bad Gateway',
    message:
      'The gateway was unable to get a valid response. Please try again.',
    errorCodeMessage: 'EC_502',
  },

  EC_503: {
    title: 'Service Unavailable',
    message: 'Service is temporarily unavailable. Please try again later.',
    errorCodeMessage: 'EC_503',
  },

  EC_504: {
    title: 'Gateway Timeout',
    message:
      'The gateway timed out while waiting for a response. Please try again.',
    errorCodeMessage: 'EC_504',
  },

  // Transaction Specific Errors
  PREPARE_FAILED: {
    title: 'Terminal Setup Failed',
    message:
      'Failed to prepare the payment terminal. This could be due to network issues or terminal configuration problems. Please try again.',
    errorCodeMessage: 'PREPARE_FAILED',
  },

  RESUME_FAILED: {
    title: 'Terminal Connection Lost',
    message: 'Lost connection to the payment terminal. Please try again.',
    errorCodeMessage: 'RESUME_FAILED',
  },

  TRANSACTION_ERROR: {
    title: 'Transaction Error',
    message:
      'Reader not ready. Please ensure the terminal is properly prepared and try again.',
    errorCodeMessage: 'TRANSACTION_ERROR',
  },

  TRANSACTION_FAILED: {
    title: 'Transaction Failed',
    message:
      'The transaction could not be completed. Please try again or use a different payment method.',
    errorCodeMessage: 'TRANSACTION_FAILED',
  },
};

// Helper function to get error info from error object or message
export const getCloudCommerceErrorInfo = (
  error: any,
): CloudCommerceErrorInfo => {
  let errorCode: string | undefined;

  // Extract error code from various possible formats
  if (typeof error === 'object' && error !== null) {
    errorCode = error.code || error.errorCode;

    // Some native errors surface an internal platform/backend code inside the message/userInfo.
    // Example seen in logs:
    // "Transaction failed: Internal Server Error  (Code: INTERNAL_SERVER_ERR)"
    const possibleMessage =
      error?.userInfo?.NSLocalizedDescription ||
      error?.message ||
      error?.localizedDescription;
    if (typeof possibleMessage === 'string') {
      // Prefer the embedded "(Code: XYZ)" if present, since native bridges often wrap errors
      // with a generic outer code (e.g., ARISE_TRANSACTION_FAILED).
      const embeddedCodeMatch = possibleMessage.match(
        /\(Code:\s*([A-Z0-9_]+)\)/,
      );
      const embeddedCode = embeddedCodeMatch?.[1];
      if (embeddedCode) {
        errorCode = embeddedCode;
      }

      if (possibleMessage.includes('INTERNAL_SERVER_ERR')) {
        // Reuse our existing server error mapping to force error UI (no auto-recovery).
        errorCode = 'EC_500';
      }
    }
  } else if (typeof error === 'string') {
    // Handle string errors with message matching (fallback)
    if (
      error.includes(
        'Merchant is not allowed to operate in the current country',
      )
    ) {
      errorCode = 'GPS004';
    } else if (error.toLowerCase().includes('device could not be located')) {
      errorCode = 'GPS006';
    } else if (error.includes('Location service') || error.includes('GPS')) {
      errorCode = 'GPS003';
    } else if (error.includes('Reader not ready')) {
      errorCode = 'TRANSACTION_ERROR';
    } else if (error.includes('network connection was lost')) {
      errorCode = 'ATT018';
    } else if (error.toLowerCase().includes('cancel')) {
      errorCode = 'USER_CANCELED';
    }
  }

  // Return mapped error info or default
  if (errorCode && CLOUD_COMMERCE_ERROR_MAPPINGS[errorCode]) {
    return CLOUD_COMMERCE_ERROR_MAPPINGS[errorCode];
  }

  // Handle explicit USER_CANCELED even if not in mappings
  if (errorCode === 'USER_CANCELED') {
    return {
      title: 'Transaction Cancelled',
      message: 'The transaction was cancelled by the user.',
      errorCodeMessage: 'USER_CANCELED',
    };
  }

  // Default error for unmapped cases
  return {
    title: 'Connection Issue',
    message:
      "We're having trouble connecting to the payment terminal. Please try again or go back to select a different payment method.",
    errorCodeMessage: errorCode || 'UNKNOWN',
  };
};
