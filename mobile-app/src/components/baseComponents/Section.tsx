import React from 'react';
import {View} from 'react-native';

interface SectionProps {
  children: React.ReactNode;
}
const Section = ({children}: SectionProps): React.JSX.Element => {
  return (
    <View className="border-y border-slate-100 pt-3 pb-3 ">{children}</View>
  );
};

export default Section;
