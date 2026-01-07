import {create} from 'zustand';
import {SettingsAutofill} from '@/types/SettingsAutofill';
import {TransactionSaleResponse} from '@/types/TransactionSale';

interface TransactionState {
  transactionId?: any;
  paymentType?: any;
  amount: number;
  accountNumber?: string;
  cardNumber: string;
  expDate: string;
  cvv: string;
  zipCode: string;
  securityCode?: string;
  referenceId?: string;
  customer?: {id: string; name: string};
  payLink?: string;
  binData?: number;
  response?: TransactionSaleResponse;
  status?: any;
  surchargeAmount: number;
  totalAmount: number;
  surchargeRate: number;
  paymentProcessorId: string;
  settingsAutofill: SettingsAutofill | undefined;
  useCardPrice?: boolean | undefined;
  setResponse: (response: TransactionSaleResponse) => void;
  setAmount: (amount: number) => void;
  setAccountNumber: (accountNumber: string) => void;
  setCardNumber: (cardNumber: string) => void;
  setExpDate: (expDate: string) => void;
  setCvv: (cvv: string) => void;
  setZipCode: (zipCode: string) => void;
  setSecurityCode: (securityCode: string) => void;
  setReferenceId: (referenceId: string) => void;
  setCustomer: (customer: {id: string; name: string}) => void;
  setBinData: (binData: number | undefined) => void;
  setUseCardPrice: (useCardPrice: boolean | undefined) => void;
  setPayLink: (payLink: string) => void;
  reset: () => void;
  retryTransaction: () => void;
  setSurchargeAmount: (surchargeAmount: number) => void;
  setTotalAmount: (totalAmount: number) => void;
  setSurchargeRate: (surchargeRate: number) => void;
  setPaymentProcessorId: (paymentProcessorId: string) => void;
  setSettingsAutofill: (settingsAutofill: SettingsAutofill | undefined) => void;
}

const initialState = {
  amount: 0,
  cardNumber: '',
  cvv: '',
  expDate: '',
  zipCode: '',
  binData: undefined,
  surchargeAmount: 0,
  totalAmount: 0,
  surchargeRate: 0,
  paymentProcessorId: '',
  settingsAutofill: undefined,
  response: undefined,
  useCardPrice: undefined,
};

export const useTransactionStore = create<TransactionState>(set => ({
  ...initialState,
  payLink: undefined,
  setAmount: amount => set({amount}),
  setAccountNumber: accountNumber => set({accountNumber}),
  setCardNumber: cardNumber => set({cardNumber}),
  setExpDate: expDate => set({expDate}),
  setCvv: cvv => set({cvv}),
  setZipCode: zipCode => set({zipCode}),
  setSecurityCode: securityCode => set({securityCode}),
  setReferenceId: referenceId => set({referenceId}),
  setCustomer: customer => set({customer}),
  setBinData: binData => set({binData}),
  setPayLink: payLink => set({payLink}),
  setUseCardPrice: useCardPrice => set({useCardPrice}),
  reset: () => set(initialState),
  retryTransaction: () =>
    set(state => ({...initialState, amount: state.amount})),
  setSurchargeAmount: surchargeAmount => set({surchargeAmount}),
  setTotalAmount: totalAmount => set({totalAmount}),
  setSurchargeRate: surchargeRate => set({surchargeRate}),
  setPaymentProcessorId: paymentProcessorId => set({paymentProcessorId}),
  setSettingsAutofill: settingsAutofill => set({settingsAutofill}),
  setResponse: response => set({response}),
}));
