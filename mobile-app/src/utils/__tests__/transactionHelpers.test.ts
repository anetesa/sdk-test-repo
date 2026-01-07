import {getTransactionCount} from '../transactionHelpers';

describe('getTransactionCount', () => {
  describe('Feature flag combinations', () => {
    it('should return 5 transactions when both features are disabled', () => {
      const result = getTransactionCount(false, false);
      expect(result).toBe(5);
    });

    it('should return 4 transactions when only new transaction is enabled', () => {
      const result = getTransactionCount(false, true);
      expect(result).toBe(4);
    });

    it('should return 2 transactions when both features are enabled', () => {
      const result = getTransactionCount(true, true);
      expect(result).toBe(2);
    });

    it('should return 4 transactions when only feedback is enabled (default fallback)', () => {
      const result = getTransactionCount(true, false);
      expect(result).toBe(4);
    });
  });

  describe('Business rules verification', () => {
    it('should prioritize showing fewer transactions when both features are active', () => {
      // When both features are on, we show the minimum (2) to make room for both UI elements
      expect(getTransactionCount(true, true)).toBe(2);
    });

    it('should show maximum transactions when no additional UI is needed', () => {
      // When no features are on, we can show the most transactions (5)
      expect(getTransactionCount(false, false)).toBe(5);
    });

    it('should handle single feature scenarios consistently', () => {
      // Both single-feature scenarios should show the same count (4)
      expect(getTransactionCount(false, true)).toBe(4); // Only new transaction
      expect(getTransactionCount(true, false)).toBe(4); // Only feedback
    });
  });

  describe('Edge cases and type safety', () => {
    it('should handle boolean parameters correctly', () => {
      // Test with explicit boolean values to ensure type safety
      expect(getTransactionCount(true as boolean, false as boolean)).toBe(4);
      expect(getTransactionCount(false as boolean, true as boolean)).toBe(4);
    });

    it('should always return a positive number', () => {
      const testCases = [
        [false, false],
        [false, true],
        [true, false],
        [true, true],
      ] as const;

      testCases.forEach(([feedback, newTransaction]) => {
        const result = getTransactionCount(feedback, newTransaction);
        expect(result).toBeGreaterThan(0);
        expect(Number.isInteger(result)).toBe(true);
      });
    });
  });
});
