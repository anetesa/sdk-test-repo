import {Dictionary, IBaseDictionaryEntry} from './Base';

export enum CardTransactionStatus {
  Authorized = 1,
  Captured = 2,
  Voided = 3,
  Refunded = 4,
  Verified = 5,
  Settled = 6,
  PartiallyAuthorized = 7,
  Informational = 8,
}

export enum AchTransactionStatus {
  Scheduled = 21,
  Cancelled = 22,
  ChargedBack = 23,
  InProgress = 24,
  Cleared = 25,
  Held = 26,
  HeldByProcessor = 27,
}

export enum CommonTransactionStatus {
  Pending = 90,
  Declined = 91,
  Failed = 92,
}

const CommonTransactionStatusRecords: IBaseDictionaryEntry<CommonTransactionStatus>[] =
  [
    {id: CommonTransactionStatus.Pending, name: 'Pending'},
    {id: CommonTransactionStatus.Declined, name: 'Declined'},
    {id: CommonTransactionStatus.Failed, name: 'Failed'},
  ];

const CardTransactionStatusRecords: IBaseDictionaryEntry<
  CardTransactionStatus | CommonTransactionStatus
>[] = [
  {id: CardTransactionStatus.Authorized, name: 'Authorized'},
  {id: CardTransactionStatus.PartiallyAuthorized, name: 'Partially Authorized'},
  {id: CardTransactionStatus.Captured, name: 'Captured'},
  {id: CardTransactionStatus.Voided, name: 'Voided'},
  {id: CardTransactionStatus.Refunded, name: 'Refunded'},
  {id: CardTransactionStatus.Informational, name: 'Informational'},
  {id: CardTransactionStatus.Verified, name: 'Verified'},
  {id: CardTransactionStatus.Settled, name: 'Settled'},
];

const AchTransactionStatusRecords: IBaseDictionaryEntry<
  AchTransactionStatus | CommonTransactionStatus
>[] = [
  {id: AchTransactionStatus.Scheduled, name: 'Scheduled'},
  {id: AchTransactionStatus.Cancelled, name: 'Cancelled'},
  {id: AchTransactionStatus.ChargedBack, name: 'Charged Back'},
  {id: AchTransactionStatus.InProgress, name: 'In Progress'},
  {id: AchTransactionStatus.Cleared, name: 'Cleared'},
  {id: AchTransactionStatus.Held, name: 'Held'},
  {id: AchTransactionStatus.HeldByProcessor, name: 'Held By Processor'},
];

const AllTransactionStatusRecords: IBaseDictionaryEntry<
  CardTransactionStatus | AchTransactionStatus | CommonTransactionStatus
>[] = [
  ...CardTransactionStatusRecords,
  ...AchTransactionStatusRecords,
  ...CommonTransactionStatusRecords,
];

export const CardTransactionStatuses = new Dictionary<
  CardTransactionStatus | CommonTransactionStatus,
  IBaseDictionaryEntry<CardTransactionStatus | CommonTransactionStatus>
>([...CardTransactionStatusRecords, ...CommonTransactionStatusRecords]);
export const AchTransactionStatuses = new Dictionary<
  AchTransactionStatus | CommonTransactionStatus,
  IBaseDictionaryEntry<AchTransactionStatus | CommonTransactionStatus>
>([...AchTransactionStatusRecords, ...CommonTransactionStatusRecords]);
export const AllTransactionStatuses = new Dictionary<
  AchTransactionStatus | CardTransactionStatus | CommonTransactionStatus,
  IBaseDictionaryEntry<
    AchTransactionStatus | CardTransactionStatus | CommonTransactionStatus
  >
>(AllTransactionStatusRecords);
