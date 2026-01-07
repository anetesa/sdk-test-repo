import React from 'react';
import {renderHook, act, waitFor} from '@testing-library/react-native';
import {useRememberMe} from '../useRememberMe';

jest.mock('@/utils/asyncStorage', () => ({
  getRememberMeEmail: jest.fn(),
  setRememberMeEmail: jest.fn(),
  removeRememberMeEmail: jest.fn(),
}));

jest.mock('@/utils/logger', () => ({
  logger: {error: jest.fn()},
}));

const {
  getRememberMeEmail,
  setRememberMeEmail,
  removeRememberMeEmail,
} = require('@/utils/asyncStorage');
const {logger} = require('@/utils/logger');

describe('useRememberMe', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('loads remembered email and sets checkbox on', async () => {
    (getRememberMeEmail as jest.Mock).mockResolvedValue('foo@example.com');
    const {result} = renderHook(() => useRememberMe());
    await waitFor(() => expect(getRememberMeEmail).toHaveBeenCalled());
    expect(result.current.email).toBe('foo@example.com');
    expect(result.current.rememberMeCheckBox).toBe(true);
  });

  it('handles storage error and still ends loading', async () => {
    (getRememberMeEmail as jest.Mock).mockRejectedValue(new Error('boom'));
    const {result} = renderHook(() => useRememberMe());
    await waitFor(() => expect(logger.error).toHaveBeenCalled());
    expect(logger.error).toHaveBeenCalled();
  });

  it('toggle updates storage and state correctly', async () => {
    (getRememberMeEmail as jest.Mock).mockResolvedValue(null);
    const {result} = renderHook(() => useRememberMe());
    await waitFor(() => expect(getRememberMeEmail).toHaveBeenCalled());

    // Turn on remember me
    act(() => {
      result.current.handleRememberMeToggle();
    });
    expect(result.current.rememberMeCheckBox).toBe(true);

    // Save email on login when checkbox is on
    act(() => {
      result.current.saveEmailOnLogin('bar@example.com');
    });
    expect(setRememberMeEmail).toHaveBeenCalledWith('bar@example.com');
    expect(result.current.email).toBe('bar@example.com');

    // Turn off remember me clears storage and email
    act(() => {
      result.current.handleRememberMeToggle();
    });
    expect(removeRememberMeEmail).toHaveBeenCalled();
    expect(result.current.rememberMeCheckBox).toBe(false);
    expect(result.current.email).toBe('');
  });
});
