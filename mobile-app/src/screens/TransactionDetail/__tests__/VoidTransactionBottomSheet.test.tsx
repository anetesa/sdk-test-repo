import React, {useRef} from 'react';
import {render, fireEvent, screen} from '@testing-library/react-native';
import VoidTransactionBottomSheet from '../VoidTransactionBottomSheet';
import BSheet from '@gorhom/bottom-sheet';

jest.mock('@gorhom/bottom-sheet', () => {
  const React = require('react');
  const RN = require('react-native');
  const Mock = React.forwardRef((props: any, ref: any) => (
    <RN.View ref={ref} {...props} />
  ));
  return Object.assign(Mock, {
    __esModule: true,
    default: Mock,
    BottomSheetView: RN.View,
    BottomSheetBackdrop: (props: any) => <RN.View {...props} />,
  });
});

describe('VoidTransactionBottomSheet', () => {
  it('calls handlers on button presses', () => {
    const onConfirm = jest.fn();
    const onClose = jest.fn();

    render(
      <VoidTransactionBottomSheet onConfirm={onConfirm} onClose={onClose} />,
    );

    fireEvent.press(screen.getByText('Void'));
    fireEvent.press(screen.getByText('Cancel'));

    expect(onConfirm).toHaveBeenCalled();
    expect(onClose).toHaveBeenCalled();
  });
});
