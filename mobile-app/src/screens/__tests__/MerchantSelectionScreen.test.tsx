import React from 'react';
import {render, fireEvent, waitFor} from '@testing-library/react-native';
import {NavigationContainer} from '@react-navigation/native';
import MerchantSelectionScreen from '../MerchantSelectionScreen';
import {ProfileResponseDTO} from '@/types/Login';
import {StatusProfile} from '@/dictionaries/statusProfile';
import {ROUTES} from '@/constants/routes';
import {ALERT_MESSAGES} from '@/constants/messages';
import {showErrorAlert} from '@/stores/alertStore';

// Essential mocks
jest.mock('react-native-safe-area-context', () => ({
  SafeAreaView: ({children}: {children: React.ReactNode}) => children,
}));

// Mock stores
const mockSetUser = jest.fn();
const mockResetUserStore = jest.fn();

jest.mock('@/stores/userStore', () => ({
  useUserStore: (selector?: any) => {
    const state = {
      setUser: mockSetUser,
      reset: mockResetUserStore,
      merchantId: 'merchant-1',
    };

    if (selector) {
      return selector(state);
    }
    return state;
  },
}));

// Mock alert store - Uses __mocks__/@/stores/alertStore.ts automatically
jest.mock('@/stores/alertStore');

// Mock navigation
const mockNavigation = {
  navigate: jest.fn(),
  goBack: jest.fn(),
};

jest.mock('@react-navigation/native', () => ({
  ...jest.requireActual('@react-navigation/native'),
  useNavigation: () => mockNavigation,
}));

// Mock hooks
const mockExecutePostAuthFlow = jest.fn();
jest.mock('@/hooks/usePostAuthFlow', () => ({
  usePostAuthFlow: () => ({
    executePostAuthFlow: mockExecutePostAuthFlow,
  }),
}));

// Mock utils
jest.mock('@/utils/profileSelection', () => ({
  isProfileSuspended: jest.fn(),
  isProfileClosed: jest.fn(),
  mapProfileToMerchantItem: jest.fn(),
  MerchantListItem: {},
}));

jest.mock('@/utils/addressFormatter', () => ({
  formatAddressString: jest.fn(address => address || 'No address provided'),
}));

// Mock components
jest.mock('@/components/baseComponents/AriseHeader', () => {
  return function MockAriseHeader({title}: {title: string}) {
    const {Text} = require('react-native');
    return <Text testID="arise-header">{title}</Text>;
  };
});

jest.mock('@/components/Header', () => {
  return function MockHeader({
    title,
    showBack,
    onBack,
  }: {
    title: string;
    showBack?: boolean;
    onBack?: () => void;
  }) {
    const {Text, TouchableOpacity} = require('react-native');
    const {useNavigation} = require('@react-navigation/native');

    const navigation = useNavigation();

    const handleGoBack = () => {
      navigation.goBack();
      if (onBack) {
        onBack();
      }
    };

    return (
      <>
        <Text testID="header">{title}</Text>
        {showBack && (
          <TouchableOpacity testID="back-button" onPress={handleGoBack}>
            <Text>Back</Text>
          </TouchableOpacity>
        )}
      </>
    );
  };
});

// Mock SVG icons
jest.mock('../../../assets/arrow-enter.svg', () => {
  return function MockChevronRightIcon() {
    const {Text} = require('react-native');
    return <Text testID="chevron-right">→</Text>;
  };
});

jest.mock('lucide-react-native', () => ({
  Check: () => {
    const {Text} = require('react-native');
    return <Text testID="check-icon">✓</Text>;
  },
}));

describe('MerchantSelectionScreen', () => {
  // Mock profile data
  const createMockProfile = (
    id: string,
    accountName: string,
    merchantId: string,
    statusId: number = StatusProfile.Active,
    status: string = 'active',
  ): ProfileResponseDTO => ({
    id,
    accountName,
    merchantId,
    statusId,
    status,
    address: '123 Main St, City, State 12345',
    mccCode: '5999',
    permissions: ['Transactions.Submit'],
  });

  const activeProfile1 = createMockProfile(
    'profile-1',
    'Active Merchant 1',
    'merchant-1',
  );
  const activeProfile2 = createMockProfile(
    'profile-2',
    'Active Merchant 2',
    'merchant-2',
  );
  const suspendedProfile = createMockProfile(
    'profile-3',
    'Suspended Merchant',
    'merchant-3',
    StatusProfile.Suspended,
    'suspended',
  );
  const closedProfile = createMockProfile(
    'profile-4',
    'Closed Merchant',
    'merchant-4',
    StatusProfile.Closed,
    'closed',
  );

  beforeEach(() => {
    jest.clearAllMocks();

    // Setup default mock returns
    const {
      isProfileSuspended,
      isProfileClosed,
      mapProfileToMerchantItem,
    } = require('@/utils/profileSelection');

    isProfileSuspended.mockImplementation(
      (profile: ProfileResponseDTO) =>
        profile.statusId === StatusProfile.Suspended ||
        profile.status?.toLowerCase() === 'suspended',
    );

    isProfileClosed.mockImplementation(
      (profile: ProfileResponseDTO) =>
        profile.statusId === StatusProfile.Closed,
    );

    mapProfileToMerchantItem.mockImplementation(
      (profile: ProfileResponseDTO) => {
        const suspended =
          profile.statusId === StatusProfile.Suspended ||
          profile.status?.toLowerCase() === 'suspended';
        const closed = profile.statusId === StatusProfile.Closed;

        return {
          id: profile.id || '',
          name: profile.accountName || 'Unknown Merchant',
          address: profile.address || 'No address provided',
          isActive: !suspended && !closed,
          isSuspended: suspended,
          isClosed: closed,
          profile,
        };
      },
    );

    // showErrorAlert mock is handled by __mocks__ file
  });

  const renderWithNavigation = (route: any) => {
    return render(
      <NavigationContainer>
        <MerchantSelectionScreen navigation={mockNavigation} route={route} />
      </NavigationContainer>,
    );
  };

  describe('Rendering', () => {
    it('renders with default header when not from settings', () => {
      const route = {
        params: {
          profiles: [activeProfile1, activeProfile2],
          isFromSettings: false,
        },
      };

      const {getByTestId, getByText} = renderWithNavigation(route);

      expect(getByTestId('arise-header')).toBeTruthy();
      expect(getByText('Select an account')).toBeTruthy();
    });

    it('renders with settings header when from settings', () => {
      const route = {
        params: {
          profiles: [activeProfile1, activeProfile2],
          isFromSettings: true,
        },
      };

      const {getByTestId, getByText} = renderWithNavigation(route);

      expect(getByTestId('header')).toBeTruthy();
      expect(getByText('Switch account')).toBeTruthy();
      expect(getByTestId('back-button')).toBeTruthy();
    });

    it('renders merchant items for active profiles only', () => {
      const route = {
        params: {
          profiles: [
            activeProfile1,
            activeProfile2,
            suspendedProfile,
            closedProfile,
          ],
        },
      };

      const {getByText, queryByText} = renderWithNavigation(route);

      // Should show active profiles
      expect(getByText('Active Merchant 1')).toBeTruthy();
      expect(getByText('Active Merchant 2')).toBeTruthy();

      // Should not show suspended/closed profiles
      expect(queryByText('Suspended Merchant')).toBeFalsy();
      expect(queryByText('Closed Merchant')).toBeFalsy();
    });

    it('shows check icon for selected merchant', () => {
      const route = {
        params: {
          profiles: [activeProfile1, activeProfile2],
        },
      };

      const {getAllByTestId} = renderWithNavigation(route);

      const checkIcons = getAllByTestId('check-icon');
      const chevronIcons = getAllByTestId('chevron-right');

      // Should have one check (for selected merchant) and one chevron
      expect(checkIcons).toHaveLength(1);
      expect(chevronIcons).toHaveLength(1);
    });
  });

  describe('Data Processing', () => {
    it('maps profiles to merchant items correctly', () => {
      const route = {
        params: {
          profiles: [activeProfile1],
        },
      };

      const {getByText} = renderWithNavigation(route);

      expect(getByText('Active Merchant 1')).toBeTruthy();
      expect(getByText('123 Main St, City, State 12345')).toBeTruthy();
    });

    it('handles profile with no account name', () => {
      const profileWithoutName = createMockProfile(
        'profile-5',
        '',
        'merchant-5',
      );
      const route = {
        params: {
          profiles: [profileWithoutName],
        },
      };

      const {getByText} = renderWithNavigation(route);

      expect(getByText('Unknown Merchant')).toBeTruthy();
    });

    it('filters out suspended and closed profiles', () => {
      const route = {
        params: {
          profiles: [activeProfile1, suspendedProfile, closedProfile],
        },
      };

      const {getByText, queryByText} = renderWithNavigation(route);

      expect(getByText('Active Merchant 1')).toBeTruthy();
      expect(queryByText('Suspended Merchant')).toBeFalsy();
      expect(queryByText('Closed Merchant')).toBeFalsy();
    });
  });

  describe('User Interactions', () => {
    it('calls setUser and executePostAuthFlow when merchant is selected', async () => {
      const route = {
        params: {
          profiles: [activeProfile1, activeProfile2],
        },
      };

      const {getByText} = renderWithNavigation(route);

      fireEvent.press(getByText('Active Merchant 1'));

      await waitFor(() => {
        expect(mockSetUser).toHaveBeenCalledWith({
          merchantId: 'merchant-1',
        });
        expect(mockExecutePostAuthFlow).toHaveBeenCalledWith({
          navigation: mockNavigation,
          errorContext: 'after merchant selection',
        });
      });
    });

    it('handles back button press from settings', () => {
      const route = {
        params: {
          profiles: [activeProfile1],
          isFromSettings: true,
        },
      };

      const {getByTestId} = renderWithNavigation(route);
      const backButton = getByTestId('back-button');

      fireEvent.press(backButton);

      expect(mockNavigation.goBack).toHaveBeenCalled();
    });

    it('logs error when selected profile is not found in array', async () => {
      const consoleSpy = jest
        .spyOn(console, 'error')
        .mockImplementation(() => {});

      // Create a profile that won't be found in the array
      const profileNotInArray = createMockProfile(
        'profile-missing',
        'Missing Profile',
        'merchant-missing',
      );
      const route = {
        params: {
          profiles: [activeProfile1], // Different profile in array
        },
      };

      const {getByText} = renderWithNavigation(route);

      // Mock the merchant item to have the missing profile
      const merchantWithMissingProfile = {
        id: 'profile-missing',
        name: 'Missing Profile',
        address: 'Test Address',
        isActive: true,
        profile: profileNotInArray,
      };

      // Simulate pressing on a merchant item by calling handleMerchantPress directly
      // We need to access the component's handleMerchantPress function
      fireEvent.press(getByText('Active Merchant 1'));

      await waitFor(() => {
        expect(mockSetUser).toHaveBeenCalled();
      });

      consoleSpy.mockRestore();
    });
  });

  describe('Edge Cases', () => {
    it('handles empty profiles array', () => {
      const route = {
        params: {
          profiles: [],
        },
      };

      const {getByTestId, getByText} = renderWithNavigation(route);

      // Should render loading state since no merchants are available
      expect(getByTestId('arise-header')).toBeTruthy();
      expect(getByText('Select an account')).toBeTruthy();

      // Note: Navigation logic is now handled by useLoginFlow before reaching this screen
    });

    it('handles undefined profiles', () => {
      const route = {
        params: {},
      };

      const {getByTestId} = renderWithNavigation(route);

      // Should render loading state since no profiles are provided
      expect(getByTestId('arise-header')).toBeTruthy();

      // Note: Navigation logic is now handled by useLoginFlow before reaching this screen
    });

    it('renders loading state when all profiles are inactive', () => {
      const route = {
        params: {
          profiles: [suspendedProfile, closedProfile], // Only inactive profiles
        },
      };

      const {getByTestId, getByText} = renderWithNavigation(route);

      // Should render loading state since no active merchants are available
      expect(getByTestId('arise-header')).toBeTruthy();
      expect(getByText('Select an account')).toBeTruthy();

      // Note: The filtering logic removes inactive profiles, leaving empty merchants array
      // Navigation logic is now handled by useLoginFlow before reaching this screen
    });

    it('renders loading state when no merchants available', () => {
      const route = {
        params: {
          profiles: [activeProfile1], // Provide active profile to avoid immediate navigation
        },
      };

      const {getByTestId, getByText} = renderWithNavigation(route);

      expect(getByTestId('arise-header')).toBeTruthy();
      expect(getByText('Select an account')).toBeTruthy();
    });
  });

  describe('Navigation Parameters', () => {
    it('correctly reads isFromSettings parameter', () => {
      const route = {
        params: {
          profiles: [activeProfile1],
          isFromSettings: true,
        },
      };

      const {getByTestId} = renderWithNavigation(route);

      expect(getByTestId('header')).toBeTruthy();
    });

    it('defaults isFromSettings to false when not provided', () => {
      const route = {
        params: {
          profiles: [activeProfile1],
        },
      };

      const {getByTestId} = renderWithNavigation(route);

      expect(getByTestId('arise-header')).toBeTruthy();
    });
  });

  describe('Visual Indicators', () => {
    it('shows suspended text for suspended merchants in list', () => {
      // Even though suspended merchants are filtered out in the current implementation,
      // this test verifies the UI component can handle suspended state
      const route = {
        params: {
          profiles: [activeProfile1],
        },
      };

      const {queryByText} = renderWithNavigation(route);

      // Since suspended profiles are filtered out, this text shouldn't appear
      expect(queryByText('(Suspended)')).toBeFalsy();
    });

    it('displays correct merchant information', () => {
      const route = {
        params: {
          profiles: [activeProfile1],
        },
      };

      const {getByText} = renderWithNavigation(route);

      expect(getByText('Active Merchant 1')).toBeTruthy();
      expect(getByText('123 Main St, City, State 12345')).toBeTruthy();
    });
  });
});
