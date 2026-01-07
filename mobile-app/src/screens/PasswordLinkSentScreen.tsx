import React, {useState, useEffect, useCallback} from 'react';
import {
  View,
  Text,
  Linking,
  Alert,
  TouchableOpacity,
  ActionSheetIOS,
  ActivityIndicator,
  Platform,
} from 'react-native';
import {useNavigation} from '@react-navigation/native';
import {SafeAreaView} from 'react-native-safe-area-context';
import EmailSentIcon from '../../assets/email-sent.svg';
import {EMAIL_APPS} from '../constants/emailApps';
import {ROUTES} from '@/constants/routes';
import {logger} from '@/utils/logger';

type EmailApp = {
  name: string;
  scheme: string;
};

const PasswordLinkSentScreen = () => {
  const navigation = useNavigation<any>();
  const [isLoading, setIsLoading] = useState(false);
  const [availableApps, setAvailableApps] = useState<EmailApp[]>([]);
  const [appsLoading, setAppsLoading] = useState(true);

  // Detect which email apps are installed on mount
  useEffect(() => {
    const detectEmailApps = async () => {
      const installed = [];
      for (const app of EMAIL_APPS) {
        try {
          const canOpen = await Linking.canOpenURL(app.scheme);
          if (canOpen) {
            installed.push(app);
          }
        } catch (error) {
          // Continue to next app if this one fails
          logger.error(error, 'Error detecting email app');
          continue;
        }
      }
      setAvailableApps(installed);
      setAppsLoading(false);
    };

    detectEmailApps();
  }, []);

  const openEmailApp = useCallback(async () => {
    setIsLoading(true);

    try {
      if (Platform.OS === 'ios' && availableApps.length > 1) {
        // Show ActionSheet with available apps on iOS
        const appNames = [...availableApps.map(app => app.name), 'Cancel'];
        const cancelButtonIndex = appNames.length - 1;

        ActionSheetIOS.showActionSheetWithOptions(
          {
            title: 'Choose email app',
            options: appNames,
            cancelButtonIndex,
          },
          async buttonIndex => {
            setIsLoading(false);
            if (buttonIndex !== cancelButtonIndex) {
              const selectedApp = availableApps[buttonIndex];
              try {
                await Linking.openURL(selectedApp.scheme);
              } catch (error) {
                // Fallback to mailto if specific app fails
                logger.error(error, 'Error opening specific email app');
                await Linking.openURL('mailto:');
              }
            }
          },
        );
      } else if (availableApps.length === 1) {
        // Only one app available, open it directly
        await Linking.openURL(availableApps[0].scheme);
        setIsLoading(false);
      } else {
        // No specific apps detected, use system default
        const mailtoURL = 'mailto:';
        const canOpen = await Linking.canOpenURL(mailtoURL);

        if (canOpen) {
          await Linking.openURL(mailtoURL);
        } else {
          Alert.alert(
            'No Email App',
            'No email app is available on this device. Please check your email manually.',
          );
        }
        setIsLoading(false);
      }
    } catch (error) {
      setIsLoading(false);
      logger.error(error, 'Error opening email app');
      Alert.alert('Error', 'Failed to open email app');
    }
  }, [availableApps]);

  const goBackToLogin = () => {
    navigation.navigate(ROUTES.LOGIN);
  };

  return (
    <SafeAreaView className="flex-1 bg-white justify-between ">
      <View className="flex-1 justify-center items-center bg-white px-6">
        <EmailSentIcon width={100} height={100} />

        <View className="mt-6 items-center">
          <Text className="text-2xl font-medium text-text-primary leading-[28px] mb-3">
            Password link sent
          </Text>
          <Text className="text-center text-text-secondary mb-8 text-[18px] leading-[28px] font-normal">
            Please check your inbox and follow{'\n'}the instructions in the
            email.
          </Text>
        </View>
      </View>
      <View className="absolute bottom-0 w-full px-6 pb-12 pt-6 bg-[#fafafa]">
        <TouchableOpacity
          className="w-full bg-white border border-elevation-08  rounded-lg mb-3 h-[56px] justify-center items-center"
          onPress={openEmailApp}
          disabled={appsLoading || isLoading}>
          {appsLoading ? (
            <ActivityIndicator size="small" color="#000" />
          ) : (
            <Text className="text-center text-text-primary font-medium text-base">
              {'Open Email App'}
            </Text>
          )}
        </TouchableOpacity>

        <TouchableOpacity
          className="w-full bg-white border border-elevation-08 rounded-lg h-[56px] justify-center items-center"
          onPress={goBackToLogin}>
          <Text className="text-center text-text-primary font-medium text-base">
            Back to Login
          </Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
};

export default PasswordLinkSentScreen;
