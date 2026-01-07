/**
 * Utility functions for formatting addresses according to specifications
 */

interface AddressComponents {
  line1: string;
  line2?: string;
  city: string;
  state: string;
  zipCode: string;
}

/**
 * Attempts to parse a free-form address string into components
 * This is a best-effort implementation since we don't know the exact format from the API
 */
export const parseAddress = (address: string): AddressComponents | null => {
  if (!address || address.trim() === '') {
    return null;
  }

  // Clean the address
  const cleanAddress = address.trim();

  // Try to match common patterns
  // Pattern 1: "Line1, City, State ZipCode"
  // Pattern 2: "Line1, Line2, City, State ZipCode"
  // Pattern 3: "Line1\nLine2\nCity, State ZipCode" (newline separated)

  // First, try to identify state and zip code at the end
  // Common pattern: ", STATE ZIP" or ", STATE ZIPCODE"
  const stateZipPattern = /,\s*([A-Z]{2})\s+(\d{5}(?:-\d{4})?)$/i;
  const stateZipMatch = cleanAddress.match(stateZipPattern);

  if (!stateZipMatch) {
    // Fallback: return original address if we can't parse it
    return {
      line1: cleanAddress,
      city: '',
      state: '',
      zipCode: '',
    };
  }

  const state = stateZipMatch[1].toUpperCase();
  const zipCode = stateZipMatch[2];

  // Remove the state and zip from the end to get the rest
  const addressWithoutStateZip = cleanAddress
    .replace(stateZipPattern, '')
    .trim();

  // Now try to identify city (should be the last part before state)
  const parts = addressWithoutStateZip.split(',').map(part => part.trim());

  if (parts.length < 2) {
    // Not enough parts, treat everything as line1
    return {
      line1: addressWithoutStateZip,
      city: '',
      state,
      zipCode,
    };
  }

  // Last part should be city
  const city = parts[parts.length - 1];

  // Everything else is address lines
  const addressLines = parts.slice(0, -1);

  if (addressLines.length === 1) {
    // Only line1
    return {
      line1: addressLines[0],
      city,
      state,
      zipCode,
    };
  } else if (addressLines.length >= 2) {
    // line1 and line2
    return {
      line1: addressLines[0],
      line2: addressLines[1],
      city,
      state,
      zipCode,
    };
  }

  // Fallback
  return {
    line1: addressWithoutStateZip,
    city,
    state,
    zipCode,
  };
};

/**
 * Formats address components according to specifications:
 * - (if line 2 is not provided) Line 1, City, State (Short) ZipCode
 * - (if line 2 is provided) Line 1, Line 2, City, State (Short) ZipCode
 */
export const formatAddress = (components: AddressComponents): string => {
  const {line1, line2, city, state, zipCode} = components;

  if (!line1) {
    return '';
  }

  const parts = [line1];

  if (line2) {
    parts.push(line2);
  }

  if (city) {
    parts.push(city);
  }

  // Add state and zip as the final part
  if (state && zipCode) {
    parts.push(`${state} ${zipCode}`);
  } else if (state) {
    parts.push(state);
  } else if (zipCode) {
    parts.push(zipCode);
  }

  return parts.join(', ');
};

/**
 * Main function to format an address string according to specifications
 * Falls back to original address if parsing fails
 */
export const formatAddressString = (
  address: string | null | undefined,
): string => {
  if (!address) {
    return 'No address provided';
  }

  const components = parseAddress(address);

  if (!components) {
    return address;
  }

  // If we couldn't parse properly (missing required components), return original
  if (!components.line1) {
    return address;
  }

  return formatAddress(components);
};
