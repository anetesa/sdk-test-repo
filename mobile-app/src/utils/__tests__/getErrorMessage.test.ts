import {getErrorMessage, ErrorCodes} from '../getErrorMessage';

describe('getErrorMessage', () => {
  it('returns mapped message for known codes', () => {
    expect(getErrorMessage(ErrorCodes.InvalidCvv)).toContain('Invalid CVV');
    expect(getErrorMessage(ErrorCodes.InsufficientFunds)).toContain(
      'Insufficient funds',
    );
    expect(getErrorMessage(ErrorCodes.StolenCard)).toContain(
      'reported as stolen',
    );
    expect(getErrorMessage(ErrorCodes.LostCard)).toContain('reported as lost');
    expect(getErrorMessage(ErrorCodes.SystemMalfunction)).toContain(
      'temporarily unavailable',
    );

    // Grouped mappings
    expect(getErrorMessage(ErrorCodes.InvalidRouting)).toContain(
      'communication error',
    );
    expect(getErrorMessage(ErrorCodes.DeclineViolation)).toContain(
      'communication error',
    );
    expect(getErrorMessage(ErrorCodes.DuplicateTransmission)).toContain(
      'communication error',
    );

    expect(getErrorMessage(ErrorCodes.TransactionNotPermitted)).toContain(
      'invalid response',
    );
    expect(getErrorMessage(ErrorCodes.NoReply)).toContain('invalid response');

    expect(getErrorMessage(ErrorCodes.DoNotHonor)).toContain(
      'has been declined',
    );
    expect(getErrorMessage(ErrorCodes.ExpiredCard)).toContain(
      'has been declined',
    );
    expect(getErrorMessage(ErrorCodes.InvalidServiceCode)).toContain(
      'has been declined',
    );
    expect(getErrorMessage(ErrorCodes.PinExceeded)).toContain(
      'has been declined',
    );

    expect(getErrorMessage(ErrorCodes.CardBlocked)).toContain(
      'card has been blocked',
    );
    expect(getErrorMessage(ErrorCodes.PickUpNoFraud)).toContain(
      'card has been blocked',
    );
    expect(getErrorMessage(ErrorCodes.PickUpFraud)).toContain(
      'card has been blocked',
    );
  });

  it('returns fallback for unknown/empty codes', () => {
    expect(getErrorMessage('UNKNOWN', 'fallback')).toBe('fallback');
    expect(getErrorMessage(undefined, 'default message')).toBe(
      'default message',
    );
    expect(getErrorMessage(null, 'default')).toBe('default');
  });
});
