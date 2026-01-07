import {View} from 'react-native';
import React from 'react';

const DarkBlueBannerHome = ({children}: {children: React.ReactNode}) => {
  return (
    <View className="w-full items-center pt-4 px-4">
      <View className="w-full bg-brand-main-10 rounded-2xl p-4 border border-[#22313C] flex-row items-center justify-between">
        {children}
      </View>
    </View>
  );
};

export default DarkBlueBannerHome;
