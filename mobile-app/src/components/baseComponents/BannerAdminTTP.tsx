import React, {useEffect, useState} from 'react';
import {View, Text, Pressable} from 'react-native';
import {ROUTES} from '@/constants/routes';
import {useNavigation} from '@react-navigation/native';
import {NativeStackNavigationProp} from '@react-navigation/native-stack';
import {RootStackParamList} from '@/types/navigation';
import {X} from 'lucide-react-native';
import {
  getTTPBannerDismissed,
  setTTPBannerDismissed,
} from '@/utils/asyncStorage';
import {useFeatureIsOn} from '@growthbook/growthbook-react';
import {useDeviceStatus} from '@/hooks/queries/useTapToPayJWT';
import {DeviceTapToPayStatusStringEnumType} from '@/dictionaries/DeviceTapToPayStatus';
import {FEATURES} from '@/constants/features';
import DarkBlueBannerHome from './DarkBlueBannerHome';
import {useUserStore} from '@/stores/userStore';
import AriseMobileSdk from '@/native/AriseMobileSdk';
import {useIsMerchantManager} from '@/hooks/useIsMerchantManager';

type BannerTTPNavigationProp = NativeStackNavigationProp<RootStackParamList>;

const BannerTTP = (): React.JSX.Element | null => {
  const navigation = useNavigation<BannerTTPNavigationProp>();
  const [isVisible, setIsVisible] = useState(true);
  const [isLoading, setIsLoading] = useState(true);
  const {id: userId} = useUserStore();
  const {data: rawDeviceData} = useDeviceStatus();

  const isManageMerchantSettingsPermission = useIsMerchantManager();

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

  const isShowBanner =
    isTapToPayFeatureEnabled &&
    isManageMerchantSettingsPermission &&
    rawDeviceData?.tapToPayStatus !== DeviceTapToPayStatusStringEnumType.Active;

  useEffect(() => {
    const checkBannerStatus = async () => {
      try {
        const isDismissed = await getTTPBannerDismissed(userId || '');
        setIsVisible(!isDismissed);
      } catch (error) {
        setIsVisible(true);
      } finally {
        setIsLoading(false);
      }
    };

    checkBannerStatus();
  }, [userId]);

  const handleDismiss = async () => {
    try {
      await setTTPBannerDismissed(userId || '');
      setIsVisible(false);
    } catch (error) {}
  };

  if (isLoading || !isVisible) {
    return null;
  }

  return (
    <>
      {isShowBanner && (
        <DarkBlueBannerHome>
          <View className="flex-1">
            <Text className="text-[#FAFAFA] text-[16px] font-medium text-left mb-1">
              {'Get payments with Tap to Pay!'}
            </Text>
            <Pressable
              onPress={() => {
                navigation.navigate(ROUTES.TAP_TO_PAY_SPLASH, {
                  next_page: ROUTES.HOME,
                });
              }}>
              <Text className="text-[#0EA5E9] font-medium text-[14px]">
                {'Enable Now'}
              </Text>
            </Pressable>
          </View>
          <Pressable
            onPress={handleDismiss}
            hitSlop={{top: 10, bottom: 10, left: 10, right: 10}}
            className="ml-2">
            <X width={16} height={16} color="#FFFFFF7A" />
          </Pressable>
        </DarkBlueBannerHome>
      )}
    </>
  );
};

export default BannerTTP;
