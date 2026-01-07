import {Dictionary, IBaseDictionaryEntry} from './Base';

export enum TransactionType {
  Authorization = 1,
  Sale = 2,
  Capture = 3,
  Void = 4,

  Refund = 5,
  CardAuthentication = 6,
  RefundWORef = 7,
  // TipAdjustment = 8,

  Settle = 10,

  AchDebit = 11,
  AchCredit = 16,
  AchRefund = 12,
}

export const TransactionTypeNames = {
  Authorization: 'Authorization',
  Sale: 'Sale',
  Capture: 'Capture',
  CardAuthentication: 'Card Authentication',
  Void: 'Void',
  Refund: 'Refund',
  RefundWORef: 'Refund Without Reference',
  Settle: 'Settle',
  Debit: 'Debit (Sale)',
  Credit: 'Credit (Refund / Payout)',
  AchCredit: 'ACH Credit (Refund / Payout)',
};

const TransactionTypeRecords: IBaseDictionaryEntry<TransactionType>[] = [
  {id: TransactionType.Authorization, name: TransactionTypeNames.Authorization},
  {id: TransactionType.Sale, name: TransactionTypeNames.Sale},
  {id: TransactionType.Capture, name: TransactionTypeNames.Capture},
  {
    id: TransactionType.CardAuthentication,
    name: TransactionTypeNames.CardAuthentication,
  },
  {id: TransactionType.Void, name: TransactionTypeNames.Void},
  {id: TransactionType.Refund, name: TransactionTypeNames.Refund},
  {id: TransactionType.RefundWORef, name: TransactionTypeNames.RefundWORef},
  // { id: TransactionType.TipAdjustment, name: 'Tip Adjustment' },
  {id: TransactionType.Settle, name: TransactionTypeNames.Settle},
  {id: TransactionType.AchDebit, name: TransactionTypeNames.Debit},
  {id: TransactionType.AchCredit, name: TransactionTypeNames.Credit},
  {id: TransactionType.AchRefund, name: TransactionTypeNames.AchCredit},
];

export const TransactionTypes = new Dictionary<TransactionType>(
  TransactionTypeRecords,
);
