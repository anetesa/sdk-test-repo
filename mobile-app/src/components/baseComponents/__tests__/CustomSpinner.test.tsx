import React from 'react';
import {render, screen} from '@testing-library/react-native';
import {CustomSVGSpinner, CustomLoadingIndicator} from '../CustomSpinner';
import {UI_MESSAGES} from '../../../constants/messages';

describe('CustomSpinner components', () => {
  it('renders CustomSVGSpinner', () => {
    const {toJSON} = render(<CustomSVGSpinner size={24} />);
    expect(toJSON()).toBeTruthy();
  });

  it('renders CustomLoadingIndicator with label', () => {
    render(<CustomLoadingIndicator />);
    expect(screen.getByText(UI_MESSAGES.LOADING)).toBeTruthy();
  });
});
