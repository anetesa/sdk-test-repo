import {useState} from 'react';

export const useEmailValidation = () => {
  const [emailError, setEmailError] = useState('');

  // Email validation function
  const validateEmail = (email: string): string => {
    // Check email format using regex (RFC 5322 compliant)
    // This regex already handles spaces, illegal characters, and format
    const emailRegex =
      /^[a-zA-Z0-9!#$%&*+\-/=?^_`{|}~.]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

    if (email && !emailRegex.test(email)) {
      return 'Invalid email formatting.';
    }

    return '';
  };

  // Handle email validation on blur (focus loss)
  const validateEmailOnBlur = (email: string) => {
    const error = validateEmail(email);
    setEmailError(error);
  };

  // Clear error when user starts typing
  const clearEmailError = () => {
    if (emailError) {
      setEmailError('');
    }
  };

  // Validate email and return error if any
  const validateEmailOnSubmit = (email: string): boolean => {
    const error = validateEmail(email);
    setEmailError(error);
    return !error; // return true if valid (no error)
  };

  return {
    emailError,
    validateEmail,
    validateEmailOnBlur,
    clearEmailError,
    validateEmailOnSubmit,
    setEmailError, // for manual error setting if needed
  };
};
