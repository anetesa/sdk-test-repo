import {useSelectedProfile} from '@/hooks/useSelectedProfile';
import {isStaffMerchantProfile} from '@/utils/isStaffMerchant';

export const useIsStaffMerchant = (): boolean => {
  const {selectedProfile} = useSelectedProfile();
  return isStaffMerchantProfile(selectedProfile);
};


