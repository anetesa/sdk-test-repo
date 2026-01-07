import React from 'react';
import {render} from '@testing-library/react-native';
import NumberPad from '../NumberPad';

describe('NumberPad', () => {
  it('should render all number and backspace buttons', () => {
    const {getByText} = render(<NumberPad />);

    // Check for numbers 0-9
    for (let i = 0; i < 10; i++) {
      expect(getByText(i.toString())).toBeTruthy();
    }

    // Check for backspace button
    expect(getByText('⌫')).toBeTruthy();
  });
});
