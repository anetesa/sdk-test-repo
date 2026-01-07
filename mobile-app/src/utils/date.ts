import {
  differenceInSeconds,
  formatDistanceToNow,
  format as formatFn,
} from 'date-fns';
import {formatInTimeZone} from 'date-fns-tz';

export const wait = (ms: number) =>
  new Promise(resolve => setTimeout(resolve, ms));

enum SECONDS_BREAKPOINTS {
  NOW = 60,
  HOUR = 3600,
  DAY = 86400,
}

export const formatDateToNow = (
  date: string,
  dateFormat = 'MM.dd.yyyy h:mmaaa',
): string => {
  const DIFF_IN_SECONDS = differenceInSeconds(new Date(), new Date(date));

  if (DIFF_IN_SECONDS < SECONDS_BREAKPOINTS.NOW) {
    return 'now';
  } else if (DIFF_IN_SECONDS < SECONDS_BREAKPOINTS.HOUR) {
    return formatDistanceToNow(new Date(date), {addSuffix: true});
  } else if (DIFF_IN_SECONDS < SECONDS_BREAKPOINTS.DAY) {
    return formatDistanceToNow(new Date(date), {addSuffix: true}).replace(
      'about',
      '',
    );
  }

  return formatFn(new Date(date), dateFormat);
};

export enum AriseDateFormat {
  DateTime = 1,
  DateTimeWithTimeZone = 2,
  Date = 3,
}

const AriseDateFormatsMap = {
  [AriseDateFormat.DateTime]: 'P p', // example: 7/8/2025 12:00 AM
  [AriseDateFormat.DateTimeWithTimeZone]: 'P p (z)', // example: 7/8/2025 12:00 AM GMT+3
  [AriseDateFormat.Date]: 'P', // example: 7/8/2025
};

export const formatDateTime = (
  date?: string | Date | null,
  timeZone?: string | null, // by default it will use the device's timezone
  format: AriseDateFormat = AriseDateFormat.DateTime, // if you want to see something like GMT+3 use the param "P p (z)" AriseDateFormat.DateTimeWithTimeZone
) => {
  if (!date) {
    return undefined;
  }

  return formatInTimeZone(
    date,
    timeZone || Intl.DateTimeFormat().resolvedOptions().timeZone,
    AriseDateFormatsMap[format],
  );
};

export const formatDate = (
  date?: string | Date | null,
  timeZone?: string | null,
) => formatDateTime(date, timeZone, AriseDateFormat.Date);

// Format absolute date as mm/dd/yyyy HH:MM AM/PM
const formatDateAbsolute = (date: Date): string => {
  const options: Intl.DateTimeFormatOptions = {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    hour12: true,
  };
  return date.toLocaleString('en-US', options);
};

export const convertUTCDateToLocalDate = (value: string): Date => {
  const date = new Date(value);
  const utcYear = date.getUTCFullYear();
  const utcMonth = date.getUTCMonth();
  const utcDay = date.getUTCDate();

  return new Date(utcYear, utcMonth, utcDay);
};

export const timeAgo = (isoDate: string) => {
  const date = new Date(isoDate);
  const now = new Date();
  const difference = now.getTime() - date.getTime();
  const seconds = Math.floor(difference / 1000);
  const minutes = Math.floor(seconds / 60);
  const hours = Math.floor(minutes / 60);
  const days = Math.floor(hours / 24);

  const absoluteDate = formatDateAbsolute(date);
  let relativeDate;

  if (days >= 1) {
    // Show absolute date if more than 24 hours
    relativeDate = absoluteDate; // Return absolute date for more than 24 hours
  } else if (hours > 0) {
    // Show relative time for hours
    relativeDate = `${hours} hour${hours > 1 ? 's' : ''} ago`;
  } else if (minutes > 0) {
    // Show relative time for minutes
    relativeDate = `${minutes} minute${minutes > 1 ? 's' : ''} ago`;
  } else {
    // Show relative time for seconds
    relativeDate = `${seconds} second${seconds > 1 ? 's' : ''} ago`;
  }

  return {
    absoluteDate,
    relativeDate,
  };
};
