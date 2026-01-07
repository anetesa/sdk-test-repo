import {renderHook, act} from '@testing-library/react-native';
import {useTransactionStore} from '../transactionStore';

describe('transactionStore', () => {
  beforeEach(() => {
    // Reset store before each test
    act(() => {
      useTransactionStore.getState().reset();
    });
  });

  describe('setUseCardPrice', () => {
    it('should set useCardPrice to true', () => {
      const {result} = renderHook(() => useTransactionStore());

      act(() => {
        result.current.setUseCardPrice(true);
      });

      expect(result.current.useCardPrice).toBe(true);
    });

    it('should set useCardPrice to false', () => {
      const {result} = renderHook(() => useTransactionStore());

      act(() => {
        result.current.setUseCardPrice(false);
      });

      expect(result.current.useCardPrice).toBe(false);
    });

    it('should set useCardPrice to undefined', () => {
      const {result} = renderHook(() => useTransactionStore());

      // First set to true
      act(() => {
        result.current.setUseCardPrice(true);
      });

      expect(result.current.useCardPrice).toBe(true);

      // Then set to undefined
      act(() => {
        result.current.setUseCardPrice(undefined);
      });

      expect(result.current.useCardPrice).toBeUndefined();
    });

    it('should maintain useCardPrice value with other store actions', () => {
      const {result} = renderHook(() => useTransactionStore());

      act(() => {
        result.current.setUseCardPrice(true);
        result.current.setAmount(100);
        result.current.setCardNumber('4111111111111111');
      });

      expect(result.current.useCardPrice).toBe(true);
      expect(result.current.amount).toBe(100);
      expect(result.current.cardNumber).toBe('4111111111111111');
    });

    it('should reset useCardPrice to undefined when store is reset', () => {
      const {result} = renderHook(() => useTransactionStore());

      act(() => {
        result.current.setUseCardPrice(true);
        result.current.setAmount(100);
      });

      expect(result.current.useCardPrice).toBe(true);

      act(() => {
        result.current.reset();
      });

      expect(result.current.useCardPrice).toBeUndefined();
      expect(result.current.amount).toBe(0); // Verify other fields are also reset
    });

    it('should preserve useCardPrice but reset other fields when retrying transaction', () => {
      const {result} = renderHook(() => useTransactionStore());

      act(() => {
        result.current.setUseCardPrice(true);
        result.current.setAmount(100);
        result.current.setCardNumber('4111111111111111');
      });

      expect(result.current.useCardPrice).toBe(true);
      expect(result.current.amount).toBe(100);
      expect(result.current.cardNumber).toBe('4111111111111111');

      act(() => {
        result.current.retryTransaction();
      });

      // retryTransaction should preserve the amount and reset other fields
      expect(result.current.useCardPrice).toBeUndefined();
      expect(result.current.amount).toBe(100); // Amount should be preserved
      expect(result.current.cardNumber).toBe(''); // Other fields should be reset
    });
  });

  describe('initial state', () => {
    it('should have useCardPrice as undefined initially', () => {
      const {result} = renderHook(() => useTransactionStore());

      expect(result.current.useCardPrice).toBeUndefined();
    });
  });

  describe('setters update state', () => {
    it('sets primitive fields correctly', () => {
      const {result} = renderHook(() => useTransactionStore());
      act(() => {
        result.current.setAmount(123.45);
        result.current.setAccountNumber('acc');
        result.current.setCardNumber('4111');
        result.current.setExpDate('12/30');
        result.current.setCvv('123');
        result.current.setZipCode('90210');
        result.current.setSecurityCode('SEC');
        result.current.setReferenceId('REF-1');
      });
      expect(result.current.amount).toBe(123.45);
      expect(result.current.accountNumber).toBe('acc');
      expect(result.current.cardNumber).toBe('4111');
      expect(result.current.expDate).toBe('12/30');
      expect(result.current.cvv).toBe('123');
      expect(result.current.zipCode).toBe('90210');
      expect(result.current.securityCode).toBe('SEC');
      expect(result.current.referenceId).toBe('REF-1');
    });

    it('sets object fields correctly', () => {
      const {result} = renderHook(() => useTransactionStore());
      const customer = {id: 'c1', name: 'John'};
      act(() => {
        result.current.setCustomer(customer);
        result.current.setBinData(7);
        result.current.setPayLink('plink');
        result.current.setSurchargeAmount(1.23);
        result.current.setTotalAmount(10.5);
        result.current.setSurchargeRate(3.2);
        result.current.setPaymentProcessorId('pp-1');
        result.current.setSettingsAutofill({
          l2Settings: {taxRate: 8},
          l3Settings: {
            shippingCharge: 2,
            dutyChargeRate: 1,
            product: {
              name: 'p',
              code: 'c',
              unitPrice: 1,
              measurementUnit: 'u',
              quantity: 1,
              discountPercentage: 0,
              description: null,
              discountRate: 0,
            },
          },
        } as any);
        result.current.setResponse({} as any);
      });
      expect(result.current.customer).toEqual(customer);
      expect(result.current.binData).toBe(7);
      expect(result.current.payLink).toBe('plink');
      expect(result.current.surchargeAmount).toBe(1.23);
      expect(result.current.totalAmount).toBe(10.5);
      expect(result.current.surchargeRate).toBe(3.2);
      expect(result.current.paymentProcessorId).toBe('pp-1');
      expect(result.current.settingsAutofill?.l2Settings.taxRate).toBe(8);
      expect(result.current.response).toEqual({});
    });
  });
});
