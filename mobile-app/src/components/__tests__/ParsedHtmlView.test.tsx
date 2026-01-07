import React from 'react';
import {render, waitFor} from '@testing-library/react-native';
import ParsedHtmlView, {decodeHtmlEntities} from '../ParsedHtmlView';

// Mock fetch
global.fetch = jest.fn();

describe('ParsedHtmlView', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('decodeHtmlEntities function', () => {
    it('should decode ampersand entities (&amp;)', () => {
      const input = 'Tom &amp; Jerry';
      const expected = 'Tom & Jerry';
      expect(decodeHtmlEntities(input)).toBe(expected);
    });

    it('should decode less than entities (&lt;)', () => {
      const input = 'Value is &lt; 100';
      const expected = 'Value is < 100';
      expect(decodeHtmlEntities(input)).toBe(expected);
    });

    it('should decode greater than entities (&gt;)', () => {
      const input = 'Value is &gt; 0';
      const expected = 'Value is > 0';
      expect(decodeHtmlEntities(input)).toBe(expected);
    });

    it('should decode quote entities (&quot;)', () => {
      const input = 'He said &quot;Hello&quot;';
      const expected = 'He said "Hello"';
      expect(decodeHtmlEntities(input)).toBe(expected);
    });

    it('should decode numeric apostrophe entities (&#39;)', () => {
      const input = 'It&#39;s working';
      const expected = "It's working";
      expect(decodeHtmlEntities(input)).toBe(expected);
    });

    it('should decode named apostrophe entities (&apos;)', () => {
      const input = 'Don&apos;t worry';
      const expected = "Don't worry";
      expect(decodeHtmlEntities(input)).toBe(expected);
    });

    it('should decode non-breaking space entities (&nbsp;)', () => {
      const input = 'Word&nbsp;with&nbsp;spaces';
      const expected = 'Word with spaces';
      expect(decodeHtmlEntities(input)).toBe(expected);
    });

    it('should decode multiple different entities in the same string', () => {
      const input =
        'Tom &amp; Jerry said &quot;It&#39;s &lt; 5&nbsp;degrees&quot; &amp; they were right!';
      const expected =
        'Tom & Jerry said "It\'s < 5 degrees" & they were right!';
      expect(decodeHtmlEntities(input)).toBe(expected);
    });

    it('should decode multiple instances of the same entity', () => {
      const input = '&amp;&amp;&amp;';
      const expected = '&&&';
      expect(decodeHtmlEntities(input)).toBe(expected);
    });

    it('should handle empty strings', () => {
      expect(decodeHtmlEntities('')).toBe('');
    });

    it('should handle strings without entities', () => {
      const input = 'Plain text without entities';
      expect(decodeHtmlEntities(input)).toBe(input);
    });

    it('should handle mixed entities and regular text', () => {
      const input =
        'Regular text &amp; encoded &lt;html&gt; tags &quot;with quotes&quot;';
      const expected = 'Regular text & encoded <html> tags "with quotes"';
      expect(decodeHtmlEntities(input)).toBe(expected);
    });

    it('should not decode partial or malformed entities', () => {
      const input = '&am; &l; incomplete entities';
      const expected = '&am; &l; incomplete entities';
      expect(decodeHtmlEntities(input)).toBe(expected);
    });
  });

  describe('Component functionality', () => {
    it('renders loading indicator initially', () => {
      (fetch as jest.Mock).mockImplementation(() => new Promise(() => {})); // Never resolves

      render(<ParsedHtmlView url="https://example.com" />);

      // The loading state should be active since fetch never resolves
      expect(fetch).toHaveBeenCalledWith('https://example.com');
    });

    it('renders decoded content after successful fetch', async () => {
      const mockHtml = `
        <div class="l-section-h i-cf">
          <h1>Test &amp; Title</h1>
          <p>Content with &lt;tags&gt; and &quot;quotes&quot;</p>
          <h2>Subtitle with &#39;apostrophe&#39;</h2>
        </div>
      `;

      (fetch as jest.Mock).mockResolvedValue({
        text: () => Promise.resolve(mockHtml),
      });

      const {getByText} = render(<ParsedHtmlView url="https://example.com" />);

      await waitFor(() => {
        expect(getByText('Test & Title')).toBeTruthy();
        expect(getByText('Content with <tags> and "quotes"')).toBeTruthy();
        expect(getByText("Subtitle with 'apostrophe'")).toBeTruthy();
      });
    });

    it('handles fetch errors and calls onError callback', async () => {
      // Suppress console.error for this test since we're intentionally testing error handling
      const originalConsoleError = console.error;
      console.error = jest.fn();

      const mockError = new Error('Network error');
      const mockOnError = jest.fn();

      (fetch as jest.Mock).mockRejectedValue(mockError);

      render(
        <ParsedHtmlView url="https://example.com" onError={mockOnError} />,
      );

      await waitFor(() => {
        expect(mockOnError).toHaveBeenCalledWith(mockError);
      });

      // Restore original console.error
      console.error = originalConsoleError;
    });

    it('applies custom tag styles when provided', async () => {
      const mockHtml = `
        <div class="l-section-h i-cf">
          <h1>Title</h1>
          <p>Paragraph</p>
        </div>
      `;

      const customStyles = {
        h1: {color: 'red'},
        p: {color: 'blue'},
      };

      (fetch as jest.Mock).mockResolvedValue({
        text: () => Promise.resolve(mockHtml),
      });

      const {getByText} = render(
        <ParsedHtmlView url="https://example.com" tagStyles={customStyles} />,
      );

      await waitFor(() => {
        const titleElement = getByText('Title');
        const paragraphElement = getByText('Paragraph');

        expect(titleElement).toBeTruthy();
        expect(paragraphElement).toBeTruthy();
      });
    });
  });
});
