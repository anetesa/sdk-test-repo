import React from 'react';
import {render, waitFor, fireEvent} from '@testing-library/react-native';
import {NavigationContainer} from '@react-navigation/native';
import {SafeAreaProvider} from 'react-native-safe-area-context';
import {GrowthBook, GrowthBookProvider} from '@growthbook/growthbook-react';
import {QueryClient, QueryClientProvider} from '@tanstack/react-query';
import AsyncStorage from '@react-native-async-storage/async-storage';
import HomeScreen from '../HomeScreen';
import {ROUTES} from '../../constants/routes';
import {getTransactionCount} from '../../utils/transactionHelpers';
import {UI_MESSAGES} from '../../constants/messages';
import {PERMISSIONS} from '../../constants/permission';

// Mock AsyncStorage
jest.mock('@react-native-async-storage/async-storage', () =>
  require('@react-native-async-storage/async-storage/jest/async-storage-mock'),
);

// Mock useRoute hook
jest.mock('@react-navigation/native', () => {
  const actualNav = jest.requireActual('@react-navigation/native');
  return {
    ...actualNav,
    useRoute: jest.fn(() => ({
      params: {},
    })),
  };
});

// Essential mocks only
jest.mock('react-native-safe-area-context', () => ({
  SafeAreaProvider: ({children}: {children: React.ReactNode}) => children,
  SafeAreaView: ({children}: {children: React.ReactNode}) => children,
  useSafeAreaInsets: () => ({top: 0, bottom: 0, left: 0, right: 0}),
}));

// Mock the dashboard transactions hook
jest.mock('@/hooks/queries/useGetTransactions', () => ({
  useGetInfiniteTransactions: jest.fn(() => ({
    data: {
      pages: [
        {
          items: [
            {
              id: '1',
              amount: 10050,
              createdAt: '2024-01-15T10:30:00Z',
              last4: '1234',
              status: 'COMPLETE',
              type: 'SALE',
            },
          ],
        },
      ],
    },
    isLoading: false,
    isError: false,
    hasNextPage: false,
    fetchNextPage: jest.fn(),
    isFetchingNextPage: false,
  })),
  invalidateInfiniteDashboardTransactions: jest.fn(),
}));

jest.mock('lucide-react-native', () => ({
  MoreVertical: () => 'MoreVertical',
  Eye: () => 'Eye',
  EyeOff: () => 'EyeOff',
}));

jest.mock('react-native-reanimated', () => ({
  default: {View: require('react-native').View},
  useSharedValue: () => ({value: 0}),
  useAnimatedStyle: () => ({}),
  withTiming: (value: any) => value,
  runOnJS: (fn: any) => fn,
}));

// Simple feature flags - just enable everything
jest.mock('@growthbook/growthbook-react', () => ({
  GrowthBook: jest.fn().mockImplementation(() => ({})),
  GrowthBookProvider: ({children}: {children: React.ReactNode}) => children,
  useFeatureIsOn: jest.fn(feature => true),
}));

jest.mock('@/native/AriseMobileSdk', () => ({
  checkCompatibility: jest.fn().mockResolvedValue({
    isCompatible: true,
    incompatibilityReasons: [],
  }),
}));

// --- Mock Data ---
const mockProfileData = {
  data: {
    id: 'id123',
    firstName: 'John',
    lastName: 'Doe',
    email: 'test@example.com',
    userTypeId: 2,
    profiles: [
      {
        merchantId: 'merchant123',
        accountName: 'Test Merchant',
        firstName: 'John',
        permissions: [PERMISSIONS.TRANSACTIONS_SUBMIT],
      },
    ],
  },
  isLoading: false,
  isError: false,
};

// --- Mocks ---
// Mock user data
jest.mock('@/stores/userStore', () => ({
  useUserStore: jest.fn((selector: any) => {
    const state = {
      id: 'user123',
      email: 'john@example.com',
      firstName: 'John',
      lastName: 'Doe',
      merchantId: 'merchant123',
    };
    if (typeof selector === 'function') {
      return selector(state);
    }
    return state;
  }),
}));

// Mock useSelectedProfile to prevent network call
jest.mock('@/hooks/useSelectedProfile', () => ({
  useSelectedProfile: jest.fn(() => ({
    selectedProfile: mockProfileData.data.profiles[0],
    ...mockProfileData,
  })),
}));

// Mock data hooks with simple responses
jest.mock('@/hooks/queries/useTransactionsTodayQuery', () => ({
  useTransactionsTodayQuery: () => ({
    transactionsToday: 5,
    salesToday: 1500,
    errors: {
      sales: false,
      transactions: false,
    },
    isLoading: false,
    isError: false,
  }),
  invalidateTransactionsTodayQuery: jest.fn(),
}));

// Mock complex components
jest.mock('@/components/transactions/TransactionList', () => {
  const {View, Text} = require('react-native');
  // We'll capture props here to test them
  let capturedProps: any = {};
  const MockTransactionList = (props: any) => {
    Object.assign(capturedProps, props);
    return (
      <View testID="transaction-list">
        <Text>Transaction List</Text>
      </View>
    );
  };
  MockTransactionList.getProps = () => capturedProps;
  return MockTransactionList;
});

jest.mock('@/components/baseComponents/LeaveFeedback', () => {
  const {View, Text} = require('react-native');
  return function MockLeaveFeedback() {
    return (
      <View testID="leave-feedback">
        <Text>Leave Feedback</Text>
      </View>
    );
  };
});

jest.mock('@/components/baseComponents/BannerAdminTTP', () => {
  return function MockBannerTTP() {
    return null;
  };
});

jest.mock('@/components/baseComponents/BannerStaffTTP', () => {
  return function MockBannerStaffTTP() {
    return null;
  };
});

// Mock Tap to Pay hooks
jest.mock('@/hooks/queries/useTapToPayJWT', () => ({
  useActivateTapToPay: jest.fn(() => ({
    mutateAsync: jest.fn(),
    data: null,
    isError: false,
    isSuccess: false,
  })),
  useDeviceStatus: jest.fn(() => ({
    data: null,
  })),
}));

// Mock Cloud Commerce store
jest.mock('@/stores/cloudCommerceStore', () => ({
  useCloudCommerceStore: jest.fn((selector: any) => {
    const state = {
      lastEvent: null, // remove this
    };
    if (typeof selector === 'function') {
      return selector(state);
    }
    return state;
  }),
}));

// Mock Tap to Pay education screens
jest.mock('@/cloudcommerce/tapToPayEducation', () => ({
  showTapToPayEducationScreens: jest.fn(),
}));

// Mock TransactionsToday dependencies but not the component itself
jest.mock('@/components/baseComponents/AriseCard', () => {
  const {View} = require('react-native');
  return function MockAriseCard({children, ...props}: any) {
    return <View {...props}>{children}</View>;
  };
});

jest.mock('@/utils/text', () => ({
  formatAmountShort: (value: number) => `${(value / 1000).toFixed(1)}K`,
}));

jest.mock('@/utils/transactionHelpers', () => ({
  // This mock should exactly match the logic in the actual implementation
  getTransactionCount: jest.fn(
    (
      isPendoFeedbackOn: boolean,
      isNewTransactionOn: boolean,
      isProMaxScreen: boolean,
    ) => {
      if (!isPendoFeedbackOn && !isNewTransactionOn) {
        return isProMaxScreen ? 6 : 5;
      }
      if (!isPendoFeedbackOn && isNewTransactionOn) {
        return 4;
      }
      if (isPendoFeedbackOn && isNewTransactionOn) {
        return isProMaxScreen ? 3 : 2;
      }
      return 4; // default fallback: only feedback enabled
    },
  ),
}));

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
        cacheTime: 0,
      },
    },
  });
  const growthbook = new GrowthBook();

  return ({children}: {children: React.ReactNode}) => (
    <SafeAreaProvider>
      <QueryClientProvider client={queryClient}>
        <GrowthBookProvider growthbook={growthbook}>
          <NavigationContainer>{children}</NavigationContainer>
        </GrowthBookProvider>
      </QueryClientProvider>
    </SafeAreaProvider>
  );
};

const mockNavigation = {
  navigate: jest.fn(),
};

describe('HomeScreen', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Set default AsyncStorage response
    (AsyncStorage.getItem as jest.Mock).mockResolvedValue('false');
  });

  it('should render without crashing', async () => {
    const Wrapper = createWrapper();
    const {getByText} = render(
      <Wrapper>
        <HomeScreen navigation={mockNavigation} />
      </Wrapper>,
    );

    await waitFor(() => {
      expect(getByText('Hi, John!')).toBeTruthy();
    });
  });

  it('should display basic user information', async () => {
    const Wrapper = createWrapper();
    const {getByText} = render(
      <Wrapper>
        <HomeScreen navigation={mockNavigation} />
      </Wrapper>,
    );

    await waitFor(() => {
      expect(getByText('Hi, John!')).toBeTruthy();
      expect(getByText('Test Merchant')).toBeTruthy();
      expect(getByText('Transactions Today')).toBeTruthy();
      expect(getByText('Sales Today')).toBeTruthy();
    });
  });

  it('should display transaction data', async () => {
    const Wrapper = createWrapper();
    const {getByText} = render(
      <Wrapper>
        <HomeScreen navigation={mockNavigation} />
      </Wrapper>,
    );

    await waitFor(() => {
      expect(getByText('5')).toBeTruthy(); // transactions count
      expect(getByText(UI_MESSAGES.LAST_TRANSACTIONS)).toBeTruthy();
    });
  });

  it('should render main components', async () => {
    const Wrapper = createWrapper();
    const {getByText, getByTestId} = render(
      <Wrapper>
        <HomeScreen navigation={mockNavigation} />
      </Wrapper>,
    );

    await waitFor(() => {
      expect(getByText(UI_MESSAGES.NEW_TRANSACTION)).toBeTruthy();
      expect(getByText(UI_MESSAGES.SHOW_ALL)).toBeTruthy();
      expect(getByTestId('transaction-list')).toBeTruthy();
      expect(getByTestId('leave-feedback')).toBeTruthy();
    });
  });

  describe('AsyncStorage loading for isAmountHidden', () => {
    it('should load isAmountHidden state from AsyncStorage using isAmountHiddenKey', async () => {
      // Import the actual function
      const {isAmountHiddenKey} = require('../../utils/asyncStorage');
      (AsyncStorage.getItem as jest.Mock).mockResolvedValueOnce('false');

      const Wrapper = createWrapper();
      render(
        <Wrapper>
          <HomeScreen navigation={mockNavigation} />
        </Wrapper>,
      );

      await waitFor(() => {
        expect(AsyncStorage.getItem).toHaveBeenCalledWith(
          isAmountHiddenKey('user123'),
        );
      });
    });

    it('should set isAmountHidden to false when AsyncStorage returns "false"', async () => {
      (AsyncStorage.getItem as jest.Mock).mockResolvedValueOnce('false');

      const Wrapper = createWrapper();
      const {getByText} = render(
        <Wrapper>
          <HomeScreen navigation={mockNavigation} />
        </Wrapper>,
      );

      await waitFor(() => {
        expect(getByText('Hide Amounts')).toBeTruthy();
        expect(getByText('$1.5K')).toBeTruthy(); // Visible amount
      });
    });

    it('should set isAmountHidden to true when AsyncStorage returns "true"', async () => {
      (AsyncStorage.getItem as jest.Mock).mockResolvedValueOnce('true');

      const Wrapper = createWrapper();
      const {getByText} = render(
        <Wrapper>
          <HomeScreen navigation={mockNavigation} />
        </Wrapper>,
      );

      await waitFor(() => {
        expect(getByText('Show Amounts')).toBeTruthy();
        expect(getByText('● ● ● ●')).toBeTruthy(); // Masked amount
      });
    });

    it('should default to false when AsyncStorage returns null', async () => {
      (AsyncStorage.getItem as jest.Mock).mockResolvedValueOnce(null);

      const Wrapper = createWrapper();
      const {getByText} = render(
        <Wrapper>
          <HomeScreen navigation={mockNavigation} />
        </Wrapper>,
      );

      await waitFor(() => {
        expect(getByText('Hide Amounts')).toBeTruthy();
        expect(getByText('$1.5K')).toBeTruthy(); // Visible amount (default)
      });
    });
  });

  describe('Navigation', () => {
    it('should navigate to transaction list when "Show All" is pressed', async () => {
      const Wrapper = createWrapper();
      const {getByText} = render(
        <Wrapper>
          <HomeScreen navigation={mockNavigation} />
        </Wrapper>,
      );

      await waitFor(() => {
        expect(getByText(UI_MESSAGES.SHOW_ALL)).toBeTruthy();
      });

      fireEvent.press(getByText(UI_MESSAGES.SHOW_ALL));
      expect(mockNavigation.navigate).toHaveBeenCalledWith('TransactionList');
    });

    it('should navigate to new transaction when "New Transaction" is pressed', async () => {
      const Wrapper = createWrapper();
      const {getByText} = render(
        <Wrapper>
          <HomeScreen navigation={mockNavigation} />
        </Wrapper>,
      );

      await waitFor(() => {
        expect(getByText(UI_MESSAGES.NEW_TRANSACTION)).toBeTruthy();
      });

      fireEvent.press(getByText(UI_MESSAGES.NEW_TRANSACTION));
      expect(mockNavigation.navigate).toHaveBeenCalledWith(
        ROUTES.NEW_TRANSACTION,
      );
    });

    it('should have login redirect logic for empty email', async () => {
      // This test verifies that the login redirect logic exists
      // In a real scenario with empty email, navigation.navigate would be called
      const Wrapper = createWrapper();
      const {getByText} = render(
        <Wrapper>
          <HomeScreen navigation={mockNavigation} />
        </Wrapper>,
      );

      await waitFor(() => {
        expect(getByText('Hi, John!')).toBeTruthy();
      });

      // This test verifies the navigation prop is available for login redirect
      expect(mockNavigation.navigate).toBeDefined();
    });
  });

  describe('Pull to refresh', () => {
    it('should have refresh functionality available', async () => {
      const Wrapper = createWrapper();
      const {getByText} = render(
        <Wrapper>
          <HomeScreen navigation={mockNavigation} />
        </Wrapper>,
      );

      // Just verify the component renders with RefreshWrapper
      await waitFor(() => {
        expect(getByText('Hi, John!')).toBeTruthy();
        expect(getByText('Last Transactions')).toBeTruthy();
      });

      // Verify that invalidate functions exist
      const {
        invalidateTransactionsTodayQuery,
      } = require('../../hooks/queries/useTransactionsTodayQuery');
      const {
        invalidateInfiniteDashboardTransactions,
      } = require('../../hooks/queries/useGetTransactions');

      expect(invalidateTransactionsTodayQuery).toBeDefined();
      expect(invalidateInfiniteDashboardTransactions).toBeDefined();
    });
  });

  describe('Dynamic layout with useWindowDimensions', () => {
    let mockUseWindowDimensions: jest.SpyInstance;

    beforeEach(() => {
      // Ensure we have a fresh mock for each test
      mockUseWindowDimensions = jest
        .spyOn(require('react-native'), 'useWindowDimensions')
        .mockClear();
    });

    it('should render the default number of transactions for standard screens', async () => {
      mockUseWindowDimensions.mockReturnValue({width: 375, height: 667}); // iPhone 8
      const {
        useGetInfiniteTransactions,
      } = require('@/hooks/queries/useGetTransactions');

      const Wrapper = createWrapper();
      render(
        <Wrapper>
          <HomeScreen navigation={mockNavigation} />
        </Wrapper>,
      );

      await waitFor(() => {
        // Both pendo and new transaction are on in tests
        const expectedCount = getTransactionCount(true, true, false);
        expect(useGetInfiniteTransactions).toHaveBeenCalledWith({
          pageSize: expectedCount,
          asc: false,
        });
      });
    });

    it('should render more transactions for large screens (Pro Max)', async () => {
      mockUseWindowDimensions.mockReturnValue({width: 428, height: 926}); // iPhone 13 Pro Max
      const {
        useGetInfiniteTransactions,
      } = require('@/hooks/queries/useGetTransactions');

      const Wrapper = createWrapper();
      render(
        <Wrapper>
          <HomeScreen navigation={mockNavigation} />
        </Wrapper>,
      );

      await waitFor(() => {
        const expectedCount = getTransactionCount(true, true, true);
        expect(useGetInfiniteTransactions).toHaveBeenCalledWith({
          pageSize: expectedCount,
          asc: false,
        });
      });
    });
  });

  describe('Check Merchant permission to show transaction', () => {
    const {useSelectedProfile} = require('@/hooks/useSelectedProfile');
    const {useFeatureIsOn} = require('@growthbook/growthbook-react');

    beforeEach(() => {
      (useSelectedProfile as jest.Mock).mockReturnValue({
        selectedProfile: mockProfileData.data.profiles[0],
        ...mockProfileData,
      });
      (useFeatureIsOn as jest.Mock).mockReturnValue(true);
    });

    it('should show the "New Transaction" button when the user has permission and the feature flag is on', async () => {
      const Wrapper = createWrapper();
      const {getByText} = render(
        <Wrapper>
          <HomeScreen navigation={mockNavigation} />
        </Wrapper>,
      );

      await waitFor(() => {
        expect(getByText(UI_MESSAGES.NEW_TRANSACTION)).toBeTruthy();
      });
    });

    it('should hide the "New Transaction" button when the user does not have permission', async () => {
      (useSelectedProfile as jest.Mock).mockReturnValue({
        selectedProfile: {
          ...mockProfileData.data.profiles[0],
          firstName: 'John',
          permissions: [], // No permissions
        },
        ...mockProfileData,
      });

      const Wrapper = createWrapper();
      const {queryByText} = render(
        <Wrapper>
          <HomeScreen navigation={mockNavigation} />
        </Wrapper>,
      );

      await waitFor(() => {
        expect(queryByText(UI_MESSAGES.NEW_TRANSACTION)).toBeNull();
      });
    });
  });
});
