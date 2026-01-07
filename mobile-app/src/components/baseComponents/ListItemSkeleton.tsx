import React from 'react';
import {Dimensions} from 'react-native';
import SkeletonPlaceholder from 'react-native-skeleton-placeholder';
import LineSeparator from './LineSeparator';

const {width: SCREEN_W} = Dimensions.get('window');
const CHIP_WIDTH = 90 + 12;

export const ListItemSkeleton = () => (
  <SkeletonPlaceholder
    backgroundColor="#F5F6F7"
    highlightColor="#FBFBFC"
    speed={1000}>
    <SkeletonPlaceholder.Item
      flexDirection="row"
      alignItems="flex-start"
      padding={16}>
      {/* Avatar */}
      <SkeletonPlaceholder.Item width={56} height={56} borderRadius={28} />

      {/* Text block */}
      <SkeletonPlaceholder.Item
        marginLeft={12}
        style={{
          flex: 1,
          maxWidth: SCREEN_W - 56 - 16 * 2 - CHIP_WIDTH - 12,
        }}>
        <SkeletonPlaceholder.Item width="90%" height={18} />
        <SkeletonPlaceholder.Item width="70%" height={18} marginTop={12} />
      </SkeletonPlaceholder.Item>

      {/* Chip */}
      <SkeletonPlaceholder.Item
        width={60}
        height={18}
        marginLeft={16}
        alignSelf="flex-start"
      />
    </SkeletonPlaceholder.Item>
  </SkeletonPlaceholder>
);

export const FullSkeletonList = () => (
  <>
    <ListItemSkeleton />
    <LineSeparator />
    <ListItemSkeleton />
    <LineSeparator />
    <ListItemSkeleton />
    <LineSeparator />
    <ListItemSkeleton />
    <LineSeparator />
    <ListItemSkeleton />
    <LineSeparator />
    <ListItemSkeleton />
    <LineSeparator />
    <ListItemSkeleton />
    <LineSeparator />
    <ListItemSkeleton />
  </>
);
