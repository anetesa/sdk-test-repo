import * as yup from 'yup';
import creditcardutils from 'creditcardutils';

export const CARD_NUMBER_REQUIRED_MESSAGE = 'Card number is required';
export const CARD_NUMBER_INVALID_MESSAGE = 'Invalid card number.';
export const EXPIRATION_DATE_REQUIRED_MESSAGE = 'Expiration date is required';
export const EXPIRATION_DATE_INVALID_FORMAT_MESSAGE = 'Format is invalid';
export const EXPIRATION_DATE_EXPIRED_MESSAGE = 'Card is expired';

export const keyedTransactionSchema = yup.object({
  cardNumber: yup
    .string()
    .required(CARD_NUMBER_REQUIRED_MESSAGE)
    .test('is-valid-card', CARD_NUMBER_INVALID_MESSAGE, value =>
      creditcardutils.validateCardNumber(value),
    ),
  expDate: yup
    .string()
    .required(EXPIRATION_DATE_REQUIRED_MESSAGE)
    .test('is-valid-format', EXPIRATION_DATE_INVALID_FORMAT_MESSAGE, value => {
      if (!value) {
        return false;
      }

      // Check format MM/YY
      const formatRegex = /^(0[1-9]|1[0-2])\/([0-9]{2})$/;
      if (!formatRegex.test(value)) {
        return false;
      }

      return true;
    })
    .test('is-not-expired', EXPIRATION_DATE_EXPIRED_MESSAGE, value => {
      if (!value) {
        return false;
      }

      const formatRegex = /^(0[1-9]|1[0-2])\/([0-9]{2})$/;
      if (!formatRegex.test(value)) {
        return false;
      }

      const [monthStr, yearStr] = value.split('/');
      const month = parseInt(monthStr, 10);
      const year = parseInt(yearStr, 10);

      // Convert to full year (assuming 20xx for years 00-99)
      const fullYear = year < 50 ? 2000 + year : 1900 + year;

      const currentDate = new Date();
      const currentYear = currentDate.getFullYear();
      const currentMonth = currentDate.getMonth() + 1; // getMonth() returns 0-11

      // Check if year is in the past
      if (fullYear < currentYear) {
        return false;
      }

      // Check if year is current but month is in the past
      if (fullYear === currentYear && month < currentMonth) {
        return false;
      }

      return true;
    }),
  cvv: yup
    .string()
    .required('Security code is required')
    .test('is-valid-cvv', function (value) {
      if (!value) {
        return false;
      }

      // Get card number from the form context
      const cardNumber = this.parent.cardNumber;
      if (!cardNumber) {
        // If no card number, allow 3-4 digits as fallback
        const digitCount = value.replace(/\D/g, '').length;
        if (digitCount < 3 || digitCount > 4) {
          return this.createError({
            message: 'Security code must be 3-4 digits',
          });
        }
        return true;
      }

      // Detect card type using creditcardutils
      const digitsOnly = cardNumber.replace(/\s/g, '');
      const cardType = creditcardutils.parseCardType(digitsOnly);

      // Check if it's AMEX
      const isAmex = cardType === 'amex';

      // Validate CVV length based on card type
      const digitCount = value.replace(/\D/g, '').length;

      if (isAmex) {
        // AMEX cards require 4 digits
        if (digitCount !== 4) {
          return this.createError({
            message: 'American Express cards require 4-digit security code',
          });
        }
      } else {
        // Non-AMEX cards require 3 digits
        if (digitCount !== 3) {
          return this.createError({message: 'Security code must be 3 digits'});
        }
      }

      return true;
    }),
  zipCode: yup
    .string()
    .required('Zip code is required')
    .matches(
      /^\d{5}(?:-\d{4})?$/,
      'Zip Code should be in format 12345 or 12345-1234',
    ),
});
