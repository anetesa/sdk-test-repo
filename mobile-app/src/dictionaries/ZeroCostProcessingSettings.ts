import {Dictionary, IDescriptedDictionaryEntry} from './Base';

export enum ZeroCostProcessingType {
  None = 1,
  CashDiscount,
  DualPricing,
  Surcharge,
}

const ZeroCostProcessingTypeRecords: IDescriptedDictionaryEntry<ZeroCostProcessingType>[] =
  [
    {
      id: ZeroCostProcessingType.None,
      name: 'None',
    },
    {
      id: ZeroCostProcessingType.DualPricing,
      name: 'Dual Pricing',
    },
    {
      id: ZeroCostProcessingType.CashDiscount,
      name: 'Cash Discount',
    },
    {
      id: ZeroCostProcessingType.Surcharge,
      name: 'Credit Card Surcharge',
    },
  ];

export const ZeroCostProcessingTypes = new Dictionary<
  ZeroCostProcessingType,
  IDescriptedDictionaryEntry<ZeroCostProcessingType>
>(ZeroCostProcessingTypeRecords);
