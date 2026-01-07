import {
  getAmountByType,
  getTotalAmount,
  getSurchargeAmount,
  TransactionAmountData,
  BinData,
} from '../transactionAmountHelpers';
import {BinDataType} from '../../dictionaries/BinData';

describe('transactionAmountHelpers', () => {
  const mockTransactionData: TransactionAmountData = {
    creditCard: {
      totalAmount: 100.5,
      surchargeAmount: 2.5,
    },
    debitCard: {
      totalAmount: 95.0,
      surchargeAmount: 1.25,
    },
  };

  describe('getAmountByType', () => {
    it('returns 0 when binData is null', () => {
      const result = getAmountByType(null, mockTransactionData, 'totalAmount');
      expect(result).toBe(0);
    });

    it('returns 0 when binData is undefined', () => {
      const result = getAmountByType(
        undefined,
        mockTransactionData,
        'totalAmount',
      );
      expect(result).toBe(0);
    });

    it('returns 0 when binData.typeId is undefined', () => {
      const binData: BinData = {};
      const result = getAmountByType(
        binData,
        mockTransactionData,
        'totalAmount',
      );
      expect(result).toBe(0);
    });

    it('returns 0 when transactionData is null', () => {
      const binData: BinData = {typeId: BinDataType.Credit};
      const result = getAmountByType(binData, null, 'totalAmount');
      expect(result).toBe(0);
    });

    it('returns 0 when transactionData is undefined', () => {
      const binData: BinData = {typeId: BinDataType.Credit};
      const result = getAmountByType(binData, undefined, 'totalAmount');
      expect(result).toBe(0);
    });

    it('returns credit card total amount for credit BIN type', () => {
      const binData: BinData = {typeId: BinDataType.Credit};
      const result = getAmountByType(
        binData,
        mockTransactionData,
        'totalAmount',
      );
      expect(result).toBe(100.5);
    });

    it('returns credit card surcharge amount for credit BIN type', () => {
      const binData: BinData = {typeId: BinDataType.Credit};
      const result = getAmountByType(
        binData,
        mockTransactionData,
        'surchargeAmount',
      );
      expect(result).toBe(2.5);
    });

    it('returns debit card total amount for debit BIN type', () => {
      const binData: BinData = {typeId: BinDataType.Debit};
      const result = getAmountByType(
        binData,
        mockTransactionData,
        'totalAmount',
      );
      expect(result).toBe(95.0);
    });

    it('returns debit card surcharge amount for debit BIN type', () => {
      const binData: BinData = {typeId: BinDataType.Debit};
      const result = getAmountByType(
        binData,
        mockTransactionData,
        'surchargeAmount',
      );
      expect(result).toBe(1.25);
    });

    it('returns 0 for unknown BIN type', () => {
      const binData: BinData = {typeId: BinDataType.Unknown};
      const result = getAmountByType(
        binData,
        mockTransactionData,
        'totalAmount',
      );
      expect(result).toBe(0);
    });

    it('returns 0 when credit card data is missing', () => {
      const incompleteData: TransactionAmountData = {
        debitCard: mockTransactionData.debitCard,
      };
      const binData: BinData = {typeId: BinDataType.Credit};
      const result = getAmountByType(binData, incompleteData, 'totalAmount');
      expect(result).toBe(0);
    });

    it('returns 0 when debit card data is missing', () => {
      const incompleteData: TransactionAmountData = {
        creditCard: mockTransactionData.creditCard,
      };
      const binData: BinData = {typeId: BinDataType.Debit};
      const result = getAmountByType(binData, incompleteData, 'totalAmount');
      expect(result).toBe(0);
    });

    it('returns 0 when specific amount property is missing', () => {
      const incompleteData: TransactionAmountData = {
        creditCard: {
          totalAmount: 100.5,
          // surchargeAmount is missing
        },
      };
      const binData: BinData = {typeId: BinDataType.Credit};
      const result = getAmountByType(
        binData,
        incompleteData,
        'surchargeAmount',
      );
      expect(result).toBe(0);
    });
  });

  describe('getTotalAmount', () => {
    it('returns credit card total amount for credit BIN type', () => {
      const binData: BinData = {typeId: BinDataType.Credit};
      const result = getTotalAmount(binData, mockTransactionData);
      expect(result).toBe(100.5);
    });

    it('returns debit card total amount for debit BIN type', () => {
      const binData: BinData = {typeId: BinDataType.Debit};
      const result = getTotalAmount(binData, mockTransactionData);
      expect(result).toBe(95.0);
    });

    it('returns 0 for invalid data', () => {
      const result = getTotalAmount(null, null);
      expect(result).toBe(0);
    });
  });

  describe('getSurchargeAmount', () => {
    it('returns credit card surcharge amount for credit BIN type', () => {
      const binData: BinData = {typeId: BinDataType.Credit};
      const result = getSurchargeAmount(binData, mockTransactionData);
      expect(result).toBe(2.5);
    });

    it('returns debit card surcharge amount for debit BIN type', () => {
      const binData: BinData = {typeId: BinDataType.Debit};
      const result = getSurchargeAmount(binData, mockTransactionData);
      expect(result).toBe(1.25);
    });

    it('returns 0 for invalid data', () => {
      const result = getSurchargeAmount(null, null);
      expect(result).toBe(0);
    });
  });
});
