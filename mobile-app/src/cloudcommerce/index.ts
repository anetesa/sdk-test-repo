import {NativeModules, NativeEventEmitter} from 'react-native';
import AriseMobileSdk from '../native/AriseMobileSdk';
import {logger} from '@/utils/logger';

const {AriseMobileSdkModule} = NativeModules;

const ttpEventEmitter = new NativeEventEmitter(AriseMobileSdkModule);

// Defines the structured events sent from the native module.
export type CloudCommerceEvent =
  | {type: 'StatusUpdate'; message: string}
  | {type: 'ReaderProgress'; message: string; progress: number}
  | {type: 'ReaderState'; message: string; state: string}
  | {type: 'Error'; message: string; code: string}
  | {type: 'TransactionState'; message: string; state: string}
  | {type: 'TransactionResult'; message: string; success: boolean}
  | {type: 'UnknownEvent'; message: string; description: string};

// TTP Events from the AriseMobileTTP wrapper
export type TTPReaderEvent =
  | {type: 'updateProgress'; progress: number}
  | {type: 'notReady'}
  | {type: 'readyForTap'}
  | {type: 'cardDetected'}
  | {type: 'removeCard'}
  | {type: 'readCompleted'}
  | {type: 'readRetry'}
  | {type: 'readCancelled'}
  | {type: 'pinEntryRequested'}
  | {type: 'pinEntryCompleted'}
  | {type: 'userInterfaceDismissed'}
  | {type: 'readNotCompleted'};

export type TTPCustomEvent =
  | {type: 'preparing'}
  | {type: 'ready'}
  | {type: 'readerNotReady'; reason: string}
  | {type: 'cardDetected'}
  | {type: 'cardReadSuccess'}
  | {type: 'cardReadFailure'}
  | {type: 'authorizing'}
  | {type: 'approved'}
  | {type: 'declined'}
  | {type: 'errorOccurred'}
  | {type: 'inProgress'}
  | {type: 'updateReaderProgress'; progress: number}
  | {type: 'unknownEvent'; description: string};

export type TTPEvent =
  | {type: 'readerEvent'; event: TTPReaderEvent}
  | {type: 'customEvent'; event: TTPCustomEvent};

export type MerchantConfig = {
  isPayByLinkEnabled: boolean;
  paymentNetworks: string[];
};

export type SupportContacts = {
  emails?: string[];
  phones?: string[];
};

export type CurrencyData = {
  countryName: string;
  countryCode: string;
  currencyCodeISO: string;
  countryCurrencySymbol: string;
  currencyCode: string;
  isCurrencyAfter: boolean;
};

export type MerchantDetails = {
  merchantConfig: MerchantConfig;
  supportContacts?: SupportContacts;
  currencyData: CurrencyData[];
  merchantDisplayName?: string;
};

export type SdkInformation = {
  posIdentifier: string | null;
  deviceIdentifier: string;
  merchantDetails: MerchantDetails | null;
  version: string;
  // The 'information' property is a nested object with its own structure.
  information: {[key: string]: any} | null;
  sessionExpiryTime: string | null;
};

type UpgradeResult = {
  forceUpgrade: boolean;
  recommendedUpgrade: boolean;
};

export type Merchant = {
  bannerName: string;
  categoryCode: string;
  terminalProfileId: string;
  currencyCode: string;
  countryCode: string;
};

export type TransactionDetails = {
  /**
   * Monetary amount represented as a fixed 2-decimal string (e.g., "8.70").
   * We intentionally avoid JS floating point numbers to prevent precision artifacts
   * when bridging to Swift/Decimal.
   */
  amount: string;
  currencyCode: 'USD';
  countryCode: string; // Allow dynamic country codes from GPS detection
  tip: string;
  discount: string;
  salesTaxAmount: string;
  federalTaxAmount: string;
  customData: Record<string, string> | undefined;
  subTotal: string;
  orderId: string;
};

const CloudCommerce = {
  prepare: async (): Promise<UpgradeResult> => {
    try {
      await AriseMobileSdk.ttp.prepare();
      return {forceUpgrade: false, recommendedUpgrade: false};
    } catch (error) {
      throw error; // Re-throw to let caller handle it
    }
  },

  resume: async (): Promise<string> => {
    try {
      // Use the AriseMobileTTP wrapper instead of direct CloudCommerce SDK
      await AriseMobileSdk.ttp.resume();
      return 'success'; // Return success indicator
    } catch (error: any) {
      throw error;
    }
  },

  performTransaction: async (
    transactionDetails: TransactionDetails,
  ): Promise<any> => {
    try {
      // Use the AriseMobileTTP wrapper instead of direct CloudCommerce SDK
      const result = await AriseMobileSdk.ttp.performTransaction(
        transactionDetails,
      );

      return result;
    } catch (error: any) {
      throw error;
    }
  },

  clear: async (): Promise<boolean> => {
    // Reset the Arise Mobile SDK state as well (clears tokens and instance)
    await AriseMobileSdk.reset();
    return true;
  },

  /**
   * The event manager for subscribing to real-time events from the AriseMobileSdk.
   * These events provide status updates during a transaction (e.g., "Present Card", "Processing").
   */
  eventManager: {
    /**
     * Subscribes to events from the AriseMobileTTP wrapper instead of direct SDK access.
     * @param callback A function that will be invoked with the TTP event object.
     * @returns A subscription object with a `remove()` method to unsubscribe.
     */
    addTTPListener: async (callback: (event: any) => void) => {
      const timestamp = new Date().toISOString();
      // Step 1: Register the listener FIRST
      const subscription = ttpEventEmitter.addListener('TTPEvent', event => {
        callback(event);
      });
      // Step 2: NOW start the stream (listener is already waiting)
      try {
        const streamResult = await AriseMobileSdk.ttp.eventsStream();
        logger.info(
          `[${timestamp}] ✅ TTP event stream started:`,
          streamResult,
        );
      } catch (error) {
        logger.info(
          `[${timestamp}] ⚠️ Could not start event stream (SDK may not be configured yet):`,
          error,
        );
        // Don't throw - the listener is still registered and will work when SDK is configured
      }

      return {
        remove: () => {
          const removeTimestamp = new Date().toISOString();
          logger.info(`[${removeTimestamp}] 🔌 Removing TTP event listener`);
          subscription.remove();
        },
      };
    },
  },
};

export default CloudCommerce;
