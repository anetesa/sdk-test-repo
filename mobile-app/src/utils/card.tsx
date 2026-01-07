import React from 'react';
import creditcardutils from 'creditcardutils';
import CardMCIcon from '../../assets/cards_icon/MasterCard.svg';
import CardVisaIcon from '../../assets/cards_icon/Visa.svg';
import CardAMEXIcon from '../../assets/cards_icon/AmericanExpress.svg';
import CardDiscoverIcon from '../../assets/cards_icon/Discover.svg';
import CardDinersIcon from '../../assets/cards_icon/DinersClub.svg';
import CardJCBIcon from '../../assets/cards_icon/JCB.svg';
import CardEFTIcon from '../../assets/cards_icon/EFT.svg';
import CardOtherIcon from '../../assets/cards_icon/Other.svg';

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

export const CardIssuersMap: CardIssuers = Object.freeze({
  Visa: 'visa',
  MasterCard: 'mastercard',
  AmericanExpress: 'amex',
  JCB: 'jcb',
  EFT: 'eft',
  Discover: 'discover',
  DinersClub: 'dinersclub',
  UnionPay: 'unionpay',
  Other: 'other',
});

export const CardIssuersIcons = {
  [CardIssuersMap.Visa]: <CardVisaIcon />,
  [CardIssuersMap.MasterCard]: <CardMCIcon />,
  [CardIssuersMap.AmericanExpress]: <CardAMEXIcon />,
  [CardIssuersMap.JCB]: <CardJCBIcon />,
  [CardIssuersMap.EFT]: <CardEFTIcon />,
  [CardIssuersMap.Discover]: <CardDiscoverIcon />,
  [CardIssuersMap.UnionPay]: <CardDiscoverIcon />,
  [CardIssuersMap.DinersClub]: <CardDinersIcon />,
  [CardIssuersMap.Other]: <CardOtherIcon />,
};

export const getCardIcon = (name?: string | null) => {
  if (!name) {
    return;
  }
  const Icon = CardIssuersIcons[name as keyof typeof CardIssuersIcons];
  const Other = CardIssuersIcons.Other;

  return Icon ? Icon : Other;
};

/**
 * Get card icon directly from card number
 * @param cardNumber - The card number (can contain spaces)
 * @returns React component for the card icon or default icon
 */
export const getCardIconFromNumber = (cardNumber?: string | null) => {
  if (!cardNumber) {
    return <CardOtherIcon />;
  }

  // Remove spaces and get digits only
  const digitsOnly = cardNumber.replace(/\s/g, '');

  // Detect card type using creditcardutils
  const cardType = creditcardutils.parseCardType(digitsOnly);

  // Return the appropriate icon
  return getCardIcon(cardType) || <CardOtherIcon />;
};

//get card icon from card number with **** like 4111 **** **** **** 1111
export function findDebitCardType(cardNumber: string) {
  if (!cardNumber) {
    return null;
  }
  if (!cardNumber.includes('*')) {
    // if card number does not contain * then return the card icon from the card number
    return getCardIconFromNumber(cardNumber);
  }

  const regexPattern: {[key: string]: RegExp} = {
    [CardIssuersMap.Visa]: /^4[0-9]{2,}$/,
    [CardIssuersMap.MasterCard]: /^5[1-5][0-9]+|^2[2-7][0-9]+$/,
    [CardIssuersMap.AmericanExpress]: /^3[47][0-9]{5,}$/,
    [CardIssuersMap.Discover]: /^6(?:011|5[0-9]{2})[0-9]{3,}$/,
    [CardIssuersMap.UnionPay]: /^62[0-9]{2,}$/,
    [CardIssuersMap.DinersClub]: /^3(?:0[0-5]|[68][0-9])[0-9]{4,}$/,
    [CardIssuersMap.JCB]: /^(?:2131|1800|35[0-9]{3})[0-9]{3,}$/,
  };

  for (const card in regexPattern) {
    if (cardNumber.replace(/\D/g, '').match(regexPattern[card])) {
      return getCardIcon(card) || <CardOtherIcon />;
    }
  }

  return <CardOtherIcon />;
}
