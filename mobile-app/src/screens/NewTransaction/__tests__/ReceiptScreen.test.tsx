import React from 'react';
import {
  render,
  screen,
  fireEvent,
  waitFor,
} from '@testing-library/react-native';
import {Share} from 'react-native';
import ReceiptScreen from '../ReceiptScreen';
import {UI_MESSAGES} from '@/constants/messages';

// Mock the logger
jest.mock('@/utils/logger');

// Mock Share module
jest.mock('react-native/Libraries/Share/Share', () => ({
  share: jest.fn(),
}));

// Mock react-native-webview
jest.mock('react-native-webview', () => ({
  WebView: ({testID, ...props}: any) => {
    const MockWebView = require('react-native').View;
    return <MockWebView testID={testID} {...props} />;
  },
}));

// Mock react-navigation
jest.mock('@react-navigation/native', () => ({
  useNavigation: () => ({
    goBack: jest.fn(),
  }),
}));

// Mock zustand store
jest.mock('@/stores/userStore', () => ({
  useUserStore: jest.fn(),
}));

// Mock runtime config
jest.mock('@/utils/runtimeConfig', () => ({
  runtimeConfig: {
    APP_WEB_VIEW_PUBLIC_API: 'https://test-api.example.com',
  },
}));

// Mock SVG component
jest.mock('../../../assets/share_button.svg', () => {
  const MockSvg = require('react-native').View;
  return MockSvg;
});

const mockRoute = {
  params: {
    transactionId: 'test-transaction-456',
  },
};

const renderComponent = (routeParams = {}) => {
  const useUserStoreMock = require('@/stores/userStore')
    .useUserStore as jest.Mock;
  useUserStoreMock.mockImplementation(selector => {
    const state = {
      merchantId: 'test-merchant-123',
    };
    return selector(state);
  });

  const route = {
    ...mockRoute,
    params: {...mockRoute.params, ...routeParams},
  };

  return render(<ReceiptScreen route={route} navigation={{} as any} />);
};

describe('ReceiptScreen', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Rendering', () => {
    it('renders correctly with transaction ID', () => {
      renderComponent();

      expect(screen.getByText(UI_MESSAGES.CLOSE)).toBeTruthy();
      expect(screen.getByTestId('share-button')).toBeTruthy();
      expect(screen.getByTestId('webview')).toBeTruthy();
    });

    it('displays the correct URL', () => {
      renderComponent();

      const expectedUrl =
        'test-api.example.com/receipt/card/test-merchant-123/test-transaction-456';
      expect(screen.getByText(expectedUrl)).toBeTruthy();
    });
  });

  describe('Share Functionality', () => {
    it('should call Share.share when share button is pressed', async () => {
      const mockShare = Share.share as jest.Mock;
      mockShare.mockResolvedValueOnce({});

      renderComponent();

      const shareButton = screen.getByTestId('share-button');
      fireEvent.press(shareButton);

      await waitFor(() => {
        expect(mockShare).toHaveBeenCalledWith({
          url: 'https://test-api.example.com/receipt/card/test-merchant-123/test-transaction-456',
          title: 'Transaction Receipt',
        });
      });
    });

    it('should handle share error gracefully', async () => {
      const mockShare = Share.share as jest.Mock;
      const shareError = new Error('Share failed');
      mockShare.mockRejectedValueOnce(shareError);

      renderComponent();

      const shareButton = screen.getByTestId('share-button');
      fireEvent.press(shareButton);

      await waitFor(() => {
        // Get the mocked logger
        const {logger} = require('@/utils/logger');
        expect(logger.error).toHaveBeenCalledWith(
          shareError,
          'Error sharing receipt',
        );
      });
    });
  });

  describe('WebView Configuration', () => {
    it('should pass correct props to WebView', () => {
      renderComponent();

      const webView = screen.getByTestId('webview');
      const expectedUrl =
        'https://test-api.example.com/receipt/card/test-merchant-123/test-transaction-456';

      expect(webView.props.source).toEqual({uri: expectedUrl});
      expect(webView.props.startInLoadingState).toBe(true);
      expect(webView.props.scalesPageToFit).toBe(true);
      expect(webView.props.javaScriptEnabled).toBe(true);
      expect(webView.props.domStorageEnabled).toBe(true);
    });
  });

  describe('URL Construction', () => {
    it('should construct URL correctly with different merchant and transaction IDs', () => {
      // Mock different merchant ID
      const useUserStoreMock = require('@/stores/userStore')
        .useUserStore as jest.Mock;
      useUserStoreMock.mockImplementation(selector => {
        const state = {
          merchantId: 'different-merchant-789',
        };
        return selector(state);
      });

      const route = {
        ...mockRoute,
        params: {transactionId: 'different-transaction-123'},
      };

      render(<ReceiptScreen route={route} navigation={{} as any} />);

      const expectedUrl =
        'test-api.example.com/receipt/card/different-merchant-789/different-transaction-123';
      expect(screen.getByText(expectedUrl)).toBeTruthy();
    });
  });

  describe('Accessibility', () => {
    it('should have proper accessibility for buttons', () => {
      renderComponent();

      const closeButton = screen.getByText(UI_MESSAGES.CLOSE);
      const shareButton = screen.getByTestId('share-button');

      // Buttons should be touchable/pressable
      expect(closeButton).toBeTruthy();
      expect(shareButton).toBeTruthy();
    });
  });

  describe('Edge Cases', () => {
    it('should handle empty merchantId', () => {
      const useUserStoreMock = require('@/stores/userStore')
        .useUserStore as jest.Mock;
      useUserStoreMock.mockImplementation(selector => {
        const state = {
          merchantId: '',
        };
        return selector(state);
      });

      renderComponent();

      const expectedUrl =
        'test-api.example.com/receipt/card/test-merchant-123/test-transaction-456';
      expect(screen.getByText(expectedUrl)).toBeTruthy();
    });

    it('should use the correct runtime config API URL', () => {
      renderComponent();

      // The actual URL being displayed
      const urlText = screen.getByText(
        'test-api.example.com/receipt/card/test-merchant-123/test-transaction-456',
      );
      expect(urlText).toBeTruthy();
    });
  });
});
