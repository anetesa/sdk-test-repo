import {PERMISSIONS} from '@/constants/permission';

type ProfileLike = {
  permissions?: string[] | null;
} | null;

/**
 * Single source of truth for "staff merchant" detection used by the Staff TTP banner.
 * Current business rule: staff banner applies when the user does NOT have Users.Merchants.Write.
 */
export const isStaffMerchantProfile = (profile?: ProfileLike): boolean => {
  return !Boolean(profile?.permissions?.includes(PERMISSIONS.USERS_MERCHANTS_WRITE));
};


