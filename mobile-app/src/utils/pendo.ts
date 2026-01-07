import {PendoSDK, NavigationLibraryType} from 'rn-pendo-sdk';
import {runtimeConfig} from '@/utils/runtimeConfig';
import {logger} from './logger';

// Initialize Pendo at module level
const PENDO = PendoSDK;
function initPendo() {
  const navigationOptions = {library: NavigationLibraryType.ReactNavigation};
  const pendoKey = runtimeConfig.APP_PENDO_API_KEY;

  if (pendoKey !== '') {
    PENDO.setup(pendoKey, navigationOptions);
  } else {
    logger.error('Pendo not initialized, key is empty');
  }
}

export {initPendo, PENDO};
