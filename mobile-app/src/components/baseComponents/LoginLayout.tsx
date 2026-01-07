import React, {useEffect, useState, useRef, useCallback} from 'react';
import {
  KeyboardAvoidingView,
  Platform,
  View,
  SafeAreaView,
  TouchableOpacity,
  Keyboard,
  Animated,
  Text,
  Pressable,
} from 'react-native';
import LinearGradient from 'react-native-linear-gradient';
import {useNavigation} from '@react-navigation/native';
import Logo from '../../../assets/arise-logo.svg';
import AlertInfo from '../../../assets/alert-info.svg';
import ContactSupport from '../../../assets/contact-support.svg';
import BottomSheet from '@/components/baseComponents/BottomSheet';
import AriseGradient from '@/components/baseComponents/AriseGradient';
import RNTestFlight from 'react-native-test-flight';
import {useRuntimeConfig} from '@/hooks/useRuntimeConfig';
import MessageCircleQuestionMark from '../../../assets/feedback.svg';
import {useFeatureIsOn} from '@growthbook/growthbook-react';
import {NAVIGATION_TITLES} from '@/constants/messages';
import {logger} from '@/utils/logger';

const TIMEOUT = 5000;

const LoginLayout = ({
  children,
  keyValue = 'default',
}: {
  children: React.ReactNode;
  keyValue?: string;
}): React.JSX.Element => {
  const navigation = useNavigation();
  const [isKeyboardVisible, setKeyboardVisible] = useState(false);
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const {toggleProduction} = useRuntimeConfig();

  const pressTimeoutRef = useRef<NodeJS.Timeout | null>(null);
  const isPendoFeedbackOn = useFeatureIsOn('OS2-8082-pendo-feedback');

  const handleInfoPress = () => {
    navigation.navigate('LegalInformation' as never);
  };

  const handlePressIn = useCallback(() => {
    pressTimeoutRef.current = setTimeout(() => {
      try {
        if (RNTestFlight?.isTestFlight) {
          toggleProduction();
        }
      } catch (error) {
        logger.error(error, 'Error changing environment');
      }
    }, TIMEOUT);
  }, [toggleProduction]);

  const handlePressOut = () => {
    if (pressTimeoutRef.current) {
      clearTimeout(pressTimeoutRef.current);
    }
  };

  useEffect(() => {
    return () => {
      if (pressTimeoutRef.current) {
        clearTimeout(pressTimeoutRef.current);
      }
    };
  }, []);

  const handleContactSupportPress = () => {
    navigation.navigate('UnauthenticatedContactSupport' as never);
  };

  useEffect(() => {
    const showListener =
      Platform.OS === 'ios'
        ? Keyboard.addListener('keyboardWillShow', () => {
            setKeyboardVisible(true);
            Animated.timing(fadeAnim, {
              toValue: 1,
              duration: 1,
              useNativeDriver: true,
            }).start();
          })
        : Keyboard.addListener('keyboardDidShow', () => {
            setKeyboardVisible(true);
            Animated.timing(fadeAnim, {
              toValue: 1,
              duration: 1,
              useNativeDriver: true,
            }).start();
          });

    const hideListener =
      Platform.OS === 'ios'
        ? Keyboard.addListener('keyboardWillHide', () => {
            setKeyboardVisible(false);
            Animated.timing(fadeAnim, {
              toValue: 0,
              duration: 200,
              useNativeDriver: true,
            }).start();
          })
        : Keyboard.addListener('keyboardDidHide', () => {
            setKeyboardVisible(false);
            Animated.timing(fadeAnim, {
              toValue: 0,
              duration: 200,
              useNativeDriver: true,
            }).start();
          });

    return () => {
      showListener.remove();
      hideListener.remove();
    };
  }, [fadeAnim]);

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      className="flex-1 h-full bg-white">
      {/* Header flotante animado cuando el teclado está visible */}
      <Animated.View
        style={{
          opacity: fadeAnim,
          transform: [
            {
              translateY: fadeAnim.interpolate({
                inputRange: [0, 1],
                outputRange: [-50, 0],
              }),
            },
          ],
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          zIndex: 10,
        }}>
        <SafeAreaView className="bg-[#122C46]">
          <AriseGradient>
            <View className="flex-row items-center justify-between px-4 pt-4">
              {isPendoFeedbackOn ? (
                <TouchableOpacity
                  onPress={() => {}}
                  accessibilityLabel="Pendo Feedback Button"
                  className="p-2 mr-4">
                  <MessageCircleQuestionMark width={20} height={20} />
                </TouchableOpacity>
              ) : (
                <TouchableOpacity
                  onPress={handleContactSupportPress}
                  className="p-2">
                  <ContactSupport width={20} height={20} />
                </TouchableOpacity>
              )}

              <Text className="text-xl font-medium text-white">
                {NAVIGATION_TITLES.LOGIN}
              </Text>

              <TouchableOpacity
                accessibilityLabel="InfoButton"
                onPress={handleInfoPress}
                className="p-2">
                <AlertInfo width={20} height={20} opacity={0.5} />
              </TouchableOpacity>
            </View>
          </AriseGradient>
        </SafeAreaView>
      </Animated.View>

      {/* Header con logo (oculto al abrir teclado) */}
      {!isKeyboardVisible && (
        <LinearGradient
          colors={['#122C46', '#091E34']}
          start={{x: 0, y: 0}}
          end={{x: 0, y: 1}}
          className="flex w-full flex-1">
          <SafeAreaView>
            <View className="flex-row justify-between pr-4 pl-4 pt-2 gap-2">
              {isPendoFeedbackOn ? (
                <TouchableOpacity
                  onPress={() => {}}
                  accessibilityLabel="Pendo Feedback Button"
                  className="p-2 mr-4">
                  <MessageCircleQuestionMark width={20} height={20} />
                </TouchableOpacity>
              ) : (
                <TouchableOpacity
                  onPress={handleContactSupportPress}
                  className="p-2 mr-4">
                  <ContactSupport width={20} height={20} />
                </TouchableOpacity>
              )}

              <TouchableOpacity
                accessibilityLabel="InfoButton"
                onPress={handleInfoPress}
                className="p-2 rounded-full">
                <AlertInfo width={20} height={20} opacity={0.5} />
              </TouchableOpacity>
            </View>
          </SafeAreaView>

          <View className="flex-1 justify-center items-center">
            <Pressable
              onPressIn={handlePressIn}
              onPressOut={handlePressOut}
              className="w-[70%]"
              testID="logo-pressable">
              <Logo width="100%" height="100%" style={{marginTop: '-10%'}} />
            </Pressable>
          </View>
        </LinearGradient>
      )}

      {/* Formulario */}
      <BottomSheet
        key={keyValue || ''}
        isVisible={true}
        isOverlay={false}
        height={isKeyboardVisible ? 'h-full' : 'h-min'}>
        <SafeAreaView>{children}</SafeAreaView>
      </BottomSheet>
    </KeyboardAvoidingView>
  );
};

export default LoginLayout;
