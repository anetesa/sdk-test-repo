import {
  TransactionSaleResponse,
  TransactionDetailsResponse,
  TransactionSaleError,
} from './TransactionSale';
import type {GetTransactionsResponseDTO} from '@/types/TransactionResponse';
import type {TransactionDetails} from '@/cloudcommerce';
import type {ProfileResponseDTO} from './Login';

export interface NavigationProps {
  navigation: any;
  route: {
    params?: Record<string, any>;
  };
}

export interface LoginScreenProps {
  navigation: any;
  route: {
    params?: {
      showPasswordUpdatedToast?: boolean;
    };
  };
}

export interface MFAScreenProps {
  navigation: any;
  route: {
    params?: {
      twoFactorId: string;
      methods: any[];
      userEmail: string;
      changePasswordId?: boolean;
    };
  };
}

export interface ChangePasswordScreenProps {
  navigation: any;
  route: {
    params?: {
      changePasswordId: string;
    };
  };
}

export type NewTransactionStackParamList = {
  EnterAmount:
    | {
        title?: string;
        enterAmountPrompt?: string;
        maxAmount?: number;
        defaultAmount?: string;
        continueButtonText?: string;
        continueFunction?: (amountSelected: number) => void;
        detailedAmount?: string;
      }
    | undefined;
  ChooseMethod: undefined;
  KeyedTransaction: undefined;
  LoadingTapToPay: {
    transactionDetails: TransactionDetails;
    isComingFromTapToPaySplash?: boolean;
  };
  ZCPTipsAnalysis: {
    transactionDetails: TransactionDetails;
    isSurcharge: boolean;
    isTipEnabled: boolean;
    defaultSurchargeRate?: number;
  };
  PaymentOverview: undefined;
  PaymentSuccess: {
    response: TransactionSaleResponse | undefined;
    details: TransactionDetailsResponse | undefined;
  };
  PaymentFailed: {
    response: TransactionSaleResponse | undefined;
    details: TransactionDetailsResponse | undefined;
  };
  PaymentDeclined: {
    response: TransactionSaleResponse | undefined;
    details: TransactionDetailsResponse | undefined;
  };
  PaymentReceipt: {
    transactionId?: string;
  };
  ValidationError: {
    error: TransactionSaleError | undefined;
  };
  TapToPaySplash:
    | {
        // When opened from NewTransaction flow, next_page will be a nested screen
        next_page?: keyof NewTransactionStackParamList;
        isComingFromLoginScreen?: boolean;
        transactionDetails?: TransactionDetails;
        zcp?: {
          isSurcharge: boolean;
          isTipEnabled: boolean;
          defaultSurchargeRate?: number;
        };
      }
    | undefined;
};

export type RootStackParamList = {
  Login: {showPasswordUpdatedToast?: boolean} | undefined;
  Home: {isComingFromTapToPaySplash?: boolean} | undefined;
  MFA:
    | {
        twoFactorId: string;
        methods: any[];
        userEmail: string;
        changePasswordId?: boolean;
      }
    | undefined;
  NewTransaction:
    | {
        screen: keyof NewTransactionStackParamList;
        params?: any;
      }
    | undefined;
  TransactionList: undefined;
  TransactionDetail: {
    transactionFromParams: GetTransactionsResponseDTO;
  };
  PaymentReceipt: {
    transactionId?: string;
    isACH?: boolean;
  };
  LegalInformation: undefined;
  TestMasterCartTapToPayScreen: undefined;
  PrivacyPolicy: undefined;
  TermsAndConditions: undefined;
  Settings: {isComingFromTapToPaySplash?: boolean} | undefined;
  ResetPassword: undefined;
  PasswordLinkSent: undefined;
  ContactSupport: undefined;
  UnauthenticatedContactSupport: undefined;
  ChangePassword: {changePasswordId: string} | undefined;
  ChangePasswordForm: undefined;
  MerchantSelection:
    | {profiles: ProfileResponseDTO[]; isFromSettings?: boolean}
    | undefined;
  TapToPaySplash:
    | {
        // Can route to RootStack screens (Home/Settings/etc.) OR to NewTransaction nested screens
        // (e.g. LoadingTapToPay / ZCPTipsAnalysis) depending on where the splash was opened from.
        next_page?:
          | keyof RootStackParamList
          | keyof NewTransactionStackParamList;
        isComingFromLoginScreen?: boolean;
        transactionDetails?: TransactionDetails;
        zcp?: {
          isSurcharge: boolean;
          isTipEnabled: boolean;
          defaultSurchargeRate?: number;
        };
      }
    | undefined;
};
