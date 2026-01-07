import type {CloudCommerceEvent} from '@/cloudcommerce';
import {logger} from '@/utils/logger';

// Convert TTP events from the wrapper to CloudCommerce event format for backward compatibility
export const convertTTPEventToCloudCommerceEvent = (
  ttpEvent: any,
): CloudCommerceEvent => {
  try {
    if (ttpEvent.type === 'readerEvent') {
      const readerEvent = ttpEvent.event;
      switch (readerEvent.type) {
        case 'updateProgress':
          return {
            type: 'ReaderProgress',
            message: `Reader progress: ${readerEvent.progress}%`,
            progress: readerEvent.progress,
          };
        case 'cardDetected':
          return {
            type: 'ReaderState',
            message: 'Card detected',
            state: 'cardDetected',
          };
        case 'readCompleted':
          return {
            type: 'ReaderState',
            message: 'Card read completed',
            state: 'readCompleted',
          };
        case 'readCancelled':
          return {
            type: 'ReaderState',
            message: 'Card read cancelled',
            state: 'readCancelled',
          };
        case 'userInterfaceDismissed':
          return {
            type: 'ReaderState',
            message: 'Reader UI dismissed',
            state: 'userInterfaceDismissed',
          };
        case 'readNotCompleted':
          return {
            type: 'Error',
            message: 'Card read not completed',
            code: 'READ_NOT_COMPLETED',
          };
        case 'removeCard':
          return {
            type: 'ReaderState',
            message: 'Remove card',
            state: 'removeCard',
          };
        case 'readRetry':
          return {
            type: 'ReaderState',
            message: 'Retry reading card',
            state: 'readRetry',
          };
        case 'pinEntryRequested':
          return {
            type: 'ReaderState',
            message: 'Enter PIN',
            state: 'pinEntryRequested',
          };
        case 'pinEntryCompleted':
          return {
            type: 'ReaderState',
            message: 'PIN entered',
            state: 'pinEntryCompleted',
          };
        case 'readyForTap':
          return {
            type: 'ReaderState',
            message: 'Ready for tap',
            state: 'readyForTap',
          };
        case 'notReady':
          return {
            type: 'ReaderState',
            message: 'Reader not ready',
            state: 'notReady',
          };
        default:
          return {
            type: 'ReaderState',
            message: `Reader event: ${readerEvent.type}`,
            state: readerEvent.type,
          };
      }
    } else if (ttpEvent.type === 'customEvent') {
      const customEvent = ttpEvent.event;
      switch (customEvent.type) {
        case 'preparing':
          return {
            type: 'StatusUpdate',
            message: 'Preparing terminal...',
          };
        case 'ready':
          return {
            type: 'StatusUpdate',
            message: 'Terminal is ready',
          };
        case 'approved':
          return {
            type: 'TransactionResult',
            message: 'Transaction approved!',
            success: true,
          };
        case 'declined':
          return {
            type: 'TransactionResult',
            message: 'Transaction declined',
            success: false,
          };
        case 'authorizing':
          return {
            type: 'TransactionState',
            message: 'Authorizing payment...',
            state: 'authorizing',
          };
        case 'inProgress':
          return {
            type: 'TransactionState',
            message: 'Transaction in progress',
            state: 'inProgress',
          };
        case 'cardReadSuccess':
          return {
            type: 'TransactionState',
            message: 'Card read successful',
            state: 'cardReadSuccess',
          };
        case 'cardReadFailure':
          return {
            type: 'TransactionState',
            message: 'Card read failed',
            state: 'cardReadFailure',
          };
        case 'readerNotReady':
          return {
            type: 'Error',
            message: `Reader not ready: ${customEvent.reason}`,
            code: 'READER_NOT_READY',
          };
        case 'cardDetected':
          return {
            type: 'ReaderState',
            message: 'Card detected',
            state: 'cardDetected',
          };
        case 'errorOccurred':
          return {
            type: 'Error',
            message: 'An error occurred during the transaction',
            code: 'TRANSACTION_ERROR',
          };
        case 'updateReaderProgress':
          return {
            type: 'ReaderProgress',
            message: `Reader update progress: ${customEvent.progress}%`,
            progress: customEvent.progress,
          };
        default:
          return {
            type: 'StatusUpdate',
            message: `Custom event: ${customEvent.type}`,
          };
      }
    } else {
      return {
        type: 'UnknownEvent',
        message: `Unknown TTP event type: ${ttpEvent.type}`,
        description: JSON.stringify(ttpEvent),
      };
    }
  } catch (error) {
    logger.error('Error converting TTP event:', error);
    return {
      type: 'UnknownEvent',
      message: 'Error converting TTP event',
      description: JSON.stringify(ttpEvent),
    };
  }
};
