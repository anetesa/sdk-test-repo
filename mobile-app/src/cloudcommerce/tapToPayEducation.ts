import AriseMobileSdk from '@/native/AriseMobileSdk';
import {logger} from '@/utils/logger';

interface TapToPayEducationResponse {
  success: boolean;
}

/**
 * Shows Apple's built-in educational content for Tap to Pay
 *
 * Now uses the ARISE SDK wrapper (ariseSDK.ttp.showEducationalInfo()) instead of custom screens.
 * This function displays the educational content provided by Apple SDK (iOS 18+)
 * that teach users how to use Tap to Pay for iPhone. The content includes:
 * - How to position the card correctly
 * - What to expect during the tap process
 * - Troubleshooting tips
 *
 * The educational content is:
 * - Automatically localized based on device settings
 * - Displayed in a modal popover
 * - Provided directly by Apple's ProximityReader framework
 * - Maintained centrally in the SDK (no custom views needed)
 *
 * @returns Promise that resolves when the educational content is dismissed
 * @throws Error if the device doesn't support ProximityReader, iOS < 18.0, or display error
 *
 * @example
 * try {
 *   await showTapToPayEducationScreens();
 *   console.log('Educational content was shown and dismissed');
 * } catch (error) {
 *   console.error('Failed to show educational content:', error);
 * }
 */
export const showTapToPayEducationScreens =
  async (): Promise<TapToPayEducationResponse> => {
    try {
      logger.info('📚 Showing Tap to Pay educational content from SDK');
      const result = await AriseMobileSdk.ttp.showEducationalInfo();
      logger.info('✅ Educational content dismissed by user');
      return result;
    } catch (error: any) {
      logger.error('❌ Error showing Tap to Pay education screens:', error);
      throw error;
    }
  };
