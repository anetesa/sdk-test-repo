import {create} from 'zustand';

export type AlertType = 'error' | 'success';

interface Alert {
  id: string;
  type: AlertType;
  message: string;
  isVisible: boolean;
  duration?: number;
}

interface AlertStore {
  alerts: Alert[];
  showErrorAlert: (message: string, duration?: number) => void;
  showSuccessAlert: (message: string, duration?: number) => void;
  hideAlert: (id: string) => void;
  hideAllAlerts: () => void;
}

export const useAlertStore = create<AlertStore>((set, _get) => ({
  alerts: [],

  showErrorAlert: (message: string, duration = 3000) => {
    const id = Date.now().toString();
    const newAlert: Alert = {
      id,
      type: 'error',
      message,
      isVisible: true,
      duration,
    };
    set(state => ({
      alerts: [...state.alerts, newAlert],
    }));
  },

  showSuccessAlert: (message: string, duration = 3000) => {
    const id = Date.now().toString();
    const newAlert: Alert = {
      id,
      type: 'success',
      message,
      isVisible: true,
      duration,
    };
    set(state => ({
      alerts: [...state.alerts, newAlert],
    }));
  },

  hideAlert: (id: string) => {
    set(state => ({
      alerts: state.alerts.filter(alert => alert.id !== id),
    }));
  },

  hideAllAlerts: () => {
    set({alerts: []});
  },
}));

// Global helper functions to show alerts from anywhere
export const showErrorAlert = (message: string, duration?: number) => {
  useAlertStore.getState().showErrorAlert(message, duration);
};

export const showSuccessAlert = (message: string, duration?: number) => {
  useAlertStore.getState().showSuccessAlert(message, duration);
};
