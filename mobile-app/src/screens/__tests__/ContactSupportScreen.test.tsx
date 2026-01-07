import React from 'react';
import {render, fireEvent, act} from '@testing-library/react-native';
import ContactSupportScreen from '../ContactSupportScreen';
import GlobalAlerts from '../../components/GlobalAlerts';

// Mock the hooks
jest.mock('@/hooks/useSelectedProfile', () => ({
  useSelectedProfile: jest.fn(),
}));

// Mock react-native-safe-area-context
jest.mock('react-native-safe-area-context', () => ({
  SafeAreaView: ({children}: any) => children,
}));

// Mock react-native-clipboard
jest.mock('@react-native-clipboard/clipboard', () => ({
  setString: jest.fn(),
}));

// Mock react-native Linking
jest.mock('react-native/Libraries/Linking/Linking', () => ({
  openURL: jest.fn(() => Promise.resolve()),
}));

// Mock React Navigation
jest.mock('@react-navigation/native', () => ({
  useNavigation: jest.fn(() => ({goBack: jest.fn()})),
}));

describe('ContactSupportScreen', () => {
  const mockUseSelectedProfile =
    require('@/hooks/useSelectedProfile').useSelectedProfile;

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders loading state when profile is loading', () => {
    mockUseSelectedProfile.mockReturnValue({
      selectedProfile: null,
      meProfile: null,
      isLoading: true,
    });
    const {getByText} = render(<ContactSupportScreen />);
    expect(getByText('Loading support information...')).toBeTruthy();
  });

  it('renders support information when profile is loaded with complete profileSupport', () => {
    mockUseSelectedProfile.mockReturnValue({
      selectedProfile: {
        merchantId: 'merchant123',
        support: {
          email: 'test@example.com',
          phoneNumber: '1234567890',
          website: 'https://example.com',
        },
      },
      meProfile: {
        profiles: [
          {
            merchantId: 'merchant123',
            support: {
              email: 'test@example.com',
              phoneNumber: '1234567890',
              website: 'https://example.com',
            },
          },
        ],
        defaultSupport: {
          email: 'default@example.com',
          phoneNumber: '0987654321',
          website: 'https://default.com',
        },
      },
      isLoading: false,
    });
    const {getByText, getAllByText} = render(<ContactSupportScreen />);
    expect(getByText('Do you have any questions?')).toBeTruthy();
    expect(
      getByText('Contact us and we will be happy to help you.'),
    ).toBeTruthy();
    expect(getByText('test@example.com')).toBeTruthy();
    expect(getAllByText('+1 (123) 456-7890').length).toBeGreaterThan(0);
    expect(getByText('example.com')).toBeTruthy();
  });

  it('renders with default support when profile support is completely empty', () => {
    mockUseSelectedProfile.mockReturnValue({
      selectedProfile: {
        merchantId: 'merchant123',
        // no support field
      },
      meProfile: {
        profiles: [
          {
            merchantId: 'merchant123',
            // no support field
          },
        ],
        defaultSupport: {
          email: 'default@example.com',
          phoneNumber: '0987654321',
          website: 'https://default.com',
        },
      },
      isLoading: false,
    });
    const {getByText, getAllByText} = render(<ContactSupportScreen />);
    expect(getByText('default@example.com')).toBeTruthy();
    expect(getAllByText('+1 (098) 765-4321').length).toBeGreaterThan(0);
    expect(getByText('default.com')).toBeTruthy();
  });

  it('renders with hardcoded values when no support data is available', () => {
    mockUseSelectedProfile.mockReturnValue({
      selectedProfile: null,
      meProfile: {
        profiles: [],
        defaultSupport: null,
      },
      isLoading: false,
    });
    const {getByText, getAllByText} = render(<ContactSupportScreen />);
    expect(getByText('gatewaysupport@risewithaurora.com')).toBeTruthy();
    expect(getAllByText('+1 (833) 287-6722').length).toBeGreaterThan(0);
  });

  it('shows only email when profileSupport has only email', () => {
    mockUseSelectedProfile.mockReturnValue({
      selectedProfile: {
        merchantId: 'merchant123',
        support: {
          email: 'emailonly@example.com',
        },
      },
      meProfile: {
        profiles: [
          {
            merchantId: 'merchant123',
            support: {
              email: 'emailonly@example.com',
            },
          },
        ],
        defaultSupport: {
          email: 'default@example.com',
          phoneNumber: '0987654321',
          website: 'https://default.com',
        },
      },
      isLoading: false,
    });
    const {getByText, queryByText} = render(<ContactSupportScreen />);
    expect(getByText('emailonly@example.com')).toBeTruthy();
    expect(queryByText('Phone:')).toBeFalsy();
    expect(queryByText('Website:')).toBeFalsy();
    expect(queryByText('default@example.com')).toBeFalsy();
  });

  it('shows only phone when profileSupport has only phoneNumber', () => {
    mockUseSelectedProfile.mockReturnValue({
      selectedProfile: {
        merchantId: 'merchant123',
        support: {
          phoneNumber: '(111) 222-3333',
        },
      },
      meProfile: {
        profiles: [
          {
            merchantId: 'merchant123',
            support: {
              phoneNumber: '(111) 222-3333',
            },
          },
        ],
        defaultSupport: {
          email: 'default@example.com',
          phoneNumber: '0987654321',
          website: 'https://default.com',
        },
      },
      isLoading: false,
    });
    const {queryByText, getAllByText} = render(<ContactSupportScreen />);
    expect(getAllByText('+1 (111) 222-3333').length).toBeGreaterThan(0);
    expect(queryByText('Email:')).toBeFalsy();
    expect(queryByText('Website:')).toBeFalsy();
    expect(queryByText('default@example.com')).toBeFalsy();
  });

  it('shows only website when profileSupport has only website', () => {
    mockUseSelectedProfile.mockReturnValue({
      selectedProfile: {
        merchantId: 'merchant123',
        support: {
          website: 'https://websiteonly.com',
        },
      },
      meProfile: {
        profiles: [
          {
            merchantId: 'merchant123',
            support: {
              website: 'https://websiteonly.com',
            },
          },
        ],
        defaultSupport: {
          email: 'default@example.com',
          phoneNumber: '0987654321',
          website: 'https://default.com',
        },
      },
      isLoading: false,
    });
    const {getByText, queryByText} = render(<ContactSupportScreen />);
    expect(getByText('websiteonly.com')).toBeTruthy();
    expect(queryByText('Email:')).toBeFalsy();
    expect(queryByText('Phone:')).toBeFalsy();
    expect(queryByText('default@example.com')).toBeFalsy();
  });

  it('shows email and phone when profileSupport has email and phone but no website', () => {
    mockUseSelectedProfile.mockReturnValue({
      selectedProfile: {
        merchantId: 'merchant123',
        support: {
          email: 'emailphone@example.com',
          phoneNumber: '(111) 222-3333',
        },
      },
      meProfile: {
        profiles: [
          {
            merchantId: 'merchant123',
            support: {
              email: 'emailphone@example.com',
              phoneNumber: '(111) 222-3333',
            },
          },
        ],
        defaultSupport: {
          email: 'default@example.com',
          phoneNumber: '0987654321',
          website: 'https://default.com',
        },
      },
      isLoading: false,
    });
    const {getByText, queryByText, getAllByText} = render(
      <ContactSupportScreen />,
    );
    expect(getByText('emailphone@example.com')).toBeTruthy();
    expect(getAllByText('+1 (111) 222-3333').length).toBeGreaterThan(0);
    expect(queryByText('Website:')).toBeFalsy();
    expect(queryByText('default@example.com')).toBeFalsy();
  });

  it('shows copy to clipboard and toast for email', async () => {
    mockUseSelectedProfile.mockReturnValue({
      selectedProfile: {
        merchantId: 'merchant123',
        support: {
          email: 'copy@email.com',
        },
      },
      meProfile: {
        profiles: [
          {
            merchantId: 'merchant123',
            support: {
              email: 'copy@email.com',
            },
          },
        ],
        defaultSupport: {
          email: 'default@example.com',
          phoneNumber: '0987654321',
          website: 'https://default.com',
        },
      },
      isLoading: false,
    });

    const Clipboard = require('@react-native-clipboard/clipboard');
    const {getByTestId, queryByText} = render(
      <>
        <ContactSupportScreen />
        <GlobalAlerts />
      </>,
    );

    await act(async () => {
      fireEvent.press(getByTestId('copy-email-btn'));
    });

    expect(Clipboard.setString).toHaveBeenCalledWith('copy@email.com');
    expect(queryByText('Copied to clipboard')).toBeTruthy();
  });

  it('shows Email Us button only if email exists and opens mail app', async () => {
    mockUseSelectedProfile.mockReturnValue({
      selectedProfile: {
        merchantId: 'merchant123',
        support: {
          email: 'mailme@email.com',
        },
      },
      meProfile: {
        profiles: [
          {
            merchantId: 'merchant123',
            support: {
              email: 'mailme@email.com',
            },
          },
        ],
        defaultSupport: {
          email: 'default@example.com',
          phoneNumber: '0987654321',
          website: 'https://default.com',
        },
      },
      isLoading: false,
    });

    const Linking = require('react-native/Libraries/Linking/Linking');
    const {getByTestId} = render(<ContactSupportScreen />);

    await act(async () => {
      fireEvent.press(getByTestId('email-us-btn'));
    });

    expect(Linking.openURL).toHaveBeenCalledWith('mailto:mailme@email.com');
  });

  it('shows phone button only if phone exists and opens dialer', async () => {
    mockUseSelectedProfile.mockReturnValue({
      selectedProfile: {
        merchantId: 'merchant123',
        support: {
          phoneNumber: '(123) 456-7890',
        },
      },
      meProfile: {
        profiles: [
          {
            merchantId: 'merchant123',
            support: {
              phoneNumber: '(123) 456-7890',
            },
          },
        ],
        defaultSupport: {
          email: 'default@example.com',
          phoneNumber: '0987654321',
          website: 'https://default.com',
        },
      },
      isLoading: false,
    });

    const Linking = require('react-native/Libraries/Linking/Linking');
    const {getByTestId} = render(<ContactSupportScreen />);

    await act(async () => {
      fireEvent.press(getByTestId('phone-btn'));
    });

    expect(Linking.openURL).toHaveBeenCalledWith('tel:+1 (123) 456-7890');
  });

  it('shows website domain and opens browser', async () => {
    mockUseSelectedProfile.mockReturnValue({
      selectedProfile: {
        merchantId: 'merchant123',
        support: {
          website: 'https://affiliate.com',
        },
      },
      meProfile: {
        profiles: [
          {
            merchantId: 'merchant123',
            support: {
              website: 'https://affiliate.com',
            },
          },
        ],
        defaultSupport: {
          email: 'default@example.com',
          phoneNumber: '0987654321',
          website: 'https://default.com',
        },
      },
      isLoading: false,
    });
    const Linking = require('react-native/Libraries/Linking/Linking');
    const {getByText, getByTestId} = render(<ContactSupportScreen />);
    expect(getByText('affiliate.com')).toBeTruthy();

    await act(async () => {
      fireEvent.press(getByTestId('open-website-btn'));
    });

    expect(Linking.openURL).toHaveBeenCalledWith('https://affiliate.com');
  });
});
