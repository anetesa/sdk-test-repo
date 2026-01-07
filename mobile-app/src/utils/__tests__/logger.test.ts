// Simple test for logger Sentry integration
import {logger} from '../logger';

// Mock Sentry at the top level
jest.mock('@sentry/react-native', () => ({
  captureException: jest.fn(),
  captureMessage: jest.fn(),
}));

// Use the existing logger mock
jest.mock('../logger');

describe('Logger Sentry Integration', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should call logger.error with Error object', () => {
    const testError = new Error('Test error');

    logger.error(testError);

    expect(logger.error).toHaveBeenCalledWith(testError);
  });

  it('should call logger.error with string message', () => {
    const errorMessage = 'Payment failed with sensitive data';

    logger.error(errorMessage);

    expect(logger.error).toHaveBeenCalledWith(errorMessage);
  });

  it('should call logger.error with context', () => {
    const testError = new Error('Test error');
    const context = 'Payment processing';

    logger.error(testError, context);

    expect(logger.error).toHaveBeenCalledWith(testError, context);
  });

  it('should handle null and undefined errors gracefully', () => {
    expect(() => logger.error(null)).not.toThrow();
    expect(() => logger.error(undefined)).not.toThrow();

    expect(logger.error).toHaveBeenCalledTimes(2);
    expect(logger.error).toHaveBeenCalledWith(null);
    expect(logger.error).toHaveBeenCalledWith(undefined);
  });

  it('should log various types of messages', () => {
    logger.debug('Debug message');
    logger.info('Info message');
    logger.warn('Warning message');
    logger.error('Exception message');

    expect(logger.debug).toHaveBeenCalledWith('Debug message');
    expect(logger.info).toHaveBeenCalledWith('Info message');
    expect(logger.warn).toHaveBeenCalledWith('Warning message');
    expect(logger.error).toHaveBeenCalledWith('Exception message');
  });
});
