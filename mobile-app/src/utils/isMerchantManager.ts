import {PERMISSIONS} from '@/constants/permission';

type ProfileLike = {
  permissions?: string[] | null;
} | null;

/**
 * Single source of truth for "merchant manager" detection.
 * A merchant manager is defined as having Settings.Merchants.Write permission.
 */
export const isMerchantManagerProfile = (profile?: ProfileLike): boolean => {
  return Boolean(
    profile?.permissions?.includes(PERMISSIONS.SETTINGS_MERCHANTS_WRITE),
  );
};


