import React from 'react';
import {Text} from 'react-native';
import SkeletonPlaceholder from 'react-native-skeleton-placeholder';

export const TextSkeleton = ({width = 100}: {width?: number}) => (
  <Text className="text-base h-5">
    <SkeletonPlaceholder
      backgroundColor="#F5F6F7"
      highlightColor="#FBFBFC"
      borderRadius={5}
      speed={800}>
      <SkeletonPlaceholder.Item flexDirection="row" alignItems="flex-start">
        {/* Text block */}
        <SkeletonPlaceholder.Item marginLeft={12}>
          <SkeletonPlaceholder.Item width="90%" height={18} />
          <SkeletonPlaceholder.Item width="70%" height={18} />
        </SkeletonPlaceholder.Item>

        {/* Chip */}
        <SkeletonPlaceholder.Item
          width={width}
          height={18}
          alignSelf="flex-start"
        />
      </SkeletonPlaceholder.Item>
    </SkeletonPlaceholder>
  </Text>
);
