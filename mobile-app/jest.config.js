module.exports = {
  preset: 'react-native',
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
  setupFilesAfterEnv: ['./jest-setup.js'],
  transformIgnorePatterns: ['jest-runner'],
  testTimeout: 30000,
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '\\.(svg)$': '<rootDir>/__mocks__/svgMock.js',
    'react-native-keychain': '<rootDir>/__mocks__/react-native-keychain',
    '@/utils/card': '<rootDir>/__mocks__/utils/card',
    '@/cloudcommerce': '<rootDir>/__mocks__/cloudcommerce',
    '\\.(css|less)$': 'identity-obj-proxy',
  },
};
