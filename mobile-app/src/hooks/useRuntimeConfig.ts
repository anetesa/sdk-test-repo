import {useCallback} from 'react';
import {Alert} from 'react-native';
import {runtimeConfig} from '@/utils/runtimeConfig';
import {ENVIRONMENTS} from '@/constants/environments';

function useRuntimeConfig() {
  const toggleProduction = useCallback(async () => {
    const currentEnv = runtimeConfig.currentEnvironment;

    if (currentEnv === ENVIRONMENTS.PRODUCTION) {
      // Change to other environment
      runtimeConfig.currentEnvironment = ENVIRONMENTS.UAT;
      Alert.alert('Environment set to UAT');
    } else {
      // Change to other environment
      runtimeConfig.currentEnvironment = ENVIRONMENTS.PRODUCTION;
      Alert.alert('Environment set to PROD');
    }
  }, []);

  return {runtimeConfig, toggleProduction};
}

export {useRuntimeConfig};
