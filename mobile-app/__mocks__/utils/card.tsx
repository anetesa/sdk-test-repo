import React from 'react';

// Mock card issuer constants
export const CardIssuersMap = {
  Visa: 'visa',
  MasterCard: 'mastercard',
  AmericanExpress: 'amex',
  JCB: 'jcb',
  EFT: 'eft',
  Discover: 'discover',
  DinersClub: 'dinersclub',
  UnionPay: 'unionpay',
  Other: 'other',
};

// Mock component for card icons
const MockCardIcon = () => <div data-testid="mock-card-icon">Card Icon</div>;

export const CardIssuersIcons = {
  [CardIssuersMap.Visa]: <MockCardIcon />,
  [CardIssuersMap.MasterCard]: <MockCardIcon />,
  [CardIssuersMap.AmericanExpress]: <MockCardIcon />,
  [CardIssuersMap.JCB]: <MockCardIcon />,
  [CardIssuersMap.EFT]: <MockCardIcon />,
  [CardIssuersMap.Discover]: <MockCardIcon />,
  [CardIssuersMap.UnionPay]: <MockCardIcon />,
  [CardIssuersMap.DinersClub]: <MockCardIcon />,
  [CardIssuersMap.Other]: <MockCardIcon />,
};

export const getCardIcon = jest.fn((name?: string | null) => {
  return name ? <MockCardIcon /> : undefined;
});

export const getCardIconFromNumber = jest.fn((cardNumber?: string | null) => {
  return <MockCardIcon />;
});

export const findDebitCardType = jest.fn((cardNumber: string) => {
  if (!cardNumber) {
    return null;
  }
  return <MockCardIcon />;
});

export type CardIssuers = {
  readonly Visa: string;
  readonly MasterCard: string;
  readonly AmericanExpress: string;
  readonly JCB: string;
  readonly EFT: string;
  readonly Discover: string;
  readonly UnionPay: string;
  readonly DinersClub: string;
  readonly Other: string;
};
