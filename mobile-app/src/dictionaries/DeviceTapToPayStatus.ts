import {Dictionary, IBaseDictionaryEntry} from './Base';

export enum DeviceTapToPayStatus {
  Inactive = 0,
  Requested = 1,
  Approved = 2,
  Active = 3,
  Denied = 4,
}

export enum DeviceTapToPayStatusStringEnumType {
  Inactive = 'Inactive',
  Requested = 'Requested',
  Approved = 'Approved',
  Active = 'Active',
  Denied = 'Denied',
}
const DeviceTapToPayStatusRecords: IBaseDictionaryEntry<DeviceTapToPayStatus>[] =
  [
    {id: DeviceTapToPayStatus.Inactive, name: 'Inactive'},
    {id: DeviceTapToPayStatus.Requested, name: 'Requested'},
    {id: DeviceTapToPayStatus.Approved, name: 'Approved'},
    {id: DeviceTapToPayStatus.Active, name: 'Active'},
    {id: DeviceTapToPayStatus.Denied, name: 'Denied'},
  ];

export const DeviceTapToPayStatuses = new Dictionary<
  DeviceTapToPayStatus,
  IBaseDictionaryEntry<DeviceTapToPayStatus>
>(DeviceTapToPayStatusRecords);
