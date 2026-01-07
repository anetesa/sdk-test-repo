/** @type {import('nativewind/tailwind').TailwindConfig} */
module.exports = {
  content: ['./App.{js,jsx,ts,tsx}', './src/**/*.{js,jsx,ts,tsx}'],
  theme: {
    extend: {
      fontSize: {
        '2xs': ['8px', '16px'],
      },
      textColor: {
        'text-primary': '#09090B',
        'text-secondary': '#3F3F46',
        'text-tertiary': '#71717A',
        'text-faded': '#A1A1AA',
        'text-50-alpha': '#09090B99',
        'text-brand-light': '#38BDF8',
      },
      colors: {
        icons: '#708084',
        'brand-light': '#38BDF8',
        'brand-main': '#0A6E94',
        'brand-dark': '#125978',
        'brand-darker': '#144B65',
        'brand-main-05': '#038AB70D',
        'brand-main-10': '#038AB71A',
        'brand-main-25': '#038AB73F',
        'brand-tint-1': '#00A3CC14',
        'brand-tint-2': '#00A3CC1E',
        'brand-tint-3': '#00A3CC3F',
        surface: '#FFFFFF',
        strokes: '#EBEFEF',
        'strokes-dark': '#272A2A',
        'elevation-0': '#000A0F00', // 0%
        'elevation-02': '#000A0F05', // 2%
        'elevation-04': '#000A0F0A', // 4%
        'elevation-08': '#000A0F14', // 8%
        'elevation-12': '#000A0F1F', // 12%
        'elevation-24': '#000A0F3D', // 24%
        'elevation-36': '#000A0F5C', // 36%
        'elevation-48': '#000A0F7A', // 48%
        'elevation-72': '#000A0FB8', // 72%
        'error-text': '#B20000',
        'error-1': '#FFF4F4',
        'error-2': '#FEE2E2',
        'error-3': '#FECACA',
        'error-dark': '#991B1B',
        'error-main': '#F87171',
        '_section-bg': '#262A2B',
        'success-main': '#4ADE80',
        'success-dark': '#166534',
        'success-text': '#008C32',
        'success-1': '#E9FBEF',
        'success-2': '#D3F7E0',
        'success-3': '#BDF3D1',
        'success-05': '#00EB5815',
        'success-10': '#00EB581E',
        'success-15': '#00EB5829',
        'warning-text': '#B27700',
        'warning-1': '#FFF6CC',
        'warning-2': '#FFF2B2',
        'warning-3': '#FFEE99',
        'warning-dark': '#854D0E',
        'warning-main': '#A16207',
        'warning-05': '#DB94001E',
        'warning-10': '#DB940029',
        'warning-15': '#DB940033',
        'btn-primary': '#181B1B',
        white: '#FFFFFF',
        'white-25-alpha': '#FFFFFF40',
        'section-bg': '#262A2B',
        'page-bg': '#171A1B',
        'card-100': 'rgba(255, 255, 255, 0.04)',
        'card-200': 'rgba(255, 255, 255, 0.07)',
        'surface-dark': 'rgba(30, 32, 32, 1)',
        'dark-page-bg': 'rgba(25, 25, 26, 1)',
        'dark-elavation-1': 'rgba(255, 255, 255, 0.03)',
        'elevation-1-alt': 'rgba(0, 43, 51, 0.04)',
        'deep-space': {
          50: '#C8CCD0',
          100: '#ADB3BA',
          200: '#98A3AE',
          300: '#8199B1',
          400: '#567A9F',
          500: '#2E5C8A',
          600: '#1A4775',
          700: '#123354',
          800: '#122C46',
          900: '#091E34',
          950: '#081421',
        },
        'surface-green': '#D1FADF', // Green/100
        'surface-orange': '#FFFBEB', // Yellow/50
        'surface-red': '#FEF2F2', // Red/50
        'surface-background': '#fafafa', // Gray/50
        input: '#000A0F0A', // 4% opacity
        border: '#000A0F14', // Same as elevation-08 (8%)
      },
    },
  },
  plugins: [],
};
