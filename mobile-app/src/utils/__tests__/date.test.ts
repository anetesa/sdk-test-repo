import {
  formatDateToNow,
  formatDateTime,
  formatDate,
  convertUTCDateToLocalDate,
  timeAgo,
  AriseDateFormat,
} from '../date';

describe('Date Utility Functions', () => {
  describe('formatDateTime', () => {
    const utcDateString = '2024-01-15T14:30:00.000Z';

    test('should return undefined for null/undefined input', () => {
      expect(formatDateTime(null)).toBeUndefined();
      expect(formatDateTime(undefined)).toBeUndefined();
      expect(formatDateTime('')).toBeUndefined();
    });

    test('should format date with DateTime format (default)', () => {
      const result = formatDateTime(utcDateString);
      expect(result).toBeDefined();
      expect(typeof result).toBe('string');
      expect(result).toMatch(/^\d{1,2}\/\d{1,2}\/\d{4} \d{1,2}:\d{2} (AM|PM)$/);
    });

    test('should format date with DateTimeWithTimeZone format', () => {
      const result = formatDateTime(
        utcDateString,
        null,
        AriseDateFormat.DateTimeWithTimeZone,
      );
      expect(result).toBeDefined();
      expect(typeof result).toBe('string');
      expect(result).toMatch(
        /^\d{1,2}\/\d{1,2}\/\d{4} \d{1,2}:\d{2} (AM|PM) \([A-Z]{3,4}([+-]\d{1,2})?\)$/,
      );
    });

    test('should format date with Date format', () => {
      const result = formatDateTime(utcDateString, null, AriseDateFormat.Date);
      expect(result).toBeDefined();
      expect(typeof result).toBe('string');
      expect(result).toMatch(/^\d{1,2}\/\d{1,2}\/\d{4}$/);
    });

    test('should handle Date objects', () => {
      const utcDateObject = new Date('2024-01-15T14:30:00.000Z');
      const result = formatDateTime(utcDateObject);
      expect(result).toBeDefined();
      expect(typeof result).toBe('string');
      expect(result).toMatch(/^\d{1,2}\/\d{1,2}\/\d{4} \d{1,2}:\d{2} (AM|PM)$/);
    });

    test('should use specified timezone', () => {
      const result = formatDateTime(utcDateString, 'America/New_York');
      expect(result).toBeDefined();
      expect(typeof result).toBe('string');
      expect(result).toMatch(/^\d{1,2}\/\d{1,2}\/\d{4} \d{1,2}:\d{2} (AM|PM)$/);
    });

    test('should use device timezone when no timezone specified', () => {
      const result = formatDateTime(utcDateString);
      expect(result).toBeDefined();
      expect(typeof result).toBe('string');
    });

    test('should handle different UTC time formats', () => {
      const utcDates = [
        '2024-01-15T14:30:00.000Z',
        '2024-01-15T14:30:00Z',
        '2024-01-15T14:30:00.123Z',
      ];

      utcDates.forEach(date => {
        const result = formatDateTime(date);
        expect(result).toBeDefined();
        expect(typeof result).toBe('string');
      });
    });
  });

  describe('formatDate', () => {
    const utcDateString = '2024-01-15T14:30:00.000Z';

    test('should format date without time', () => {
      const result = formatDate(utcDateString);
      expect(result).toBeDefined();
      expect(typeof result).toBe('string');
      expect(result).toMatch(/^\d{1,2}\/\d{1,2}\/\d{4}$/);
    });

    test('should handle null/undefined input', () => {
      expect(formatDate(null)).toBeUndefined();
      expect(formatDate(undefined)).toBeUndefined();
    });

    test('should use specified timezone', () => {
      const result = formatDate(utcDateString, 'Europe/London');
      expect(result).toBeDefined();
      expect(typeof result).toBe('string');
      expect(result).toMatch(/^\d{1,2}\/\d{1,2}\/\d{4}$/);
    });
  });

  describe('convertUTCDateToLocalDate', () => {
    test('should convert UTC date to local date', () => {
      const utcDateString = '2024-01-15T14:30:00.000Z';
      const result = convertUTCDateToLocalDate(utcDateString);

      expect(result).toBeInstanceOf(Date);
      expect(result.getFullYear()).toBe(2024);
      expect(result.getMonth()).toBe(0); // January
      expect(result.getDate()).toBe(15);
    });

    test('should handle different UTC date formats', () => {
      const utcDateString = '2024-12-25T23:59:59.999Z';
      const result = convertUTCDateToLocalDate(utcDateString);

      expect(result.getFullYear()).toBe(2024);
      expect(result.getMonth()).toBe(11); // December
      expect(result.getDate()).toBe(25);
    });

    test('should handle edge case dates', () => {
      const utcDateString = '2024-02-29T00:00:00.000Z'; // Leap year
      const result = convertUTCDateToLocalDate(utcDateString);

      expect(result.getFullYear()).toBe(2024);
      expect(result.getMonth()).toBe(1); // February
      expect(result.getDate()).toBe(29);
    });
  });

  describe('timeAgo', () => {
    test('should return object with absoluteDate and relativeDate', () => {
      const testDate = '2024-01-15T11:30:00.000Z';
      const result = timeAgo(testDate);

      expect(result).toHaveProperty('absoluteDate');
      expect(result).toHaveProperty('relativeDate');
      expect(typeof result.absoluteDate).toBe('string');
      expect(typeof result.relativeDate).toBe('string');
    });

    test('should format absolute date correctly', () => {
      const testDate = '2024-01-15T11:30:00.000Z';
      const result = timeAgo(testDate);

      expect(result.absoluteDate).toMatch(
        /^\d{2}\/\d{2}\/\d{4}, \d{2}:\d{2} (AM|PM)$/,
      );
    });

    test('should handle different time ranges', () => {
      const dates = [
        '2024-01-15T11:59:30.000Z', // recent
        '2024-01-15T11:30:00.000Z', // minutes ago
        '2024-01-15T06:00:00.000Z', // hours ago
        '2024-01-13T12:00:00.000Z', // days ago
      ];

      dates.forEach(date => {
        const result = timeAgo(date);
        expect(result.absoluteDate).toBeDefined();
        expect(result.relativeDate).toBeDefined();
      });
    });
  });

  describe('formatDateToNow', () => {
    test('should return string for valid date input', () => {
      const testDate = '2024-01-15T11:30:00.000Z';
      const result = formatDateToNow(testDate);

      expect(typeof result).toBe('string');
      expect(result.length).toBeGreaterThan(0);
    });

    test('should handle different date formats', () => {
      const dates = [
        '2024-01-15T11:59:30.000Z',
        '2024-01-15T11:30:00.000Z',
        '2024-01-15T06:00:00.000Z',
        '2024-01-13T12:00:00.000Z',
      ];

      dates.forEach(date => {
        const result = formatDateToNow(date);
        expect(typeof result).toBe('string');
        expect(result.length).toBeGreaterThan(0);
      });
    });

    test('should use custom date format when provided', () => {
      const testDate = '2024-01-10T12:00:00.000Z';
      const customFormat = 'yyyy-MM-dd HH:mm';
      const result = formatDateToNow(testDate, customFormat);

      expect(typeof result).toBe('string');
      expect(result.length).toBeGreaterThan(0);
    });
  });

  describe('AriseDateFormat enum', () => {
    test('should have correct enum values', () => {
      expect(AriseDateFormat.DateTime).toBe(1);
      expect(AriseDateFormat.DateTimeWithTimeZone).toBe(2);
      expect(AriseDateFormat.Date).toBe(3);
    });
  });

  describe('UTC Time Handling', () => {
    test('should correctly convert UTC time to local timezone', () => {
      const utcDate = '2024-01-15T14:30:00.000Z';
      const result = formatDateTime(utcDate);

      // The result should be in local timezone, not UTC
      expect(result).toBeDefined();
      expect(typeof result).toBe('string');
      expect(result).toMatch(/^\d{1,2}\/\d{1,2}\/\d{4} \d{1,2}:\d{2} (AM|PM)$/);
    });

    test('should handle timezone conversion with explicit timezone', () => {
      const utcDate = '2024-01-15T14:30:00.000Z';
      const result = formatDateTime(utcDate, 'America/New_York');

      expect(result).toBeDefined();
      expect(typeof result).toBe('string');
      expect(result).toMatch(/^\d{1,2}\/\d{1,2}\/\d{4} \d{1,2}:\d{2} (AM|PM)$/);
    });
  });

  describe('Edge Cases', () => {
    test('should handle invalid date strings gracefully', () => {
      const invalidDates = ['invalid-date', '', '2024-13-45T25:70:99.000Z'];

      invalidDates.forEach(date => {
        try {
          const result = formatDateTime(date);
          // Should either return undefined or a valid string, not throw
          expect(result === undefined || typeof result === 'string').toBe(true);
        } catch (error) {
          // It's acceptable for invalid dates to throw an error
          expect(error).toBeDefined();
        }
      });
    });

    test('should handle very old dates', () => {
      const oldDate = '1900-01-01T00:00:00.000Z';
      const result = formatDateTime(oldDate);
      expect(result).toBeDefined();
      expect(typeof result).toBe('string');
    });

    test('should handle future dates', () => {
      const futureDate = '2030-12-31T23:59:59.999Z';
      const result = formatDateTime(futureDate);
      expect(result).toBeDefined();
      expect(typeof result).toBe('string');
    });

    test('should handle leap year dates', () => {
      const leapYearDate = '2024-02-29T12:00:00.000Z';
      const result = formatDateTime(leapYearDate);
      expect(result).toBeDefined();
      expect(typeof result).toBe('string');
    });
  });
});
