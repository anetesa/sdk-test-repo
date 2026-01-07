// Mock data for testing all transaction scenarios
// This file contains all possible combinations of statusId and typeId
// to test the visual appearance of different transaction types

export const transactionScenarios = [
  // ===== CARD TRANSACTIONS =====

  // 1. DECLINED TRANSACTION
  {
    id: 'declined-001',
    statusId: 91, // CommonTransactionStatus.Declined
    typeId: 2, // TransactionType.Sale
    totalAmount: 25.5,
    date: '2025-01-15T10:30:00Z',
    merchant: 'Coffee Shop',
    customerName: 'John Doe',
    expectedTitle: 'Decline',
    expectedIconBgColor: 'bg-surface-red',
    description: 'Declined card transaction',
  },

  // 2. FAILED TRANSACTION
  {
    id: 'failed-001',
    statusId: 92, // CommonTransactionStatus.Failed
    typeId: 2, // TransactionType.Sale
    totalAmount: 15.75,
    date: '2025-01-14T14:20:00Z',
    merchant: 'Gas Station',
    customerName: 'Jane Smith',
    expectedTitle: 'Failed',
    expectedIconBgColor: 'bg-brand-tint-1',
    description: 'Failed card transaction',
  },

  // 3. AUTHORIZED TRANSACTION
  {
    id: 'authorized-001',
    statusId: 1, // CardTransactionStatus.Authorized
    typeId: 1, // TransactionType.Authorization
    totalAmount: 100.0,
    date: '2025-01-13T09:15:00Z',
    merchant: 'Hotel Booking',
    customerName: 'Mike Johnson',
    expectedTitle: 'Authorization',
    expectedIconBgColor: 'bg-brand-tint-1',
    description: 'Authorized card transaction',
  },

  // 4. PARTIALLY AUTHORIZED TRANSACTION
  {
    id: 'partially-authorized-001',
    statusId: 7, // CardTransactionStatus.PartiallyAuthorized
    typeId: 1, // TransactionType.Authorization
    totalAmount: 75.25,
    date: '2025-01-12T16:45:00Z',
    merchant: 'Restaurant',
    customerName: 'Sarah Wilson',
    expectedTitle: 'Authorization',
    expectedIconBgColor: 'bg-brand-tint-1',
    description: 'Partially authorized card transaction',
  },

  // 5. CAPTURED TRANSACTION (SALE)
  {
    id: 'captured-001',
    statusId: 2, // CardTransactionStatus.Captured
    typeId: 2, // TransactionType.Sale
    totalAmount: 45.8,
    date: '2025-01-11T12:30:00Z',
    merchant: 'Grocery Store',
    customerName: 'David Brown',
    expectedTitle: 'Sale',
    expectedIconBgColor: 'bg-surface-green',
    description: 'Captured sale transaction',
  },

  // 6. SETTLED TRANSACTION (SALE)
  {
    id: 'settled-001',
    statusId: 6, // CardTransactionStatus.Settled
    typeId: 2, // TransactionType.Sale
    totalAmount: 89.99,
    date: '2025-01-10T18:20:00Z',
    merchant: 'Electronics Store',
    customerName: 'Lisa Davis',
    expectedTitle: 'Sale',
    expectedIconBgColor: 'bg-surface-green',
    description: 'Settled sale transaction',
  },

  // 7. VOIDED TRANSACTION
  {
    id: 'voided-001',
    statusId: 3, // CardTransactionStatus.Voided
    typeId: 4, // TransactionType.Void
    totalAmount: 30.0,
    date: '2025-01-09T11:10:00Z',
    merchant: 'Online Store',
    customerName: 'Tom Wilson',
    expectedTitle: 'Void',
    expectedIconBgColor: 'bg-elevation-0',
    description: 'Voided card transaction',
  },

  // 8. REFUNDED TRANSACTION
  {
    id: 'refunded-001',
    statusId: 4, // CardTransactionStatus.Refunded
    typeId: 5, // TransactionType.Refund
    totalAmount: 125.5,
    date: '2025-01-08T15:40:00Z',
    merchant: 'Clothing Store',
    customerName: 'Emma Thompson',
    expectedTitle: 'Refund',
    expectedIconBgColor: 'bg-yellow-200',
    description: 'Refunded card transaction',
  },

  // 9. VERIFIED TRANSACTION
  {
    id: 'verified-001',
    statusId: 5, // CardTransactionStatus.Verified
    typeId: 6, // TransactionType.CardAuthentication
    totalAmount: 0.0,
    date: '2025-01-07T13:25:00Z',
    merchant: 'Payment Gateway',
    customerName: 'Alex Rodriguez',
    expectedTitle: null, // Should return null - no specific content
    expectedIconBgColor: null,
    description: 'Verified card transaction (should show no content)',
  },

  // 10. INFORMATIONAL TRANSACTION (Authorization type)
  {
    id: 'informational-auth-001',
    statusId: 8, // CardTransactionStatus.Informational
    typeId: 1, // TransactionType.Authorization
    totalAmount: 50.0,
    date: '2025-01-06T10:15:00Z',
    merchant: 'Test Merchant',
    customerName: 'Test Customer',
    expectedTitle: 'Failed', // Should show as Failed for Authorization + Informational
    expectedIconBgColor: 'bg-brand-tint-1',
    description: 'Informational authorization (should show as Failed)',
  },

  // ===== ACH TRANSACTIONS =====

  // 11. ACH DEBIT - SCHEDULED
  {
    id: 'ach-debit-scheduled-001',
    statusId: 21, // AchTransactionStatus.Scheduled
    typeId: 11, // TransactionType.AchDebit
    totalAmount: 500.0,
    date: '2025-01-05T08:30:00Z',
    merchant: 'Utility Company',
    customerName: 'Robert Chen',
    expectedTitle: 'ACH Sale',
    expectedIconBgColor: 'bg-green-200',
    description: 'Scheduled ACH debit transaction',
  },

  // 12. ACH DEBIT - IN PROGRESS
  {
    id: 'ach-debit-inprogress-001',
    statusId: 24, // AchTransactionStatus.InProgress
    typeId: 11, // TransactionType.AchDebit
    totalAmount: 750.25,
    date: '2025-01-04T14:20:00Z',
    merchant: 'Insurance Company',
    customerName: 'Maria Garcia',
    expectedTitle: 'ACH Sale',
    expectedIconBgColor: 'bg-green-200',
    description: 'In Progress ACH debit transaction',
  },

  // 13. ACH DEBIT - CLEARED
  {
    id: 'ach-debit-cleared-001',
    statusId: 25, // AchTransactionStatus.Cleared
    typeId: 11, // TransactionType.AchDebit
    totalAmount: 1200.0,
    date: '2025-01-03T16:45:00Z',
    merchant: 'Mortgage Company',
    customerName: 'James Lee',
    expectedTitle: 'ACH Sale',
    expectedIconBgColor: 'bg-green-200',
    description: 'Cleared ACH debit transaction',
  },

  // 14. ACH DEBIT - HELD
  {
    id: 'ach-debit-held-001',
    statusId: 26, // AchTransactionStatus.Held
    typeId: 11, // TransactionType.AchDebit
    totalAmount: 300.5,
    date: '2025-01-02T11:30:00Z',
    merchant: 'Subscription Service',
    customerName: 'Patricia White',
    expectedTitle: 'ACH Sale',
    expectedIconBgColor: 'bg-green-200',
    description: 'Held ACH debit transaction',
  },

  // 15. ACH DEBIT - HELD BY PROCESSOR
  {
    id: 'ach-debit-heldbyprocessor-001',
    statusId: 27, // AchTransactionStatus.HeldByProcessor
    typeId: 11, // TransactionType.AchDebit
    totalAmount: 450.75,
    date: '2025-01-01T09:15:00Z',
    merchant: 'Software Company',
    customerName: 'Kevin Martinez',
    expectedTitle: 'ACH Sale',
    expectedIconBgColor: 'bg-green-200',
    description: 'Held by Processor ACH debit transaction',
  },

  // 16. ACH DEBIT - PENDING
  {
    id: 'ach-debit-pending-001',
    statusId: 90, // CommonTransactionStatus.Pending
    typeId: 11, // TransactionType.AchDebit
    totalAmount: 600.0,
    date: '2024-12-31T12:00:00Z',
    merchant: 'Online Service',
    customerName: 'Jennifer Taylor',
    expectedTitle: 'ACH Sale',
    expectedIconBgColor: 'bg-green-200',
    description: 'Pending ACH debit transaction',
  },

  // 17. ACH DEBIT - CANCELLED (VOID)
  {
    id: 'ach-debit-cancelled-001',
    statusId: 22, // AchTransactionStatus.Cancelled
    typeId: 11, // TransactionType.AchDebit
    totalAmount: 800.0,
    date: '2024-12-30T15:20:00Z',
    merchant: 'Service Provider',
    customerName: 'Christopher Anderson',
    expectedTitle: 'ACH Void',
    expectedIconBgColor: 'bg-elevation-0',
    description: 'Cancelled ACH debit transaction (should show as ACH Void)',
  },

  // 18. ACH CREDIT - SCHEDULED
  {
    id: 'ach-credit-scheduled-001',
    statusId: 21, // AchTransactionStatus.Scheduled
    typeId: 16, // TransactionType.AchCredit
    totalAmount: 250.0,
    date: '2024-12-29T10:45:00Z',
    merchant: 'Employer',
    customerName: 'Amanda Clark',
    expectedTitle: 'ACH Credit',
    expectedIconBgColor: 'bg-warning-05',
    description: 'Scheduled ACH credit transaction',
  },

  // 19. ACH CREDIT - IN PROGRESS
  {
    id: 'ach-credit-inprogress-001',
    statusId: 24, // AchTransactionStatus.InProgress
    typeId: 16, // TransactionType.AchCredit
    totalAmount: 1800.5,
    date: '2024-12-28T13:30:00Z',
    merchant: 'Investment Firm',
    customerName: 'Daniel Lewis',
    expectedTitle: 'ACH Credit',
    expectedIconBgColor: 'bg-warning-05',
    description: 'In Progress ACH credit transaction',
  },

  // 20. ACH CREDIT - CLEARED
  {
    id: 'ach-credit-cleared-001',
    statusId: 25, // AchTransactionStatus.Cleared
    typeId: 16, // TransactionType.AchCredit
    totalAmount: 3200.75,
    date: '2024-12-27T16:15:00Z',
    merchant: 'Bank Transfer',
    customerName: 'Michelle Hall',
    expectedTitle: 'ACH Credit',
    expectedIconBgColor: 'bg-warning-05',
    description: 'Cleared ACH credit transaction',
  },

  // 21. ACH REFUND - SCHEDULED
  {
    id: 'ach-refund-scheduled-001',
    statusId: 21, // AchTransactionStatus.Scheduled
    typeId: 12, // TransactionType.AchRefund
    totalAmount: 150.25,
    date: '2024-12-26T11:20:00Z',
    merchant: 'Refund Service',
    customerName: 'Steven Young',
    expectedTitle: 'ACH Refund',
    expectedIconBgColor: 'bg-yellow-200',
    description: 'Scheduled ACH refund transaction',
  },

  // 22. ACH REFUND - CHARGED BACK
  {
    id: 'ach-refund-chargedback-001',
    statusId: 23, // AchTransactionStatus.ChargedBack
    typeId: 12, // TransactionType.AchRefund
    totalAmount: 75.5,
    date: '2024-12-25T14:40:00Z',
    merchant: 'Dispute Resolution',
    customerName: 'Nicole King',
    expectedTitle: 'ACH Refund',
    expectedIconBgColor: 'bg-yellow-200',
    description: 'Charged back ACH refund transaction',
  },

  // ===== EDGE CASES =====

  // 23. ZERO AMOUNT TRANSACTION
  {
    id: 'zero-amount-001',
    statusId: 2, // CardTransactionStatus.Captured
    typeId: 2, // TransactionType.Sale
    totalAmount: 0.0,
    date: '2024-12-24T09:30:00Z',
    merchant: 'Free Service',
    customerName: 'Free Customer',
    expectedTitle: 'Sale',
    expectedIconBgColor: 'bg-surface-green',
    description: 'Zero amount sale transaction',
  },

  // 24. LARGE AMOUNT TRANSACTION
  {
    id: 'large-amount-001',
    statusId: 2, // CardTransactionStatus.Captured
    typeId: 2, // TransactionType.Sale
    totalAmount: 999999.99,
    date: '2024-12-23T17:45:00Z',
    merchant: 'Luxury Store',
    customerName: 'High Value Customer',
    expectedTitle: 'Sale',
    expectedIconBgColor: 'bg-surface-green',
    description: 'Large amount sale transaction',
  },

  // 25. DECIMAL AMOUNT TRANSACTION
  {
    id: 'decimal-amount-001',
    statusId: 2, // CardTransactionStatus.Captured
    typeId: 2, // TransactionType.Sale
    totalAmount: 123.45,
    date: '2024-12-22T12:15:00Z',
    merchant: 'Precise Store',
    customerName: 'Precise Customer',
    expectedTitle: 'Sale',
    expectedIconBgColor: 'bg-surface-green',
    description: 'Decimal amount sale transaction',
  },

  // 26. UNKNOWN STATUS (should return null)
  {
    id: 'unknown-status-001',
    statusId: 999, // Unknown status
    typeId: 2, // TransactionType.Sale
    totalAmount: 50.0,
    date: '2024-12-21T10:00:00Z',
    merchant: 'Unknown Merchant',
    customerName: 'Unknown Customer',
    expectedTitle: null, // Should return null
    expectedIconBgColor: null,
    description: 'Unknown status transaction (should show no content)',
  },

  // 27. UNKNOWN TYPE (should return null)
  {
    id: 'unknown-type-001',
    statusId: 2, // CardTransactionStatus.Captured
    typeId: 999, // Unknown type
    totalAmount: 50.0,
    date: '2024-12-20T15:30:00Z',
    merchant: 'Unknown Type Merchant',
    customerName: 'Unknown Type Customer',
    expectedTitle: null, // Should return null
    expectedIconBgColor: null,
    description: 'Unknown type transaction (should show no content)',
  },
];

// Helper function to get scenarios by category
export const getScenariosByCategory = () => {
  return {
    cardTransactions: transactionScenarios.filter(
      t =>
        [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].includes(t.statusId) ||
        (t.statusId >= 90 && t.statusId <= 92),
    ),
    achTransactions: transactionScenarios.filter(
      t => t.statusId >= 21 && t.statusId <= 27,
    ),
    edgeCases: transactionScenarios.filter(
      t =>
        t.id.includes('zero-amount') ||
        t.id.includes('large-amount') ||
        t.id.includes('decimal-amount') ||
        t.id.includes('unknown'),
    ),
    allScenarios: transactionScenarios,
  };
};

// Helper function to get scenarios that should return null
export const getNullScenarios = () => {
  return transactionScenarios.filter(t => t.expectedTitle === null);
};

// Helper function to get scenarios that should display content
export const getDisplayScenarios = () => {
  return transactionScenarios.filter(t => t.expectedTitle !== null);
};
