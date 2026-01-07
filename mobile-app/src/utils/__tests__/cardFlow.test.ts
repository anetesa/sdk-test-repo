import {describe, it, expect} from '@jest/globals';
import {maskPan, getPaymentProcessorCardId} from '../cardFlow';
import {
  ArisePaymentProcessor,
  ArisePaymentSettings,
} from '../../native/AriseMobileSdk';
import {PaymentProcessorType} from '../../dictionaries/PaymentProcessorType';

const createSettings = (
  processors: ArisePaymentProcessor[] | null | undefined,
): ArisePaymentSettings =>
  ({
    availableCurrencies: [],
    zeroCostProcessingOptionId: null,
    zeroCostProcessingOption: null,
    defaultSurchargeRate: null,
    defaultCashDiscountRate: null,
    defaultDualPricingRate: null,
    isTipsEnabled: false,
    defaultTipsOptions: [],
    availableCardTypes: [],
    availableTransactionTypes: [],
    availablePaymentProcessors: processors ?? [],
    avs: null,
    isCustomerCardSavingByTerminalEnabled: false,
  } as ArisePaymentSettings);

const createProcessor = (
  overrides: Partial<ArisePaymentProcessor> = {},
): ArisePaymentProcessor => ({
  id: 'processor-id',
  name: 'Processor',
  isDefault: false,
  typeId: PaymentProcessorType.Tsys,
  type: 'TSYS',
  settlementBatchTimeSlots: [],
  ...overrides,
});

describe('maskPan', () => {
  it('returns empty string when account is undefined', () => {
    expect(maskPan(undefined)).toBe('');
  });

  it('returns empty string when account is empty', () => {
    expect(maskPan('')).toBe('');
  });

  it('returns the account as-is when length is less than 4', () => {
    expect(maskPan('1')).toBe('1');
    expect(maskPan('12')).toBe('12');
    expect(maskPan('abc')).toBe('abc');
  });

  it('masks correctly when length is exactly 4', () => {
    expect(maskPan('1234')).toBe('**** 1234');
  });

  it('masks correctly when length is greater than 4', () => {
    expect(maskPan('00001234')).toBe('**** 1234');
    expect(maskPan('987654321')).toBe('**** 4321');
  });
});

describe('getPaymentProcessorCardId', () => {
  it('returns empty string when data is undefined', () => {
    expect(getPaymentProcessorCardId(undefined)).toBe('');
  });

  it('returns empty string when paymentProcessors is not an array', () => {
    const invalidData = {
      availablePaymentProcessors: null,
    } as unknown as ArisePaymentSettings;
    expect(getPaymentProcessorCardId(invalidData)).toBe('');
  });

  it('returns empty string when paymentProcessors array is empty', () => {
    const data = createSettings([]);
    expect(getPaymentProcessorCardId(data)).toBe('');
  });

  it('returns empty string when no payment processors have Card payment method', () => {
    const data = createSettings([
      createProcessor({
        id: 'pp1',
        typeId: PaymentProcessorType.Ach,
        type: 'ACH',
        isDefault: true,
      }),
    ]);
    expect(getPaymentProcessorCardId(data)).toBe('');
  });

  it('returns empty string when multiple processors exist but none are Cards', () => {
    const data = createSettings([
      createProcessor({
        id: 'pp1',
        typeId: PaymentProcessorType.Ach,
        type: 'ACH',
        isDefault: true,
      }),
      createProcessor({
        id: 'pp2',
        typeId: 3,
        type: 'Wire',
        isDefault: false,
      }),
    ]);
    expect(getPaymentProcessorCardId(data)).toBe('');
  });

  it('returns card id when single processor is both default and Card', () => {
    const data = createSettings([
      createProcessor({
        id: 'single-card-pp',
        name: 'Single Card Processor',
        isDefault: true,
      }),
    ]);
    expect(getPaymentProcessorCardId(data)).toBe('single-card-pp');
  });

  it('returns first card id when there are cards but none are default', () => {
    const data = createSettings([
      createProcessor({
        id: 'pp1',
        name: 'Card Processor 1',
      }),
      createProcessor({
        id: 'pp2',
        name: 'Card Processor 2',
      }),
    ]);
    expect(getPaymentProcessorCardId(data)).toBe('pp1');
  });

  it('returns the id when there is a default card with an id', () => {
    const data = createSettings([
      createProcessor({
        id: 'pp1',
        name: 'Card Processor 1',
        isDefault: false,
      }),
      createProcessor({
        id: 'pp2',
        name: 'Default Card Processor',
        isDefault: true,
      }),
    ]);
    expect(getPaymentProcessorCardId(data)).toBe('pp2');
  });

  it('handles mixed payment methods and returns only the default card id', () => {
    const data = createSettings([
      createProcessor({
        id: 'pp1',
        name: 'Bank Transfer Processor',
        isDefault: true,
        typeId: PaymentProcessorType.Ach,
        type: 'ACH',
      }),
      createProcessor({
        id: 'pp2',
        name: 'Card Processor',
        isDefault: false,
      }),
      createProcessor({
        id: 'pp3',
        name: 'Default Card Processor',
        isDefault: true,
      }),
    ]);
    expect(getPaymentProcessorCardId(data)).toBe('pp3');
  });

  it('handles real scenario with ACH as default and TSYS as card', () => {
    const data = createSettings([
      createProcessor({
        id: '82668bdb-8169-4162-aece-b3e78c86a3d1',
        name: 'ACH',
        isDefault: true,
        typeId: PaymentProcessorType.Ach,
        type: 'ACH',
      }),
      createProcessor({
        id: 'fd0959b0-7778-46ef-9542-7dc82c90eddd',
        name: 'TSYS',
        isDefault: false,
        typeId: PaymentProcessorType.Tsys,
        type: 'TSYS',
      }),
    ]);
    expect(getPaymentProcessorCardId(data)).toBe(
      'fd0959b0-7778-46ef-9542-7dc82c90eddd',
    );
  });
});
