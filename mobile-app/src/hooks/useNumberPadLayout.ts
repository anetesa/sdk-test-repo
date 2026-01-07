import {useState, useCallback} from 'react';
import type {LayoutChangeEvent} from 'react-native';

const GAP_PX = 12;

/**
 * PROBLEM: the "0" button does not measure exactly two cells + a gap using flex/gap.
 * SOLUTION: measure the actual width and calculate cellWidth and zeroWidth pixel-perfect.
 *
 * Hook that calculates:
 *  - cellWidth: width of a normal button
 *  - zeroWidth: width of the "0" button (2 cells + 1 gap)
 *  - gap: gap between buttons
 */
export function useNumberPadLayout() {
  const [layout, setLayout] = useState({
    cellWidth: 0,
    zeroWidth: 0,
    gap: GAP_PX,
  });

  const onLayout = useCallback((e: LayoutChangeEvent) => {
    const total = e.nativeEvent.layout.width;
    const cell = (total - GAP_PX * 2) / 3;
    setLayout({
      cellWidth: cell,
      zeroWidth: cell * 2 + GAP_PX,
      gap: GAP_PX,
    });
  }, []);

  return {...layout, onLayout};
}
