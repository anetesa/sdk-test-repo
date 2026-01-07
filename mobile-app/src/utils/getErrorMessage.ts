export enum ErrorCodes {
  NoError = '00',

  InvalidCvv = 'N7',
  CardBlocked = '78',
  PickUpNoFraud = '04',
  PickUpFraud = '07',

  DoNotHonor = '05',
  ExpiredCard = '54',
  InvalidServiceCode = '62',
  PinExceeded = '75',

  TransactionNotPermitted = '57',
  NoReply = '91',

  InvalidRouting = '92',
  DeclineViolation = '93',
  DuplicateTransmission = '94',

  SystemMalfunction = '96',

  LostCard = '41',

  StolenCard = '43',

  InsufficientFunds = '51',

  AmountError = '61',
}

export function getErrorMessage(
  code?: ErrorCodes | string | null,
  fallback = '',
) {
  switch (code) {
    case ErrorCodes.AmountError:
      return "The transaction amount exceeds the customer's card limit. Please request an alternative card or payment method from the customer to complete the transaction.";
    case ErrorCodes.InsufficientFunds:
      return 'Insufficient funds. Please request an alternative card or payment method from the customer to proceed with the transaction.';
    case ErrorCodes.StolenCard:
      return "The customer's card has been reported as stolen. Please request an alternative card or payment method from the customer to complete the transaction.";
    case ErrorCodes.LostCard:
      return "The customer's card has been reported as lost. Please request an alternative card or payment method from the customer to complete the transaction.";
    case ErrorCodes.InvalidCvv:
      return 'Invalid CVV code. Please check the card details and try again.';
    case ErrorCodes.SystemMalfunction:
      return 'The processing center is temporarily unavailable. Please retry the transaction at a later time or request an alternative card or payment method from the customer if the issue persists.';
    case ErrorCodes.InvalidRouting:
    case ErrorCodes.DeclineViolation:
    case ErrorCodes.DuplicateTransmission:
      return 'A communication error occurred with the processing center. Please retry the transaction or request an alternative card or payment method from the customer if the issue persists.';
    case ErrorCodes.TransactionNotPermitted:
    case ErrorCodes.NoReply:
      return 'Received an invalid response from the card issuer. Please retry the transaction or request an alternative card or payment method from the customer to complete the transaction.';
    case ErrorCodes.DoNotHonor:
    case ErrorCodes.ExpiredCard:
    case ErrorCodes.InvalidServiceCode:
    case ErrorCodes.PinExceeded:
      return 'The transaction has been declined by the card issuer. Please request an alternative card or payment method from the customer to complete the transaction.';
    case ErrorCodes.CardBlocked:
    case ErrorCodes.PickUpNoFraud:
    case ErrorCodes.PickUpFraud:
      return "The customer's card has been blocked by the card issuer. Please request an alternative card or payment method from the customer to complete the transaction.";
    default:
      return fallback;
  }
}
