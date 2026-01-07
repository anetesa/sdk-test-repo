import * as Sentry from '@sentry/react-native';
import {sentryConfig} from '@/utils/sentry';

// Helper to run beforeSend
const runBeforeSend = (event: Sentry.ErrorEvent) => {
  const beforeSend = sentryConfig.beforeSend as NonNullable<
    Sentry.ReactNativeOptions['beforeSend']
  >;
  return beforeSend(event) as Sentry.ErrorEvent;
};

describe('Sentry sanitize beforeSend', () => {
  it('redacts keys that contain sensitive substrings (e.g., expirationMonth)', () => {
    const event: Sentry.ErrorEvent = {
      event_id: '1',
      extra: {
        expirationMonth: 12,
        creditCardExpirationMonth: 12,
        securityCode: 999,
        accountNumber: '4111 1111 1111 1111',
        phoneNumber: '123-456-7890',
        lastName: 'Doe',
        billingAddress: {line1: '123 Main', city: 'NYC'},
        shippingAddress: {line1: '456 Side', city: 'LA'},
      },
    } as any;

    const sanitized = runBeforeSend(event);
    expect(sanitized.extra?.expirationMonth).toBe('[EXPIRATIONMONTH]');
    expect(sanitized.extra?.creditCardExpirationMonth).toBe(
      '[CREDITCARDEXPIRATIONMONTH]',
    );
    expect(sanitized.extra?.securityCode).toBe('[SECURITYCODE]');
    expect(sanitized.extra?.accountNumber).toBe('[ACCOUNTNUMBER]');
    expect(sanitized.extra?.phoneNumber).toBe('[PHONENUMBER]');
    expect(sanitized.extra?.lastName).toBe('[LASTNAME]');
    expect(sanitized.extra?.billingAddress).toBe('[BILLINGADDRESS]');
    expect(sanitized.extra?.shippingAddress).toBe('[SHIPPINGADDRESS]');
  });

  it('sanitizes strings for patterns (cards, emails, phone, amounts)', () => {
    const event: Sentry.ErrorEvent = {
      event_id: '2',
      message:
        'Card 4111 1111 1111 1111 declined for $22.10; email john@doe.com; phone 123-456-7890',
      extra: {
        note: 'Charge 4111-1111-1111-1111 failed. Contact john+test@site.io at 123-456-7890 for $10.00',
      },
    } as any;

    const sanitized = runBeforeSend(event);
    expect(sanitized.message).not.toMatch(
      /\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}/,
    );
    expect(sanitized.message).toMatch(/\[CARD\]/);
    expect(sanitized.message).toMatch(/\[EMAIL\]/);
    expect(sanitized.message).toMatch(/\[PHONE\]/);
    expect(sanitized.message).toMatch(/\[AMOUNT\]/);

    expect(sanitized.extra?.note).toMatch(/\[CARD\]/);
    expect(sanitized.extra?.note).toMatch(/\[EMAIL\]/);
    expect(sanitized.extra?.note).toMatch(/\[PHONE\]/);
    expect(sanitized.extra?.note).toMatch(/\[AMOUNT\]/);
  });

  it('recursively sanitizes nested extra objects and leaves non-sensitive keys intact', () => {
    const event: Sentry.ErrorEvent = {
      event_id: '3',
      extra: {
        level1: {
          userEmail: 'a@b.com',
          inner: {
            expirationYear: 2025,
            cardNumber: '4111111111111111',
            okField: 'hello',
          },
        },
      },
    } as any;

    const sanitized = runBeforeSend(event);
    expect(sanitized.extra?.level1).toBeDefined();
    expect(sanitized.extra?.level1.userEmail).toBe('[USEREMAIL]');
    expect(sanitized.extra?.level1.inner.expirationYear).toBe(
      '[EXPIRATIONYEAR]',
    );
    expect(sanitized.extra?.level1.inner.cardNumber).toBe('[CARDNUMBER]');
    expect(sanitized.extra?.level1.inner.okField).toBe('hello');
  });

  it('sanitizes exception values and breadcrumbs', () => {
    const event: Sentry.ErrorEvent = {
      event_id: '4',
      exception: {
        values: [
          {
            type: 'Error',
            value:
              'Payment failed for 4111 1111 1111 1111, email foo@bar.com, $30.00',
            stacktrace: {frames: []},
          },
        ],
      },
      breadcrumbs: [
        {
          category: 'request',
          message: 'Sent to 123-456-7890; cvv=123',
          data: {to: 'foo@bar.com', info: '4111-1111-1111-1111'},
        },
      ],
    } as any;

    const sanitized = runBeforeSend(event);
    expect(sanitized.exception?.values?.[0].value).toMatch(/\[CARD\]/);
    expect(sanitized.exception?.values?.[0].value).toMatch(/\[EMAIL\]/);
    expect(sanitized.exception?.values?.[0].value).toMatch(/\[AMOUNT\]/);

    const crumb = sanitized.breadcrumbs?.[0]!;
    expect(crumb.message).toMatch(/\[PHONE\]/);
    expect(crumb.message).toMatch(/CVV: \[CVV\]/);
    expect((crumb.data as any).to).toBe('[EMAIL]');
    expect((crumb.data as any).info).toMatch(/\[CARD\]/);
  });
});
