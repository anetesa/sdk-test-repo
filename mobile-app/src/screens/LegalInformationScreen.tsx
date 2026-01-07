import React from 'react';
import {View} from 'react-native';
import AriseHeader from '@/components/baseComponents/AriseHeader';
import ListNavigator from '@/components/baseComponents/ListNavigator';
import {NAVIGATION_TITLES} from '@/constants/messages';

const LegalInformationScreen = (): React.JSX.Element => {
  const legalItems = [
    {
      title: NAVIGATION_TITLES.PRIVACY_POLICY,
      destination: 'PrivacyPolicy',
      textColor: 'text-text-primary',
    },
    {
      title: NAVIGATION_TITLES.TERMS_AND_CONDITIONS,
      destination: 'TermsAndConditions',
      textColor: 'text-gray-900',
    },
  ];

  return (
    <View className="flex-1 bg-white">
      <AriseHeader title={NAVIGATION_TITLES.LEGAL_INFORMATION} />
      <View className="flex-1 px-4 py-6">
        <ListNavigator items={legalItems} />
      </View>
    </View>
  );
};

export default LegalInformationScreen;
