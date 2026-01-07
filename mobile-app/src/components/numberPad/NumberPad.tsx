import React from 'react';
import {View} from 'react-native';
import type {FC} from 'react';
import NumberPadButton from './NumberPadButton';
import {useNumberPadLayout} from '@/hooks/useNumberPadLayout';

interface NumberPadProps {
  onNumberPress?: (string: string, int: number) => void;
  onBackspacePressIn?: () => void;
  onBackspacePressOut?: () => void;
}

const NumberPad: FC<NumberPadProps> = ({
  onNumberPress,
  onBackspacePressIn,
  onBackspacePressOut,
}) => {
  const {cellWidth, zeroWidth, gap, onLayout} = useNumberPadLayout();

  return (
    <View className={'flex flex-col w-full space-y-3'} onLayout={onLayout}>
      <View className={'flex flex-row justify-between gap-3'}>
        <View className={'basis-1/3'}>
          <NumberPadButton
            value="1"
            onPress={() => onNumberPress?.('one', 1)}
          />
        </View>
        <View className={'basis-1/3'}>
          <NumberPadButton
            value="2"
            onPress={() => onNumberPress?.('two', 2)}
          />
        </View>
        <View className={'basis-1/3'}>
          <NumberPadButton
            value="3"
            onPress={() => onNumberPress?.('three', 3)}
          />
        </View>
      </View>

      <View className={'flex flex-row justify-between'}>
        <View className={'basis-1/3'}>
          <NumberPadButton
            value="4"
            onPress={() => onNumberPress?.('four', 4)}
          />
        </View>
        <View className={'basis-1/3'}>
          <NumberPadButton
            value="5"
            onPress={() => onNumberPress?.('five', 5)}
          />
        </View>
        <View className={'basis-1/3'}>
          <NumberPadButton
            value="6"
            onPress={() => onNumberPress?.('six', 6)}
          />
        </View>
      </View>

      <View className={'flex flex-row justify-between'}>
        <View className={'basis-1/3'}>
          <NumberPadButton
            value="7"
            onPress={() => onNumberPress?.('seven', 7)}
          />
        </View>
        <View className={'basis-1/3'}>
          <NumberPadButton
            value="8"
            onPress={() => onNumberPress?.('eight', 8)}
          />
        </View>
        <View className={'basis-1/3'}>
          <NumberPadButton
            value="9"
            onPress={() => onNumberPress?.('nine', 9)}
          />
        </View>
      </View>

      <View className="flex flex-row">
        <NumberPadButton
          value="0"
          onPress={() => onNumberPress?.('zero', 0)}
          style={{width: zeroWidth}}
        />

        {/* manual gap */}
        <View style={{width: gap}} />

        <NumberPadButton
          value="⌫"
          className="text-slate-300"
          onPressIn={onBackspacePressIn}
          onPressOut={onBackspacePressOut}
          style={{width: cellWidth}}
          testID="backspace-button"
        />
      </View>
    </View>
  );
};

export default NumberPad;
