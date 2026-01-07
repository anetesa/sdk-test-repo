import {create} from 'zustand';

interface UserState {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  merchantId?: string;
}

interface UserActions {
  setUser: (user: Partial<UserState>) => void;
  reset: () => void;
}

const initialState: UserState = {
  id: '',
  email: '',
  firstName: '',
  lastName: '',
  merchantId: '',
};

export const useUserStore = create<UserState & UserActions>(set => ({
  ...initialState,
  setUser: user => set(state => ({...state, ...user})),
  reset: () => set(initialState),
}));
