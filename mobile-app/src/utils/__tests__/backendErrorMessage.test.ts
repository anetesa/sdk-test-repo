import {describe, expect, it} from '@jest/globals';
import {__private__} from '../backendErrorMessage';

describe('backendErrorMessage.__private__.extractFirstArrayMessage', () => {
  const extractFirstArrayMessage = __private__.extractFirstArrayMessage;

  it('extracts first message from backend Errors object', () => {
    const payload = {
      Errors: {
        UseCardPrice: ['CardPrice must be provided for ZCP option DualPricing'],
      },
      StatusCode: 400,
      ErrorCode: 'V0000',
    };

    expect(extractFirstArrayMessage(payload)).toBe(
      'CardPrice must be provided for ZCP option DualPricing',
    );
  });

  it('works even if the key is unknown (any object->array->first string)', () => {
    const payload = {
      Errors: {
        Anything: ['First message', 'Second message'],
      },
    };

    expect(extractFirstArrayMessage(payload)).toBe('First message');
  });

  it('finds nested arrays of strings', () => {
    const payload = {
      a: {b: {c: {Errors: {x: ['Nested message']}}}},
    };

    expect(extractFirstArrayMessage(payload)).toBe('Nested message');
  });

  it('skips empty/whitespace strings and finds the next valid one', () => {
    const payload = {
      Errors: {
        Field: ['   ', 'Real message'],
      },
    };

    expect(extractFirstArrayMessage(payload)).toBe('Real message');
  });

  it('returns undefined when no array-of-strings exists', () => {
    const payload = {Errors: {Field: []}, StatusCode: 400};
    expect(extractFirstArrayMessage(payload)).toBeUndefined();
  });

  it('does not infinite-loop on circular structures', () => {
    const payload: any = {Errors: {Field: ['Hello']}};
    payload.self = payload;

    expect(extractFirstArrayMessage(payload)).toBe('Hello');
  });
});
