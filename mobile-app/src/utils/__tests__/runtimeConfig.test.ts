import {runtimeConfig, RuntimeConfigManager} from '../runtimeConfig';

jest.mock('react-native-config', () => ({
  __esModule: true,
  default: {
    APP_ENV: 'uat',
    UAT_APP_API_AUTH_URL: 'https://uat-auth',
    UAT_APP_API_MERCHANT_URL: 'https://uat-merchant',
  },
}));

jest.mock('react-native-test-flight', () => ({
  __esModule: true,
  default: {isTestFlight: false},
}));

jest.mock('@/utils/asyncStorage', () => ({
  getEnvironmentValue: jest.fn().mockResolvedValue(null),
  setEnvironmentValue: jest.fn(),
}));

jest.mock('../logger', () => ({
  logger: {error: jest.fn()},
}));

describe('runtimeConfig', () => {
  it('returns prefixed values for UAT environment', () => {
    expect(runtimeConfig.APP_API_AUTH_URL).toBe('https://uat-auth');
    expect(runtimeConfig.APP_API_MERCHANT_URL).toBe('https://uat-merchant');
  });

  it('isProduction returns false for UAT', () => {
    expect(runtimeConfig.isProduction()).toBe(false);
  });

  it('notifies listeners on environment change', () => {
    const mgr = new RuntimeConfigManager();
    const cb = jest.fn();
    mgr.addEnvironmentChangeListener(cb);
    mgr.currentEnvironment = 'development' as any;
    expect(cb).toHaveBeenCalled();
  });
});
