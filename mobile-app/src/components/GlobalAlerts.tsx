import React from 'react';
import {View} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';
import AnimatedAlert from './AnimatedAlert';
import {useAlertStore} from '@/stores/alertStore';

const GlobalAlerts: React.FC = () => {
  const {alerts, hideAlert} = useAlertStore();

  return (
    <>
      {alerts.length > 0 && (
        <View className="absolute bottom-0 left-0 right-0 z-50">
          <SafeAreaView edges={['bottom']}>
            {alerts.map(alert => (
              <AnimatedAlert
                key={alert.id}
                id={alert.id}
                type={alert.type}
                message={alert.message}
                isVisible={alert.isVisible}
                onHide={() => hideAlert(alert.id)}
              />
            ))}
          </SafeAreaView>
        </View>
      )}
    </>
  );
};

export default GlobalAlerts;
