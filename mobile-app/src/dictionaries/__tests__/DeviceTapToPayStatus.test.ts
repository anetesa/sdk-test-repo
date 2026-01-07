import {
  DeviceTapToPayStatus,
  DeviceTapToPayStatuses,
} from '../DeviceTapToPayStatus';

describe('DeviceTapToPayStatus dictionary', () => {
  it('provides names for each device tap to pay status', () => {
    expect(DeviceTapToPayStatuses.getName(DeviceTapToPayStatus.Inactive)).toBe(
      'Inactive',
    );
    expect(DeviceTapToPayStatuses.getName(DeviceTapToPayStatus.Requested)).toBe(
      'Requested',
    );
    expect(DeviceTapToPayStatuses.getName(DeviceTapToPayStatus.Approved)).toBe(
      'Approved',
    );
    expect(DeviceTapToPayStatuses.getName(DeviceTapToPayStatus.Active)).toBe(
      'Active',
    );
    expect(DeviceTapToPayStatuses.getName(DeviceTapToPayStatus.Denied)).toBe(
      'Denied',
    );
  });

  it('enum values match expected numeric values', () => {
    expect(DeviceTapToPayStatus.Inactive).toBe(0);
    expect(DeviceTapToPayStatus.Requested).toBe(1);
    expect(DeviceTapToPayStatus.Approved).toBe(2);
    expect(DeviceTapToPayStatus.Active).toBe(3);
    expect(DeviceTapToPayStatus.Denied).toBe(4);
  });
});
