import {
  logger as reactNativeLogger,
  transportFunctionType,
} from 'react-native-logs';
import * as Sentry from '@sentry/react-native';
import {runtimeConfig} from './runtimeConfig';

/**
 * Enum representing log severity levels.
 * Higher numbers indicate higher severity (more important logs).
 */
export enum LogSeverity {
  /** Debug level - most verbose, used for development debugging */
  DEBUG = 0,
  /** Info level - general information messages */
  INFO = 1,
  /** Warning level - potentially harmful situations */
  WARN = 2,
  /** Exception level - error conditions that should be sent to Sentry */
  ERROR = 3,
}

/**
 * Determines if we should show detailed logs based on the environment.
 * @returns true if logs should be enabled (dev or non-production), false otherwise
 */
const shouldEnableLogs = (): boolean => {
  // Always enable in __DEV__ (Metro bundler running)
  if (__DEV__) {
    return true;
  }

  // For compiled builds, check if we're NOT in production
  return !runtimeConfig.isProduction();
};

/**
 * Gets the appropriate log severity level based on environment.
 * @returns The severity level string
 */
const getLogSeverity = (): 'debug' | 'info' | 'warn' | 'error' => {
  // Development: show everything
  if (__DEV__) {
    return 'debug';
  }

  // Production: only errors
  if (runtimeConfig.isProduction()) {
    return 'error';
  }

  // UAT/Staging: info and above
  return 'info';
};

type TransportParams = Parameters<transportFunctionType<{}>>[0];

/**
 * Custom transport function that handles log output to console and conditionally sends
 * exception-level logs to Sentry for error tracking.
 *
 * @param props - Transport parameters containing log message, level, and metadata
 */
const customTransport = (props: TransportParams) => {
  // Print to console (react-native-logs handles this internally, but we ensure it's visible)
  console.log(props.msg);

  // Send only error-level logs to Sentry
  if (props.level.severity >= LogSeverity.ERROR) {
    // Extract the actual error message from the formatted message
    const errorMessage =
      Array.isArray(props.rawMsg) && props.rawMsg.length > 0
        ? props.rawMsg[0]
        : props.msg;

    // If it's an Error object, capture it as an exception
    if (errorMessage instanceof Error) {
      Sentry.captureException(errorMessage);
    }
  }
};

// Create the logger instance
export const logger = reactNativeLogger.createLogger({
  levels: {
    debug: LogSeverity.DEBUG,
    info: LogSeverity.INFO,
    warn: LogSeverity.WARN,
    error: LogSeverity.ERROR,
  },
  // Dynamic severity based on environment
  severity: getLogSeverity(),
  transport: customTransport,
  transportOptions: {
    colors: {
      debug: 'white',
      info: 'blueBright',
      warn: 'yellowBright',
      error: 'redBright',
    },
  },
  async: true,
  dateFormat: 'time',
  printLevel: true,
  printDate: true,
  // Dynamic enable based on environment
  enabled: shouldEnableLogs(),
});
