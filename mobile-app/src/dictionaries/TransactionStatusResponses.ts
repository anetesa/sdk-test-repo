import {Dictionary, IBaseDictionaryEntry} from './Base';

export enum TransactionStatusResponse {
  Success = 1,
  Failed = 2,
  Declined = 3,
}

const TransactionStatusResponseRecords: IBaseDictionaryEntry<TransactionStatusResponse>[] =
  [
    {id: TransactionStatusResponse.Success, name: 'Success'},
    {id: TransactionStatusResponse.Failed, name: 'Failed'},
    {id: TransactionStatusResponse.Declined, name: 'Declined'},
  ];

export const TransactionStatusResponses =
  new Dictionary<TransactionStatusResponse>(TransactionStatusResponseRecords);
