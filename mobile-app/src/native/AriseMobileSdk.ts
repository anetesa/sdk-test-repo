import {NativeModules} from 'react-native';
import {GetTransactionsResponseDTO} from '@/types/TransactionResponse';
import {TransactionSalePayload} from '@/types/TransactionSale';
import {RefundTransactionPayload} from '@/types/TransactionRefund';
import {GetApiTransactionsCalculateAmountParams} from '@/types/CalculateAmount';

const LINKING_ERROR =
  "AriseMobileSdkModule is not linked. Make sure you have run 'pod install' and rebuilt the app.";

type NativeAuthenticationResult = {
  accessToken: string;
  refreshToken?: string | null;
  expiresIn: number;
  tokenType: string;
};

type NativeAriseMobileSdkModule = {
  configure(
    environment: string,
    countryCode?: string,
  ): Promise<{environment: string}>;
  authenticate(
    clientId: string,
    clientSecret: string,
  ): Promise<NativeAuthenticationResult>;
  reset(): Promise<void>;
  getDeviceId(): Promise<string>;
  getPaymentSettings(): Promise<Record<string, unknown>>;
  getDeviceInfo(deviceId: string): Promise<Record<string, unknown>>;
  getTransactions(filters: TransactionFilters): Promise<{
    items: Record<string, unknown>[];
    total: number;
  }>;
  submitSaleTransaction(
    input: Record<string, unknown>,
  ): Promise<Record<string, unknown>>;
  voidTransaction(transactionId: string): Promise<SDKTransactionResponse>;
  captureTransaction(
    transactionId: string,
    amount: number,
  ): Promise<SDKTransactionResponse>;
  refundTransaction(
    input: Record<string, unknown>,
  ): Promise<SDKTransactionResponse>;
  calculateAmount(
    input: Record<string, unknown>,
  ): Promise<Record<string, unknown>>;
  checkCompatibility(): Promise<{
    isCompatible: boolean;
    incompatibilityReasons: string[];
  }>;
  activate(): Promise<string>;
  prepare(): Promise<void>;
  getTapToPayStatus(): Promise<string>;
  eventsStream(): Promise<{streamId: string; status: string}>;
  resume(): Promise<void>;
  performTransaction(
    transactionDetails: Record<string, unknown>,
  ): Promise<Record<string, unknown>>;
  showEducationalInfo(): Promise<{success: boolean}>;
};

export type SDKTransactionResponse = {
  transactionId?: string | null;
  transactionDateTime?: string | null;
  typeId?: number | null;
  type?: string | null;
  statusId?: number | null;
  status?: string | null;
  details?: {
    hostResponseCode?: string | null;
    hostResponseMessage?: string | null;
    hostResponseDefinition?: string | null;
    code?: string | null;
    message?: string | null;
    processorResponseCode?: string | null;
    authCode?: string | null;
    maskedPan?: string | null;
  } | null;
  // Allow other properties
  [key: string]: any;
};

export type TransactionFilters = {
  page?: number;
  pageSize?: number;
  asc?: boolean;
  orderBy?: string;
  createMethodId?: number;
  createdById?: string;
  batchId?: string;
  noBatch?: boolean;
};

export type AriseEnvironment = 'production' | 'sandbox' | 'uat';

export type AriseAuthenticationResult = {
  accessToken: string;
  refreshToken: string | null;
  expiresIn: number;
  tokenType: string;
};

export type AriseNamedOption = {
  id: number;
  name?: string | null;
};

export type AriseSettlementBatchTimeSlot = {
  hours?: number | null;
  minutes?: number | null;
  timezoneName?: string | null;
};

export type ArisePaymentProcessor = {
  id?: string | null;
  name?: string | null;
  isDefault?: boolean | null;
  typeId?: number | null;
  type?: string | null;
  settlementBatchTimeSlots?: AriseSettlementBatchTimeSlot[] | null;
};

export type AriseAvsOptions = {
  isEnabled?: boolean | null;
  profileId?: number | null;
  profile?: string | null;
};

export type ArisePaymentSettings = {
  availableCurrencies: AriseNamedOption[];
  zeroCostProcessingOptionId?: number | null;
  zeroCostProcessingOption?: string | null;
  defaultSurchargeRate?: number | null;
  defaultCashDiscountRate?: number | null;
  defaultDualPricingRate?: number | null;
  isTipsEnabled: boolean;
  defaultTipsOptions?: number[] | null;
  availableCardTypes: AriseNamedOption[];
  availableTransactionTypes: AriseNamedOption[];
  availablePaymentProcessors: ArisePaymentProcessor[];
  avs?: AriseAvsOptions | null;
  isCustomerCardSavingByTerminalEnabled: boolean;
  isCashDiscountEnabled?: boolean;
  isDualPricingEnabled?: boolean;
  isSurchargeEnabled?: boolean;
};

export type AriseDeviceUser = {
  id?: string | null;
  firstName?: string | null;
  lastName?: string | null;
  email?: string | null;
};

export type AriseDeviceInfo = {
  deviceId?: string | null;
  deviceName?: string | null;
  lastLoginAt?: string | null;
  tapToPayStatus?: string | null;
  tapToPayStatusId?: number | null;
  tapToPayEnabled: boolean;
  userProfiles: AriseDeviceUser[];
};

const AriseMobileSdkModule: NativeAriseMobileSdkModule | undefined =
  NativeModules.AriseMobileSdkModule;

const ensureModule = (): NativeAriseMobileSdkModule => {
  if (!AriseMobileSdkModule) {
    throw new Error(LINKING_ERROR);
  }

  return AriseMobileSdkModule;
};

let configuredEnvironment: AriseEnvironment | null = null;
let moduleConfigured = false;

const normalizeEnvironment = (environment: AriseEnvironment): string => {
  if (environment === 'production') {
    return 'production';
  }

  return 'sandbox';
};

const normalizeAuthenticationResult = (
  result: NativeAuthenticationResult,
): AriseAuthenticationResult => ({
  accessToken: result.accessToken,
  refreshToken: result.refreshToken ?? null,
  expiresIn: result.expiresIn,
  tokenType: result.tokenType,
});

const normalizeNamedOption = (input: any): AriseNamedOption => ({
  id: typeof input?.id === 'number' ? input.id : 0,
  name:
    typeof input?.name === 'string' || input?.name === null ? input.name : null,
});

const normalizeSettlementBatchTimeSlot = (
  input: any,
): AriseSettlementBatchTimeSlot => ({
  hours:
    typeof input?.hours === 'number' || input?.hours === null
      ? input.hours
      : null,
  minutes:
    typeof input?.minutes === 'number' || input?.minutes === null
      ? input.minutes
      : null,
  timezoneName:
    typeof input?.timezoneName === 'string' || input?.timezoneName === null
      ? input.timezoneName
      : null,
});

const normalizePaymentProcessor = (input: any): ArisePaymentProcessor => ({
  id: typeof input?.id === 'string' || input?.id === null ? input.id : null,
  name:
    typeof input?.name === 'string' || input?.name === null ? input.name : null,
  isDefault:
    typeof input?.isDefault === 'boolean' || input?.isDefault === null
      ? input.isDefault
      : null,
  typeId:
    typeof input?.typeId === 'number' || input?.typeId === null
      ? input.typeId
      : null,
  type:
    typeof input?.type === 'string' || input?.type === null ? input.type : null,
  settlementBatchTimeSlots: Array.isArray(input?.settlementBatchTimeSlots)
    ? input.settlementBatchTimeSlots.map(normalizeSettlementBatchTimeSlot)
    : input?.settlementBatchTimeSlots === null
    ? null
    : [],
});

const normalizeAvsOptions = (input: any): AriseAvsOptions => ({
  isEnabled:
    typeof input?.isEnabled === 'boolean' || input?.isEnabled === null
      ? input.isEnabled
      : null,
  profileId:
    typeof input?.profileId === 'number' || input?.profileId === null
      ? input.profileId
      : null,
  profile:
    typeof input?.profile === 'string' || input?.profile === null
      ? input.profile
      : null,
});

const normalizePaymentSettings = (
  input: Record<string, unknown>,
): ArisePaymentSettings => {
  const toNamedOptions = (value: unknown): AriseNamedOption[] =>
    Array.isArray(value) ? value.map(normalizeNamedOption) : [];

  const defaultTipsOptions =
    input.defaultTipsOptions === null
      ? null
      : Array.isArray(input.defaultTipsOptions)
      ? (input.defaultTipsOptions as number[])
      : undefined;

  let paymentProcessors: ArisePaymentProcessor[] = [];
  if (Array.isArray(input.availablePaymentProcessors)) {
    paymentProcessors = input.availablePaymentProcessors.map(
      normalizePaymentProcessor,
    );
  }

  let avs: AriseAvsOptions | null | undefined;
  if (input.avs === null) {
    avs = null;
  } else if (typeof input.avs === 'object' && input.avs !== null) {
    avs = normalizeAvsOptions(input.avs);
  }

  return {
    availableCurrencies: toNamedOptions(input.availableCurrencies),
    zeroCostProcessingOptionId:
      typeof input.zeroCostProcessingOptionId === 'number' ||
      input.zeroCostProcessingOptionId === null
        ? (input.zeroCostProcessingOptionId as number | null)
        : null,
    zeroCostProcessingOption:
      typeof input.zeroCostProcessingOption === 'string' ||
      input.zeroCostProcessingOption === null
        ? (input.zeroCostProcessingOption as string | null)
        : null,
    defaultSurchargeRate:
      typeof input.defaultSurchargeRate === 'number' ||
      input.defaultSurchargeRate === null
        ? (input.defaultSurchargeRate as number | null)
        : null,
    defaultCashDiscountRate:
      typeof input.defaultCashDiscountRate === 'number' ||
      input.defaultCashDiscountRate === null
        ? (input.defaultCashDiscountRate as number | null)
        : null,
    defaultDualPricingRate:
      typeof input.defaultDualPricingRate === 'number' ||
      input.defaultDualPricingRate === null
        ? (input.defaultDualPricingRate as number | null)
        : null,
    isTipsEnabled: Boolean(input.isTipsEnabled),
    defaultTipsOptions,
    availableCardTypes: toNamedOptions(input.availableCardTypes),
    availableTransactionTypes: toNamedOptions(input.availableTransactionTypes),
    availablePaymentProcessors: paymentProcessors,
    avs,
    isCustomerCardSavingByTerminalEnabled: Boolean(
      input.isCustomerCardSavingByTerminalEnabled,
    ),
    isCashDiscountEnabled:
      typeof input.isCashDiscountEnabled === 'boolean'
        ? (input.isCashDiscountEnabled as boolean)
        : undefined,
    isDualPricingEnabled:
      typeof input.isDualPricingEnabled === 'boolean'
        ? (input.isDualPricingEnabled as boolean)
        : undefined,
    isSurchargeEnabled:
      typeof input.isSurchargeEnabled === 'boolean'
        ? (input.isSurchargeEnabled as boolean)
        : undefined,
  };
};

const normalizeDeviceUser = (input: any): AriseDeviceUser => ({
  id: typeof input?.id === 'string' || input?.id === null ? input.id : null,
  firstName:
    typeof input?.firstName === 'string' || input?.firstName === null
      ? input.firstName
      : null,
  lastName:
    typeof input?.lastName === 'string' || input?.lastName === null
      ? input.lastName
      : null,
  email:
    typeof input?.email === 'string' || input?.email === null
      ? input.email
      : null,
});

const normalizeDeviceInfo = (input: any): AriseDeviceInfo => ({
  deviceId:
    typeof input?.deviceId === 'string' || input?.deviceId === null
      ? input.deviceId
      : null,
  deviceName:
    typeof input?.deviceName === 'string' || input?.deviceName === null
      ? input.deviceName
      : null,
  lastLoginAt:
    typeof input?.lastLoginAt === 'string' || input?.lastLoginAt === null
      ? input.lastLoginAt
      : null,
  tapToPayStatus:
    typeof input?.tapToPayStatus === 'string' || input?.tapToPayStatus === null
      ? input.tapToPayStatus
      : null,
  tapToPayStatusId:
    typeof input?.tapToPayStatusId === 'number' ||
    input?.tapToPayStatusId === null
      ? input.tapToPayStatusId
      : null,
  tapToPayEnabled: Boolean(input?.tapToPayEnabled),
  userProfiles: Array.isArray(input?.userProfiles)
    ? input.userProfiles.map(normalizeDeviceUser)
    : [],
});

const AriseMobileSdk = {
  configure: async (
    environment: AriseEnvironment,
    countryCode?: string,
  ): Promise<void> => {
    const module = ensureModule();
    await module.configure(normalizeEnvironment(environment), countryCode);
    configuredEnvironment = environment;
    moduleConfigured = true;
  },
  getDeviceId: async (): Promise<string> => {
    const module = ensureModule();
    return await module.getDeviceId();
  },
  authenticate: async (
    clientId: string,
    clientSecret: string,
  ): Promise<AriseAuthenticationResult> => {
    if (!moduleConfigured) {
      throw new Error(
        'AriseMobileSdk not configured. Call AriseMobileSdk.configure(environment) before invoking authenticate.',
      );
    }

    const module = ensureModule();
    const nativeResult = await module.authenticate(clientId, clientSecret);

    return normalizeAuthenticationResult(nativeResult);
  },
  reset: async (): Promise<void> => {
    const module = ensureModule();
    await module.reset();
    moduleConfigured = false;
    configuredEnvironment = null;
  },
  getPaymentSettings: async (): Promise<ArisePaymentSettings> => {
    if (!moduleConfigured) {
      throw new Error(
        'AriseMobileSdk not configured. Call AriseMobileSdk.configure(environment) before invoking getPaymentSettings.',
      );
    }

    const module = ensureModule();
    const raw = await module.getPaymentSettings();
    return normalizePaymentSettings(raw);
  },
  getDeviceInfo: async (deviceId: string): Promise<AriseDeviceInfo> => {
    if (!moduleConfigured) {
      throw new Error(
        'AriseMobileSdk not configured. Call AriseMobileSdk.configure(environment) before invoking getDeviceInfo.',
      );
    }

    const module = ensureModule();
    const raw = await module.getDeviceInfo(deviceId);
    return normalizeDeviceInfo(raw);
  },
  getConfiguredEnvironment: (): AriseEnvironment | null =>
    configuredEnvironment,
  isConfigured: (): boolean => moduleConfigured,
  getTransactions: async (
    filters: TransactionFilters,
  ): Promise<{items: GetTransactionsResponseDTO[]; total: number}> => {
    if (!moduleConfigured) {
      throw new Error(
        'AriseMobileSdk not configured. Call AriseMobileSdk.configure(environment) before invoking getTransactions.',
      );
    }

    const module = ensureModule();
    const raw = await module.getTransactions(filters);
    // The native module returns items as dictionaries which match the DTO structure
    // We might need more strict normalization if the DTO structure is complex
    return raw as {items: GetTransactionsResponseDTO[]; total: number};
  },
  submitSaleTransaction: async (
    input: TransactionSalePayload,
  ): Promise<Record<string, unknown>> => {
    if (!moduleConfigured) {
      throw new Error(
        'AriseMobileSdk not configured. Call AriseMobileSdk.configure(environment) before invoking submitSaleTransaction.',
      );
    }

    const module = ensureModule();

    return await module.submitSaleTransaction(
      input as unknown as Record<string, unknown>,
    );
  },
  voidTransaction: async (
    transactionId: string,
  ): Promise<SDKTransactionResponse> => {
    if (!moduleConfigured) {
      throw new Error(
        'AriseMobileSdk not configured. Call AriseMobileSdk.configure(environment) before invoking voidTransaction.',
      );
    }

    const module = ensureModule();
    return (await module.voidTransaction(
      transactionId,
    )) as unknown as SDKTransactionResponse;
  },
  captureTransaction: async (
    transactionId: string,
    amount: number,
  ): Promise<SDKTransactionResponse> => {
    if (!moduleConfigured) {
      throw new Error(
        'AriseMobileSdk not configured. Call AriseMobileSdk.configure(environment) before invoking captureTransaction.',
      );
    }

    const module = ensureModule();
    return (await module.captureTransaction(
      transactionId,
      amount,
    )) as unknown as SDKTransactionResponse;
  },
  refundTransaction: async (
    input: RefundTransactionPayload,
  ): Promise<SDKTransactionResponse> => {
    if (!moduleConfigured) {
      throw new Error(
        'AriseMobileSdk not configured. Call AriseMobileSdk.configure(environment) before invoking refundTransaction.',
      );
    }

    const module = ensureModule();
    return (await module.refundTransaction(
      input as unknown as Record<string, unknown>,
    )) as unknown as SDKTransactionResponse;
  },
  calculateAmount: async (
    input: GetApiTransactionsCalculateAmountParams,
  ): Promise<Record<string, unknown>> => {
    if (!moduleConfigured) {
      throw new Error(
        'AriseMobileSdk not configured. Call AriseMobileSdk.configure(environment) before invoking calculateAmount.',
      );
    }

    const module = ensureModule();
    // Map params to request structure if needed, but for now we assume direct compatibility for common fields
    // The SDK expects `CalculateAmountRequest` fields: amount, percentageOffRate, surchargeRate, tipAmount, tipRate, currencyId, useCardPrice
    // GetApiTransactionsCalculateAmountParams has these + merchantId, zeroCostProcessingInvoiceOption
    // We pass the object and let Swift implementation extract what it needs.
    return await module.calculateAmount(
      input as unknown as Record<string, unknown>,
    );
  },
  checkCompatibility: async (): Promise<{
    isCompatible: boolean;
    incompatibilityReasons: string[];
  }> => {
    // Note: configure() is not strictly required for this check as it's device capability check
    const module = ensureModule();
    return await module.checkCompatibility();
  },
  ttp: {
    activate: async (): Promise<string> => {
      if (!moduleConfigured) {
        throw new Error(
          'AriseMobileSdk not configured. Call AriseMobileSdk.configure(environment) before invoking ttp.activate.',
        );
      }
      const module = ensureModule();
      return await module.activate();
    },
    prepare: async (): Promise<void> => {
      if (!moduleConfigured) {
        throw new Error(
          'AriseMobileSdk not configured. Call AriseMobileSdk.configure(environment) before invoking ttp.prepare.',
        );
      }
      const module = ensureModule();
      return await module.prepare();
    },
    getStatus: async (): Promise<string> => {
      if (!moduleConfigured) {
        throw new Error(
          'AriseMobileSdk not configured. Call AriseMobileSdk.configure(environment) before invoking ttp.getStatus.',
        );
      }
      const module = ensureModule();
      return await module.getTapToPayStatus();
    },
    eventsStream: async (): Promise<{streamId: string; status: string}> => {
      if (!moduleConfigured) {
        throw new Error(
          'AriseMobileSdk not configured. Call AriseMobileSdk.configure(environment) before invoking ttp.eventsStream.',
        );
      }
      const module = ensureModule();
      return await module.eventsStream();
    },
    resume: async (): Promise<void> => {
      if (!moduleConfigured) {
        throw new Error(
          'AriseMobileSdk not configured. Call AriseMobileSdk.configure(environment) before invoking ttp.resume.',
        );
      }
      const module = ensureModule();
      return await module.resume();
    },
    performTransaction: async (
      transactionDetails: Record<string, unknown>,
    ): Promise<Record<string, unknown>> => {
      if (!moduleConfigured) {
        throw new Error(
          'AriseMobileSdk not configured. Call AriseMobileSdk.configure(environment) before invoking ttp.performTransaction.',
        );
      }
      const module = ensureModule();
      return await module.performTransaction(transactionDetails);
    },
    showEducationalInfo: async (): Promise<{success: boolean}> => {
      if (!moduleConfigured) {
        throw new Error(
          'AriseMobileSdk not configured. Call AriseMobileSdk.configure(environment) before invoking ttp.showEducationalInfo.',
        );
      }
      const module = ensureModule();
      return await module.showEducationalInfo();
    },
  },
};

export default AriseMobileSdk;
