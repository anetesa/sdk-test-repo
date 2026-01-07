import React from 'react';
import {render, waitFor, act} from '@testing-library/react-native';
import AnimatedAlert from '../AnimatedAlert';
import {ANIMATION_DURATIONS} from '../../constants/timing';

// Mock the Alert components to simplify testing
jest.mock('../baseComponents/AlertError', () => {
  const {View, Text, TouchableOpacity} = require('react-native');
  return ({message, onDismiss}: any) => (
    <View testID="alert-error">
      <Text testID="error-message">{message}</Text>
      <TouchableOpacity testID="dismiss-button" onPress={onDismiss}>
        <Text>Dismiss</Text>
      </TouchableOpacity>
    </View>
  );
});

jest.mock('../baseComponents/AlertSuccess', () => {
  const {View, Text, TouchableOpacity} = require('react-native');
  return ({message, onDismiss}: any) => (
    <View testID="alert-success">
      <Text testID="success-message">{message}</Text>
      <TouchableOpacity testID="dismiss-button" onPress={onDismiss}>
        <Text>Dismiss</Text>
      </TouchableOpacity>
    </View>
  );
});

describe('AnimatedAlert', () => {
  const defaultProps = {
    id: 'test-alert',
    type: 'error' as const,
    message: 'Test message',
    isVisible: true,
    onHide: jest.fn(),
  };

  beforeEach(() => {
    jest.clearAllMocks();
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.runOnlyPendingTimers();
    jest.useRealTimers();
  });

  it('renders error alert when type is error', () => {
    const {getByTestId, getByText} = render(
      <AnimatedAlert {...defaultProps} type="error" />,
    );

    expect(getByTestId('alert-error')).toBeTruthy();
    expect(getByText('Test message')).toBeTruthy();
  });

  it('renders success alert when type is success', () => {
    const {getByTestId, getByText} = render(
      <AnimatedAlert {...defaultProps} type="success" />,
    );

    expect(getByTestId('alert-success')).toBeTruthy();
    expect(getByText('Test message')).toBeTruthy();
  });

  it('does not render when isVisible is false', () => {
    const {queryByTestId} = render(
      <AnimatedAlert {...defaultProps} isVisible={false} />,
    );

    expect(queryByTestId('alert-error')).toBeNull();
    expect(queryByTestId('alert-success')).toBeNull();
  });

  it('automatically dismisses error alert after default duration', async () => {
    const onHideMock = jest.fn();

    render(
      <AnimatedAlert {...defaultProps} type="error" onHide={onHideMock} />,
    );

    // Initially, onHide should not be called
    expect(onHideMock).not.toHaveBeenCalled();

    // Fast-forward time by the default TOAST duration (5000ms)
    act(() => {
      jest.advanceTimersByTime(ANIMATION_DURATIONS.TOAST);
    });

    // Wait for the animation to complete and onHide to be called
    await waitFor(() => {
      expect(onHideMock).toHaveBeenCalled();
    });
  });

  it('automatically dismisses success alert after default duration', async () => {
    const onHideMock = jest.fn();

    render(
      <AnimatedAlert {...defaultProps} type="success" onHide={onHideMock} />,
    );

    // Initially, onHide should not be called
    expect(onHideMock).not.toHaveBeenCalled();

    // Fast-forward time by the default TOAST duration (5000ms)
    act(() => {
      jest.advanceTimersByTime(ANIMATION_DURATIONS.TOAST);
    });

    // Wait for the animation to complete and onHide to be called
    await waitFor(() => {
      expect(onHideMock).toHaveBeenCalled();
    });
  });

  it('automatically dismisses alert after custom duration', async () => {
    const onHideMock = jest.fn();
    const customDuration = 3000;

    render(
      <AnimatedAlert
        {...defaultProps}
        type="error"
        duration={customDuration}
        onHide={onHideMock}
      />,
    );

    // Initially, onHide should not be called
    expect(onHideMock).not.toHaveBeenCalled();

    // Fast-forward time by less than custom duration - should not dismiss yet
    act(() => {
      jest.advanceTimersByTime(customDuration - 100);
    });

    expect(onHideMock).not.toHaveBeenCalled();

    // Fast-forward the remaining time
    act(() => {
      jest.advanceTimersByTime(100);
    });

    // Wait for the animation to complete and onHide to be called
    await waitFor(() => {
      expect(onHideMock).toHaveBeenCalled();
    });
  });

  it('clears timer when component unmounts', () => {
    const onHideMock = jest.fn();

    const {unmount} = render(
      <AnimatedAlert {...defaultProps} onHide={onHideMock} />,
    );

    // Unmount before timer expires
    unmount();

    // Fast-forward time past the duration
    act(() => {
      jest.advanceTimersByTime(ANIMATION_DURATIONS.TOAST + 1000);
    });

    // onHide should not be called since component was unmounted
    expect(onHideMock).not.toHaveBeenCalled();
  });

  it('clears timer when isVisible becomes false', () => {
    const onHideMock = jest.fn();

    const {rerender} = render(
      <AnimatedAlert {...defaultProps} onHide={onHideMock} isVisible={true} />,
    );

    // Change isVisible to false before timer expires
    rerender(
      <AnimatedAlert {...defaultProps} onHide={onHideMock} isVisible={false} />,
    );

    // Fast-forward time past the duration
    act(() => {
      jest.advanceTimersByTime(ANIMATION_DURATIONS.TOAST + 1000);
    });

    // onHide should not be called since isVisible was set to false
    expect(onHideMock).not.toHaveBeenCalled();
  });

  it('restarts timer when alert becomes visible again', async () => {
    const onHideMock = jest.fn();

    const {rerender} = render(
      <AnimatedAlert {...defaultProps} onHide={onHideMock} isVisible={false} />,
    );

    // Make alert visible
    rerender(
      <AnimatedAlert {...defaultProps} onHide={onHideMock} isVisible={true} />,
    );

    // Fast-forward time by the duration
    act(() => {
      jest.advanceTimersByTime(ANIMATION_DURATIONS.TOAST);
    });

    // Wait for the animation to complete and onHide to be called
    await waitFor(() => {
      expect(onHideMock).toHaveBeenCalled();
    });
  });

  it('uses correct default duration from constants', () => {
    // This test verifies that our constant is set to 5 seconds as required
    expect(ANIMATION_DURATIONS.TOAST).toBe(5000);
  });
});
