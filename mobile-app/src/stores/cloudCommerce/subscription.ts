import CloudCommerce from '@/cloudcommerce';
import {logger} from '@/utils/logger';
import {useCloudCommerceStore} from '@/stores/cloudCommerceStore';
import {convertTTPEventToCloudCommerceEvent} from '@/stores/cloudCommerce/convertTTPEventToCloudCommerceEvent';

// Event listener subscription helper (kept outside the zustand store to avoid mixing concerns).
let eventSubscription: any = null;
let eventSubscriptionPromise: Promise<any> | null = null;

export const subscribeToCloudCommerceEvents = async () => {
  const timestamp = new Date().toISOString();

  // Check if we already have an active subscription
  if (eventSubscription) {
    logger.info(
      `[${timestamp}] ⚠️ CloudCommerce events already subscribed, skipping re-subscription`,
    );
    logger.info(`[${timestamp}] ⚠️ Event subscription already exists`);
    return eventSubscription;
  }

  // Prevent double subscriptions if two callers arrive before the first await completes.
  if (eventSubscriptionPromise) {
    logger.info(
      `[${timestamp}] ⏳ CloudCommerce event subscription already in progress - awaiting it`,
    );
    return await eventSubscriptionPromise;
  }

  logger.info(
    `[${timestamp}] 📡 Subscribing to CloudCommerce TTP events using wrapper`,
  );
  logger.info(`[${timestamp}] 📡 Starting TTP event subscription process...`);

  eventSubscriptionPromise = (async () => {
    try {
      // Use the new TTP event listener from the wrapper
      // This registers the listener THEN starts the stream
      logger.info(
        `[${timestamp}] 🔄 Calling CloudCommerce.eventManager.addTTPListener...`,
      );
      eventSubscription = await CloudCommerce.eventManager.addTTPListener(
        (event: any) => {
          const eventTimestamp = new Date().toISOString();
          logger.info(`[${eventTimestamp}] 📨 TTP event received in store:`, event);
          logger.info(
            `[${eventTimestamp}] 📨 Store received TTP event:`,
            JSON.stringify(event, null, 2),
          );
          const convertedEvent = convertTTPEventToCloudCommerceEvent(event);
          logger.info(
            `[${eventTimestamp}] 🔄 Converted to CloudCommerce event:`,
            JSON.stringify(convertedEvent, null, 2),
          );
          useCloudCommerceStore.getState().handleSdkEvent(convertedEvent);
        },
      );
      logger.info(
        `[${timestamp}] ✅ Successfully subscribed to CloudCommerce TTP events`,
      );
      logger.info(
        `[${timestamp}] ✅ Event subscription complete. Subscription object:`,
        eventSubscription ? 'exists' : 'null',
      );
      return eventSubscription;
    } catch (error: any) {
      const errorTimestamp = new Date().toISOString();
      logger.error(
        `[${errorTimestamp}] ❌ Failed to subscribe to AriseMobileSdk TTP events:`,
        error,
      );
      logger.info(
        `[${errorTimestamp}] ❌ AriseMobileSdk TTP subscription error:`,
        error,
      );
      return null;
    } finally {
      eventSubscriptionPromise = null;
    }
  })();

  return await eventSubscriptionPromise;
};

export const unsubscribeFromCloudCommerceEvents = () => {
  const timestamp = new Date().toISOString();
  if (eventSubscription) {
    logger.info(`[${timestamp}] 🔌 Unsubscribing from CloudCommerce events`);
    logger.info('Unsubscribing from CloudCommerce events');
    try {
      eventSubscription.remove();
      logger.info(`[${timestamp}] ✅ Successfully unsubscribed`);
      logger.info('Successfully unsubscribed from CloudCommerce events');
    } catch (error) {
      logger.error(`[${timestamp}] ❌ Error unsubscribing:`, error);
      logger.error('Error unsubscribing from CloudCommerce events:', error);
    } finally {
      eventSubscription = null;
    }
  } else {
    logger.info(`[${timestamp}] ℹ️ No active subscription to unsubscribe from`);
  }
};

// Helper function to check if events are subscribed
export const isSubscribedToCloudCommerceEvents = (): boolean => {
  const isSubscribed = eventSubscription !== null;
  logger.info(
    `[isSubscribedToCloudCommerceEvents] Subscription status: ${
      isSubscribed ? 'ACTIVE' : 'INACTIVE'
    }`,
  );
  return isSubscribed;
};


