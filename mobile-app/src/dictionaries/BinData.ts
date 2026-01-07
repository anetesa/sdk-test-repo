import {Dictionary, IBaseDictionaryEntry} from './Base';

export enum BinDataType {
  Credit = 1,
  Debit = 2,
  Unknown = 3,
}

const BinDataTypeRecords: IBaseDictionaryEntry<BinDataType>[] = [
  {id: BinDataType.Credit, name: 'Credit'},
  {id: BinDataType.Debit, name: 'Debit'},
  {id: BinDataType.Unknown, name: 'Unknown'},
];

export const BinDataTypes = new Dictionary<BinDataType>(BinDataTypeRecords);
