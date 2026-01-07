import React from 'react';
import {View} from 'react-native';
import {createNativeStackNavigator} from '@react-navigation/native-stack';
import EnterAmountScreen from './EnterAmountScreen';
import {ChooseMethod} from './ChooseMethod';
import KeyedTransaction from './KeyedTransaction';
import {PaymentOverviewScreen} from './PaymentOverviewScreen';
import {SCREEN_NAMES, ROUTES} from '@/constants/routes';
import PaymentFailedScreen from './PaymentFailedScreen';
import PaymentSuccessScreen from './PaymentSuccessScreen';
import type {NewTransactionStackParamList} from '@/types/navigation';
import PaymentDeclinedScreen from './PaymentDeclinedScreen';
import ValidationErrorScreen from './ValidationErrorScreen';
import LoadingTapToPayScreen from './LoadingTapToPayScreen';
import ZCPTipsAnalysisScreen from './ZCPTipsAnalysisScreen';
import TapToPaySplashScreen from '@/screens/TapToPaySplashScreen';

const NestedStack = createNativeStackNavigator<NewTransactionStackParamList>();

const NewTransactionScreen: React.FC = () => {
  return (
    <View className="flex h-full bg-dark-page-bg w-full">
      <NestedStack.Navigator
        screenOptions={{
          headerShown: false, // Hides the header for all screens
        }}>
        <NestedStack.Screen
          name={SCREEN_NAMES.ENTER_AMOUNT}
          component={EnterAmountScreen}
        />
        <NestedStack.Screen
          name={SCREEN_NAMES.CHOOSE_METHOD}
          component={ChooseMethod}
        />
        <NestedStack.Screen
          name={SCREEN_NAMES.KEYED_TRANSACTION}
          component={KeyedTransaction}
        />
        <NestedStack.Screen
          name={SCREEN_NAMES.PAYMENT_OVERVIEW}
          component={PaymentOverviewScreen}
        />
        <NestedStack.Screen
          name={SCREEN_NAMES.PAYMENT_SUCCESS}
          component={PaymentSuccessScreen}
          options={{
            gestureEnabled: false,
          }}
        />
        <NestedStack.Screen
          name={SCREEN_NAMES.PAYMENT_FAILED}
          component={PaymentFailedScreen}
          options={{
            gestureEnabled: false,
          }}
        />
        <NestedStack.Screen
          name={SCREEN_NAMES.PAYMENT_DECLINED}
          component={PaymentDeclinedScreen}
          options={{
            gestureEnabled: false,
          }}
        />

        <NestedStack.Screen
          name={SCREEN_NAMES.VALIDATION_ERROR}
          component={ValidationErrorScreen}
          options={{
            gestureEnabled: false,
          }}
        />

        <NestedStack.Screen
          name={SCREEN_NAMES.LOADING_TAP_TO_PAY}
          component={LoadingTapToPayScreen}
          options={{
            presentation: 'card',
            animation: 'slide_from_right',
          }}
        />

        <NestedStack.Screen
          name={SCREEN_NAMES.ZCP_TIPS_ANALYSIS}
          component={ZCPTipsAnalysisScreen}
          options={{
            presentation: 'card',
            animation: 'slide_from_right',
          }}
        />
        <NestedStack.Screen
          name={ROUTES.TAP_TO_PAY_SPLASH}
          component={TapToPaySplashScreen}
          options={{
            gestureEnabled: true,
          }}
        />
      </NestedStack.Navigator>
    </View>
  );
};

export default NewTransactionScreen;
