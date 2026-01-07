import React from 'react';
import {render, screen} from '@testing-library/react-native';
import LoadingSpinner from '../LoadingSpinner';

describe('LoadingSpinner', () => {
  it('renders message only when showSpinner is false', () => {
    render(<LoadingSpinner message="Please wait" showSpinner={false} />);
    expect(screen.getByText('Please wait')).toBeTruthy();
  });

  it('renders spinner and message when showSpinner is true', () => {
    render(<LoadingSpinner message="Working" showSpinner={true} />);
    expect(screen.getByText('Working')).toBeTruthy();
  });
});
