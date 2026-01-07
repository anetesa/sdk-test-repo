import React from 'react';
import {View} from 'react-native';

interface LineSeparatorProps {
  className?: string;
  color?: string;
  height?: number;
}

const LineSeparator: React.FC<LineSeparatorProps> = ({
  className = '',
  color = 'border-elevation-08',
  height = 1,
}) => {
  return (
    <View
      className={`border-b ${color} mx-[20px] ${className}`}
      style={{borderBottomWidth: height}}
    />
  );
};

export default LineSeparator;
