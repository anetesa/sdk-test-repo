import React from 'react';
import LinearGradient from 'react-native-linear-gradient';
import {GRADIENT_COLORS} from '@/constants/colors';

const AriseGradient = ({children}: {children: React.ReactNode}) => {
  return (
    <LinearGradient
      colors={[...GRADIENT_COLORS.BACKGROUND]}
      start={{x: 0, y: 0}}
      end={{x: 0, y: 1}}
      className="h-[80px]">
      {children}
    </LinearGradient>
  );
};

export default AriseGradient;
