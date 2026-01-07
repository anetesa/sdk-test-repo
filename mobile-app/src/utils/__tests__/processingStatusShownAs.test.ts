import {ProcessingStatusShownAs} from '../processingStatusShownAs';

describe('ProcessingStatusShownAs', () => {
  it('maps Authorization + Authorized to APPROVED', () => {
    expect(ProcessingStatusShownAs('Authorized', 'Authorization')).toBe(
      'APPROVED',
    );
  });

  it('maps Sale + Captured to APPROVED', () => {
    expect(ProcessingStatusShownAs('Captured', 'Sale')).toBe('APPROVED');
  });

  it('maps Sale + Settled to APPROVED', () => {
    expect(ProcessingStatusShownAs('Settled', 'Sale')).toBe('APPROVED');
  });

  it('maps Refunded to APPROVED regardless of type', () => {
    expect(ProcessingStatusShownAs('Refunded', 'Sale')).toBe('APPROVED');
  });

  it('uppercases fallback statuses', () => {
    expect(ProcessingStatusShownAs('Declined', 'Sale')).toBe('DECLINED');
  });
});
