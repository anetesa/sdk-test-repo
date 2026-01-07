import {useMemo} from 'react';
import {useMeProfile} from '@/hooks/queries/useMeProfile';
import {useUserStore} from '@/stores/userStore';
import {ProfileResponseDTO} from '@/types/Login';

/**
 * Hook that returns the currently selected profile based on merchantId from userStore.
 * This eliminates the need to manually find the profile in every component.
 *
 * @param options - Options to pass to useMeProfile
 * @returns The selected profile or undefined if not found
 */
export const useSelectedProfile = (options?: {
  enabled?: boolean;
  forceFresh?: boolean;
}) => {
  const {data: meProfile, ...meProfileRest} = useMeProfile(options);
  const merchantId = useUserStore(s => s.merchantId);

  const selectedProfile = useMemo((): ProfileResponseDTO | undefined => {
    if (!meProfile?.profiles || !merchantId) {
      return undefined;
    }
    return meProfile.profiles.find(
      (profile: ProfileResponseDTO) => profile.merchantId === merchantId,
    );
  }, [meProfile?.profiles, merchantId]);

  return {
    selectedProfile,
    meProfile,
    merchantId,
    ...meProfileRest,
  };
};
