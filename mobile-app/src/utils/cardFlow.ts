import {CARD_DISPLAY, CARD_DEFAULTS} from '@/constants/cardValidation';
import {BinDataType} from '@/dictionaries/BinData';
import {ArisePaymentSettings} from '@/native/AriseMobileSdk';
import {PaymentProcessorType} from '@/dictionaries/PaymentProcessorType';

export const maskPan = (account: string | undefined) => {
  if (!account) {
    return CARD_DEFAULTS.EMPTY_STRING;
  }
  if (account.length >= CARD_DISPLAY.LAST_DIGITS_COUNT) {
    return `${CARD_DISPLAY.MASK_PATTERN}${account.slice(
      -CARD_DISPLAY.LAST_DIGITS_COUNT,
    )}`;
  }
  return account;
};

export const getCardType = (type?: BinDataType | number | null): string => {
  switch (type) {
    case BinDataType.Credit:
      return 'Credit';
    case BinDataType.Debit:
      return 'Debit';
    case BinDataType.Unknown:
      return 'Unknown';
    default:
      return 'Unknown';
  }
};

export function getPaymentProcessorCardId(
  data: ArisePaymentSettings | undefined,
) {
  if (!data || !Array.isArray(data.availablePaymentProcessors)) {
    return CARD_DEFAULTS.EMPTY_STRING;
  }

  const cards = data.availablePaymentProcessors.filter(
    pp => pp.typeId === PaymentProcessorType.Tsys,
  );

  if (cards.length === CARD_DEFAULTS.ZERO_VALUE) {
    return CARD_DEFAULTS.EMPTY_STRING;
  }

  const defaultCard = cards.find(pp => pp.isDefault === true);
  return defaultCard?.id || cards[0].id || CARD_DEFAULTS.EMPTY_STRING;
}
