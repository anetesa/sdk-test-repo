import React, {useRef, useEffect} from 'react';
import {
  View,
  TextInput,
  Text,
  AppState,
  Platform,
  Keyboard,
  TouchableWithoutFeedback,
} from 'react-native';
import Clipboard from '@react-native-clipboard/clipboard';
import {UI_ERROR_MESSAGES} from '@/constants/messages';
import {logger} from '@/utils/logger';

const CodeInput = ({
  code,
  setCode,
  invalidCode,
}: {
  code: string[];
  setCode: (code: string[]) => void;
  invalidCode: boolean;
}) => {
  const inputRefs = useRef<TextInput[] | null>([]);

  const isEmpty = () => code.every(c => !c);

  // Ref to avoid applying the same clipboard code multiple times
  const lastClipboardCode = useRef<string | null>(null);

  const tryPasteClipboard = async () => {
    try {
      const text = await Clipboard.getString();
      if (/^\d{6}$/.test(text.trim()) && text !== lastClipboardCode.current) {
        lastClipboardCode.current = text.trim();

        // Autopaste only if user hasn't typed anything yet
        if (isEmpty()) {
          const digits = text.trim().split('');
          setCode(digits);
          // Always close keyboard since autofill always gives 6 digits
          Keyboard.dismiss();
        }
      }
    } catch (e) {
      logger.error(e, 'Error in CodeInput');
    }
  };

  // Initial check and when the app returns to foreground
  useEffect(() => {
    tryPasteClipboard();

    const sub = AppState.addEventListener('change', state => {
      if (state === 'active') {
        tryPasteClipboard();
      }
    });

    return () => {
      sub.remove();
    };
    // intentionally omit dependency to avoid loop; function is stable enough
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const handleCodeChange = (text: string, index: number) => {
    if (text.length > 1 && /^\d{6}$/.test(text)) {
      // iOS/Android autofill devolvió código completo
      const digits = text.slice(0, 6).split('');
      setCode(digits);
      // Always close keyboard since autofill always gives 6 digits
      Keyboard.dismiss();
      return;
    }

    const newCode = [...code];
    newCode[index] = text;
    setCode(newCode);

    // check if the code will be complete after the change
    const willBeComplete = newCode.every(c => c !== '');

    if (text && index < 5 && !willBeComplete) {
      inputRefs.current?.[index + 1]?.focus();
    } else if (willBeComplete) {
      // if the code is complete, close the keyboard
      Keyboard.dismiss();
    }
  };

  const handleKeyPress = (e: any, index: number) => {
    if (e.nativeEvent.key === 'Backspace') {
      if (!code[index] && index > 0) {
        // delete the previous field and focus it
        const newCode = [...code];
        newCode[index - 1] = '';
        setCode(newCode);
        inputRefs.current?.[index - 1]?.focus();
      }
    }
  };

  return (
    <TouchableWithoutFeedback onPress={Keyboard.dismiss}>
      <>
        <View className="flex-row justify-between">
          {code.map((digit, index) => (
            <TextInput
              key={index}
              ref={(ref: TextInput | null) => {
                if (inputRefs.current && ref) {
                  inputRefs.current[index] = ref;
                }
              }}
              className="box-border overflow-hidden box-border rounded-xl bg-elevation-0 px-5 py-4 border border-elevation-08 focus:border-brand-main focus:border-2 text-text-primary"
              maxLength={index === 0 ? 6 : 1}
              keyboardType="number-pad"
              textContentType="oneTimeCode"
              autoComplete={
                Platform.OS === 'android' ? 'sms-otp' : 'one-time-code'
              }
              value={digit}
              onChangeText={text => handleCodeChange(text, index)}
              onKeyPress={e => handleKeyPress(e, index)}
            />
          ))}
        </View>

        {invalidCode && (
          <Text className="text-error-text text-center mt-3 leading-[24px]">
            {UI_ERROR_MESSAGES.INVALID_CODE}
          </Text>
        )}
      </>
    </TouchableWithoutFeedback>
  );
};

export default CodeInput;
