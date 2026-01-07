import {GetApiTransactionsCalculateAmountParams} from '../CalculateAmount';

describe('CalculateAmount Types', () => {
  it('should have correct structure for GetApiTransactionsCalculateAmountParams', () => {
    const params: GetApiTransactionsCalculateAmountParams = {
      merchantId: 'merchant123',
      amount: 100,
      useCardPrice: true,
      currencyId: 1,
    };

    expect(params.merchantId).toBe('merchant123');
    expect(params.amount).toBe(100);
    expect(params.useCardPrice).toBe(true);
    expect(params.currencyId).toBe(1);
  });

  it('should allow optional parameters', () => {
    const params: GetApiTransactionsCalculateAmountParams = {
      merchantId: 'merchant123',
      amount: 100,
    };

    expect(params.merchantId).toBe('merchant123');
    expect(params.amount).toBe(100);
    expect(params.useCardPrice).toBeUndefined();
    expect(params.surchargeRate).toBeUndefined();
  });

  it('should support dual pricing parameter useCardPrice as boolean', () => {
    const paramsTrue: GetApiTransactionsCalculateAmountParams = {
      merchantId: 'merchant123',
      amount: 100,
      useCardPrice: true,
    };

    const paramsFalse: GetApiTransactionsCalculateAmountParams = {
      merchantId: 'merchant123',
      amount: 100,
      useCardPrice: false,
    };

    expect(typeof paramsTrue.useCardPrice).toBe('boolean');
    expect(typeof paramsFalse.useCardPrice).toBe('boolean');
    expect(paramsTrue.useCardPrice).toBe(true);
    expect(paramsFalse.useCardPrice).toBe(false);
  });
});
