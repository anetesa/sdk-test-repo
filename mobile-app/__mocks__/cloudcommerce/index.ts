// Mock for CloudCommerce module to prevent NativeEventEmitter errors in tests

export type CloudCommerceEvent =
  | {type: 'StatusUpdate'; message: string}
  | {type: 'ReaderProgress'; message: string; progress: number}
  | {type: 'ReaderState'; message: string; state: string}
  | {type: 'Error'; message: string; code: string}
  | {type: 'TransactionState'; message: string; state: string}
  | {type: 'TransactionResult'; message: string; success: boolean}
  | {type: 'UnknownEvent'; message: string; description: string};

export type MerchantConfig = {
  isPayByLinkEnabled: boolean;
  paymentNetworks: string[];
};

export type SupportContacts = {
  emails?: string[];
  phones?: string[];
};

export type CurrencyData = {
  countryName: string;
  countryCode: string;
  currencyCodeISO: string;
  countryCurrencySymbol: string;
  currencyCode: string;
  isCurrencyAfter: boolean;
};

export type MerchantDetails = {
  merchantConfig: MerchantConfig;
  supportContacts?: SupportContacts;
  currencyData: CurrencyData[];
  merchantDisplayName?: string;
};

export type SdkInformation = {
  posIdentifier: string | null;
  deviceIdentifier: string;
  merchantDetails: MerchantDetails | null;
  version: string;
  information: {[key: string]: any} | null;
  sessionExpiryTime: string | null;
};

export type Merchant = {
  bannerName: string;
  categoryCode: string;
  terminalProfileId: string;
  currencyCode: string;
  countryCode: string;
};

export type TransactionDetails = {
  amount: number;
  currencyCode: 'USD';
  countryCode: string;
  tip: string;
  discount: string;
  salesTaxAmount: string;
  federalTaxAmount: string;
  customData: string | undefined;
  subTotal: string;
  orderId: string;
};

// Mock CloudCommerce object
const CloudCommerce = {
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
};

export default CloudCommerce;
