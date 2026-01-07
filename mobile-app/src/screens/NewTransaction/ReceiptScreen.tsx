import React, {useEffect} from 'react';
import {View, Text, TouchableOpacity, Share} from 'react-native';
import {WebView} from 'react-native-webview';
import {SafeAreaView} from 'react-native-safe-area-context';

import type {NativeStackScreenProps} from '@react-navigation/native-stack';
import type {RootStackParamList} from '@/types/navigation';
import {useUserStore} from '@/stores/userStore';
import {runtimeConfig} from '@/utils/runtimeConfig';
import {useNavigation} from '@react-navigation/native';
import {UI_MESSAGES} from '@/constants/messages';
import ExternalLinkIcon from '../../../assets/share_button.svg';
import {logger} from '@/utils/logger';
import {PENDO} from '@/utils/pendo';

type ReceiptScreenProps = NativeStackScreenProps<
  RootStackParamList,
  'PaymentReceipt'
>;

const ReceiptScreen = ({route}: ReceiptScreenProps) => {
  const navigation = useNavigation();
  const merchantId = useUserStore(state => state.merchantId);
  const transactionId = route.params?.transactionId;
  const isACH = route.params?.isACH;
  const url = isACH
    ? `${runtimeConfig.APP_WEB_VIEW_PUBLIC_API}/receipt/ach/${merchantId}/${transactionId}`
    : `${runtimeConfig.APP_WEB_VIEW_PUBLIC_API}/receipt/card/${merchantId}/${transactionId}`;

  useEffect(() => {
    if (PENDO && url) {
      PENDO.screenContentChanged?.();
    }
  }, [url]);

  const handleClose = () => {
    navigation.goBack();
  };

  const handleShare = async () => {
    try {
      await Share.share({
        url: url,
        title: 'Transaction Receipt',
      });
    } catch (error) {
      logger.error(error, 'Error sharing receipt');
    }
  };

  return (
    <SafeAreaView edges={['bottom']} className="flex-1 bg-white">
      {/* Top rounded line indicator */}
      <View className="items-center pt-2 pb-0">
        <View
          className="w-9 h-1 bg-[#3C3C434D] rounded-full"
          testID="rounded-line-indicator"
        />
      </View>

      {/* Header */}
      <View className="flex-row items-center justify-between px-4 py-3 bg-gray-50 border-b border-gray-200 pt-0">
        <TouchableOpacity
          onPress={handleClose}
          className="min-w-[60px]"
          accessibilityLabel={'close receipt'}
          // @ts-ignore
          nativeID={'close-receipt'}
          testID="close-button">
          <Text className="text-[#007AFF] text-[17px] font-normal">
            {UI_MESSAGES.CLOSE}
          </Text>
        </TouchableOpacity>

        <View className="flex-1 items-center px-2">
          <Text
            className="text-[17px] text-[#000000] font-semibold"
            numberOfLines={1}>
            {url.replace('https://', '').replace('http://', '')}
          </Text>
        </View>

        <TouchableOpacity
          onPress={handleShare}
          className="min-w-[60px] items-end p-2"
          accessibilityLabel={'share button'}
          testID="share-button"
          // @ts-ignore
          nativeID={'share-button'}>
          <ExternalLinkIcon width={25} height={22} color="#007AFF" />
        </TouchableOpacity>
      </View>

      {/* WebView */}
      <View style={{flex: 1, paddingBottom: 70}}>
        <WebView
          source={{uri: url}}
          className="flex-1"
          startInLoadingState={true}
          scalesPageToFit={true}
          javaScriptEnabled={true}
          domStorageEnabled={true}
          contentInsetAdjustmentBehavior="automatic"
          testID="webview"
        />
      </View>
    </SafeAreaView>
  );
};

export default ReceiptScreen;
