/**
 * Jest Setup File
 *
 * This file is executed before each test file is executed. It's the perfect place
 * to set up global configurations and mocks for your test environment.
 *
 * --- WHY THIS SETUP IS NEEDED ---
 *
 * Testing React Native applications, especially those with complex animations and
 * gestures, requires mocking several native modules that are not available in the
 * Node.js environment where Jest runs.
 *
 * 1. `react-native-gesture-handler`: Provides necessary mocks for gesture interactions.
 *
 * 2. `react-native-reanimated`: This is the core of the animation fix. While
 *    `setUpTests()` provides a baseline, it's often not enough to prevent "act(...)"
 *    warnings. These warnings appear when state updates (triggered by animations)
 *    happen outside of the test's control.
 *    - We use `jest.mock` to replace the module with a special mock version.
 *    - We override `Reanimated.default.call` because the default mock can
 *      sometimes execute animation callbacks immediately, leading to unpredictable
 *      test behavior. Setting it to a no-op gives us stability.
 *
 * 3. `jest.useFakeTimers()`: This is crucial for controlling time-based operations
 *    like animations. It replaces native timer functions (`setTimeout`, etc.) with
 *    mocks that we can control in our tests (e.g., `jest.runAllTimers()`),
 *    allowing us to test the final state of an animation instantly.
 *
 * --- PROS & CONS ---
 *
 * Pros:
 * - Eliminates `act(...)` warnings, leading to cleaner and more reliable test runs.
 * - Speeds up tests significantly by not waiting for real animation durations.
 * - Creates a stable and predictable test environment, reducing flakiness.
 *
 * Cons:
 * - Does not test the visual aspect of the animation. We are testing the component's
 *   logic and its state before and after the animation, not the smoothness or
 *   correctness of the animation itself. Visual testing should be done manually
 *   or with End-to-End (E2E) testing tools.
 * - Can add a layer of complexity to tests that have intricate, chained animations,
 *   as you might need to manually manage the fake timers.
 */
import 'react-native-gesture-handler/jestSetup';
import {jest} from '@jest/globals';

require('react-native-reanimated').setUpTests();

jest.mock('react-native-reanimated', () => {
  const Reanimated = require('react-native-reanimated/mock');

  // The mock for `call` immediately calls the callback which is incorrect
  // So we override it with a no-op
  Reanimated.default.call = () => {};

  return Reanimated;
});

jest.useFakeTimers();

// Suppress console output during tests to keep test output clean
global.console = {
  ...console,
  log: jest.fn(),
  debug: jest.fn(),
  info: jest.fn(),
  warn: jest.fn(),
  error: jest.fn(),
};

// Mock apiClient globally to avoid runtimeConfig dependency issues
jest.mock('@/clients/apiClient', () => ({
  apiClient: {
    get: jest.fn(),
    post: jest.fn(),
    put: jest.fn(),
    delete: jest.fn(),
    interceptors: {
      request: {use: jest.fn(), handlers: []},
      response: {use: jest.fn(), handlers: []},
    },
  },
  publicApiClient: {
    get: jest.fn(),
    post: jest.fn(),
    put: jest.fn(),
    delete: jest.fn(),
    interceptors: {
      request: {use: jest.fn(), handlers: []},
      response: {use: jest.fn(), handlers: []},
    },
  },
}));

// Mock CloudCommerce to prevent NativeEventEmitter issues
jest.mock('@/cloudcommerce', () => ({
  __esModule: true,
  default: {
    prepare: jest.fn().mockResolvedValue({
      forceUpgrade: false,
      recommendedUpgrade: false,
    }),
    resume: jest.fn().mockResolvedValue('mock-session-id'),
    performTransaction: jest.fn().mockResolvedValue({
      success: true,
      transactionId: 'mock-transaction-id',
    }),
    clear: jest.fn().mockResolvedValue(true),
    eventManager: {
      addListener: jest.fn().mockReturnValue({
        remove: jest.fn(),
      }),
    },
    getSdkDetails: jest.fn().mockResolvedValue({
      posIdentifier: 'mock-pos-id',
      deviceIdentifier: 'mock-device-id',
      merchantDetails: {
        merchantConfig: {
          isPayByLinkEnabled: true,
          paymentNetworks: ['visa', 'mastercard'],
        },
        currencyData: [
          {
            countryName: 'United States',
            countryCode: 'US',
            currencyCodeISO: 'USD',
            countryCurrencySymbol: '$',
            currencyCode: 'USD',
            isCurrencyAfter: false,
          },
        ],
      },
      version: '1.0.0',
      information: {},
      sessionExpiryTime: null,
    }),
  },
}));

// Mock the cloudcommerce native module directly instead of react-native
jest.mock(
  '@/cloudcommerce/index',
  () => require('./__mocks__/cloudcommerce/index.ts').default,
);

// Mock react-native-localize to prevent native module errors
jest.mock('react-native-localize', () => ({
  getCountry: jest.fn(() => 'US'),
  getLocales: jest.fn(() => [
    {
      countryCode: 'US',
      languageTag: 'en-US',
      languageCode: 'en',
      isRTL: false,
    },
  ]),
  getCurrencies: jest.fn(() => ['USD']),
  getTimeZone: jest.fn(() => 'America/New_York'),
  uses24HourClock: jest.fn(() => false),
  usesMetricSystem: jest.fn(() => false),
  addEventListener: jest.fn(),
  removeEventListener: jest.fn(),
}));

// Note: runtimeConfig is not mocked globally to allow its own tests to work
// Individual test files should mock it specifically if needed

// Mock growthBook to prevent initialization errors
jest.mock('@/utils/growthBook', () => ({
  growthBook: {
    getFeatureValue: jest.fn(() => false),
    loadFeatures: jest.fn().mockResolvedValue(undefined),
    setAttributes: jest.fn(),
    destroy: jest.fn(),
  },
}));

// Global Mock for AriseMobileSdk
// This prevents tests from crashing when components import AriseMobileSdk
jest.mock('@/native/AriseMobileSdk', () => ({
  __esModule: true,
  default: {
    authenticate: jest.fn().mockResolvedValue({
      accessToken: 'mock-token',
      expiresIn: 3600,
      tokenType: 'Bearer',
    }),
    checkCompatibility: jest.fn().mockResolvedValue({
      isCompatible: true,
      incompatibilityReasons: [],
    }),
    configure: jest.fn().mockResolvedValue(undefined),
    isConfigured: jest.fn().mockReturnValue(true),
    getConfiguredEnvironment: jest.fn().mockReturnValue('uat'),
    getPaymentSettings: jest.fn().mockResolvedValue({}),
    getDeviceInfo: jest.fn().mockResolvedValue({}),
    getTransactions: jest.fn().mockResolvedValue({items: [], total: 0}),
    submitSaleTransaction: jest.fn().mockResolvedValue({}),
    voidTransaction: jest.fn().mockResolvedValue({}),
    captureTransaction: jest.fn().mockResolvedValue({}),
    refundTransaction: jest.fn().mockResolvedValue({}),
    calculateAmount: jest.fn().mockResolvedValue({}),
  },
  ArisePaymentSettings: {},
  AriseEnvironment: {},
}));
