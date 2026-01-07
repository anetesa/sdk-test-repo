import {TransactionSalePayload} from '../TransactionSale';

describe('TransactionSale Types', () => {
  it('should include useCardPrice property in payload', () => {
    const payload: TransactionSalePayload = {
      merchantId: 'merchant123',
      amount: 100,
      cardNumber: '4111111111111111',
      expirationMonth: 12,
      expirationYear: 2025,
      securityCode: '123',
      useCardPrice: true,
    };

    expect(payload.useCardPrice).toBe(true);
    expect(typeof payload.useCardPrice).toBe('boolean');
  });

  it('should allow useCardPrice to be null', () => {
    const payload: TransactionSalePayload = {
      merchantId: 'merchant123',
      amount: 100,
      cardNumber: '4111111111111111',
      expirationMonth: 12,
      expirationYear: 2025,
      securityCode: '123',
      useCardPrice: null,
    };

    expect(payload.useCardPrice).toBeNull();
  });

  it('should allow useCardPrice to be undefined', () => {
    const payload: TransactionSalePayload = {
      merchantId: 'merchant123',
      amount: 100,
      cardNumber: '4111111111111111',
      expirationMonth: 12,
      expirationYear: 2025,
      securityCode: '123',
    };

    expect(payload.useCardPrice).toBeUndefined();
  });

  it('should support both boolean values for useCardPrice', () => {
    const payloadTrue: TransactionSalePayload = {
      merchantId: 'merchant123',
      amount: 100,
      cardNumber: '4111111111111111',
      expirationMonth: 12,
      expirationYear: 2025,
      securityCode: '123',
      useCardPrice: true,
    };

    const payloadFalse: TransactionSalePayload = {
      merchantId: 'merchant123',
      amount: 100,
      cardNumber: '4111111111111111',
      expirationMonth: 12,
      expirationYear: 2025,
      securityCode: '123',
      useCardPrice: false,
    };

    expect(payloadTrue.useCardPrice).toBe(true);
    expect(payloadFalse.useCardPrice).toBe(false);
  });
});
