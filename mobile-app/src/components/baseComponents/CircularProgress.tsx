import React from 'react';
import {View, Text} from 'react-native';
import Svg, {Circle} from 'react-native-svg';

interface CircularProgressProps {
  size?: number;
  strokeWidth?: number;
  progress: number; // 0-100
  progressColor?: string;
  backgroundColor?: string;
  showPercentage?: boolean;
}

const CircularProgress: React.FC<CircularProgressProps> = ({
  size = 200,
  strokeWidth = 12,
  progress = 0,
  progressColor = '#007AFF', // blue-500
  backgroundColor = '#1F2937', // gray-800
  showPercentage = true,
}) => {
  const radius = (size - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;
  const progressOffset = circumference - (progress / 100) * circumference;

  // Calculate fontSize proportional to size (24% of size)
  const fontSize = size * 0.16;

  return (
    <View style={{width: size, height: size, position: 'relative'}}>
      <Svg width={size} height={size}>
        {/* Background Circle */}
        <Circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          stroke={backgroundColor}
          strokeWidth={strokeWidth}
          fill="transparent"
        />

        {/* Progress Circle */}
        <Circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          stroke={progressColor}
          strokeWidth={strokeWidth}
          fill="transparent"
          strokeDasharray={circumference}
          strokeDashoffset={progressOffset}
          strokeLinecap="butt"
          rotation="-90"
          origin={`${size / 2}, ${size / 2}`}
        />
      </Svg>

      {/* Percentage Text in Center */}
      {showPercentage && (
        <View
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            justifyContent: 'center',
            alignItems: 'center',
          }}>
          <Text
            style={{
              color: 'white',
              fontSize: fontSize,
              fontWeight: '500',
            }}>
            {Math.round(progress)}%
          </Text>
        </View>
      )}
    </View>
  );
};

export default CircularProgress;
