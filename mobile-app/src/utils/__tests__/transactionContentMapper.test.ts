import {
  getTransactionContent,
  isPending,
  isDeclined,
  isFailed,
  isAuthorized,
  isVoided,
  isSale,
  isRefunded,
  isAchSale,
  isAchVoid,
  isAchRefundStatus,
  isAchCreditStatus,
  createDeclinedContent,
  createFailedContent,
  createAuthorizationContent,
  createVoidContent,
  createSaleContent,
  createRefundContent,
  createAchSaleContent,
  createAchVoidContent,
  createAchRefundContent,
  createAchCreditContent,
  createPendingContent,
} from '../transactionContentMapper';
import {
  CardTransactionStatus,
  AchTransactionStatus,
  CommonTransactionStatus,
} from '@/dictionaries/TransactionStatuses';
import {TransactionType} from '@/dictionaries/TransactionTypes';

describe('Transaction Content Mapper', () => {
  describe('Pure Functions - Transaction Type Checks', () => {
    test('should correctly identify declined transactions', () => {
      expect(isDeclined(CommonTransactionStatus.Declined)).toBe(true);
      expect(isDeclined(CommonTransactionStatus.Failed)).toBe(false);
      expect(isDeclined(CardTransactionStatus.Authorized)).toBe(false);
    });

    test('should correctly identify failed transactions', () => {
      expect(
        isFailed(CommonTransactionStatus.Failed, TransactionType.Sale),
      ).toBe(true);
      expect(
        isFailed(
          CardTransactionStatus.Informational,
          TransactionType.Authorization,
        ),
      ).toBe(true);
      expect(
        isFailed(CardTransactionStatus.Informational, TransactionType.Sale),
      ).toBe(true);
    });

    test('should correctly identify authorized transactions', () => {
      expect(
        isAuthorized(
          CardTransactionStatus.Authorized,
          TransactionType.Authorization,
        ),
      ).toBe(true);
      expect(
        isAuthorized(
          CardTransactionStatus.PartiallyAuthorized,
          TransactionType.Authorization,
        ),
      ).toBe(true);
      expect(
        isAuthorized(CardTransactionStatus.Authorized, TransactionType.Sale),
      ).toBe(false);
    });

    test('should correctly identify voided transactions', () => {
      expect(isVoided(CardTransactionStatus.Voided)).toBe(true);
      expect(isVoided(CardTransactionStatus.Authorized)).toBe(false);
    });

    test('should correctly identify sale transactions', () => {
      expect(isSale(CardTransactionStatus.Captured)).toBe(true);
      expect(isSale(CardTransactionStatus.Settled)).toBe(true);
      expect(isSale(CardTransactionStatus.Authorized)).toBe(false);
    });

    test('should correctly identify refunded transactions', () => {
      expect(isRefunded(CardTransactionStatus.Refunded)).toBe(true);
      expect(isRefunded(CardTransactionStatus.Captured)).toBe(false);
    });

    test('should correctly identify ACH sale transactions', () => {
      expect(
        isAchSale(AchTransactionStatus.Scheduled, TransactionType.AchDebit),
      ).toBe(true);
      expect(
        isAchSale(AchTransactionStatus.InProgress, TransactionType.AchDebit),
      ).toBe(true);
      expect(
        isAchSale(AchTransactionStatus.Cleared, TransactionType.AchDebit),
      ).toBe(true);
      expect(
        isAchSale(AchTransactionStatus.Scheduled, TransactionType.AchCredit),
      ).toBe(false);
      expect(
        isAchSale(CardTransactionStatus.Authorized, TransactionType.AchDebit),
      ).toBe(false);
    });

    test('should correctly identify ACH void transactions', () => {
      expect(isAchVoid(AchTransactionStatus.Cancelled)).toBe(true);
      expect(isAchVoid(AchTransactionStatus.Scheduled)).toBe(false);
    });

    test('should correctly identify ACH refund transactions', () => {
      expect(
        isAchRefundStatus(
          AchTransactionStatus.ChargedBack,
          TransactionType.AchCredit,
        ),
      ).toBe(true);
      expect(
        isAchRefundStatus(
          AchTransactionStatus.Scheduled,
          TransactionType.AchRefund,
        ),
      ).toBe(true);
      expect(
        isAchRefundStatus(
          AchTransactionStatus.Scheduled,
          TransactionType.AchDebit,
        ),
      ).toBe(false);
    });

    test('should correctly identify ACH credit transactions', () => {
      expect(
        isAchCreditStatus(
          AchTransactionStatus.Scheduled,
          TransactionType.AchCredit,
        ),
      ).toBe(true);
      expect(
        isAchCreditStatus(
          AchTransactionStatus.InProgress,
          TransactionType.AchCredit,
        ),
      ).toBe(true);
      expect(
        isAchCreditStatus(
          AchTransactionStatus.Scheduled,
          TransactionType.AchDebit,
        ),
      ).toBe(false);
    });

    test('should correctly identify pending transactions', () => {
      expect(isPending(CommonTransactionStatus.Pending)).toBe(true);
      expect(isPending(CommonTransactionStatus.Declined)).toBe(false);
      expect(isPending(CardTransactionStatus.Authorized)).toBe(false);
      expect(isPending(AchTransactionStatus.Scheduled)).toBe(false);
    });
  });

  describe('Content Creation Functions', () => {
    test('should create declined content correctly', () => {
      const content = createDeclinedContent();
      expect(content.title).toBe('Decline');
      expect(content.iconBgColor).toBe('bg-surface-red');
      expect(content.icon).toBeDefined();
    });

    test('should create failed content correctly', () => {
      const content = createFailedContent();
      expect(content.title).toBe('Failed');
      expect(content.iconBgColor).toBe('bg-surface-red');
      expect(content.icon).toBeDefined();
    });

    test('should create authorization content correctly', () => {
      const content = createAuthorizationContent();
      expect(content.title).toBe('Authorization');
      expect(content.iconBgColor).toBe('bg-brand-main-05');
      expect(content.icon).toBeDefined();
    });

    test('should create void content correctly', () => {
      const content = createVoidContent();
      expect(content.title).toBe('Void');
      expect(content.iconBgColor).toBe('bg-elevation-04');
      expect(content.icon).toBeDefined();
    });

    test('should create sale content correctly', () => {
      const content = createSaleContent();
      expect(content.title).toBe('Sale');
      expect(content.iconBgColor).toBe('bg-surface-green');
      expect(content.icon).toBeDefined();
    });

    test('should create refund content correctly', () => {
      const content = createRefundContent();
      expect(content.title).toBe('Refund');
      expect(content.iconBgColor).toBe('bg-warning-05');
      expect(content.icon).toBeDefined();
    });

    test('should create ACH sale content correctly', () => {
      const content = createAchSaleContent();
      expect(content.title).toBe('ACH Sale');
      expect(content.iconBgColor).toBe('bg-surface-green');
      expect(content.icon).toBeDefined();
    });

    test('should create ACH void content correctly', () => {
      const content = createAchVoidContent();
      expect(content.title).toBe('ACH Void');
      expect(content.iconBgColor).toBe('bg-elevation-04');
      expect(content.icon).toBeDefined();
    });

    test('should create ACH refund content correctly', () => {
      const content = createAchRefundContent();
      expect(content.title).toBe('ACH Refund');
      expect(content.iconBgColor).toBe('bg-warning-05');
      expect(content.icon).toBeDefined();
    });

    test('should create ACH credit content correctly', () => {
      const content = createAchCreditContent();
      expect(content.title).toBe('ACH Credit');
      expect(content.iconBgColor).toBe('bg-warning-05');
      expect(content.icon).toBeDefined();
    });

    test('should create pending content correctly', () => {
      const content = createPendingContent('Test Pending');
      expect(content.title).toBe('Test Pending');
      expect(content.iconBgColor).toBe('bg-warning-05');
      expect(content.icon).toBeDefined();
    });
  });

  describe('Main getTransactionContent Function', () => {
    describe('Pending Transactions', () => {
      test('should return pending authorization content for pending authorization', () => {
        const transaction = {
          statusId: CommonTransactionStatus.Pending,
          typeId: TransactionType.Authorization,
        };
        const content = getTransactionContent(transaction);
        expect(content?.title).toBe('Authorization');
        expect(content?.iconBgColor).toBe('bg-warning-05');
      });

      test('should return pending sale content for pending sale', () => {
        const transaction = {
          statusId: CommonTransactionStatus.Pending,
          typeId: TransactionType.Sale,
        };
        const content = getTransactionContent(transaction);
        expect(content?.title).toBe('Sale');
        expect(content?.iconBgColor).toBe('bg-warning-05');
      });

      test('should return pending refund content for pending refund', () => {
        const transaction = {
          statusId: CommonTransactionStatus.Pending,
          typeId: TransactionType.Refund,
        };
        const content = getTransactionContent(transaction);
        expect(content?.title).toBe('Refund');
        expect(content?.iconBgColor).toBe('bg-warning-05');
      });

      test('should return pending ACH refund content for pending ACH refund', () => {
        const transaction = {
          statusId: CommonTransactionStatus.Pending,
          typeId: TransactionType.AchRefund,
        };
        const content = getTransactionContent(transaction);
        expect(content?.title).toBe('ACH Refund');
        expect(content?.iconBgColor).toBe('bg-warning-05');
      });

      test('should return pending ACH sale content for pending ACH debit', () => {
        const transaction = {
          statusId: CommonTransactionStatus.Pending,
          typeId: TransactionType.AchDebit,
        };
        const content = getTransactionContent(transaction);
        expect(content?.title).toBe('ACH Sale');
        expect(content?.iconBgColor).toBe('bg-warning-05');
      });

      test('should return pending ACH credit content for pending ACH credit', () => {
        const transaction = {
          statusId: CommonTransactionStatus.Pending,
          typeId: TransactionType.AchCredit,
        };
        const content = getTransactionContent(transaction);
        expect(content?.title).toBe('ACH Credit');
        expect(content?.iconBgColor).toBe('bg-warning-05');
      });

      test('should return pending refund content for pending refund without reference', () => {
        const transaction = {
          statusId: CommonTransactionStatus.Pending,
          typeId: TransactionType.RefundWORef,
        };
        const content = getTransactionContent(transaction);
        expect(content?.title).toBe('Refund');
        expect(content?.iconBgColor).toBe('bg-warning-05');
      });

      test('should not return pending content for non-pending status with pending transaction types', () => {
        const transaction = {
          statusId: CommonTransactionStatus.Declined,
          typeId: TransactionType.Authorization,
        };
        const content = getTransactionContent(transaction);
        expect(content?.title).toBe('Decline');
        expect(content?.title).not.toBe('Authorization');
      });

      test('should prioritize pending status over other status checks', () => {
        const transaction = {
          statusId: CommonTransactionStatus.Pending,
          typeId: TransactionType.Authorization,
        };
        const content = getTransactionContent(transaction);
        expect(content?.title).toBe('Authorization');
        expect(content?.iconBgColor).toBe('bg-warning-05');
      });
    });

    test('should return declined content for declined transactions', () => {
      const transaction = {
        statusId: CommonTransactionStatus.Declined,
        typeId: TransactionType.Sale,
      };
      const content = getTransactionContent(transaction);
      expect(content?.title).toBe('Decline');
    });

    test('should return failed content for failed transactions', () => {
      const transaction = {
        statusId: CommonTransactionStatus.Failed,
        typeId: TransactionType.Sale,
      };
      const content = getTransactionContent(transaction);
      expect(content?.title).toBe('Failed');
    });

    test('should return failed content for informational authorization', () => {
      const transaction = {
        statusId: CardTransactionStatus.Informational,
        typeId: TransactionType.Authorization,
      };
      const content = getTransactionContent(transaction);
      expect(content?.title).toBe('Failed');
    });

    test('should return failed content for informational sale', () => {
      const transaction = {
        statusId: CardTransactionStatus.Informational,
        typeId: TransactionType.Sale,
      };
      const content = getTransactionContent(transaction);
      expect(content?.title).toBe('Failed');
    });

    test('should return authorization content for authorized transactions', () => {
      const transaction = {
        statusId: CardTransactionStatus.Authorized,
        typeId: TransactionType.Authorization,
      };
      const content = getTransactionContent(transaction);
      expect(content?.title).toBe('Authorization');
    });

    test('should return void content for voided transactions', () => {
      const transaction = {
        statusId: CardTransactionStatus.Voided,
        typeId: TransactionType.Void,
      };
      const content = getTransactionContent(transaction);
      expect(content?.title).toBe('Void');
    });

    test('should return sale content for captured transactions', () => {
      const transaction = {
        statusId: CardTransactionStatus.Captured,
        typeId: TransactionType.Sale,
      };
      const content = getTransactionContent(transaction);
      expect(content?.title).toBe('Sale');
    });

    test('should return sale content for settled transactions', () => {
      const transaction = {
        statusId: CardTransactionStatus.Settled,
        typeId: TransactionType.Sale,
      };
      const content = getTransactionContent(transaction);
      expect(content?.title).toBe('Sale');
    });

    test('should return refund content for refunded transactions', () => {
      const transaction = {
        statusId: CardTransactionStatus.Refunded,
        typeId: TransactionType.Refund,
      };
      const content = getTransactionContent(transaction);
      expect(content?.title).toBe('Refund');
    });

    test('should return ACH sale content for ACH debit transactions', () => {
      const transaction = {
        statusId: AchTransactionStatus.Scheduled,
        typeId: TransactionType.AchDebit,
      };
      const content = getTransactionContent(transaction);
      expect(content?.title).toBe('ACH Sale');
    });

    test('should return ACH void content for cancelled ACH transactions', () => {
      const transaction = {
        statusId: AchTransactionStatus.Cancelled,
        typeId: TransactionType.AchDebit,
      };
      const content = getTransactionContent(transaction);
      expect(content?.title).toBe('ACH Void');
    });

    test('should return charged back content for charged back transactions', () => {
      const transaction = {
        statusId: AchTransactionStatus.ChargedBack,
        typeId: TransactionType.AchDebit,
      };
      const content = getTransactionContent(transaction);
      expect(content?.title).toBe('Charged Back');
    });

    test('should return ACH refund content for ACH refund transactions', () => {
      const transaction = {
        statusId: AchTransactionStatus.Scheduled,
        typeId: TransactionType.AchRefund,
      };
      const content = getTransactionContent(transaction);
      expect(content?.title).toBe('ACH Refund');
    });

    test('should return ACH credit content for ACH credit transactions', () => {
      const transaction = {
        statusId: AchTransactionStatus.Scheduled,
        typeId: TransactionType.AchCredit,
      };
      const content = getTransactionContent(transaction);
      expect(content?.title).toBe('ACH Credit');
    });

    test('should return null for unknown transaction combinations', () => {
      const transaction = {
        statusId: 999, // Unknown status
        typeId: 999, // Unknown type
      };
      const content = getTransactionContent(transaction);
      expect(content).toBeNull();
    });
  });

  describe('Edge Cases', () => {
    test('should handle edge case statuses correctly', () => {
      // Test with boundary values
      const edgeCases = [
        {statusId: 0, typeId: TransactionType.Sale},
        {statusId: -1, typeId: TransactionType.Authorization},
        {statusId: Number.MAX_SAFE_INTEGER, typeId: TransactionType.AchDebit},
      ];

      edgeCases.forEach(transaction => {
        const content = getTransactionContent(transaction);
        // Should either return null or a valid content object
        expect(
          content === null || (content && content.title && content.iconBgColor),
        ).toBe(true);
      });
    });

    test('should be deterministic - same input always produces same output', () => {
      const transaction = {
        statusId: CardTransactionStatus.Authorized,
        typeId: TransactionType.Authorization,
      };

      const firstCall = getTransactionContent(transaction);
      const secondCall = getTransactionContent(transaction);
      const thirdCall = getTransactionContent(transaction);

      expect(firstCall).toEqual(secondCall);
      expect(secondCall).toEqual(thirdCall);
    });
  });
});
