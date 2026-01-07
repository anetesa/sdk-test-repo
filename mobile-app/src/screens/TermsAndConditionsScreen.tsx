import React from 'react';
import {View} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';
import ParsedHtmlView from '@/components/ParsedHtmlView';
import Header from '@/components/Header';
import {useUserStore} from '@/stores/userStore';
import AriseHeader from '@/components/baseComponents/AriseHeader';
import {TERMS_AND_CONDITIONS_URL} from '@/constants/termsAndConditionsAndPolicy';
import {NAVIGATION_TITLES} from '@/constants/messages';

const TermsAndConditionsScreen = (): React.JSX.Element => {
  const {id} = useUserStore();

  return (
    <View className="flex-1">
      {id ? (
        <SafeAreaView className="bg-dark-page-bg" edges={['top']}>
          <Header
            showBack={true}
            title={NAVIGATION_TITLES.TERMS_AND_CONDITIONS}
          />
        </SafeAreaView>
      ) : (
        <AriseHeader title={NAVIGATION_TITLES.TERMS_AND_CONDITIONS} />
      )}

      <SafeAreaView className="flex-1 bg-white" edges={['bottom']}>
        <ParsedHtmlView
          url={TERMS_AND_CONDITIONS_URL}
          className="flex-1"
          tagStyles={{
            h1: {color: '#09090B'},
            h2: {color: '#3F3F46'},
            p: {color: '#3F3F46'},
          }}
        />
      </SafeAreaView>
    </View>
  );
};

export default TermsAndConditionsScreen;
