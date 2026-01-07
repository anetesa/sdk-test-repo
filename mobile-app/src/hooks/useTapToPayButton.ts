import {useMemo} from 'react';
import {DeviceTapToPayStatusStringEnumType} from '@/dictionaries/DeviceTapToPayStatus';

interface UseTapToPayButtonConfig {
  tapToPayStatus: DeviceTapToPayStatusStringEnumType;
  hasManagePermission: boolean;
  isIOSVersionSupported: boolean;
  isLoadingCloudCommerce: boolean;
  isPreparedCloudCommerce: boolean;
}

export type ButtonVariant = 'request' | 'requested' | 'enable' | 'enabled';

interface TapToPayButtonState {
  label: string;
  variant: ButtonVariant;
  isDisabled: boolean;
  isGhostState: boolean;
  onPress: () => void;
}

/**
 * Custom hook to handle Tap to Pay button logic
 * Encapsulates all business rules for button state, label, and behavior
 */
export const useTapToPayButton = (
  config: UseTapToPayButtonConfig,
  onRequestPress: () => void,
  onEnablePress: () => void,
): TapToPayButtonState => {
  const {
    tapToPayStatus,
    hasManagePermission,
    isIOSVersionSupported,
    isLoadingCloudCommerce,
    isPreparedCloudCommerce,
  } = config;

  return useMemo(() => {
    // Determine button variant based on TTP status and user permission
    const getButtonVariant = (): ButtonVariant => {
      // Users WITH "Manage merchant settings" permission:
      // Only see "Enable" or "Enabled" (simplified flow)
      if (hasManagePermission) {
        return tapToPayStatus === DeviceTapToPayStatusStringEnumType.Active
          ? 'enabled'
          : 'enable';
      }

      // Users WITHOUT "Manage merchant settings" permission:
      // See all states and can request TTP
      switch (tapToPayStatus) {
        case DeviceTapToPayStatusStringEnumType.Inactive:
        case DeviceTapToPayStatusStringEnumType.Denied:
          return 'request';
        case DeviceTapToPayStatusStringEnumType.Requested:
          return 'requested';
        case DeviceTapToPayStatusStringEnumType.Approved:
          return 'enable';
        case DeviceTapToPayStatusStringEnumType.Active:
          return 'enabled';
        default:
          return 'request';
      }
    };

    // Get button label based on variant
    const getButtonLabel = (variant: ButtonVariant): string => {
      const labels: Record<ButtonVariant, string> = {
        request: 'Request',
        requested: 'Requested',
        enable: 'Enable',
        enabled: 'Enabled',
      };
      return labels[variant];
    };

    // Determine if button should be disabled
    const isButtonDisabled = (variant: ButtonVariant): boolean => {
      // Ghost states are always disabled
      if (variant === 'requested' || variant === 'enabled') {
        return true;
      }

      // Disable Enable button if iOS version not supported
      if (variant === 'enable' && !isIOSVersionSupported) {
        return true;
      }

      // Disable if CloudCommerce is loading or prepared
      if (isLoadingCloudCommerce || isPreparedCloudCommerce) {
        return true;
      }

      return false;
    };

    // Determine button press handler
    const getButtonPressHandler = (variant: ButtonVariant) => {
      switch (variant) {
        case 'request':
          return onRequestPress;
        case 'enable':
          return onEnablePress;
        case 'requested':
        case 'enabled':
        default:
          return () => {}; // No-op for disabled states
      }
    };

    const variant = getButtonVariant();
    const isGhost = variant === 'requested' || variant === 'enabled';

    return {
      label: getButtonLabel(variant),
      variant,
      isDisabled: isButtonDisabled(variant),
      isGhostState: isGhost,
      onPress: getButtonPressHandler(variant),
    };
  }, [
    tapToPayStatus,
    hasManagePermission,
    isIOSVersionSupported,
    isLoadingCloudCommerce,
    isPreparedCloudCommerce,
    onRequestPress,
    onEnablePress,
  ]);
};

/**
 * Hook to determine visibility of TapToPayItem component
 *
 * Visibility rules:
 * - Feature flag must be enabled
 * - Not loading
 * - User has "Manage merchant settings" permission (can always see it)
 * - OR User does not have permission but device TTP Status = Approved, Active, Requested, Inactive, or Denied
 *   (allowing users to request TTP even without permission)
 */
export const useTapToPayItemVisibility = (
  isTapToPayFeatureEnabled: boolean,
  hasManagePermission: boolean,
  tapToPayStatus: DeviceTapToPayStatusStringEnumType | undefined,
  isLoading: boolean,
  isCheckingVersion: boolean,
): boolean => {
  return useMemo(() => {
    if (!isTapToPayFeatureEnabled || isLoading || isCheckingVersion) {
      return false;
    }

    // Show if user has manage permission
    if (hasManagePermission) {
      return true;
    }

    // Show if user does not have permission but wants to request TTP or device has been approved
    // This includes: Inactive, Denied (can request), Requested (waiting), Approved, Active (approved/active)
    const canSeeWithoutPermission =
      tapToPayStatus === DeviceTapToPayStatusStringEnumType.Inactive ||
      tapToPayStatus === DeviceTapToPayStatusStringEnumType.Denied ||
      tapToPayStatus === DeviceTapToPayStatusStringEnumType.Requested ||
      tapToPayStatus === DeviceTapToPayStatusStringEnumType.Approved ||
      tapToPayStatus === DeviceTapToPayStatusStringEnumType.Active;

    return canSeeWithoutPermission;
  }, [
    isTapToPayFeatureEnabled,
    hasManagePermission,
    tapToPayStatus,
    isLoading,
    isCheckingVersion,
  ]);
};
