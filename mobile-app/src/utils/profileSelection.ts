import {ProfileResponseDTO, MeProfileResponse} from '@/types/Login';
import {useUserStore} from '@/stores/userStore';
import {StatusProfile} from '@/dictionaries/statusProfile';
import {formatAddressString} from '@/utils/addressFormatter';

// Type for merchant list items (different from the existing Merchant type used for payments)
export interface MerchantListItem {
  id: string;
  name: string;
  address: string;
  isActive: boolean;
  isClosed?: boolean;
  isSuspended?: boolean;
  profile?: ProfileResponseDTO; // Reference to original profile data
}

/**
 * Profile status helper functions
 */
export const isProfileActive = (profile: ProfileResponseDTO): boolean => {
  return profile.statusId === StatusProfile.Active;
};

export const isProfileSuspended = (profile: ProfileResponseDTO): boolean => {
  return (
    profile.statusId === StatusProfile.Suspended ||
    profile.status?.toLowerCase() === 'suspended' ||
    profile.status?.toLowerCase() === 'inactive'
  );
};

export const isProfileClosed = (profile: ProfileResponseDTO): boolean => {
  return profile.statusId === StatusProfile.Closed;
};

export const isProfileAvailable = (profile: ProfileResponseDTO): boolean => {
  return isProfileActive(profile);
};

/**
 * Maps a ProfileResponseDTO to MerchantListItem for UI display
 */
export const mapProfileToMerchantItem = (
  profile: ProfileResponseDTO,
): MerchantListItem => {
  const suspended = isProfileSuspended(profile);
  const closed = isProfileClosed(profile);

  return {
    id: profile.id || '',
    name: profile.accountName || 'Unknown Merchant',
    address: formatAddressString(profile.address),
    isActive: !suspended && !closed,
    isSuspended: suspended,
    isClosed: closed,
    profile, // Keep reference to original profile for selection
  };
};

/**
 * Gets the selected profile based on the merchantId stored in userStore
 */
export const getSelectedProfile = (
  profileData: MeProfileResponse | undefined,
): ProfileResponseDTO | undefined => {
  if (!profileData?.profiles || profileData.profiles.length === 0) {
    return undefined;
  }

  const {merchantId} = useUserStore.getState();

  return profileData.profiles.find(p => p.merchantId === merchantId);
};

/**
 * Gets the selected profile ID based on the merchantId stored in userStore
 * Used for API headers
 */
export const getSelectedProfileId = (
  profileData: MeProfileResponse | undefined,
): string | undefined => {
  const selectedProfile = getSelectedProfile(profileData);
  return selectedProfile?.id;
};
