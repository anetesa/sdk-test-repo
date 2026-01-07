import React, {useCallback, useRef, useEffect} from 'react';
import {View, Text, Pressable} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';
import Header from '@/components/Header';
import {useUserStore} from '@/stores/userStore';
import {PendoSDK} from 'rn-pendo-sdk';
import {useSelectedProfile} from '@/hooks/useSelectedProfile';
import {ChevronRight, LogOut} from 'lucide-react-native';
import BSheet from '@gorhom/bottom-sheet';
import LogOutBottomSheet from '@/screens/SettingsScreen/LogOutBottomSheet';
import {ROUTES} from '@/constants/routes';
import {logger} from '@/utils/logger';
import {PENDO} from '@/utils/pendo';
import {clearSession} from '@/utils/clearSession';
import TapToPayItem from '@/components/TapToPayItem';

const SettingsScreen = ({navigation}: any) => {
  const {meProfile} = useSelectedProfile();
  const {selectedProfile} = useSelectedProfile();
  const merchantName = selectedProfile?.accountName;
  const bottomSheetRef = useRef<BSheet>(null);

  useEffect(() => {
    if (merchantName) {
      PENDO.screenContentChanged?.();
    }
  }, [merchantName]);

  const handleLogoutConfirm = async () => {
    try {
      PendoSDK.endSession();
    } catch (error) {
      logger.error(error, 'Error ending Pendo session');
    }

    // Clear all stores and session data
    try {
      useUserStore.getState().setUser({
        id: '',
        email: '',
        firstName: '',
        lastName: '',
        merchantId: '',
      });
      await clearSession();
    } catch (error) {
      logger.error(error, 'Error clearing session');
    }

    bottomSheetRef.current?.close();
    // Use reset instead of navigate to make Login the root screen
    // This prevents users from swiping back to Home after logout
    navigation.reset({
      index: 0,
      routes: [{name: ROUTES.LOGIN}],
    });
  };

  const handleLogout = useCallback(() => {
    bottomSheetRef.current?.expand();
  }, []);

  const handleSwitchAccount = useCallback(() => {
    navigation.push(ROUTES.MERCHANT_SELECTION, {
      profiles: meProfile?.profiles || [],
      isFromSettings: true,
    });
  }, [navigation, meProfile]);

  const settingsItems = [
    /*
    {
      title: 'Payment Methods',
      destination: 'PaymentMethods',
      description:
        'Control which payment methods are\nsupported when performing a transaction.',
    },
    */
    {
      renderCustomItem: () => <TapToPayItem />,
    },
    {
      title: 'Switch Account',
      onPress: handleSwitchAccount,
      isHidden: meProfile?.profiles?.length === 1,
    },
    {
      title: 'Support',
      destination: 'ContactSupport',
    },
    {
      title: 'Privacy Policy',
      destination: 'PrivacyPolicy',
    },
    {
      title: 'Terms and Conditions',
      destination: 'TermsAndConditions',
    },
    {
      title: 'Log Out',
      onPress: handleLogout,
      color: '#991B1B',
      icon: LogOut,
    },
  ];

  const renderItem = (item: any, index: number) =>
    item.isHidden ? null : (
      <View key={index} className="z-0">
        <Pressable
          onPress={
            item.onPress || (() => navigation.navigate(item.destination))
          }
          className="py-[20px] px-[24px] flex-row justify-between items-center z-0"
          accessibilityLabel={item.title}>
          <View className="flex-1">
            <Text
              className={`text-lg leading-[24px] font-medium ${
                item.color ? '' : 'text-text-primary'
              }`}
              style={item.color ? {color: item.color} : undefined}>
              {item.title}
            </Text>
            {item.description && (
              <Text className="text-sm text-text-tertiary mt-2">
                {item.description}
              </Text>
            )}
          </View>
          {item.icon ? (
            <item.icon
              color={item.color || '#8FA0A3'}
              size={24}
              strokeWidth={1.5}
            />
          ) : (
            <ChevronRight
              className="text-text-tertiary"
              size={24}
              strokeWidth={1.5}
            />
          )}
        </Pressable>
        {index < settingsItems.length - 1 && (
          <View className="mx-[24px] border-t border-gray-200 z-0" />
        )}
      </View>
    );

  return (
    <SafeAreaView className="flex-1 bg-dark-page-bg" edges={['top']}>
      <Header showBack={true} title={merchantName || 'Settings'} />
      <View className="flex-1 bg-white z-0">
        {settingsItems.map((item, index) =>
          item.renderCustomItem
            ? item.renderCustomItem()
            : renderItem(item, index),
        )}
      </View>
      <LogOutBottomSheet
        ref={bottomSheetRef}
        onLogout={handleLogoutConfirm}
        onClose={() => bottomSheetRef.current?.close()}
      />
    </SafeAreaView>
  );
};

export default SettingsScreen;
