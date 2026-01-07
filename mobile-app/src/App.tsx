import HomeScreen from '@/screens/HomeScreen';
import LoginScreen from '@/screens/LoginScreen';
import MFAScreen from '@/screens/MFAScreen';
import LegalInformationScreen from '@/screens/LegalInformationScreen';
import PrivacyPolicyScreen from '@/screens/PrivacyPolicyScreen';
import TermsAndConditionsScreen from '@/screens/TermsAndConditionsScreen';
import {createNativeStackNavigator} from '@react-navigation/native-stack';
import {NavigationContainer} from '@react-navigation/native';
import React, {useEffect} from 'react';
import {GestureHandlerRootView} from 'react-native-gesture-handler';
import NewTransactionScreen from '@/screens/NewTransaction/NewTransactionScreen';
import {EventProvider} from 'react-native-outside-press';
//import {TransactionTestScreen} from '@/screens/TransactionTestScreen';
import {TransactionListScreen} from '@/screens/TransactionListScreen'; // use TransactionTestScreen if you want to test the transaction list screen
import {useInactivityTimer} from '@/hooks/useInactivityTimer';
import {useUserStore} from '@/stores/userStore';
import {usePendoSessionManagement} from '@/hooks/usePendoSessionManagement';
import TestMasterCartTapToPayScreen from '@/screens/TestMasterCartTapToPayScreen'; // Import the new screen

import {WithPendoReactNavigation} from 'rn-pendo-sdk';
import {clearSession} from '@/utils/clearSession';
import ResetPasswordScreen from '@/screens/ResetPasswordScreen';
import PasswordLinkSentScreen from '@/screens/PasswordLinkSentScreen';
import ContactSupportScreen from '@/screens/ContactSupportScreen';
import ChangePasswordScreen from '@/screens/ChangePasswordScreen';
import ChangePasswordFormScreen from '@/screens/ChangePasswordFormScreen';
import SettingsScreen from '@/screens/SettingsScreen/SettingsScreen';
import UnauthenticatedContactSupportScreen from './screens/UnauthenticatedContactSupportScreen';
import MerchantSelectionScreen from '@/screens/MerchantSelectionScreen';
import TapToPaySplashScreen from '@/screens/TapToPaySplashScreen';
import * as Sentry from '@sentry/react-native';
import {initPendo} from '@/utils/pendo';
import {ROUTES} from './constants/routes';
import type {RootStackParamList} from '@/types/navigation';
import {navigationRef} from '@/utils/navigationRef';
import TransactionDetail from '@/screens/TransactionDetail';
import ReceiptScreen from '@/screens/NewTransaction/ReceiptScreen';
import {nativeIDs} from '@/utils/nativeIDs';

import {sentryConfig} from '@/utils/sentry';
import {Atlantis} from '@/utils/atlantis';

Sentry.init(sentryConfig);
initPendo();

// Initialize Atlantis network debugging (only active in development)
if (__DEV__) {
  Atlantis.start();
}

// Create the Pendo-wrapped NavigationContainer at module level
const PendoNavigationContainer = WithPendoReactNavigation(NavigationContainer, {
  nativeIDs: nativeIDs
    .split(',')
    .map(id => id.trim())
    .filter(id => id.length > 0),
});
const Stack = createNativeStackNavigator<RootStackParamList>();

function App(): React.JSX.Element {
  useEffect(() => {
    const resetApp = async () => {
      await clearSession();
    };
    resetApp();
  }, []);

  // Determine if the user is logged in by checking for an id in zustand store
  const isLoggedIn = Boolean(useUserStore(state => state.id));

  // Initialize Pendo when user is logged in
  usePendoSessionManagement();

  // Activate inactivity timer only when the user is authenticated
  const panHandlers = useInactivityTimer(isLoggedIn);

  return (
    <GestureHandlerRootView style={{flex: 1}} {...(panHandlers || {})}>
      <EventProvider>
        <PendoNavigationContainer ref={navigationRef}>
          <Stack.Navigator
            initialRouteName={ROUTES.LOGIN}
            screenOptions={{
              headerShown: false,
            }}>
            <Stack.Screen
              name={ROUTES.LOGIN}
              component={LoginScreen}
              options={{
                presentation: 'card',
                animation: 'flip',
              }}
            />
            <Stack.Screen
              name={ROUTES.HOME}
              component={HomeScreen}
              options={{
                presentation: 'card',
                animation: 'fade_from_bottom',
                gestureEnabled: false,
              }}
            />

            <Stack.Screen
              name={ROUTES.MFA}
              component={MFAScreen}
              options={{
                presentation: 'card',
                animation: 'slide_from_bottom',
              }}
            />
            <Stack.Screen
              name={ROUTES.NEW_TRANSACTION}
              component={NewTransactionScreen}
              options={{
                presentation: 'card',
              }}
            />
            <Stack.Screen
              name={ROUTES.TRANSACTION_LIST}
              component={TransactionListScreen}
            />
            <Stack.Screen
              name={ROUTES.TRANSACTION_DETAIL}
              component={TransactionDetail}
              options={{
                presentation: 'card',
              }}
            />
            <Stack.Screen
              name={ROUTES.PAYMENT_RECEIPT}
              component={ReceiptScreen}
              options={{
                presentation: 'modal',
                animation: 'slide_from_bottom',
                gestureEnabled: true,
              }}
            />

            <Stack.Screen
              name={ROUTES.LEGAL_INFORMATION}
              component={LegalInformationScreen}
              options={{
                presentation: 'card',
              }}
            />
            <Stack.Screen
              name={ROUTES.TEST_MASTER_CART_TAP_TO_PAY}
              component={TestMasterCartTapToPayScreen}
            />
            <Stack.Screen
              name={ROUTES.PRIVACY_POLICY}
              component={PrivacyPolicyScreen}
              options={{
                presentation: 'card',
              }}
            />
            <Stack.Screen
              name={ROUTES.TERMS_AND_CONDITIONS}
              component={TermsAndConditionsScreen}
              options={{
                presentation: 'card',
              }}
            />
            <Stack.Screen
              name={ROUTES.SETTINGS}
              component={SettingsScreen}
              options={{
                presentation: 'card',
                animation: 'slide_from_right',
              }}
            />
            <Stack.Screen
              name={ROUTES.RESET_PASSWORD}
              component={ResetPasswordScreen}
              options={{
                presentation: 'card',
                animation: 'fade_from_bottom',
              }}
            />
            <Stack.Screen
              name={ROUTES.PASSWORD_LINK_SENT}
              component={PasswordLinkSentScreen}
              options={{
                presentation: 'card',
                animation: 'fade_from_bottom',
              }}
            />
            <Stack.Screen
              name={ROUTES.CONTACT_SUPPORT}
              component={ContactSupportScreen}
              options={{
                presentation: 'card',
              }}
            />
            <Stack.Screen
              name={ROUTES.UNAUTHENTICATED_CONTACT_SUPPORT}
              component={UnauthenticatedContactSupportScreen}
              options={{
                presentation: 'card',
              }}
            />
            <Stack.Screen
              name={ROUTES.CHANGE_PASSWORD}
              component={ChangePasswordScreen}
              options={{
                presentation: 'card',
                animation: 'fade_from_bottom',
              }}
            />
            <Stack.Screen
              name={ROUTES.CHANGE_PASSWORD_FORM}
              component={ChangePasswordFormScreen}
              options={{
                presentation: 'card',
                animation: 'slide_from_right',
              }}
            />
            <Stack.Screen
              name={ROUTES.MERCHANT_SELECTION}
              component={MerchantSelectionScreen}
              options={{
                presentation: 'card',
                gestureEnabled: true,
                animation: 'slide_from_right',
              }}
            />
            <Stack.Screen
              name={ROUTES.TAP_TO_PAY_SPLASH}
              component={TapToPaySplashScreen}
              options={{
                gestureEnabled: true,
              }}
            />
          </Stack.Navigator>
        </PendoNavigationContainer>
      </EventProvider>
    </GestureHandlerRootView>
  );
}

export default Sentry.wrap(App);
