import React from 'react';
import creditcardutils from 'creditcardutils';
import {
  getCardIcon,
  getCardIconFromNumber,
  findDebitCardType,
  CardIssuersMap,
} from '../card';

jest.mock('creditcardutils', () => ({
  __esModule: true,
  default: {
    parseCardType: jest.fn(),
  },
}));

describe('card utils', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('getCardIcon returns undefined for falsy name', () => {
    expect(getCardIcon(undefined)).toBeUndefined();
    expect(getCardIcon(null)).toBeUndefined();
  });

  it('getCardIcon returns matching icon or undefined for unknown', () => {
    const visa = getCardIcon(CardIssuersMap.Visa);
    const unknown = getCardIcon('non-existent');
    const otherExplicit = getCardIcon(CardIssuersMap.Other);
    expect(React.isValidElement(visa)).toBe(true);
    expect(unknown).toBeUndefined();
    expect(React.isValidElement(otherExplicit as any)).toBe(true);
  });

  it('getCardIconFromNumber returns Other for empty and maps by parsed type', () => {
    // Empty
    const emptyIcon = getCardIconFromNumber(undefined);
    expect(React.isValidElement(emptyIcon)).toBe(true);

    // Parsed card type
    (creditcardutils.parseCardType as jest.Mock).mockReturnValue(
      CardIssuersMap.MasterCard,
    );
    const mcIcon = getCardIconFromNumber('5555 4444 3333 2222');
    expect(React.isValidElement(mcIcon)).toBe(true);
  });

  it('findDebitCardType returns React components for card types', () => {
    // For card number without asterisks, should return React component
    const visaIcon = findDebitCardType('4111 1111 1111 1111');
    expect(React.isValidElement(visaIcon)).toBe(true);

    // For empty string, should return null
    expect(findDebitCardType('')).toBeNull();

    // For unknown card pattern with asterisks, should return Other icon component
    const otherIcon = findDebitCardType('0000****0000');
    expect(React.isValidElement(otherIcon)).toBe(true);

    // For American Express with asterisks (like the user's case)
    const amexIcon = findDebitCardType('370382*****7520');
    expect(React.isValidElement(amexIcon)).toBe(true);
  });
});
