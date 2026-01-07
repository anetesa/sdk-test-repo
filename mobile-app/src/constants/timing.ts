/**
 * Timing and duration constants
 * Centralized timing values for animations, caching, and delays
 */

/**
 * Cache and stale times for React Query (in milliseconds)
 */
export const CACHE_TIMES = {
  // Default cache times
  DEFAULT_STALE: 900, // 900ms minimum to prevent rapid successive requests
  DEFAULT_CACHE: 10 * 60 * 1000, // 10 minutes by default

  // Profile-specific cache times
  PROFILE_STALE: 30 * 60 * 1000, // 30 minutes
  PROFILE_CACHE: 60 * 60 * 1000, // 1 hour

  // Fresh data (no cache)
  NO_CACHE: 0,
} as const;

/**
 * Animation durations (in milliseconds)
 */
export const ANIMATION_DURATIONS = {
  // UI animations
  FAST: 100,
  NORMAL: 180,
  SLOW: 300,

  // Specific animations
  SHAKE: 100, // For input validation shake
  FADE: 200, // For fade transitions
  LOGIN_LAYOUT: 1, // Login layout transitions

  // Loading states
  SPINNER: 1000, // Spinner rotation cycle
  LOGO_ANIMATION: 3000, // Logo animation cycle

  // User feedback
  TOAST: 5000, // Toast notification display time
  REFRESH_TIMEOUT: 1000, // Pull-to-refresh simulation

  // Bottom sheet
  BOTTOM_SHEET_OPEN: 500,
  BOTTOM_SHEET_CLOSE: 300,
} as const;

/**
 * Delays and timeouts (in milliseconds)
 */
export const DELAYS = {
  // Focus and input delays
  INPUT_FOCUS: 300, // Delay before focusing input
  KEYBOARD_DISMISS: 100, // Delay for keyboard dismiss

  // Navigation delays
  NAVIGATION_DELAY: 500, // Delay before navigation

  // Refresh delays
  MANUAL_REFRESH_RESET: 500, // Time to keep manual refresh indicator

  // Toast reset
  TOAST_RESET: 100, // Delay before resetting toast state
} as const;

/**
 * Pagination and data loading
 */
export const PAGINATION = {
  DEFAULT_PAGE_SIZE: 100,
  INFINITE_PAGE_SIZE: 20,
} as const;

/**
 * Time conversion utilities
 */
export const TIME_UNITS = {
  SECOND: 1000,
  MINUTE: 60 * 1000,
  HOUR: 60 * 60 * 1000,
  DAY: 24 * 60 * 60 * 1000,
} as const;

/**
 * Inactivity and session management
 */
export const SESSION_TIMING = {
  // Inactivity timeout (15 minutes)
  INACTIVITY_TIMEOUT: 15 * 60 * 1000,
  // Time tolerance for inactivity calculations (1 second)
  TIME_TOLERANCE: 1000,
  // AsyncStorage key for last activity time
  LAST_ACTIVITY_KEY: 'lastActivityTime',
} as const;

/**
 * Helper functions for time calculations
 */
export const timeHelpers = {
  /**
   * Convert minutes to milliseconds
   */
  minutesToMs: (minutes: number): number => minutes * TIME_UNITS.MINUTE,

  /**
   * Convert seconds to milliseconds
   */
  secondsToMs: (seconds: number): number => seconds * TIME_UNITS.SECOND,

  /**
   * Convert hours to milliseconds
   */
  hoursToMs: (hours: number): number => hours * TIME_UNITS.HOUR,
} as const;
