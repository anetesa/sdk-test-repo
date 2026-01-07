import React from 'react';
import {
  CircleX,
  CircleArrowLeft,
  FileInput,
  CircleCheck,
  X,
  FileOutput,
  Clock2,
  CircleCheckBig,
} from 'lucide-react-native';
import {COLORS} from '@/constants/colors';

import {
  CardTransactionStatus,
  AchTransactionStatus,
  CommonTransactionStatus,
} from '@/dictionaries/TransactionStatuses';
import {TransactionType} from '@/dictionaries/TransactionTypes';

export interface TransactionContent {
  icon: React.ReactElement;
  iconBgColor: string;
  title: string;
  statusTextColor: string;
}

export interface TransactionData {
  statusId: number;
  typeId: number;
}

// Pure functions for determining transaction types

export const isAchDebit = (typeId: number): boolean =>
  typeId === TransactionType.AchDebit;

export const isAchCredit = (typeId: number): boolean =>
  typeId === TransactionType.AchCredit;

export const isAchRefund = (typeId: number): boolean =>
  typeId === TransactionType.AchRefund;

export const isAuthorization = (typeId: number): boolean =>
  typeId === TransactionType.Authorization;

// Pure functions for determining transaction statuses

export const isPending = (statusId: number): boolean =>
  statusId === CommonTransactionStatus.Pending;

export const isDeclined = (statusId: number): boolean =>
  statusId === CommonTransactionStatus.Declined;

export const isFailed = (statusId: number, typeId: number): boolean =>
  statusId === CommonTransactionStatus.Failed ||
  (typeId === TransactionType.Authorization &&
    statusId === CardTransactionStatus.Informational) ||
  (typeId === TransactionType.Sale &&
    statusId === CardTransactionStatus.Informational);

export const isAuthorized = (statusId: number, typeId: number): boolean =>
  [
    CardTransactionStatus.Authorized,
    CardTransactionStatus.PartiallyAuthorized,
  ].includes(statusId) && typeId === TransactionType.Authorization;

export const isVoided = (statusId: number): boolean =>
  [CardTransactionStatus.Voided].includes(statusId);

export const isSale = (statusId: number): boolean =>
  [CardTransactionStatus.Captured, CardTransactionStatus.Settled].includes(
    statusId,
  );

export const isRefunded = (statusId: number): boolean =>
  [CardTransactionStatus.Refunded].includes(statusId);

export const isAchSale = (statusId: number, typeId: number): boolean =>
  isAchDebit(typeId) &&
  [
    AchTransactionStatus.Scheduled,
    AchTransactionStatus.InProgress,
    AchTransactionStatus.Cleared,
    AchTransactionStatus.Held,
    AchTransactionStatus.HeldByProcessor,
  ].includes(statusId);

export const isAchSaleChargedBack = (
  statusId: number,
  typeId: number,
): boolean =>
  isAchDebit(typeId) && [AchTransactionStatus.ChargedBack].includes(statusId);

export const isAchSaleHeld = (statusId: number, typeId: number): boolean =>
  isAchDebit(typeId) &&
  [AchTransactionStatus.Held, AchTransactionStatus.HeldByProcessor].includes(
    statusId,
  );

export const isAchVoid = (statusId: number): boolean =>
  [AchTransactionStatus.Cancelled].includes(statusId);

export const isAchRefundStatus = (statusId: number, typeId: number): boolean =>
  AchTransactionStatus.ChargedBack === statusId ||
  (isAchRefund(typeId) &&
    [
      AchTransactionStatus.Scheduled,
      AchTransactionStatus.InProgress,
      AchTransactionStatus.Cleared,
      AchTransactionStatus.Held,
      AchTransactionStatus.HeldByProcessor,
    ].includes(statusId));

export const isAchCreditStatus = (statusId: number, typeId: number): boolean =>
  isAchCredit(typeId) &&
  [
    AchTransactionStatus.Scheduled,
    AchTransactionStatus.InProgress,
    AchTransactionStatus.Cleared,
    AchTransactionStatus.Held,
    AchTransactionStatus.HeldByProcessor,
  ].includes(statusId);

// Pure functions for creating transaction content
export const createDeclinedContent = (): TransactionContent => ({
  icon: React.createElement(X, {color: COLORS.ERROR, size: 20}),
  iconBgColor: 'bg-surface-red',
  title: 'Decline',
  statusTextColor: 'text-[#B91C1C]',
});

export const createFailedContent = (): TransactionContent => ({
  icon: React.createElement(X, {color: COLORS.ERROR, size: 20}),
  iconBgColor: 'bg-surface-red',
  title: 'Failed',
  statusTextColor: 'text-[#B91C1C]',
});

export const createAuthorizationContent = (): TransactionContent => ({
  icon: React.createElement(CircleCheck, {color: COLORS.INFO_BLUE, size: 20}),
  iconBgColor: 'bg-brand-main-05',
  title: 'Authorization',
  statusTextColor: 'text-brand-main',
});

export const createVoidContent = (): TransactionContent => ({
  icon: React.createElement(CircleX, {color: '#71717A', size: 20}),
  iconBgColor: 'bg-elevation-04',
  title: 'Void',
  statusTextColor: 'text-text-tertiary',
});

export const createSaleContent = (): TransactionContent => ({
  icon: React.createElement(CircleCheckBig, {color: COLORS.SUCCESS, size: 20}),
  iconBgColor: 'bg-surface-green',
  title: 'Sale',
  statusTextColor: 'text-[#15803D]',
});

export const createRefundContent = (): TransactionContent => ({
  icon: React.createElement(CircleArrowLeft, {color: '#A16207', size: 20}),
  iconBgColor: 'bg-warning-05',
  title: 'Refund',
  statusTextColor: 'text-warning-main',
});

export const createAchSaleContent = (): TransactionContent => ({
  icon: React.createElement(FileInput, {color: COLORS.SUCCESS, size: 20}),
  iconBgColor: 'bg-surface-green',
  title: 'ACH Sale',
  statusTextColor: 'text-[#15803D]',
});

export const createAchVoidContent = (): TransactionContent => ({
  icon: React.createElement(CircleX, {color: '#71717A', size: 20}),
  iconBgColor: 'bg-elevation-04',
  title: 'ACH Void',
  statusTextColor: 'text-text-tertiary',
});

export const createAchRefundContent = (): TransactionContent => ({
  icon: React.createElement(CircleArrowLeft, {color: '#A16207', size: 20}),
  iconBgColor: 'bg-warning-05',
  title: 'ACH Refund',
  statusTextColor: 'text-warning-main',
});

export const createAchCreditContent = (): TransactionContent => ({
  icon: React.createElement(FileOutput, {color: COLORS.WARNING, size: 20}),
  iconBgColor: 'bg-warning-05',
  title: 'ACH Credit',
  statusTextColor: 'text-warning-main',
});

export const createPendingContent = (title: string): TransactionContent => ({
  icon: React.createElement(Clock2, {color: COLORS.WARNING, size: 20}),
  iconBgColor: 'bg-warning-05',
  title: title,
  statusTextColor: 'text-warning-main',
});

export const createAchSaleChargedBackContent = (): TransactionContent => ({
  icon: React.createElement(X, {color: COLORS.ERROR, size: 20}),
  iconBgColor: 'bg-surface-red',
  title: 'Charged Back',
  statusTextColor: 'text-[#B91C1C]',
});

export const createAchSaleHeldContent = (): TransactionContent => ({
  icon: React.createElement(Clock2, {color: COLORS.WARNING, size: 20}),
  iconBgColor: 'bg-warning-05',
  title: 'Held',
  statusTextColor: 'text-warning-main',
});

// Main pure function that determines transaction content
export const getTransactionContent = (
  transaction: TransactionData,
): TransactionContent | null => {
  const {statusId, typeId} = transaction;

  if (isPending(statusId) && typeId === TransactionType.Authorization) {
    return createPendingContent('Authorization');
  } else if (isPending(statusId) && typeId === TransactionType.Sale) {
    return createPendingContent('Sale');
  } else if (isPending(statusId) && typeId === TransactionType.Refund) {
    return createPendingContent('Refund');
  } else if (isPending(statusId) && typeId === TransactionType.AchRefund) {
    return createPendingContent('ACH Refund');
  } else if (isPending(statusId) && typeId === TransactionType.AchDebit) {
    return createPendingContent('ACH Sale');
  } else if (isPending(statusId) && typeId === TransactionType.AchCredit) {
    return createPendingContent('ACH Credit');
  } else if (isPending(statusId) && typeId === TransactionType.RefundWORef) {
    return createPendingContent('Refund');
  }

  if (isDeclined(statusId)) {
    return createDeclinedContent();
  }

  if (isFailed(statusId, typeId)) {
    return createFailedContent();
  }

  if (isAuthorized(statusId, typeId)) {
    return createAuthorizationContent();
  }

  if (isVoided(statusId)) {
    return createVoidContent();
  }

  if (isSale(statusId)) {
    return createSaleContent();
  }

  if (isRefunded(statusId)) {
    return createRefundContent();
  }

  if (isAchSaleHeld(statusId, typeId)) {
    return createAchSaleHeldContent();
  }

  if (isAchSale(statusId, typeId)) {
    return createAchSaleContent();
  }

  if (isAchVoid(statusId)) {
    return createAchVoidContent();
  }

  if (isAchSaleChargedBack(statusId, typeId)) {
    return createAchSaleChargedBackContent();
  }

  if (isAchRefundStatus(statusId, typeId)) {
    return createAchRefundContent();
  }

  if (isAchCreditStatus(statusId, typeId)) {
    return createAchCreditContent();
  }

  return null;
};
