import React, {useEffect, useRef} from 'react';
import {View, Text, Image, SafeAreaView} from 'react-native';
import {
  useNavigation,
  useRoute,
  RouteProp,
  useIsFocused,
} from '@react-navigation/native';
import {NativeStackNavigationProp} from '@react-navigation/native-stack';
import type {RootStackParamList} from '@/types/navigation';
import AriseButton from '@/components/baseComponents/AriseButton';
import {useCloudCommerceStore} from '@/stores/cloudCommerceStore';
import {setTTPSplashScreenDismissed} from '@/utils/asyncStorage';
import {useUserStore} from '@/stores/userStore';
import {logger} from '@/utils/logger';
import {DeviceTapToPayStatusStringEnumType} from '@/dictionaries/DeviceTapToPayStatus';
import {queryClient} from '@/utils/queryClient';
import {ROUTES} from '@/constants/routes';
import {TAP_TO_PAY_MESSAGES} from '@/constants/messages';
import {useIsMerchantManager} from '@/hooks/useIsMerchantManager';

type TapToPaySplashScreenNavigationProp = NativeStackNavigationProp<
  RootStackParamList,
  'TapToPaySplash'
>;

type TapToPaySplashScreenRouteProp = RouteProp<
  RootStackParamList,
  'TapToPaySplash'
>;

const TapToPaySplashScreen = () => {
  const navigation = useNavigation<TapToPaySplashScreenNavigationProp>();
  const route = useRoute<TapToPaySplashScreenRouteProp>();
  const {next_page, transactionDetails, zcp} = route.params || {};

  const cloudCommerce = useCloudCommerceStore();
  const isComingFromLoginScreen = route.params?.isComingFromLoginScreen;
  const merchantId = useUserStore(s => s.merchantId || '') || '';
  const isFocused = useIsFocused();
  const isMerchantManager = useIsMerchantManager();

  // Track CloudCommerce store state
  const isLoading = useCloudCommerceStore(state => state.isLoading);
  const isPrepared = useCloudCommerceStore(state => state.isPrepared);

  // Ref to hold the timeout ID so we can clear it
  const navigationTimeoutRef = useRef<NodeJS.Timeout | null>(null);

  // Clear timeout on unmount
  useEffect(() => {
    return () => {
      if (navigationTimeoutRef.current) {
        clearTimeout(navigationTimeoutRef.current);
      }
    };
  }, []);

  const navigateToNext = () => {
    // If this splash was presented right after Login, "back" returns to Login.
    // In that case we must go to Home (and reset) to avoid leaving Login in the back stack.
    if (!next_page) {
      if (isComingFromLoginScreen) {
        navigation.reset({
          index: 0,
          routes: [{name: ROUTES.HOME as any}],
        });
      } else {
        navigation.goBack();
      }
      return;
    }

    const isNewTransactionNextPage =
      next_page === 'LoadingTapToPay' || next_page === 'ZCPTipsAnalysis';

    // Only forward transaction params to NewTransaction flow screens.
    const paramsForNext = isNewTransactionNextPage
      ? next_page === 'ZCPTipsAnalysis'
        ? {
            isComingFromTapToPaySplash: true,
            transactionDetails,
            ...(zcp ?? {}),
          }
        : {
            isComingFromTapToPaySplash: true,
            transactionDetails,
          }
      : {isComingFromTapToPaySplash: true};

    const routeNames: string[] =
      (navigation as any).getState?.()?.routeNames ?? [];
    const canHandleLocally = routeNames.includes(String(next_page));

    // If the splash is inside NewTransaction stack, we can replace directly to nested screens.
    if (canHandleLocally) {
      navigation.replace(next_page as any, paramsForNext);
      return;
    }

    // Otherwise, route via Root -> NewTransaction nested screen.
    if (isNewTransactionNextPage) {
      navigation.replace(ROUTES.NEW_TRANSACTION as any, {
        screen: next_page,
        params: paramsForNext,
      });
      return;
    }

    // RootStack screen (or parent navigator). If this splash is nested, replace on parent.
    const parentNav = (navigation as any).getParent?.();
    const parentRouteNames: string[] =
      parentNav?.getState?.()?.routeNames ?? [];
    if (parentNav && parentRouteNames.includes(String(next_page))) {
      parentNav.replace(next_page as any, paramsForNext);
      return;
    }

    navigation.replace(next_page as any, paramsForNext);
  };

  // Navigate back when TapToPay is ready
  useEffect(() => {
    // Only navigate if this screen is focused and prepared
    if (isPrepared && isFocused) {
      // Clear the timeout if we're navigating due to isPrepared
      if (navigationTimeoutRef.current) {
        clearTimeout(navigationTimeoutRef.current);
        navigationTimeoutRef.current = null;
      }

      // IMPORTANT:
      // Never leave TapToPaySplash in the back stack. Use replace() so "Back" from the next
      // screen never shows this splash screen.
      navigateToNext();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isPrepared, navigation, next_page, isFocused]);

  // Detect swipe back gesture or any navigation away
  useEffect(() => {
    const unsubscribe = navigation.addListener('blur', () => {
      // Clear timeout when screen loses focus
      if (navigationTimeoutRef.current) {
        clearTimeout(navigationTimeoutRef.current);
        navigationTimeoutRef.current = null;
      }
    });
    return unsubscribe;
  }, [navigation]);

  // Detect swipe back gesture
  useEffect(() => {
    const unsubscribe = navigation.addListener('beforeRemove', _e => {
      if (isComingFromLoginScreen) {
        setTTPSplashScreenDismissed(merchantId);
      }
    });

    return unsubscribe;
  }, [navigation, isComingFromLoginScreen, merchantId]);

  const handleEnableNow = async () => {
    try {
      // Wait for activation (+ education modal) to finish.
      // Terminal preparation runs in the background and will complete on LoadingTapToPay.
      const result = await cloudCommerce.activateTapToPay();

      if (result.activated) {
        // Optimistic update of the device status to Active (UI only)
        queryClient.setQueryData(
          ['tap-to-pay-device-status'],
          (oldData: any) => {
            return {
              ...oldData,
              tapToPayStatus: DeviceTapToPayStatusStringEnumType.Active,
            };
          },
        );
      }

      if (next_page) {
        navigateToNext();
      } else {
        navigation.goBack();
      }
    } catch (error) {
      // The user could press the Cancel button in the SDK modal,
      logger.error('Failed to activate Tap to Pay:', error);
      // Handle error - could show an alert or navigate to error screen
      // Alert.alert('Error', 'Failed to activate Tap to Pay. Please try again.');
    }
  };

  const handleCancel = () => {
    if (isComingFromLoginScreen) {
      setTTPSplashScreenDismissed(merchantId);
      navigation.reset({
        index: 0,
        routes: [{name: ROUTES.HOME as any}],
      });
      return;
    }

    // Cancel should behave like a true back action (pop the splash) whenever possible.
    // Using navigate(next_page) can leave the splash behind the destination screen,
    // causing "Back" from Settings/Home to land back on this splash.
    if (navigation.canGoBack()) {
      navigation.goBack();
      return;
    }

    if (next_page) {
      navigateToNext();
      return;
    }

    navigation.replace(ROUTES.HOME as any);
  };

  return (
    <View className="flex-1">
      {/* Top Section with Blue Background */}
      <View className="bg-[#0EA5E914]">
        <SafeAreaView>
          <View className="justify-center items-center h-[340px]">
            <Image
              source={require('../../assets/ttpSplash.png')}
              className="w-full max-w-full h-full"
              resizeMode="cover"
            />
          </View>
        </SafeAreaView>
      </View>

      {/* Bottom Section with White Background */}
      <View className="flex-1 bg-white">
        <SafeAreaView className="flex-1">
          <View className="flex-1 px-4 py-[30px]">
            <View className="mb-4">
              <Text className="text-3xl font-bold text-center text-gray-900 mb-4">
                Tap to Pay on iPhone
              </Text>
              <Text className="text-base text-center text-text-secondary leading-7 px-3">
                Accept physical debit and credit cards as well as Apple Pay and
                other digital wallets.{'\n'}Right on your iPhone.
              </Text>
            </View>

            {/* Footnote */}
            <View className="mb-[30px]">
              <Text className="text-xs text-center text-text-tertiary leading-5 px-2">
                {isMerchantManager
                  ? TAP_TO_PAY_MESSAGES.SPLASH_DISCLAIMER_MANAGER
                  : TAP_TO_PAY_MESSAGES.SPLASH_DISCLAIMER_NON_MANAGER}
              </Text>
            </View>

            {/* Buttons */}
            <View className="space-y-4">
              <AriseButton
                title={'Enable Now'}
                onPress={handleEnableNow}
                className="w-full"
                loading={isLoading}
                disabled={isLoading}
              />

              <AriseButton
                type="outline"
                title={isComingFromLoginScreen ? 'Skip' : 'Cancel'}
                className="h-[56px]"
                onPress={handleCancel}
                disabled={isLoading}
              />
            </View>
          </View>
        </SafeAreaView>
      </View>
    </View>
  );
};

export default TapToPaySplashScreen;
