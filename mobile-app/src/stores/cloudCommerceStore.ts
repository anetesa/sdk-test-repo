import {create} from 'zustand';
import CloudCommerce, {
  CloudCommerceEvent,
  TransactionDetails,
} from '@/cloudcommerce';
import {logger} from '@/utils/logger';
import {initialStatus, initialConfig} from '@/types/CloudCommerceStore';
import {showTapToPayEducationScreens} from '@/cloudcommerce/tapToPayEducation';

// Single-flight lock for terminal preparation: all callers await the same in-flight promise.
let prepareTerminalPromise: Promise<void> | null = null;
// Single-flight lock for performTransaction: prevents JS double-invocations from throwing + breaking UI state.
let performTransactionPromise: Promise<any> | null = null;

export const useCloudCommerceStore = create((set, get: () => any) => ({
  // Initial state
  ...initialStatus,
  ...initialConfig,

  prepareTerminal: async () => {
    const timestamp = new Date().toISOString();

    // If a prepare is already in-flight, never start another one.
    // All callers await the same promise (no polling/timeouts).
    if (prepareTerminalPromise) {
      logger.info(
        `[${timestamp}] ⏳ CloudCommerce prepare() already in progress - awaiting it`,
      );
      return await prepareTerminalPromise;
    }

    prepareTerminalPromise = (async () => {
      set({
        isLoading: true,
        status: 'Preparing terminal...',
        error: null,
      });

      try {
        logger.info(`[${timestamp}] Starting CloudCommerce preparation`);
        await CloudCommerce.prepare();
        set({
          isPrepared: true,
          status: '✅ Terminal prepared successfully',
          error: null,
        });
        logger.info(
          `[${timestamp}] ✅ CloudCommerce preparation completed successfully`,
        );
      } catch (error: any) {
        set({
          isPrepared: false,
          status: '❌ Terminal preparation failed',
          error: error,
        });
        logger.error(
          `[${timestamp}] ❌ CloudCommerce preparation failed:`,
          error,
        );
        throw error;
      } finally {
        set({isLoading: false});
        prepareTerminalPromise = null;
      }
    })();

    return await prepareTerminalPromise;
  },

  resumeTerminal: async () => {
    set({isLoading: true, status: 'Resuming terminal...'});

    try {
      logger.info('Resuming CloudCommerce terminal');
      const response = await CloudCommerce.resume();
      set({
        isLoading: false,
        status: '✅ Terminal resumed successfully',
        error: null,
        isPrepared: true,
      });
      return response;
    } catch (error: any) {
      set({
        isLoading: false,
        status: '❌ Terminal resume failed',
        error: error,
        isPrepared: false,
      });
      //call prepareTerminal() one more time. in case the terminal is not prepared.
      get().prepareTerminal();

      throw error;
    }
  },

  clearTerminal: async () => {
    try {
      logger.info('Clearing CloudCommerce terminal');
      const result = await CloudCommerce.clear();
      set({isPrepared: false, status: 'Terminal cleared', error: null});
      return result;
    } catch (error: any) {
      throw error;
    }
  },

  activateTapToPay: async (): Promise<{
    activated: boolean;
    prepared: boolean;
    activationStatus: string;
  }> => {
    if (get().isLoading) {
      logger.warn('Tap to Pay activation already in progress');
      return {
        activated: false,
        prepared: Boolean(get().isPrepared),
        activationStatus: 'Unknown',
      };
    }

    const timestamp = new Date().toISOString();

    set({
      isLoading: true,
      status: 'Activating Tap to Pay...',
      error: null,
    });

    let stage: 'activation' | 'preparation' = 'activation';
    let activated = false;

    try {
      logger.info(`[${timestamp}] Starting Tap to Pay activation`);

      // Import AriseMobileSdk dynamically to activate Tap to Pay
      const {default: AriseMobileSdk} = await import('@/native/AriseMobileSdk');
      logger.info(`[${timestamp}] ⚡ Calling AriseMobileSdk.ttp.activate()...`);
      const activationStatus = await AriseMobileSdk.ttp.activate();
      logger.info(`[${timestamp}] ✅ Activation completed`);

      // Native SDK shows a modal popover. Track visibility explicitly since navigation focus
      // can remain "focused" even when native UI is on top.

      try {
        // IMPORTANT: Wait until the user dismisses the native educational modal before continuing.
        await showTapToPayEducationScreens();
      } catch (educationError) {
        // Non-fatal: education modal failing shouldn't block activation/preparation flow.
        logger.warn('Tap to Pay education modal failed or was interrupted', {
          educationError,
        });
      }

      activated = true;
      stage = 'preparation';

      // IMPORTANT: activation does NOT implicitly prepare the terminal.
      // After activation succeeds, prepare the terminal so the app can process transactions.
      set({
        status: 'Activation completed. Preparing terminal...',
        error: null,
      });

      // IMPORTANT UX:
      // We intentionally DO NOT await prepareTerminal() here so the UI can move forward immediately
      // after activation + education, and the next screen can wait for preparation to finish.
      get()
        .prepareTerminal()
        .catch((prepareError: unknown) => {
          logger.error(
            'Tap to Pay activated but terminal preparation failed (background):',
            prepareError,
          );
        });

      const prepared = Boolean(get().isPrepared);

      logger.info(
        '✅ Tap to Pay activation completed successfully preparing terminal is running in the background',
      );

      // Invalidate device status query to refresh TTP status
      const {queryClient} = await import('@/utils/queryClient');
      logger.info(`[${timestamp}] Invalidating device status query...`);
      await queryClient.invalidateQueries({
        queryKey: ['tap-to-pay-device-status'],
      });
      logger.info('✅ Device status query invalidated after TTP activation');
      logger.info(`[${timestamp}] ✅ Device status should now refresh`);

      return {activated, prepared, activationStatus};
    } catch (error: any) {
      const status =
        stage === 'preparation'
          ? '❌ Tap to Pay activated but terminal preparation failed'
          : '❌ Tap to Pay activation failed';

      set({
        isLoading: false,
        status,
        error: error,
      });
      logger.error('Tap to Pay activation failed:', error);
      throw error;
    }
  },

  performTransaction: async (transactionDetails: TransactionDetails) => {
    if (!get().isPrepared) {
      const error = 'Terminal not prepared. Please prepare terminal first.';
      set({error, status: '❌ ' + error});
      throw new Error(error);
    }

    performTransactionPromise = (async () => {
      set({
        isLoading: true,
        status: 'Processing transaction...',
        error: null,
      });

      try {
        logger.info('Starting CloudCommerce transaction', transactionDetails);
        const result = await CloudCommerce.performTransaction(
          transactionDetails,
        );

        set({
          isLoading: false,
          status: '✅ Transaction completed successfully',
          error: null,
        });
        return result;
      } catch (error: any) {
        logger.error('CloudCommerce transaction failed', error);

        // 'ReadError error 13' typically means the reading session was invalidated
        // (e.g., user closed the UI)
        const isSessionError =
          error?.message?.includes('ReadError error 13') ||
          error?.message?.includes('ReadError error 14');

        if (isSessionError) {
          // If it's specifically error 13 (User Cancelled / UI Dismissed), don't retry.
          if (error?.message?.includes('ReadError error 13')) {
            logger.warn(
              '⚠️ ReadError 13 detected - treating as User Cancellation / UI Dismissed',
            );
            set({
              isLoading: false,
              status: 'Transaction cancelled',
              error: null, // Clear error so we don't show error screen
              sdkState: 'userInterfaceDismissed',
            });
            // We don't throw here to avoid generic error handling in the component
            return {transactionId: null}; // Return empty result
          }
        }

        set({
          isLoading: false,
          status: '❌ Transaction failed',
          error: error, // ✅ Store the complete error object
        });
        throw error;
      } finally {
        performTransactionPromise = null;
      }
    })();

    return await performTransactionPromise;
  },

  // Configuration setters (deprecated - kept for backward compatibility)
  setEnvironment: (isProd: boolean) => set({isProd}),

  // State management
  setStatus: (status: string) => set({status}),
  setSdkState: (sdkState: string | null) => set({sdkState}),
  setError: (error: string | null) => set({error}),
  setLoading: (isLoading: boolean) => set({isLoading}),

  handleSdkEvent: (event: CloudCommerceEvent) => {
    const timestamp = new Date().toISOString();
    logger.info(`[${timestamp}] CloudCommerce SDK Event received`, event);

    // Handle different types of events based on the structured format
    switch (event.type) {
      case 'StatusUpdate': // General status updates (e.g., from prepare/resume)
        set({
          status: event.message,
          sdkState: null,
          readerProgress: null,
        });
        break;

      case 'ReaderState': //State of the card reader
      case 'TransactionState': //State of the transaction
        set({
          status: event.message,
          sdkState: event.state,
          readerProgress: null,
        });
        break;

      case 'ReaderProgress': //Progress of the card reader firmware update (PRF) (0-100%)
        set({
          status: `${event.message} ${event.progress}%`,
          sdkState: 'updateReaderFirmware',
          readerProgress: event.progress,
          error: null, // ✅ Clear any reader-related errors when update starts
        });
        break;

      case 'TransactionResult': //Final result of the transaction (approved/declined)
        set({
          status: `${event.message} (Success: ${event.success})`,
          sdkState: event.success ? 'Completed' : 'Failed',
          isLoading: false,
          readerProgress: null,
        });
        break;

      case 'Error':
        set({
          status: `❌ ERROR: ${event.message} (Code: ${event.code})`,
          sdkState: 'Error',
          error: event, // ✅ FIXED: Store the complete event object, not just the message
          isLoading: false,
          readerProgress: null,
        });
        break;

      default:
        set({
          status: `Unknown Event: ${event.message}`,
          sdkState: 'Unknown',
          readerProgress: null,
        });
    }
  },

  // AppState "active" hook: keep terminal prepared after returning from background (no retry logic).
  handleBackgroundReturn: async () => {
    const currentState = get();

    if (currentState.isLoading) {
      logger.info(
        '🔒 handleBackgroundReturn - Busy (loading/education), skipping prepare',
      );
      return;
    }

    try {
      const {isPrepared} = get();

      if (!isPrepared) {
        logger.info('🔄 handleBackgroundReturn - Not prepared, preparing...');
        try {
          await get().prepareTerminal();
          logger.info(
            '✅ handleBackgroundReturn - Terminal prepared and ready for transactions',
          );
        } catch (prepareError: any) {
          logger.error(
            '❌ handleBackgroundReturn - Prepare failed:',
            prepareError,
          );
          // Error is already stored by prepareTerminal()
        }
      }
    } catch (error: any) {
      logger.error('💥 handleBackgroundReturn - Unexpected error:', error);
    }
  },

  // Reset method
  reset: () => {
    logger.info('Resetting CloudCommerce store');
    set({
      ...initialStatus,
      ...initialConfig,
    });
  },
}));
