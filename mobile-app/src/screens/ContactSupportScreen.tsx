import React, {useEffect} from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  Linking,
  Alert,
  ActivityIndicator,
} from 'react-native';
import Clipboard from '@react-native-clipboard/clipboard';
import {Copy, ExternalLink, Mail, Phone} from 'lucide-react-native';
import {SafeAreaView} from 'react-native-safe-area-context';
import Header from '@/components/Header';
import {useSelectedProfile} from '@/hooks/useSelectedProfile';
import {UI_MESSAGES, ALERT_MESSAGES} from '@/constants/messages';
import {COLORS} from '@/constants/colors';
import {useAlertStore} from '@/stores/alertStore';
import {logger} from '@/utils/logger';
import {PENDO} from '@/utils/pendo';

const ContactSupportScreen = (): React.JSX.Element => {
  const {
    selectedProfile,
    meProfile,
    isLoading: isMeProfileLoading,
  } = useSelectedProfile({
    forceFresh: true,
  });

  // Get support info with priority: Profile -> Default -> Hardcoded
  const profileSupport = selectedProfile?.support;
  const defaultSupport = meProfile?.defaultSupport;

  const formatFullPhoneNumber = (phoneNumber: string | undefined): string => {
    if (!phoneNumber) {
      return '';
    }
    const cleaned = phoneNumber.replace(/\D/g, '');

    // Assumes US-style numbers (10 or 11 digits)
    const match = cleaned.match(/^(1)?(\d{3})(\d{3})(\d{4})$/);
    if (match) {
      // match[2] is area code, match[3] is prefix, match[4] is line number
      return `+1 (${match[2]}) ${match[3]}-${match[4]}`;
    }

    // Fallback for numbers that are already formatted or have a different structure
    return phoneNumber;
  };

  useEffect(() => {
    if (!isMeProfileLoading) {
      PENDO.screenContentChanged?.();
    }
  }, [isMeProfileLoading]);

  let email: string | undefined;
  let rawPhone: string | undefined;
  let website: string | undefined;

  const hasProfileSupport =
    profileSupport?.email ||
    profileSupport?.phoneNumber ||
    profileSupport?.website;

  if (hasProfileSupport) {
    email = profileSupport?.email || '';
    rawPhone = profileSupport?.phoneNumber || '';
    website = profileSupport?.website || '';
  } else {
    email = defaultSupport?.email || 'gatewaysupport@risewithaurora.com';
    rawPhone = defaultSupport?.phoneNumber || '+1 (833) 287-6722';
    website = defaultSupport?.website || '';
  }

  const phone = formatFullPhoneNumber(rawPhone);
  const {showSuccessAlert} = useAlertStore();

  const copyToClipboard = (text: string | undefined) => {
    if (!text) {
      return;
    }
    Clipboard.setString(text);
    showSuccessAlert('Copied to clipboard');
  };

  const handleEmailPress = () => {
    if (!email) {
      return;
    }
    const url = `mailto:${email}`;
    Linking.openURL(url).catch(error => {
      logger.error(error, 'Error opening email link');
      Alert.alert('Error', ALERT_MESSAGES.EMAIL_APP_ERROR);
    });
  };

  const handlePhonePress = () => {
    if (!phone) {
      return;
    }
    const url = `tel:${phone}`;
    Linking.openURL(url).catch(error => {
      logger.error(error, 'Error opening phone link');
      Alert.alert('Error', ALERT_MESSAGES.PHONE_CALL_ERROR);
    });
  };

  const handleWebsitePress = () => {
    if (!website) {
      return;
    }
    let url = website;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = `https://${url}`;
    }
    Linking.openURL(url).catch(error => {
      logger.error(error, 'Error opening website link');
      Alert.alert('Error', 'Unable to open website');
    });
  };

  const formatWebsiteDomain = (url: string | undefined) => {
    if (!url) {
      return '';
    }
    try {
      const parsedUrl = new URL(
        url.startsWith('http') ? url : `https://${url}`,
      );
      return parsedUrl?.hostname?.replace(/^www\./, '');
    } catch (e) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?/i, '').split('/')[0];
    }
  };

  if (isMeProfileLoading) {
    return (
      <View className="flex-1 bg-dark-page-bg">
        <SafeAreaView edges={['top']}>
          <Header showBack={true} title="Support" />
        </SafeAreaView>
        <View className="flex-1 justify-center items-center bg-white">
          <ActivityIndicator size="large" color={COLORS.SECONDARY} />
          <Text className="text-base text-text-secondary mt-2">
            {UI_MESSAGES.LOADING_SUPPORT}
          </Text>
        </View>
      </View>
    );
  }

  return (
    <View className="flex-1 bg-dark-page-bg">
      <SafeAreaView edges={['top']}>
        <Header showBack={true} title="Support" />
      </SafeAreaView>
      <View className="flex-1 justify-between bg-white">
        <View className="px-6 pt-4">
          <Text className="text-xl leading-[24px] font-medium text-text-primary mb-2">
            Do you have any questions?
          </Text>
          <Text className="text-base text-text-secondary mb-6">
            Contact us and we will be happy to help you.
          </Text>
          {/* Email Section */}
          {email && (
            <View className="mb-6">
              <Text className="text-sm leading-[20px] text-text-primary font-medium mb-2">
                Email:
              </Text>
              <View className="flex-row items-center">
                <Text
                  className="text-base text-text-primary font-medium"
                  selectable={true}>
                  {email}
                </Text>
                <TouchableOpacity
                  onPress={() => copyToClipboard(email)}
                  className="ml-2"
                  accessibilityLabel="Copy email"
                  testID="copy-email-btn">
                  <Copy size={20} color="#6B7280" />
                </TouchableOpacity>
              </View>
            </View>
          )}

          {/* Phone Section */}
          {phone && (
            <View className="mb-6">
              <Text className="text-sm leading-[20px] text-text-primary font-medium mb-2">
                Phone:
              </Text>
              <View className="flex-row items-center">
                <Text
                  className="text-base text-text-primary font-medium"
                  selectable={true}>
                  {phone}
                </Text>
                <TouchableOpacity
                  onPress={() => copyToClipboard(phone)}
                  className="ml-2"
                  accessibilityLabel="Copy phone number"
                  testID="copy-phone-btn">
                  <Copy size={20} color="#6B7280" />
                </TouchableOpacity>
              </View>
            </View>
          )}

          {/* Website Section */}
          {website && (
            <View className="mb-6">
              <Text className="text-sm leading-[20px] text-text-primary font-medium mb-2">
                Website:
              </Text>
              <View className="flex-row items-center">
                <Text
                  className="text-base text-text-primary font-medium"
                  selectable={true}>
                  {formatWebsiteDomain(website)}
                </Text>
                <TouchableOpacity
                  onPress={handleWebsitePress}
                  className="ml-2"
                  accessibilityLabel="Open website"
                  testID="open-website-btn"
                  // @ts-ignore - nativeID is supported but not in types
                  nativeID="open-website-btn">
                  <ExternalLink size={20} color="#6B7280" />
                </TouchableOpacity>
              </View>
            </View>
          )}
        </View>

        {/* Action Buttons */}
        <View className="px-6 pb-12 pt-6 space-y-4">
          {email && (
            <TouchableOpacity
              onPress={handleEmailPress}
              className="bg-white border border-gray-300 rounded-lg py-4 px-6 flex-row items-center justify-center"
              testID="email-us-btn"
              // @ts-ignore - nativeID is supported but not in types
              nativeID="email-us-btn">
              <Mail color="#6B7280" size={20} className="mr-2" />
              <Text className="text-text-primary font-medium text-base">
                Email Us
              </Text>
            </TouchableOpacity>
          )}
          {phone && (
            <TouchableOpacity
              onPress={handlePhonePress}
              className="bg-white border border-gray-300 rounded-lg py-4 px-6 flex-row items-center justify-center"
              testID="phone-btn"
              // @ts-ignore - nativeID is supported but not in types
              nativeID="phone-btn">
              <Phone color="#6B7280" size={20} className="mr-2" />
              <Text className="text-text-primary font-medium text-base">
                {phone}
              </Text>
            </TouchableOpacity>
          )}
        </View>
      </View>
    </View>
  );
};

export default ContactSupportScreen;
