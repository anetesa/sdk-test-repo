import React from 'react';
import {render} from '@testing-library/react-native';
import {LogoAndTitle} from '../LogoAndTitle';

// Mock lucide-react-native icons
jest.mock('lucide-react-native', () => ({
  CircleDollarSign: 'CircleDollarSign',
  WalletCards: 'WalletCards',
}));

describe('LogoAndTitle', () => {
  describe('Icon Display', () => {
    it('should display CircleDollarSign icon when isTipEnabled is true and isSurcharge is false', () => {
      const {UNSAFE_getByType} = render(
        <LogoAndTitle isSurcharge={false} isTipEnabled={true} />,
      );

      const icon = UNSAFE_getByType('CircleDollarSign');
      expect(icon).toBeTruthy();
    });

    it('should display WalletCards icon when isSurcharge is true and isTipEnabled is false', () => {
      const {UNSAFE_getByType} = render(
        <LogoAndTitle isSurcharge={true} isTipEnabled={false} />,
      );

      const icon = UNSAFE_getByType('WalletCards');
      expect(icon).toBeTruthy();
    });

    it('should display WalletCards icon when both isSurcharge and isTipEnabled are true', () => {
      const {UNSAFE_getByType} = render(
        <LogoAndTitle isSurcharge={true} isTipEnabled={true} />,
      );

      const icon = UNSAFE_getByType('WalletCards');
      expect(icon).toBeTruthy();
    });

    it('should display WalletCards icon when both isSurcharge and isTipEnabled are false', () => {
      const {UNSAFE_getByType} = render(
        <LogoAndTitle isSurcharge={false} isTipEnabled={false} />,
      );

      const icon = UNSAFE_getByType('WalletCards');
      expect(icon).toBeTruthy();
    });
  });

  describe('Title Display - Tip Only', () => {
    it('should display "Add a Tip?" when isTipEnabled is true and isSurcharge is false', () => {
      const {getByText} = render(
        <LogoAndTitle isSurcharge={false} isTipEnabled={true} />,
      );

      expect(getByText('Add a Tip?')).toBeTruthy();
    });
  });

  describe('Title Display - Surcharge Only', () => {
    it('should display "Select the card type" when isSurcharge is true and isTipEnabled is false', () => {
      const {getByText} = render(
        <LogoAndTitle isSurcharge={true} isTipEnabled={false} />,
      );

      expect(getByText('Select the card type')).toBeTruthy();
    });
  });

  describe('Title Display - Both Enabled', () => {
    it('should display "Select the card type and tip amount" when both are true', () => {
      const {getByText} = render(
        <LogoAndTitle isSurcharge={true} isTipEnabled={true} />,
      );

      expect(getByText('Select the card type and tip amount')).toBeTruthy();
    });
  });

  describe('Title Display - Neither Enabled', () => {
    it('should display empty string when both are false', () => {
      const {queryByText} = render(
        <LogoAndTitle isSurcharge={false} isTipEnabled={false} />,
      );

      // Should not display any of the specific titles
      expect(queryByText('Add a Tip?')).toBeNull();
      expect(queryByText('Select the card type')).toBeNull();
      expect(
        queryByText('Select the card type and tip amount'),
      ).toBeNull();
    });
  });

  describe('Component Rendering', () => {
    it('should render title and icon correctly', () => {
      const {getByText, UNSAFE_getByType} = render(
        <LogoAndTitle isSurcharge={true} isTipEnabled={false} />,
      );

      // Verify title text is rendered
      expect(getByText('Select the card type')).toBeTruthy();
      
      // Verify icon is rendered
      const icon = UNSAFE_getByType('WalletCards');
      expect(icon).toBeTruthy();
    });
  });

  describe('All Possible Combinations', () => {
    const combinations = [
      {
        isSurcharge: false,
        isTipEnabled: false,
        expectedTitle: '',
        expectedIcon: 'WalletCards',
        description: 'neither enabled',
      },
      {
        isSurcharge: false,
        isTipEnabled: true,
        expectedTitle: 'Add a Tip?',
        expectedIcon: 'CircleDollarSign',
        description: 'only tip enabled',
      },
      {
        isSurcharge: true,
        isTipEnabled: false,
        expectedTitle: 'Select the card type',
        expectedIcon: 'WalletCards',
        description: 'only surcharge enabled',
      },
      {
        isSurcharge: true,
        isTipEnabled: true,
        expectedTitle: 'Select the card type and tip amount',
        expectedIcon: 'WalletCards',
        description: 'both enabled',
      },
    ];

    combinations.forEach(
      ({isSurcharge, isTipEnabled, expectedTitle, expectedIcon, description}) => {
        it(`should render correctly when ${description}`, () => {
          const {getByText, queryByText, UNSAFE_getByType} = render(
            <LogoAndTitle
              isSurcharge={isSurcharge}
              isTipEnabled={isTipEnabled}
            />,
          );

          // Check icon
          const icon = UNSAFE_getByType(expectedIcon);
          expect(icon).toBeTruthy();

          // Check title
          if (expectedTitle) {
            expect(getByText(expectedTitle)).toBeTruthy();
          } else {
            // Check that no title texts are displayed
            expect(queryByText('Add a Tip?')).toBeNull();
            expect(queryByText('Select the card type')).toBeNull();
            expect(
              queryByText('Select the card type and tip amount'),
            ).toBeNull();
          }
        });
      },
    );
  });

  describe('Accessibility', () => {
    it('should render text in accessible format', () => {
      const {getByText} = render(
        <LogoAndTitle isSurcharge={true} isTipEnabled={false} />,
      );

      const titleText = getByText('Select the card type');
      expect(titleText).toBeTruthy();
    });
  });
});

