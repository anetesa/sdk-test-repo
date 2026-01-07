import {MerchantSettings} from '../MerchantIdSettings';

describe('MerchantIdSettings Types', () => {
  it('should have new dual pricing properties', () => {
    const merchantSettings: MerchantSettings = {
      merchantId: 'merchant123',
      merchantName: 'Test Merchant',
      defaultSurchargeRate: 0.025,
      defaultCashDiscountRate: 0.02,
      defaultDualPricingRate: 0.03,
      numberOfRetriesOnFailure: 3,
      intervalDaysBetweenRetriesOnFailure: 1,
      binCheckFallbackEnabled: true,
      isCashDiscountEnabled: true,
      isDualPricingEnabled: true,
      isSurchargeEnabled: true,
    };

    expect(merchantSettings.isCashDiscountEnabled).toBe(true);
    expect(merchantSettings.isDualPricingEnabled).toBe(true);
    expect(merchantSettings.isSurchargeEnabled).toBe(true);
  });

  it('should allow new properties to be optional', () => {
    const merchantSettings: MerchantSettings = {
      merchantId: 'merchant123',
      merchantName: 'Test Merchant',
      defaultSurchargeRate: 0.025,
      numberOfRetriesOnFailure: 3,
      intervalDaysBetweenRetriesOnFailure: 1,
      binCheckFallbackEnabled: true,
    };

    expect(merchantSettings.isCashDiscountEnabled).toBeUndefined();
    expect(merchantSettings.isDualPricingEnabled).toBeUndefined();
    expect(merchantSettings.isSurchargeEnabled).toBeUndefined();
  });

  it('should support boolean type for new pricing flags', () => {
    const settingsTrue: Partial<MerchantSettings> = {
      isCashDiscountEnabled: true,
      isDualPricingEnabled: true,
      isSurchargeEnabled: true,
    };

    const settingsFalse: Partial<MerchantSettings> = {
      isCashDiscountEnabled: false,
      isDualPricingEnabled: false,
      isSurchargeEnabled: false,
    };

    expect(typeof settingsTrue.isCashDiscountEnabled).toBe('boolean');
    expect(typeof settingsTrue.isDualPricingEnabled).toBe('boolean');
    expect(typeof settingsTrue.isSurchargeEnabled).toBe('boolean');

    expect(typeof settingsFalse.isCashDiscountEnabled).toBe('boolean');
    expect(typeof settingsFalse.isDualPricingEnabled).toBe('boolean');
    expect(typeof settingsFalse.isSurchargeEnabled).toBe('boolean');
  });
});
