export const ProcessingStatusShownAs = (
  status: string,
  transactionType: string,
) => {
  if (transactionType === 'Authorization' && status === 'Authorized') {
    return 'APPROVED';
  }
  if (transactionType === 'Sale' && status === 'Captured') {
    return 'APPROVED';
  }
  if (transactionType === 'Capture' && status === 'Captured') {
    return 'APPROVED';
  }
  if (transactionType === 'Sale' && status === 'Settled') {
    return 'APPROVED';
  }
  if (status === 'Refunded') {
    return 'APPROVED';
  }
  if (status === 'ChargedBack') {
    return 'CHARGED BACK';
  }
  if (status === 'InProgress') {
    return 'IN PROGRESS';
  }
  if (status === 'HeldByProcessor') {
    return 'HELD BY PROCESSOR';
  }
  return status.toUpperCase();
};
