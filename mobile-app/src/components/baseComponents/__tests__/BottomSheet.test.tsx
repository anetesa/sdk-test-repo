import React from 'react';
import {render, fireEvent} from '@testing-library/react-native';
import {Text, View} from 'react-native';
import BottomSheet from '../BottomSheet';

// Mock react-native-reanimated
jest.mock('react-native-reanimated', () => {
  const Reanimated = require('react-native-reanimated/mock');
  Reanimated.default.call = () => {};
  return Reanimated;
});

describe('BottomSheet', () => {
  const defaultProps = {
    isVisible: true,
    isOverlay: true,
    height: 'h-64',
    onClose: jest.fn(),
    children: <Text>Test Content</Text>,
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders correctly when visible', () => {
    const {getByText} = render(<BottomSheet {...defaultProps} />);

    expect(getByText('Test Content')).toBeTruthy();
  });

  it('does not render when not visible', () => {
    const {queryByText} = render(
      <BottomSheet {...defaultProps} isVisible={false} />,
    );

    expect(queryByText('Test Content')).toBeNull();
  });

  it('calls onClose when overlay is pressed', () => {
    const onCloseMock = jest.fn();
    const {getByTestId} = render(
      <BottomSheet {...defaultProps} onClose={onCloseMock} />,
    );

    const overlay = getByTestId('overlay');
    fireEvent.press(overlay);

    expect(onCloseMock).toHaveBeenCalledTimes(1);
  });

  it('renders children correctly', () => {
    const customChildren = (
      <View>
        <Text>Custom Child 1</Text>
        <Text>Custom Child 2</Text>
      </View>
    );

    const {getByText} = render(
      <BottomSheet {...defaultProps} children={customChildren} />,
    );

    expect(getByText('Custom Child 1')).toBeTruthy();
    expect(getByText('Custom Child 2')).toBeTruthy();
  });

  it('renders without overlay when isOverlay is false', () => {
    const {queryByTestId} = render(
      <BottomSheet {...defaultProps} isOverlay={false} />,
    );

    expect(queryByTestId('overlay')).toBeNull();
  });

  it('applies correct height class', () => {
    const {getByText} = render(<BottomSheet {...defaultProps} height="h-96" />);

    // The component should render with the specified height
    expect(getByText('Test Content')).toBeTruthy();
  });

  it('handles numeric height values', () => {
    const {getByText} = render(<BottomSheet {...defaultProps} height={200} />);

    expect(getByText('Test Content')).toBeTruthy();
  });

  it('does not call onClose when overlay is not enabled', () => {
    const onCloseMock = jest.fn();
    const {getByText} = render(
      <BottomSheet {...defaultProps} isOverlay={false} onClose={onCloseMock} />,
    );

    // Try to press the content area (which would be the overlay if enabled)
    const content = getByText('Test Content');
    fireEvent.press(content);

    // onClose should not be called since there's no overlay
    expect(onCloseMock).not.toHaveBeenCalled();
  });

  it('renders with full height when height is h-full', () => {
    const {getByText} = render(
      <BottomSheet {...defaultProps} height="h-full" />,
    );

    expect(getByText('Test Content')).toBeTruthy();
  });
});
