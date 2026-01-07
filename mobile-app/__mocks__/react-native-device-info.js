module.exports = {
  getModel: jest.fn(() => Promise.resolve('iPhone 14 Pro')),
  getDeviceId: jest.fn(() => Promise.resolve('test-device-id')),
  getSystemName: jest.fn(() => Promise.resolve('iOS')),
  getSystemVersion: jest.fn(() => Promise.resolve('16.0')),
  getVersion: jest.fn(() => Promise.resolve('1.0.0')),
  getBuildNumber: jest.fn(() => Promise.resolve('100')),
  getBundleId: jest.fn(() => Promise.resolve('com.arise.app')),
  getApplicationName: jest.fn(() => Promise.resolve('Arise')),
  getBrand: jest.fn(() => Promise.resolve('Apple')),
  getDeviceName: jest.fn(() => Promise.resolve('Test iPhone')),
  getUniqueId: jest.fn(() => Promise.resolve('unique-test-id')),
  default: {
    getModel: jest.fn(() => Promise.resolve('iPhone 14 Pro')),
  },
};
