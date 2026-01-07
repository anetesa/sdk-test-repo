import {jest, describe, it, expect} from '@jest/globals';
import {renderHook, waitFor} from '@testing-library/react-native';
import {usePendoSessionManagement} from '../usePendoSessionManagement';
import {PendoSDK} from 'rn-pendo-sdk';

jest.mock('rn-pendo-sdk', () => ({
  PendoSDK: {
    startSession: jest.fn(),
  },
}));

jest.mock('@/utils/pendo', () => ({
  initPendo: jest.fn(),
}));

jest.mock('@/hooks/queries/useMeProfile', () => ({
  useMeProfile: () => ({
    data: {
      id: 'user-1',
      userType: 'merchant',
      selectedProfileRoleName: 'Admin',
      profiles: [
        {
          merchantId: 'm-1',
          mccCode: '1234',
          mccCodeDescription: 'Test MCC',
          isMainContact: true,
        },
      ],
    },
  }),
}));

jest.mock('@/hooks/queries/useMerchantSettings', () => ({
  useMerchantSettings: () => ({
    data: {
      merchantSettings: {
        zeroCostProcessingOptionId: 4, // Surcharge
        defaultDualPricingRate: null,
        defaultCashDiscountRate: null,
        defaultSurchargeRate: 3,
        useCardPrice: true,
        isTipsEnabled: true,
      },
      customizationSettings: {logoUrl: 'http://example.com/logo.png'},
      avsSettings: {isAvsEnabled: true, avsMerchantProfile: 1},
    },
  }),
}));

jest.mock('@/hooks/queries/useMerchantFeatures', () => ({
  useMerchantFeatures: () => ({
    data: {
      isCardNetworkTokenizationEnabled: true,
      isEFTEnabled: true,
      isEnhancedDataEnabled: true,
      isSmsNotificationsEnabled: false,
    },
  }),
}));

jest.mock('@/hooks/queries/useApiSettings', () => ({
  useApiSettings: () => ({
    data: {
      avsMerchantProfiles: [{id: 1, name: 'Default AVS'}],
    },
    refetch: jest.fn(),
  }),
}));

jest.mock('@/hooks/queries/usePaymentsSettings', () => ({
  usePaymentsSettings: () => ({
    data: {
      availableCurrencies: [],
      zeroCostProcessingOptionId: 4,
      zeroCostProcessingOption: null,
      defaultSurchargeRate: 3,
      defaultCashDiscountRate: null,
      defaultDualPricingRate: null,
      isTipsEnabled: true,
      defaultTipsOptions: [],
      availableCardTypes: [],
      availableTransactionTypes: [],
      availablePaymentProcessors: [],
      avs: null,
      isCustomerCardSavingByTerminalEnabled: false,
      isDualPricingEnabled: false,
    },
    isLoading: false,
    isError: false,
    error: null,
  }),
}));

jest.mock('@/stores/userStore', () => ({
  useUserStore: Object.assign(
    jest.fn((selector: any) => {
      const state = {
        id: 'user-1',
        merchantId: 'merchant-123',
      };
      if (typeof selector === 'function') {
        return selector(state);
      }
      return state;
    }),
    {
      getState: () => ({
        id: 'user-1',
        merchantId: 'merchant-123',
      }),
    },
  ),
}));

describe('usePendoSessionManagement', () => {
  it('starts Pendo session with ZCPMode mapped to Surcharge', async () => {
    const {result} = renderHook(() => usePendoSessionManagement());
    expect(result.current.refetchApiSettings).toBeDefined();

    await waitFor(() => {
      expect(PendoSDK.startSession).toHaveBeenCalled();
    });

    const lastCallArgs =
      (PendoSDK.startSession as jest.Mock).mock.calls.pop() ?? [];
    // [visitorId, accountId, visitorData, accountData]
    const accountData = lastCallArgs[3] as Record<string, unknown>;
    expect(accountData?.ZCPMode).toBe('Surcharge');
  });
});
