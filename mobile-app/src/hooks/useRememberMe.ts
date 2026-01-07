import {useState, useEffect} from 'react';
import {
  getRememberMeEmail,
  removeRememberMeEmail,
  setRememberMeEmail,
} from '@/utils/asyncStorage';
import {logger} from '@/utils/logger';

export const useRememberMe = () => {
  const [email, setEmail] = useState('');
  const [rememberMeCheckBox, setRememberMeCheckBox] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const loadRememberedEmail = async () => {
      try {
        const rememberedEmail = await getRememberMeEmail();
        if (rememberedEmail) {
          setEmail(rememberedEmail);
          setRememberMeCheckBox(true);
        }
      } catch (error) {
        logger.error(error, 'Error loading remembered email');
      } finally {
        setIsLoading(false);
      }
    };

    loadRememberedEmail();
  }, []);

  const handleRememberMeToggle = () => {
    const newValue = !rememberMeCheckBox;
    setRememberMeCheckBox(newValue);

    if (!newValue) {
      removeRememberMeEmail();
      setEmail('');
    } else if (email) {
      setEmail(email);
      setRememberMeEmail(email);
    }
  };

  const saveEmailOnLogin = (text: string) => {
    if (rememberMeCheckBox && text) {
      setEmail(text);
      setRememberMeEmail(text);
    } else if (!rememberMeCheckBox) {
      setEmail('');
      removeRememberMeEmail();
    }
  };

  return {
    email,
    rememberMeCheckBox,
    isLoading,
    handleRememberMeToggle,
    saveEmailOnLogin,
  };
};
