// Mock implementation for alertStore
export const showErrorAlert = jest.fn();
export const showSuccessAlert = jest.fn();
export const useAlertStore = jest.fn(() => ({
  alerts: [],
  showErrorAlert: jest.fn(),
  showSuccessAlert: jest.fn(),
  hideAlert: jest.fn(),
  hideAllAlerts: jest.fn(),
}));
