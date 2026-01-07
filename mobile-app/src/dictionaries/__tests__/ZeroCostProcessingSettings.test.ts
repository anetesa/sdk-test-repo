import {
  ZeroCostProcessingType,
  ZeroCostProcessingTypes,
} from '../ZeroCostProcessingSettings';

describe('ZeroCostProcessingSettings dictionary', () => {
  it('provides names for each ZCP type', () => {
    expect(ZeroCostProcessingTypes.getName(ZeroCostProcessingType.None)).toBe(
      'None',
    );
    expect(
      ZeroCostProcessingTypes.getName(ZeroCostProcessingType.DualPricing),
    ).toBe('Dual Pricing');
    expect(
      ZeroCostProcessingTypes.getName(ZeroCostProcessingType.CashDiscount),
    ).toBe('Cash Discount');
    expect(
      ZeroCostProcessingTypes.getName(ZeroCostProcessingType.Surcharge),
    ).toBe('Credit Card Surcharge');
  });
});
