import React from 'react';
import {render, fireEvent, act} from '@testing-library/react-native';
import GlobalAlerts from '../GlobalAlerts';
import {useAlertStore} from '../../stores/alertStore';

// Mock the AnimatedAlert component to simplify testing
jest.mock('../AnimatedAlert', () => {
  const {View, Text, TouchableOpacity} = require('react-native');

  return ({id, type, message, isVisible, onHide}: any) => (
    <View testID={`animated-alert-${id}`}>
      <Text>{type}</Text>
      <Text>{message}</Text>
      <Text>{String(isVisible)}</Text>
      <TouchableOpacity testID={`alert-hide-${id}`} onPress={onHide}>
        <Text>Hide Alert</Text>
      </TouchableOpacity>
    </View>
  );
});

describe('GlobalAlerts', () => {
  beforeEach(() => {
    // Reset the store before each test
    act(() => {
      useAlertStore.getState().hideAllAlerts();
    });
  });

  it('renders nothing when there are no alerts', () => {
    const {queryByTestId} = render(<GlobalAlerts />);

    // Should not render any alert components
    expect(queryByTestId(/animated-alert-/)).toBeNull();
  });

  it('renders a single error alert', () => {
    act(() => {
      useAlertStore.getState().showErrorAlert('Test error message');
    });

    const {getByText, getAllByTestId} = render(<GlobalAlerts />);

    // Should render one alert
    const alertElements = getAllByTestId(/animated-alert-/);
    expect(alertElements).toHaveLength(1);

    // Check alert properties
    expect(getByText('error')).toBeTruthy();
    expect(getByText('Test error message')).toBeTruthy();
    expect(getByText('true')).toBeTruthy();
  });

  it('renders a single success alert', () => {
    act(() => {
      useAlertStore.getState().showSuccessAlert('Test success message');
    });

    const {getByText, getAllByTestId} = render(<GlobalAlerts />);

    // Should render one alert
    const alertElements = getAllByTestId(/animated-alert-/);
    expect(alertElements).toHaveLength(1);

    // Check alert properties
    expect(getByText('success')).toBeTruthy();
    expect(getByText('Test success message')).toBeTruthy();
    expect(getByText('true')).toBeTruthy();
  });

  it('renders multiple alerts', () => {
    act(() => {
      useAlertStore.getState().showErrorAlert('First error');
      // Add small delay to ensure different timestamps
      jest.advanceTimersByTime(1);
      useAlertStore.getState().showSuccessAlert('First success');
      jest.advanceTimersByTime(1);
      useAlertStore.getState().showErrorAlert('Second error');
    });

    const {getAllByTestId} = render(<GlobalAlerts />);

    // Should render three alerts
    const alertElements = getAllByTestId(/animated-alert-/);
    expect(alertElements).toHaveLength(3);
  });

  it('hides alert when hide button is pressed', () => {
    let alertId: string;

    act(() => {
      useAlertStore.getState().showErrorAlert('Test message');
    });

    const {getAllByTestId, rerender} = render(<GlobalAlerts />);

    // Should render one alert initially
    let alertElements = getAllByTestId(/animated-alert-/);
    expect(alertElements).toHaveLength(1);

    alertId = alertElements[0].props.testID.replace('animated-alert-', '');

    // Trigger the hide action
    act(() => {
      fireEvent.press(getAllByTestId(`alert-hide-${alertId}`)[0]);
    });

    // Re-render to see the updated state
    rerender(<GlobalAlerts />);

    // Should now have no alerts
    expect(() => getAllByTestId(/animated-alert-/)).toThrow();
  });

  it('shows correct alert content', () => {
    act(() => {
      useAlertStore.getState().showSuccessAlert('Custom message');
    });

    const {getByText} = render(<GlobalAlerts />);

    // Verify content is displayed
    expect(getByText('success')).toBeTruthy();
    expect(getByText('Custom message')).toBeTruthy();
    expect(getByText('true')).toBeTruthy();
    expect(getByText('Hide Alert')).toBeTruthy();
  });

  it('updates when alerts are added dynamically', () => {
    const {getAllByTestId, rerender} = render(<GlobalAlerts />);

    // Initially no alerts
    expect(() => getAllByTestId(/animated-alert-/)).toThrow();

    // Add an alert
    act(() => {
      useAlertStore.getState().showErrorAlert('New alert');
    });

    // Re-render to see the change
    rerender(<GlobalAlerts />);

    // Should now show one alert
    const alertElements = getAllByTestId(/animated-alert-/);
    expect(alertElements).toHaveLength(1);
  });
});
