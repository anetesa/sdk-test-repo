import React, {useEffect, useState, useRef, useCallback} from 'react';
import {View, Text, Pressable} from 'react-native';
import {useDeviceStatus} from '@/hooks/queries/useTapToPayJWT';
import {
  useTapToPayButton,
  useTapToPayItemVisibility,
} from '@/hooks/useTapToPayButton';
import {FEATURES} from '@/constants/features';
import {useFeatureIsOn} from '@growthbook/growthbook-react';
import {isIOS18OrHigher} from '@/utils/deviceUtils';
import {useFocusEffect, useNavigation} from '@react-navigation/native';
import {NativeStackNavigationProp} from '@react-navigation/native-stack';
import {RootStackParamList} from '@/types/navigation';
import {ROUTES} from '@/constants/routes';
import {useCloudCommerceStore} from '@/stores/cloudCommerceStore';
import {showTapToPayEducationScreens} from '@/cloudcommerce/tapToPayEducation';
import RequestTapToPayBottomSheet, {
  RequestTapToPayBottomSheetRef,
} from './RequestTapToPayBottomSheet';
import {logger} from '@/utils/logger';
import {useRequestTapToPay} from '@/hooks/queries/useTapToPayJWT';
import {DeviceTapToPayStatusStringEnumType} from '@/dictionaries/DeviceTapToPayStatus';
import {queryClient} from '@/utils/queryClient';
import {useUserStore} from '@/stores/userStore';
import AriseMobileSdk from '@/native/AriseMobileSdk';
import {useIsMerchantManager} from '@/hooks/useIsMerchantManager';

import {showErrorAlert} from '@/stores/alertStore';

type TapToPayItemNavigationProp = NativeStackNavigationProp<
  RootStackParamList,
  'Settings'
>;

const TapToPayItem = () => {
  const navigation = useNavigation<TapToPayItemNavigationProp>();
  const hasManagePermission = useIsMerchantManager();

  // State
  const [isIOSVersionSupported, setIsIOSVersionSupported] = useState(true);
  const [isCheckingVersion, setIsCheckingVersion] = useState(true);

  const merchantId = useUserStore(state => state.merchantId);
  // Refs
  const bottomSheetRef = useRef<RequestTapToPayBottomSheetRef>(null);
  const {
    mutateAsync: requestTapToPayMutation,
    isError: isRequestTapToPayError,
  } = useRequestTapToPay(); // Mutation to request Tap to Pay
  // Feature flag
  const [isTapToPayFeatureEnabled, setIsTapToPayFeatureEnabled] =
    useState(false);
  const isFeatureOn = useFeatureIsOn(FEATURES.TAP_TO_PAY_BASIC_TRANSACTION);

  useEffect(() => {
    const checkCompatibility = async () => {
      const compatibility = await AriseMobileSdk.checkCompatibility();
      setIsTapToPayFeatureEnabled(isFeatureOn && compatibility.isCompatible);
    };
    checkCompatibility();
  }, [isFeatureOn]);

  // CloudCommerce store state
  const isLoadingCloudCommerce = useCloudCommerceStore(
    state => state.isLoading,
  );
  const isPreparedCloudCommerce = useCloudCommerceStore(
    state => state.isPrepared,
  );

  // Data fetching
  const {
    data: rawDeviceData,
    isLoading,
    isError,
    error: deviceStatusError,
  } = useDeviceStatus();

  // Avoid showing cached/old status when returning to Settings.
  // NOTE: keep the focus callback stable to avoid infinite loops (useFocusEffect reruns when the callback changes).
  const lastFocusRefetchAtRef = useRef(0);
  useFocusEffect(
    useCallback(() => {
      const now = Date.now();
      // Throttle to avoid bursts if focus fires multiple times quickly.
      if (now - lastFocusRefetchAtRef.current < 500) {
        return;
      }
      // Avoid stacking refetches if one is already in-flight.
      if (
        queryClient.isFetching({queryKey: ['tap-to-pay-device-status']}) > 0
      ) {
        return;
      }

      lastFocusRefetchAtRef.current = now;
      queryClient.invalidateQueries({
        queryKey: ['tap-to-pay-device-status'],
        refetchType: 'active',
      });
    }, []),
  );

  useEffect(() => {
    if (isError) {
      showErrorAlert(
        (deviceStatusError as any)?.response?.data?.Details ||
          'Failed to fetch Tap to Pay device status',
      );
    }
  }, [isError, deviceStatusError]);

  useEffect(() => {
    if (isRequestTapToPayError) {
      showErrorAlert('Failed to request Tap to Pay');

      queryClient.setQueryData(['tap-to-pay-device-status'], (oldData: any) => {
        return {
          ...oldData,
          tapToPayStatus: DeviceTapToPayStatusStringEnumType.Inactive,
        };
      });
    }
  }, [isRequestTapToPayError, merchantId]);

  // Check iOS version
  useEffect(() => {
    const checkIOSVersion = async () => {
      try {
        const isSupported = await isIOS18OrHigher();
        setIsIOSVersionSupported(isSupported);
      } catch (error) {
        // Default to true to avoid blocking functionality
        setIsIOSVersionSupported(true);
      } finally {
        setIsCheckingVersion(false);
      }
    };

    checkIOSVersion();
  }, []);

  logger.info('rawDeviceData?.tapToPayStatus', rawDeviceData?.tapToPayStatus);

  // Button state using custom hook
  const buttonState = useTapToPayButton(
    {
      tapToPayStatus:
        rawDeviceData?.tapToPayStatus as DeviceTapToPayStatusStringEnumType,
      hasManagePermission: hasManagePermission ?? false,
      isIOSVersionSupported,
      isLoadingCloudCommerce,
      isPreparedCloudCommerce,
    },
    // onRequestPress
    useCallback(() => {
      bottomSheetRef.current?.present();
    }, []),
    // onEnablePress
    useCallback(() => {
      navigation.navigate(ROUTES.TAP_TO_PAY_SPLASH, {
        next_page: ROUTES.SETTINGS,
      });
    }, [navigation]),
  );

  // Component visibility
  const isVisible = useTapToPayItemVisibility(
    isTapToPayFeatureEnabled,
    hasManagePermission ?? false,
    rawDeviceData?.tapToPayStatus as DeviceTapToPayStatusStringEnumType,
    isLoading,
    isCheckingVersion,
  );

  // Handle request confirmation
  const handleConfirmRequest = useCallback(async () => {
    requestTapToPayMutation();
    //update the device status to requested
    queryClient.setQueryData(['tap-to-pay-device-status'], (oldData: any) => {
      return {
        ...oldData,
        tapToPayStatus: DeviceTapToPayStatusStringEnumType.Requested,
      };
    });
    bottomSheetRef.current?.dismiss();
  }, [requestTapToPayMutation]);

  const handleCloseBottomSheet = useCallback(() => {
    bottomSheetRef.current?.dismiss();
  }, []);

  // Don't render if not visible
  if (!isVisible) {
    return null;
  }

  return (
    <>
      <View className="py-[20px] px-[24px] flex-row justify-between items-center">
        <View className="flex-1">
          <Text className="text-lg leading-[24px] font-medium text-text-primary">
            Tap to Pay on iPhone
          </Text>
          <Text className="text-sm text-text-tertiary mt-2 font-normal">
            Turn your iPhone into a terminal{'\n'}to receive contactless
            payments.
          </Text>
          <Pressable
            className="mt-2"
            onPress={() => {
              showTapToPayEducationScreens();
            }}>
            <Text className="text-sm text-brand-main font-medium">
              Learn More
            </Text>
          </Pressable>
          {!isIOSVersionSupported && (
            <View className="mt-2">
              <Text className="text-sm text-warning-main font-normal">
                Available only on iOS 18 or higher.
              </Text>
            </View>
          )}
        </View>

        {/* Dynamic Button based on TTP Status */}
        <Pressable
          disabled={buttonState.isDisabled}
          onPress={buttonState.onPress}
          className={`w-21 rounded-xl border py-3 px-4 ${
            buttonState.isGhostState ||
            !isIOSVersionSupported ||
            buttonState.isDisabled
              ? 'border-gray-200 opacity-50'
              : 'border-gray-300'
          }`}>
          <Text className="text-sm font-medium text-text-primary text-center">
            {buttonState.label}
          </Text>
        </Pressable>
      </View>

      <View className="mx-[24px] border-t border-gray-200" />

      {/* Confirmation Bottom Sheet */}
      <RequestTapToPayBottomSheet
        ref={bottomSheetRef}
        onConfirm={handleConfirmRequest}
        onClose={handleCloseBottomSheet}
      />
    </>
  );
};

export default TapToPayItem;
