import React from 'react';
import {render, screen} from '@testing-library/react-native';
import PendingRequest from '../PendingRequest';

describe('PendingRequest', () => {
  it('renders title and subtitle', () => {
    render(<PendingRequest title="Processing..." subtitle="Please wait" />);

    expect(screen.getByText('Processing...')).toBeTruthy();
    expect(screen.getByText('Please wait')).toBeTruthy();
  });
});
