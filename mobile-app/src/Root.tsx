import React, {useEffect} from 'react';
import {AppState, AppStateStatus} from 'react-native';
import App from './App';
import {QueryClientProvider} from '@tanstack/react-query';
import {useGrowthBookAttributes} from './hooks/useGrowthBook';
import {growthBook} from '@/utils/growthBook';
import {GrowthBookProvider} from '@growthbook/growthbook-react';
import {queryClient} from '@/utils/queryClient';
import GlobalAlerts from '@/components/GlobalAlerts';
import {useCloudCommerceStore} from '@/stores/cloudCommerceStore';
import {
  subscribeToCloudCommerceEvents,
  unsubscribeFromCloudCommerceEvents,
  isSubscribedToCloudCommerceEvents,
} from '@/stores/cloudCommerce/subscription';
import {logger} from '@/utils/logger';

// https://docs.growthbook.io/lib/react#error-handling
growthBook.instance.init();

// CloudCommerce initialization component - must be inside GrowthBookProvider
const CloudCommerceInitializer: React.FC = () => {
  const {useFeatureIsOn} = require('@growthbook/growthbook-react');
  const isTapToPayEnabled = useFeatureIsOn('ARISE-644-TTP-Basic-Transaction');

  // Global CloudCommerce event subscription - only if feature is enabled
  useEffect(() => {
    if (!isTapToPayEnabled) {
      return; // Don't subscribe to events if feature is disabled
    }

    const timestamp = new Date().toISOString();
    logger.info(
      `[${timestamp}] 🎬 [Root] Setting up TTP event listener on app start`,
    );

    // Subscribe to events on app start
    // The listener is registered immediately but the stream starts automatically in prepare()
    subscribeToCloudCommerceEvents();

    // Handle app state changes to maintain subscription and recovery
    const handleAppStateChange = (nextAppState: AppStateStatus) => {
      const ts = new Date().toISOString();
      logger.info(`[${ts}] 🔄 [Root] App state changed to: ${nextAppState}`);
      if (nextAppState === 'active') {
        logger.info(
          `[${ts}] 🔄 [Root] App became active, checking event subscription...`,
        );
        const state = useCloudCommerceStore.getState();

        // During TTP UI flows (especially after coming from Splash/activation),
        // iOS will bounce AppState and we must NOT resubscribe/prepare mid-transaction.
        if (state.isLoading) {
          logger.info(
            `[${ts}] 🔒 [Root] TTP flow busy (transaction/activate/prepare/education) - skipping resubscribe/recovery`,
          );
          return;
        }

        // Keep subscription alive, but don't force-unsubscribe/resubscribe every time.
        if (!isSubscribedToCloudCommerceEvents()) {
          subscribeToCloudCommerceEvents();
        }

        // Trigger global recovery only when safe.
        setTimeout(() => {
          const latest = useCloudCommerceStore.getState();
          if (latest.isLoading) {
            return;
          }
          latest.handleBackgroundReturn();
        }, 150);
      }
    };

    // Add app state listener
    const appStateSubscription = AppState.addEventListener(
      'change',
      handleAppStateChange,
    );

    // Cleanup function
    return () => {
      appStateSubscription?.remove();
      unsubscribeFromCloudCommerceEvents();
    };
  }, [isTapToPayEnabled]); // Re-run when feature flag changes

  return null; // This component doesn't render anything
};

export default function Root() {
  useGrowthBookAttributes();

  return (
    <GrowthBookProvider growthbook={growthBook.instance}>
      <CloudCommerceInitializer />
      <QueryClientProvider client={queryClient}>
        <App />
        <GlobalAlerts />
      </QueryClientProvider>
    </GrowthBookProvider>
  );
}
