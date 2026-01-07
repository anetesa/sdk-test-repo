import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  SafeAreaView,
} from 'react-native';
import ChevronRightIcon from '../../assets/arrow-enter.svg';
import {Check} from 'lucide-react-native';
import {NativeStackScreenProps} from '@react-navigation/native-stack';
import {RootStackParamList} from '@/types/navigation';
import {useUserStore} from '@/stores/userStore';
import {usePostAuthFlow} from '@/hooks/usePostAuthFlow';
import AriseHeader from '@/components/baseComponents/AriseHeader';

import {
  MerchantListItem,
  mapProfileToMerchantItem,
} from '@/utils/profileSelection';
import Header from '@/components/Header';

interface MerchantItemProps {
  merchant: MerchantListItem;
  onPress: (merchant: MerchantListItem) => void;
  merchantIdSelected: string;
}

const MerchantItem: React.FC<MerchantItemProps> = ({
  merchant,
  onPress,
  merchantIdSelected,
}) => {
  return (
    <TouchableOpacity
      className="bg-white"
      onPress={() => onPress(merchant)}
      activeOpacity={0.7}>
      <View className="flex-row items-center py-5 border-b border-[#000A0F14] gap-4 ml-4 mr-4">
        <View className="flex-1 ">
          <View className="flex-row items-center gap-1 ml-[-14px] mb-2">
            <Text
              className="text-lg font-medium leading-6 text-text-primary"
              numberOfLines={1}
              style={{letterSpacing: -0.18}}>
              {merchant.name}
            </Text>
            {merchant.isSuspended && (
              <Text
                className="text-lg font-medium leading-6 text-text-faded"
                style={{letterSpacing: -0.18}}>
                (Suspended)
              </Text>
            )}
          </View>
          <Text
            className="text-sm font-normal leading-5 text-text-tertiary ml-[-10px]"
            numberOfLines={1}>
            {merchant.address}
          </Text>
        </View>
        {merchantIdSelected === merchant.profile?.merchantId ? (
          <Check color="#0369A1" width={19} height={24} />
        ) : (
          <ChevronRightIcon width={14} height={14} />
        )}
      </View>
    </TouchableOpacity>
  );
};

type Props = NativeStackScreenProps<RootStackParamList, 'MerchantSelection'>;

const MerchantSelectionScreen = ({navigation, route}: Props) => {
  const profiles = route.params?.profiles || [];
  const isFromSettings = route.params?.isFromSettings || false;

  const merchants = profiles
    .map(mapProfileToMerchantItem)
    .filter(merchant => !merchant.isSuspended && !merchant.isClosed);

  const {executePostAuthFlow} = usePostAuthFlow();
  const setUser = useUserStore(state => state.setUser);

  const merchantIdSelected = useUserStore(state => state.merchantId) || '';

  // Show loading or empty state while navigating
  if (merchants.length === 0) {
    return (
      <View className="flex-1 bg-white">
        <AriseHeader title="Select an account" />
      </View>
    );
  }

  const handleMerchantPress = async (merchant: MerchantListItem) => {
    if (merchant.profile) {
      // Find the index of the selected profile in the original profiles array
      const profileIndex = profiles.findIndex(
        p => p.id === merchant.profile!.id,
      );

      setUser({
        merchantId: merchant.profile!.merchantId || '',
      });

      if (profileIndex !== -1) {
        // Continue with post-auth flow
        await executePostAuthFlow({
          navigation,
          errorContext: 'after merchant selection',
        });
      } else {
        console.error('Could not find selected profile in profiles array');
      }
    }
  };

  return (
    <View className="flex-1 bg-white">
      {isFromSettings ? (
        <SafeAreaView className=" bg-dark-page-bg">
          <Header showBack={true} title={'Switch account'} />
        </SafeAreaView>
      ) : (
        <AriseHeader title="Select an account" />
      )}

      <ScrollView className="flex-1" showsVerticalScrollIndicator={false}>
        <View className="px-0 mt-3">
          {merchants.map(merchant => (
            <MerchantItem
              key={merchant.id}
              merchantIdSelected={merchantIdSelected}
              merchant={merchant}
              onPress={handleMerchantPress}
            />
          ))}
        </View>
      </ScrollView>
    </View>
  );
};

export default MerchantSelectionScreen;
