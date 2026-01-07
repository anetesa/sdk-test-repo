import * as yup from 'yup';
import creditcardutils from 'creditcardutils';

export const CARD_NUMBER_REQUIRED_MESSAGE = 'Card number is required';
export const CARD_NUMBER_INVALID_MESSAGE = 'Invalid card number.';

export const cardNumberSchema = yup.object({
  cardNumber: yup
    .string()
    .required(CARD_NUMBER_REQUIRED_MESSAGE)
    .test('is-valid-card', CARD_NUMBER_INVALID_MESSAGE, value =>
      creditcardutils.validateCardNumber(value),
    ),
});
