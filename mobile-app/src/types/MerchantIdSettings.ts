export interface TimeZone {
  id: number;
  name: string;
  originalTimezoneName: string;
  isDaylightSavingTime: boolean;
  offset: string;
}

export interface MerchantSettings {
  timeZone: TimeZone;
  externalIdentifier: string;
  receipt: string;
  allowedCardTypes: number[];
  defaultTipsOptions: number[];
  isTipsEnabled: boolean;
  isTipAdjustmentEnabled: boolean;
  isLimitTransactionsEnabled: boolean;
  maxTransactionAmount: number | null;
  monthlyVolumeLimit: number | null;
  maxNumberOfTransactions: number;
  maxNumberOfTransactionsPerTimeUnit: number | null;
  isDuplicatedTransactionsEnabled: boolean;
  duplicateTimeLimit: number | null;
  zeroCostProcessingOptionId: number;
  isPercentageOffEnabled: boolean;
  defaultDualPricingRate: number | null;
  useCardPrice: boolean;
  allowToOverrideDualPricingTypeInVirtualTerminal: boolean;
  defaultSurchargeRate: number;
  defaultCashDiscountRate: number | null;
  allowOverrideSurcharge: boolean;
  numberOfRetriesOnFailure: number;
  intervalDaysBetweenRetriesOnFailure: number;
  binCheckFallbackEnabled: boolean;
  isCashDiscountEnabled?: boolean;
  isDualPricingEnabled?: boolean;
  isSurchargeEnabled?: boolean;
}

export interface PaymentMethod {
  id: number;
  name: string;
}

export interface TransactionType {
  id: number;
  name: string;
}

export interface VirtualTerminalSettings {
  defaultPaymentMethod: PaymentMethod;
  isPreAuthorizeEnabled: boolean;
  defaultTransactionType: TransactionType;
}

export interface CustomizationSettings {
  logoUrl: string | null;
  isLogoUploaded: boolean;
}

export interface ACHTimeSlot {
  id: number;
  hours: number;
  minutes: number;
}

export interface ACHSettings {
  achAllowFasterProcessing: boolean;
  subscriptionProcessingTimeId: number;
  achVerificationType: number;
  achVerificationFrequency: number;
  defaultProcessingTimeSlots: ACHTimeSlot[];
}

export interface AVSSettings {
  isAvsEnabled: boolean;
  avsMerchantProfile: number;
}

export interface MerchantIdSettings {
  merchantSettings: MerchantSettings;
  virtualTerminalSettings: VirtualTerminalSettings;
  customizationSettings: CustomizationSettings;
  achSettings: ACHSettings;
  avsSettings: AVSSettings;
}
