/**
 * Dimensions and layout constants
 * Centralized dimension values for consistent spacing and sizing
 */

/**
 * Icon and visual element sizes
 */
export const ICON_SIZES = {
  // Container sizes
  LARGE_CONTAINER: 96, // Large circular icon containers

  // Icon sizes
  SPINNER_SIZE: 48, // Loading spinner size
} as const;

/**
 * Section and container heights
 */
export const SECTION_HEIGHTS = {
  PAYMENT_OVERVIEW: 320, // Main payment overview section
  PAYMENT_SUCCESS_OVERVIEW: 393, // Main payment overview section
  BUTTON_CONTAINER: 196, // Bottom button container
} as const;

/**
 * Button dimensions
 */
export const BUTTON_DIMENSIONS = {
  HEIGHT: 56, // Standard button height
} as const;

/**
 * Spacing and padding values
 */
export const SPACING = {
  // Vertical spacing
  ROW_PADDING: 10, // Vertical padding for row items

  // Standard spacing increments
  SMALL: 8,
  MEDIUM: 16,
  LARGE: 24,
  EXTRA_LARGE: 32,
} as const;

/**
 * Shadow and elevation properties
 */
export const SHADOW_PROPERTIES = {
  ELEVATION: 1,
  SHADOW_RADIUS: 4,
  SHADOW_OPACITY: 0.15,
  SHADOW_OFFSET: {
    width: 0,
    height: 1,
  },
} as const;

/**
 * Combined dimensions for common UI patterns
 */
export const UI_PATTERNS = {
  // Icon container pattern (circular with icon inside)
  ICON_CONTAINER: {
    SIZE: ICON_SIZES.LARGE_CONTAINER,
    BORDER_RADIUS: ICON_SIZES.LARGE_CONTAINER / 2, // Circular
  },

  // Button pattern
  STANDARD_BUTTON: {
    HEIGHT: BUTTON_DIMENSIONS.HEIGHT,
    BORDER_RADIUS: 16, // 2xl in Tailwind
  },
} as const;

/**
 * Type definitions for dimension usage
 */
export type IconSizes = (typeof ICON_SIZES)[keyof typeof ICON_SIZES];
export type SectionHeights =
  (typeof SECTION_HEIGHTS)[keyof typeof SECTION_HEIGHTS];
export type SpacingValues = (typeof SPACING)[keyof typeof SPACING];
