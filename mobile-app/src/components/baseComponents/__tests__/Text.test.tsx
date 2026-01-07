import React from 'react';
import {render, screen} from '@testing-library/react-native';
import {Text as RNText} from 'react-native';
import {Text} from '../Text';

jest.mock('../TextSkeleton', () => ({
  TextSkeleton: ({width}: {width?: number}) => {
    const RN = require('react-native');
    return (
      <RN.View testID="text-skeleton">
        <RN.Text testID="text-skeleton-width">{String(width ?? '')}</RN.Text>
      </RN.View>
    );
  },
}));

describe('Text (baseComponents)', () => {
  it('renders TextSkeleton when isLoading is true with widthSkeleton', () => {
    render(<Text isLoading widthSkeleton={180} />);

    expect(screen.getByTestId('text-skeleton')).toBeTruthy();
    expect(screen.getByTestId('text-skeleton-width').props.children).toBe(
      '180',
    );
  });

  it('renders RN Text when isLoading is false', () => {
    render(<Text>Content</Text>);

    // Should not render skeleton
    expect(screen.queryByTestId('text-skeleton')).toBeNull();

    // Should render react-native Text content
    expect(screen.getByText('Content')).toBeTruthy();
  });

  it('passes other props down to RNText', () => {
    render(
      <Text accessibilityLabel="the-text" testID="base-text">
        Hello
      </Text>,
    );

    const baseText = screen.getByTestId('base-text');
    expect(baseText).toBeTruthy();
    expect(baseText.props.accessibilityLabel).toBe('the-text');
  });
});
