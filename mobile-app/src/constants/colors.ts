/**
 * Color constants
 * Centralized color definitions to ensure consistency and easy theme management
 *
 * IMPORTANT: Color System Architecture
 * ====================================
 *
 * This project uses a dual color system due to React Native + NativeWind requirements:
 *
 * 1. TAILWIND COLORS (tailwind.config.js):
 *    - Used for CSS classes in JSX: className="bg-brand-main text-error-main"
 *    - Perfect for styling with NativeWind/Tailwind CSS
 *    - Example: <View className="bg-brand-main border-error-dark" />
 *
 * 2. JAVASCRIPT COLORS (this file):
 *    - Used when components require hexadecimal color values as props
 *    - Required for: color, tintColor, shadowColor, backgroundColor in style prop, etc.
 *    - Example: <Icon color={COLORS.BRAND_MAIN} /> or style={{shadowColor: COLORS.ERROR}}
 *
 * USAGE GUIDELINES:
 * - Use Tailwind classes when possible: className="text-brand-main"
 * - Use these constants for component props: color={COLORS.BRAND_MAIN}
 * - Keep both systems in sync for consistent theming
 *
 * WHY BOTH ARE NEEDED:
 * Tailwind classes work great for most styling, but React Native components often
 * need actual hex values for props like color, tintColor, shadowColor, etc.
 * This file provides those hex values while maintaining the same color palette.
 */
export const COLORS = {
  // Error and negative states
  ERROR: '#B91C1C',
  ERROR_DARK: '#991B1B',

  // Info and informational states
  INFO: '#075985',
  INFO_LIGHT: '#0284C7',
  INFO_BLUE: '#0369A1',

  // Secondary and neutral
  SECONDARY: '#6B7280',
  NEUTRAL_GRAY: '#71717A',
  GRAY_400: '#9CA3AF',
  GRAY_600: '#4B5563',
  GRAY_300: '#D1D5DB',

  // Success and positive states
  SUCCESS: '#15803D',
  SUCCESS_MAIN: '#10B981',
  SUCCESS_DARK: '#047857',

  // Warning states
  WARNING: '#A16207',
  WARNING_AMBER: '#F59E0B',

  // White and transparent
  WHITE: '#FFFFFF',
  WHITE_75: 'rgba(255, 255, 255, 0.75)',
  WHITE_60: 'rgba(255, 255, 255, 0.6)',

  // Black and shadows
  BLACK: '#000000',

  // Background colors
  BACKGROUND_WHITE: 'white', // React Native standard white background

  // Dark and background
  DARK_PRIMARY: '#122C46',
  DARK_SECONDARY: '#091E34',

  // Brand colors (from gradients and UI)
  BRAND_MAIN: '#0284C7',
  BRAND_SECONDARY: '#0369A1',
  BRAND_PRESSED_1: '#125978',
  BRAND_PRESSED_2: '#144B65',

  // Orange/Amber states
  ORANGE: '#FF9800',

  // Additional utility colors
  GREEN_500: '#10B981',
  RED_600: '#DC2626',
  BLUE_600: '#2563EB',

  // Background and border colors
  LIGHT_BLUE_BG: '#F3F8FB',
  BORDER_GRAY: '#E5E7EB',
} as const;

/**
 * Gradient color combinations
 * Pre-defined gradient combinations for consistent usage
 */
export const GRADIENT_COLORS = {
  PRIMARY: [COLORS.BRAND_MAIN, COLORS.BRAND_SECONDARY],
  PRIMARY_PRESSED: [COLORS.BRAND_PRESSED_1, COLORS.BRAND_PRESSED_2],
  BACKGROUND: [COLORS.DARK_PRIMARY, COLORS.DARK_SECONDARY],
} as const;

/**
 * Icon colors for consistent icon theming
 */
export const ICON_COLORS = {
  ERROR: COLORS.ERROR,
  SUCCESS: COLORS.SUCCESS,
  WARNING: COLORS.WARNING,
  INFO: COLORS.INFO,
  SECONDARY: COLORS.SECONDARY,
  WHITE: COLORS.WHITE,
} as const;

/**
 * Type definitions for color usage
 */
export type ColorNames = (typeof COLORS)[keyof typeof COLORS];
export type GradientNames = keyof typeof GRADIENT_COLORS;
