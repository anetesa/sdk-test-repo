import React from 'react';
import {beforeEach, describe, expect, it, jest} from '@jest/globals';
import {render, fireEvent} from '@testing-library/react-native';
import {ChooseMethod} from '../ChooseMethod';
import {NavigationContainer} from '@react-navigation/native';
import {QueryClient, QueryClientProvider} from '@tanstack/react-query';

jest.mock('../../../stores/transactionStore', () => ({
  useTransactionStore: jest.fn((selector: any) => selector({amount: 12345})),
}));

jest.mock('../../../hooks/queries/useMerchantSettings', () => ({
  useMerchantSettings: jest.fn(() => ({
    data: {
      merchantSettings: {
        tapToPay: true,
        manualEntry: true,
      },
    },
    isLoading: false,
    isError: false,
  })),
}));

jest.mock('../../../stores/userStore', () => ({
  useUserStore: jest.fn((selector: any) =>
    selector({merchantId: 'test-merchant-123'}),
  ),
}));

jest.mock('@growthbook/growthbook-react', () => ({
  useFeatureIsOn: jest.fn(() => true),
  useFeatureValue: jest.fn(() => null),
}));

jest.mock('../../../hooks/queries/usePaymentsSettings', () => ({
  usePaymentsSettings: jest.fn(() => ({
    data: {
      // Ensure Tap to Pay goes directly to LoadingTapToPay (no tips/surcharge flow)
      isTipsEnabled: false,
      zeroCostProcessingOptionId: null,
      defaultSurchargeRate: null,
      isSurchargeEnabled: false,
    },
  })),
}));

jest.mock('../../../hooks/queries/useTapToPayJWT', () => ({
  useDeviceStatus: jest.fn(() => ({
    data: {tapToPayStatus: 'Approved'},
    isActive: true,
  })),
}));

jest.mock('../../../hooks/useSelectedProfile', () => ({
  useSelectedProfile: jest.fn(() => ({
    selectedProfile: {permissions: []},
  })),
}));

jest.mock('../../../utils/logger', () => ({
  logger: {
    info: jest.fn(),
    error: jest.fn(),
    warn: jest.fn(),
    debug: jest.fn(),
  },
}));

jest.mock(
  '../../../../assets/text-cursor-input.svg',
  () => 'TextCursorInputIcon',
);

jest.mock('@/native/AriseMobileSdk', () => ({
  checkCompatibility: jest.fn(async () => ({
    isCompatible: true,
    incompatibilityReasons: [],
  })),
}));

const mockNavigate = jest.fn();

const TestWrapper = ({children}: {children: React.ReactNode}) => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
      },
    },
  });

  return (
    <QueryClientProvider client={queryClient}>
      <NavigationContainer>{children}</NavigationContainer>
    </QueryClientProvider>
  );
};

describe('ChooseMethod', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  const renderComponent = () =>
    render(
      <TestWrapper>
        <ChooseMethod navigation={{navigate: mockNavigate}} />
      </TestWrapper>,
    );

  it('should render all elements correctly', () => {
    const {getByText} = renderComponent();

    expect(getByText('New Transaction')).toBeTruthy();
    expect(getByText('Subtotal:')).toBeTruthy();
    expect(getByText('123.45')).toBeTruthy(); // Formatted amount
    expect(getByText('Select payment method')).toBeTruthy();
    expect(getByText('Manual Entry')).toBeTruthy();
    expect(getByText('Manually enter the card details')).toBeTruthy();
  });

  it('should navigate to KeyedTransaction on manual entry press', () => {
    const {getByText} = renderComponent();

    fireEvent.press(getByText('Manual Entry'));
    expect(mockNavigate).toHaveBeenCalledWith('KeyedTransaction');
  });

  it('should pass Tap to Pay transactionDetails.amount as a 2-decimal string', async () => {
    const {findByText} = renderComponent();

    // Tap to Pay option renders after async compatibility check
    const ttpButton = await findByText('Tap to Pay on iPhone');
    fireEvent.press(ttpButton);

    expect(mockNavigate).toHaveBeenCalled();
    const navigateCall = mockNavigate.mock.calls[0] as any;
    const screenName = navigateCall?.[0] as any;
    const params = navigateCall?.[1] as any;

    expect(screenName).toBeTruthy();
    expect(params?.transactionDetails).toBeTruthy();

    const {transactionDetails} = params;
    expect(typeof transactionDetails.amount).toBe('string');
    expect(transactionDetails.amount).toMatch(/^\d+\.\d{2}$/);
    expect(typeof transactionDetails.subTotal).toBe('string');
  });
});
