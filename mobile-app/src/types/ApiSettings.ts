export type ApiSettings = {
  accountHolderTypes: {id: number; name: string}[];
  accountTypes: {id: number; name: string}[];
  countries: Country[];
  allCountries: (Country | BusinessCategory)[];
  timeUnits: {id: number; name: string}[];
  timeZones: TimeZone[];
  cardTypes: {id: number; name: string}[];
  paymentProcessorTypes: {id: number; name: string}[];
  merchantStatuses: {id: number; name: string}[];
  paymentProcessorStatuses: {id: number; name: string}[];
  paymentMethodTypes: {id: number; name: string}[];
  transactionTypes: {id: number; name: string}[];
  affiliateBusinessModelTypes: {id: number; name: string}[];
  businessCategories: {id: number; name: string}[];
  affiliateStatuses: {id: number; name: string}[];
  avsMerchantProfiles: {id: number; name: string}[];
  avsActions: {id: number; name: string}[];
  avsRuleNames: {id: number; name: string}[];
  avsProfileMap: {
    [profileName: string]: {
      [ruleName: string]: 'Allow' | 'Deny';
    };
  };
  zeroCostProcessingOptions: {id: number; name: string}[];
  supportProviderTypes: {id: number; name: string}[];
  printReceiptModes: {id: number; name: string}[];
  terminalCardTypesOptions: {id: number; name: string}[];
};

type Country = {
  id: number;
  isoCode: string;
  name: string;
  states: {
    id: number;
    code: string;
    name: string;
  }[];
};

type BusinessCategory = {
  id: number;
  code: string;
  description: string;
};

type TimeZone = {
  id: number;
  name: string;
  originalTimezoneName: string;
  isDaylightSavingTime: boolean;
  offset: string;
};
