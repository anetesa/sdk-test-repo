/**
 * Extract a clean, user-facing message from backend validation errors.
 *
 * This is designed to work with:
 * - Axios-like errors: error.response.data (web)
 * - React Native native-module errors: error.userInfo (iOS bridge)
 * - OpenAPI runtime wrapped errors: "Client encountered ... underlying error: ..."
 *
 * The function is intentionally defensive and avoids showing native stack traces.
 */

const looksLikeNativeStackLine = (s: string): boolean =>
  /^\d+\s+\S+\.dylib\s+0x[0-9a-fA-F]+\s+/.test(s) ||
  s.includes('RCTJSErrorFromCodeMessageAndNSError');

const extractFirstArrayMessage = (input: unknown): string | undefined => {
  // Walk the object looking for any object value that is an array of strings.
  // Example backend payload:
  // { Errors: { UseCardPrice: ["CardPrice must be provided..."] }, ... }
  const seen = new Set<any>();

  const visit = (node: any, depth: number): string | undefined => {
    if (depth > 6) {
      return undefined;
    }
    if (!node || typeof node !== 'object') {
      return undefined;
    }
    if (seen.has(node)) {
      return undefined;
    }
    seen.add(node);

    if (Array.isArray(node)) {
      // Prefer the first non-empty string element in the array.
      for (const item of node) {
        if (typeof item === 'string' && item.trim().length > 0) {
          return item.trim();
        }
      }

      // Otherwise, recurse into nested objects/arrays.
      for (const item of node) {
        const found = visit(item, depth + 1);
        if (found) {
          return found;
        }
      }

      return undefined;
    }

    for (const value of Object.values(node)) {
      if (Array.isArray(value)) {
        // Prefer first non-empty string in the array (not just index 0).
        for (const item of value) {
          if (typeof item === 'string' && item.trim().length > 0) {
            return item.trim();
          }
        }
      }
    }

    for (const value of Object.values(node)) {
      const found = visit(value, depth + 1);
      if (found) {
        return found;
      }
    }

    return undefined;
  };

  return visit(input as any, 0);
};

// Exposed for unit testing; not part of the public API contract.
export const __private__ = {
  extractFirstArrayMessage,
};

const normalizeWrappedMessage = (input: string): string => {
  const trimmed = input.trim();
  if (!trimmed) {
    return trimmed;
  }

  // OpenAPI runtime can wrap errors like:
  // "Client encountered an error invoking ... underlying error: <real error>."
  const underlyingMarker = 'underlying error:';
  const underlyingIndex = trimmed.toLowerCase().indexOf(underlyingMarker);
  const candidate =
    underlyingIndex >= 0
      ? trimmed.slice(underlyingIndex + underlyingMarker.length).trim()
      : trimmed;

  // Native/SDK errors often come wrapped like:
  // "BadRequest Error: <message> (Correlation ID: ...) (Error Code: ...)"
  const badRequestPrefix = 'BadRequest Error:';
  let out = candidate.startsWith(badRequestPrefix)
    ? candidate.slice(badRequestPrefix.length).trim()
    : candidate;

  // Remove trailing metadata in parentheses.
  out = out.replace(/\s*\(Correlation ID:[^)]+\)\s*/g, ' ').trim();
  out = out.replace(/\s*\(Error Code:[^)]+\)\s*/g, ' ').trim();
  out = out.replace(/\.\s*$/, '').trim();
  out = out.replace(/\s+/g, ' ').trim();

  return out;
};

export function getBackendErrorMessage(
  error: unknown,
  fallbackMessage = 'Unable to calculate amounts. Please try again.',
): string {
  const payload = (error as any)?.response?.data ?? (error as any)?.userInfo;

  const candidateFirstArrayMessage = extractFirstArrayMessage(payload);
  if (
    typeof candidateFirstArrayMessage === 'string' &&
    candidateFirstArrayMessage.trim().length > 0 &&
    !looksLikeNativeStackLine(candidateFirstArrayMessage.trim())
  ) {
    return candidateFirstArrayMessage.trim();
  }

  const details =
    (error as any)?.userInfo?.Details ??
    (error as any)?.response?.data?.Details ??
    (error as any)?.response?.data?.details ??
    (error as any)?.message ??
    (error as any)?.localizedDescription;

  if (typeof details === 'string' && details.trim().length > 0) {
    const normalized = normalizeWrappedMessage(details);
    if (normalized && !looksLikeNativeStackLine(normalized)) {
      return normalized;
    }
  }

  return fallbackMessage;
}
