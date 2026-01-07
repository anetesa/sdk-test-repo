import React from 'react';
import IconProps from './IconProps';
import Svg, {Path, G, Defs, ClipPath, Rect} from 'react-native-svg';
import {COLORS} from '@/constants/colors';

const AlertCircleIcon: React.FC<IconProps> = ({color = COLORS.ERROR_DARK}) => (
  <Svg width="16" height="16" viewBox="0 0 16 16" fill="none">
    <G clipPath="url(#clip0_2127_6442)">
      <Path
        d="M8.00016 5.3335V8.00016M8.00016 10.6668H8.00683M14.6668 8.00016C14.6668 11.6821 11.6821 14.6668 8.00016 14.6668C4.31826 14.6668 1.3335 11.6821 1.3335 8.00016C1.3335 4.31826 4.31826 1.3335 8.00016 1.3335C11.6821 1.3335 14.6668 4.31826 14.6668 8.00016Z"
        stroke={color}
        strokeWidth="1.25"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </G>
    <Defs>
      <ClipPath id="clip0_2127_6442">
        <Rect width="16" height="16" fill="white" />
      </ClipPath>
    </Defs>
  </Svg>
);

export default AlertCircleIcon;
