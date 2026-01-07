// @ts-ignore
import * as RNLocalize from 'react-native-localize';
import {logger} from '@/utils/logger';

// Mapping of device country codes to CloudCommerce
const COUNTRY_MAPPING: Record<string, {code: string; name: string}> = {
  US: {code: 'USA', name: 'United States'},
  CL: {code: 'CHL', name: 'Chile'},
  BR: {code: 'BRA', name: 'Brazil'},
  IN: {code: 'IND', name: 'India'},
  PL: {code: 'POL', name: 'Poland'},
  TR: {code: 'TUR', name: 'Turkey'},
  UA: {code: 'UKR', name: 'Ukraine'},
};

const FALLBACK_COUNTRY = {
  code: 'USA',
  name: 'United States',
};

/**
 * Detect country from device configuration
 */
export const detectCountryFromDevice = async (): Promise<{
  code: string;
  name: string;
  source: 'device' | 'fallback';
  confidence: 'high' | 'medium' | 'low';
}> => {
  try {
    logger.info('Starting device country detection');

    const deviceCountryCode = RNLocalize.getCountry();

    const mappedCountry =
      COUNTRY_MAPPING[deviceCountryCode] || FALLBACK_COUNTRY;

    logger.info('Device country detection completed successfully', {
      deviceCode: deviceCountryCode,
      mappedCode: mappedCountry.code,
      countryName: mappedCountry.name,
    });

    return {
      ...mappedCountry,
      source: 'device',
      confidence: 'high',
    };
  } catch (error: any) {
    logger.error('Device country detection failed', error);

    return {
      ...FALLBACK_COUNTRY,
      source: 'fallback',
      confidence: 'low',
    };
  }
};
