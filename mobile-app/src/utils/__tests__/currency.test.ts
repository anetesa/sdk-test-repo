import {formatAmountForDisplay} from '../currency';

describe('formatAmountForDisplay', () => {
  it('should format amounts from cents correctly', () => {
    expect(formatAmountForDisplay({cents: 12345})).toBe('123.45');
    expect(formatAmountForDisplay({cents: 100})).toBe('1.00');
    expect(formatAmountForDisplay({cents: 99})).toBe('0.99');
    expect(formatAmountForDisplay({cents: 0})).toBe('0.00');
    expect(formatAmountForDisplay({cents: 100000000})).toBe('1,000,000.00');
  });

  it('should format amounts from dollars correctly', () => {
    expect(formatAmountForDisplay({dollars: 123.45})).toBe('123.45');
    expect(formatAmountForDisplay({dollars: 1.0})).toBe('1.00');
    expect(formatAmountForDisplay({dollars: 0.99})).toBe('0.99');
    expect(formatAmountForDisplay({dollars: 0})).toBe('0.00');
    expect(formatAmountForDisplay({dollars: 0.9})).toBe('0.90');
    expect(formatAmountForDisplay({dollars: 1000000})).toBe('1,000,000.00');
  });

  it('should handle null and undefined values', () => {
    expect(formatAmountForDisplay({cents: null})).toBe('0.00');
    expect(formatAmountForDisplay({cents: undefined})).toBe('0.00');
    expect(formatAmountForDisplay({dollars: null})).toBe('0.00');
    expect(formatAmountForDisplay({dollars: undefined})).toBe('0.00');
    expect(formatAmountForDisplay({})).toBe('0.00');
  });

  it('should prioritize cents over dollars when both are provided', () => {
    expect(formatAmountForDisplay({cents: 150, dollars: 2.0})).toBe('1.50');
  });
});
