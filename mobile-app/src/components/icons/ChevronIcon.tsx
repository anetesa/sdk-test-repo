import React from 'react';
import IconProps from './IconProps';

import Svg, {Path} from 'react-native-svg';

const ChevronIcon: React.FC<IconProps> = ({color = '#000000'}) => (
  <Svg width="24" height="24" viewBox="0 0 24 24" fill="none">
    <Path
      d="M9 6L15 12L9 18"
      stroke={color}
      stroke-width="1.5"
      stroke-linecap="round"
      stroke-linejoin="round"
    />
  </Svg>
);

export default ChevronIcon;
