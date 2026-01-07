import {useSelectedProfile} from '@/hooks/useSelectedProfile';
import {isMerchantManagerProfile} from '@/utils/isMerchantManager';

export const useIsMerchantManager = (): boolean => {
  const {selectedProfile} = useSelectedProfile();
  return isMerchantManagerProfile(selectedProfile);
};


