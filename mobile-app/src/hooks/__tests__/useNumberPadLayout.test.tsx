import {renderHook, act} from '@testing-library/react-native';
import {useNumberPadLayout} from '../useNumberPadLayout';

it('Make sure to calculate the button widths correctly.', () => {
  const {result} = renderHook(() => useNumberPadLayout());

  act(() => {
    result.current.onLayout({
      nativeEvent: {layout: {width: 300}},
    } as any);
  });

  // GAP = 12, total=300 → cell = (300 - 24)/3 = 92, zero = 92*2 + 12 = 196
  expect(result.current.cellWidth).toBeCloseTo(92);
  expect(result.current.zeroWidth).toBeCloseTo(196);
  expect(result.current.gap).toBe(12);
});
