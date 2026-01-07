import * as Sentry from '@sentry/react-native';
import {runtimeConfig} from '@/utils/runtimeConfig';
import {ENVIRONMENTS} from '@/constants/environments';

export const sentryConfig: Sentry.ReactNativeOptions = {
  dsn: runtimeConfig.APP_SENTRY_DSN || '',

  // Adds more context data to events (IP address, cookies, user, etc.)
  // For more information, visit: https://docs.sentry.io/platforms/react-native/data-management/data-collected/
  sendDefaultPii: true,
  environment: runtimeConfig.APP_ENV || ENVIRONMENTS.DEVELOPMENT,
  // Configure Session Replay
  replaysSessionSampleRate: 0.1,
  replaysOnErrorSampleRate: 1,
  integrations: [Sentry.mobileReplayIntegration()],

  // Configure beforeSend to sanitize sensitive information
  beforeSend(event: Sentry.ErrorEvent) {
    return sanitizeErrorEvent(event);
  },

  // uncomment the line below to enable Spotlight (https://spotlightjs.com)
  // spotlight: __DEV__,
};

/**
 * Sanitizes Sentry ErrorEvent objects specifically, targeting known sensitive fields
 * while preserving debugging information. This approach is less aggressive than
 * generic sanitization and maintains Sentry's event structure.
 *
 * @param event - The Sentry ErrorEvent to sanitize
 * @returns The sanitized ErrorEvent with sensitive data masked
 *
 * @example
 * // Sanitizes: exception messages, user data, extra fields, request data, breadcrumbs
 * // Preserves: stack traces, error types, contexts, tags (non-sensitive)
 */
const sanitizeErrorEvent = (
  event: Sentry.ErrorEvent,
): Sentry.ErrorEvent | null => {
  if (!event) {
    return null;
  }

  const sanitizedEvent = {...event};

  // Sanitize exception messages and stack traces
  if (sanitizedEvent.exception?.values) {
    sanitizedEvent.exception.values = sanitizedEvent.exception.values.map(
      exception => ({
        ...exception,
        value: exception.value
          ? sanitizeString(exception.value)
          : exception.value,
        // Keep stack traces intact for debugging
        stacktrace: exception.stacktrace,
      }),
    );
  }

  // Sanitize extra data while preserving structure
  if (sanitizedEvent.extra) {
    sanitizedEvent.extra = sanitizeExtra(sanitizedEvent.extra);
  }

  // Sanitize breadcrumbs messages
  if (sanitizedEvent.breadcrumbs) {
    sanitizedEvent.breadcrumbs = sanitizedEvent.breadcrumbs.map(breadcrumb => ({
      ...breadcrumb,
      message: breadcrumb.message
        ? sanitizeString(breadcrumb.message)
        : breadcrumb.message,
      data: breadcrumb.data ? sanitizeExtra(breadcrumb.data) : breadcrumb.data,
    }));
  }

  // Sanitize main message
  if (sanitizedEvent.message) {
    sanitizedEvent.message = sanitizeString(sanitizedEvent.message);
  }

  return sanitizedEvent;
};

/**
 * Sanitizes string content while preserving debugging value.
 * Less aggressive than full sanitization - focuses on PII patterns.
 */
const sanitizeString = (str: string): string => {
  if (!str) {
    return str;
  }

  const sanitized = str
    // Credit card numbers (but preserve partial for debugging)
    .replace(
      /\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b/g,
      '**** **** **** [CARD]',
    )
    // CVV codes
    .replace(/(?:cvv|cvc|security\s*code)[\s:=]*\d{3,4}\b/gi, 'CVV: [CVV]')
    // Full email addresses
    .replace(/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/g, '[EMAIL]')
    // Phone numbers
    .replace(/\b\d{3}-\d{3}-\d{4}\b/g, '[PHONE]')
    // Amounts (but be less aggressive - only obvious currency)
    .replace(/\$\d+(\.\d{2})?/g, '[AMOUNT]');

  return sanitized;
};

/**
 * Sanitizes extra data more selectively than the aggressive sanitizeData function
 */
const sanitizeExtra = (extra: Record<string, any>): Record<string, any> => {
  const sanitized = {...extra};

  // Redact when key contains any of these substrings (insensitive)
  const sensitiveKeySubstrings = [
    'password',
    'token',
    'auth',
    'refresh',
    'api',
    'secret',
    'card',
    'cvv',
    'exp',
    'account',
    'routing',
    'ssn',
    'phone',
    'email',
    'name',
    'address',
    'city',
    'state',
    'zip',
    'security',
    'code',
    'expiration',
  ];

  Object.keys(sanitized).forEach(key => {
    const value = sanitized[key];
    const keyLower = key.toLowerCase();
    const shouldRedactByKey = sensitiveKeySubstrings.some(substr =>
      keyLower.includes(substr),
    );

    if (shouldRedactByKey) {
      sanitized[key] = `[${key.toUpperCase()}]`;
    } else if (typeof value === 'string') {
      // Apply string sanitization to preserve structure but clean content
      sanitized[key] = sanitizeString(value);
    } else if (typeof value === 'object' && value !== null) {
      // Recursively sanitize nested objects
      sanitized[key] = sanitizeExtra(value as Record<string, any>);
    }
  });

  return sanitized;
};
