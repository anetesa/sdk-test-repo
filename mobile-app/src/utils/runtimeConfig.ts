import Config from 'react-native-config';
import RNTestFlight from 'react-native-test-flight';
import {ENVIRONMENTS} from '../constants/environments';
import {logger} from './logger';
import {getEnvironmentValue, setEnvironmentValue} from '@/utils/asyncStorage';
import {AriseEnvironment} from '@/native/AriseMobileSdk';

const {UAT, PRODUCTION, DEVELOPMENT} = ENVIRONMENTS;
export type EnvName = (typeof ENVIRONMENTS)[keyof typeof ENVIRONMENTS];

interface RuntimeConfig {
  APP_API_AUTH_URL: string;
  APP_FUSIONAUTH_APPLICATION_ID: string;
  APP_API_MERCHANT_URL: string;
  APP_API_PUBLIC_URL: string;
  APP_PENDO_API_KEY: string;
  APP_ENV: string;
  APP_FUSIONAUTH_TENANT_ID: string;
  APP_GROWTHBOOK_API_HOST: string;
  APP_GROWTHBOOK_CLIENT_KEY: string;
  APP_SENTRY_DSN: string;
  APP_SENTRY_AUTH_TOKEN: string;
  APP_SENTRY_ORG: string;
  APP_SENTRY_PROJECT: string;
  APP_SENTRY_URL: string;
  APP_WEB_VIEW_PUBLIC_API: string;
  APP_TERMINAL_PROFILE_ID_FROM_APPLE: string;
  APP_AURORA_MASTERCARD_JWT_KEY: string;
  [key: string]: string;
}

// Define callback type
type EnvironmentChangeCallback = () => void;

export class RuntimeConfigManager {
  private _currentEnvironment: EnvName = PRODUCTION; // Default
  readonly ENV_KEY = 'runtime_environment';

  constructor() {
    this.initialize();
  }

  private async initialize() {
    const buildEnv = (Config.APP_ENV as EnvName) || PRODUCTION;

    let effectiveEnv: EnvName = buildEnv;

    if (buildEnv === UAT) {
      const storedEnv = (await getEnvironmentValue(
        this.ENV_KEY,
      )) as EnvName | null;
      // In a UAT build, TestFlight users can switch and have it remembered.
      // Non-TestFlight (e.g., local dev) defaults to 'uat'.
      effectiveEnv = RNTestFlight?.isTestFlight
        ? storedEnv || PRODUCTION // On TestFlight, allow falling back to prod
        : UAT;
    }
    this.currentEnvironment = effectiveEnv;
  }

  // Getter for the current environment, determined synchronously
  get currentEnvironment(): EnvName {
    return this._currentEnvironment;
  }

  // Setter for manually changing the environment
  set currentEnvironment(environment: EnvName) {
    if (this._currentEnvironment === environment) {
      return; // Avoid unnecessary updates
    }
    try {
      this._currentEnvironment = environment;
      setEnvironmentValue(this.ENV_KEY, environment);
      this.notifyEnvironmentChange();
    } catch (error) {
      logger.error(error, 'Error changing runtime environment');
    }
  }

  // The 'get' method now constructs the prefixed key on the fly
  private get(baseKey: keyof RuntimeConfig): string {
    const env = this.currentEnvironment;
    let prefix = '';
    if (env === DEVELOPMENT) {
      prefix = 'DEV';
    } else if (env === UAT) {
      prefix = 'UAT';
    } else if (env === PRODUCTION) {
      prefix = 'PROD';
    }

    // Construct the full prefixed key (e.g., 'DEV_APP_API_AUTH_URL')
    const fullKey = `${prefix}_${baseKey}`;

    // Return the value from Config, or an empty string if not found
    return Config[fullKey] || '';
  }

  isProduction(): boolean {
    return this.currentEnvironment === PRODUCTION;
  }

  getAriseEnvironment(): AriseEnvironment {
    switch (this.currentEnvironment) {
      case ENVIRONMENTS.PRODUCTION:
        return 'production';
      case ENVIRONMENTS.UAT:
        return 'uat';
      case ENVIRONMENTS.DEVELOPMENT:
      default:
        return 'sandbox';
    }
  }

  private environmentChangeCallbacks: EnvironmentChangeCallback[] = [];

  // Listener management methods remain the same
  addEnvironmentChangeListener(callback: EnvironmentChangeCallback): void {
    if (!this.environmentChangeCallbacks.includes(callback)) {
      this.environmentChangeCallbacks.push(callback);
    }
  }

  removeEnvironmentChangeListener(callback: EnvironmentChangeCallback): void {
    const index = this.environmentChangeCallbacks.indexOf(callback);
    if (index > -1) {
      this.environmentChangeCallbacks.splice(index, 1);
    }
  }

  private notifyEnvironmentChange(): void {
    this.environmentChangeCallbacks.forEach(callback => {
      try {
        callback();
      } catch (error) {
        logger.error(error, 'Error in environment change callback');
      }
    });
  }

  // Getters will now work correctly by calling the revised 'get' method
  get APP_ENV() {
    // APP_ENV is special, it's not prefixed
    return Config.APP_ENV || PRODUCTION;
  }

  get APP_API_AUTH_URL() {
    return this.get('APP_API_AUTH_URL');
  }

  get APP_SENTRY_DSN() {
    return this.get('APP_SENTRY_DSN');
  }

  get APP_SENTRY_AUTH_TOKEN() {
    return this.get('APP_SENTRY_AUTH_TOKEN');
  }

  get APP_SENTRY_ORG() {
    return this.get('APP_SENTRY_ORG');
  }

  get APP_SENTRY_PROJECT() {
    return this.get('APP_SENTRY_PROJECT');
  }

  get APP_FUSIONAUTH_TENANT_ID() {
    return this.get('APP_FUSIONAUTH_TENANT_ID');
  }

  get APP_API_MERCHANT_URL() {
    return this.get('APP_API_MERCHANT_URL');
  }

  get APP_API_PUBLIC_URL() {
    return this.get('APP_API_PUBLIC_URL');
  }

  get APP_PENDO_API_KEY() {
    return this.get('APP_PENDO_API_KEY');
  }

  get APP_FUSIONAUTH_APPLICATION_ID() {
    return this.get('APP_FUSIONAUTH_APPLICATION_ID');
  }

  get APP_GROWTHBOOK_API_HOST() {
    return this.get('APP_GROWTHBOOK_API_HOST');
  }

  get APP_GROWTHBOOK_CLIENT_KEY() {
    return this.get('APP_GROWTHBOOK_CLIENT_KEY');
  }

  get APP_WEB_VIEW_PUBLIC_API() {
    return this.get('APP_WEB_VIEW_PUBLIC_API');
  }

  get APP_TERMINAL_PROFILE_ID_FROM_APPLE() {
    return this.get('APP_TERMINAL_PROFILE_ID_FROM_APPLE');
  }

  get APP_AURORA_MASTERCARD_JWT_KEY() {
    return this.get('APP_AURORA_MASTERCARD_JWT_KEY');
  }
}

// Create singleton instance
export const runtimeConfig = new RuntimeConfigManager();

// Export types
export type {RuntimeConfig};
