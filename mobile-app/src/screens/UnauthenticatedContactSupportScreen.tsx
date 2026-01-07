import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  Linking,
  Alert,
  ActivityIndicator,
} from 'react-native';
import Clipboard from '@react-native-clipboard/clipboard';
import AriseHeader from '@/components/baseComponents/AriseHeader';
import {Copy, Mail, Phone} from 'lucide-react-native';
import {useTechSupport} from '@/hooks/queries/useTechSupport';
import {
  UI_MESSAGES,
  ALERT_MESSAGES,
  NAVIGATION_TITLES,
  SUPPORT_MESSAGES,
} from '@/constants/messages';
import {COLORS} from '@/constants/colors';
import {useAlertStore} from '@/stores/alertStore';
import {logger} from '@/utils/logger';

const UnauthenticatedContactSupportScreen = (): React.JSX.Element => {
  const {data: techSupportInfo, isLoading, isError} = useTechSupport();

  // Fallback values in case the API fails
  const email = techSupportInfo?.email || 'gatewaysupport@risewithaurora.com';
  const phone = techSupportInfo?.phone || '+1 (833) 287-6722';

  const {showSuccessAlert} = useAlertStore();
  const copyToClipboard = (text: string) => {
    Clipboard.setString(text);
    showSuccessAlert(SUPPORT_MESSAGES.COPIED_TO_CLIPBOARD);
  };

  const handleEmailPress = () => {
    const url = `mailto:${email}`;
    Linking.openURL(url).catch(error => {
      logger.error(error, 'Error opening email link');
      Alert.alert('Error', ALERT_MESSAGES.EMAIL_APP_ERROR);
    });
  };

  const handlePhonePress = () => {
    const url = `tel:${phone}`;
    Linking.openURL(url).catch(error => {
      logger.error(error, 'Error opening phone link');
      Alert.alert('Error', ALERT_MESSAGES.PHONE_CALL_ERROR);
    });
  };

  if (isLoading) {
    return (
      <View className="flex-1 bg-white">
        <AriseHeader title={NAVIGATION_TITLES.SUPPORT} />
        <View className="flex-1 justify-center items-center">
          <ActivityIndicator size="large" color={COLORS.SECONDARY} />
          <Text className="text-base text-text-secondary mt-2">
            {UI_MESSAGES.LOADING_SUPPORT}
          </Text>
        </View>
      </View>
    );
  }

  return (
    <View className="flex-1 bg-white">
      <AriseHeader title={NAVIGATION_TITLES.SUPPORT} />
      <View className="flex-1 px-6 py-6">
        {/* Error state */}
        {isError && (
          <View className="bg-red-50 border border-red-200 rounded-lg p-4 mb-4">
            <Text className="text-sm text-red-600">
              {SUPPORT_MESSAGES.UNABLE_TO_LOAD_SUPPORT}
            </Text>
          </View>
        )}

        {/* Main Content */}
        <View className="flex-1">
          <Text className="text-xl font-medium text-text-primary mb-2">
            {SUPPORT_MESSAGES.QUESTIONS_TITLE}
          </Text>
          <Text className="text-base text-text-secondary mb-6">
            {SUPPORT_MESSAGES.CONTACT_DESCRIPTION}
          </Text>

          {/* Email Section */}
          <View className="mb-8">
            <Text className="text-[14px] font-medium text-text-primary mb-2">
              {SUPPORT_MESSAGES.EMAIL_LABEL}
            </Text>
            <View className="flex-row items-center ">
              <TouchableOpacity
                onPress={() => copyToClipboard(email)}
                className="">
                <Text className="text-base text-text-primary font-medium">
                  {email}
                </Text>
              </TouchableOpacity>
              <TouchableOpacity
                onPress={() => copyToClipboard(email)}
                className="p-2">
                <Copy width={17} height={17} color={COLORS.SECONDARY} />
              </TouchableOpacity>
            </View>
          </View>

          {/* Phone Section */}
          <View className="mb-8">
            <Text className="text-[14px] font-medium text-text-primary mb-2">
              {SUPPORT_MESSAGES.PHONE_LABEL}
            </Text>
            <View className="flex-row items-center ">
              <TouchableOpacity
                onPress={() => copyToClipboard(phone)}
                className="">
                <Text className="text-base text-text-primary font-medium">
                  {phone}
                </Text>
              </TouchableOpacity>
              <TouchableOpacity
                onPress={() => copyToClipboard(phone)}
                className="p-2">
                <Copy width={17} height={17} color="#6B7280" />
              </TouchableOpacity>
            </View>
          </View>
        </View>

        {/* Bottom Action Buttons */}
        <View className="space-y-4 mb-6">
          <TouchableOpacity
            onPress={handleEmailPress}
            className="bg-white border border-gray-300 rounded-lg py-4 px-6 flex-row items-center justify-center">
            <Mail width={20} height={20} color="#6B7280" />
            <Text className="text-base font-medium text-text-primary ml-2">
              {SUPPORT_MESSAGES.EMAIL_US_BUTTON}
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            onPress={handlePhonePress}
            className="bg-white border border-gray-300 rounded-lg py-4 px-6 flex-row items-center justify-center">
            <Phone width={20} height={20} color="#6B7280" />
            <Text className="text-base font-medium text-text-primary ml-2">
              {phone}
            </Text>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
};

export default UnauthenticatedContactSupportScreen;
