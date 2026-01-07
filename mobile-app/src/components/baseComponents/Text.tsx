import React from 'react';
import {Text as RNText, TextProps} from 'react-native';
import {TextSkeleton} from './TextSkeleton';

export const Text = (
  props: TextProps & {isLoading?: boolean; widthSkeleton?: number},
) => {
  if (props.isLoading) {
    return <TextSkeleton width={props.widthSkeleton} />;
  }
  return <RNText {...props} />;
};
