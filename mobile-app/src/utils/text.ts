export const formatAmountShort = (amount: number): string => {
  // Don't shorten small numbers (< 1000)
  if (amount < 1000) {
    return amount.toLocaleString('en-US', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    });
  }

  // Define thresholds and corresponding suffixes
  const tiers = [
    {threshold: 1000000000, suffix: 'B'}, // Billions
    {threshold: 1000000, suffix: 'M'}, // Millions
    {threshold: 1000, suffix: 'K'}, // Thousands
  ];

  // Find the appropriate tier by checking if we're below the next threshold
  let tier;
  for (let i = 0; i < tiers.length; i++) {
    const nextTier = tiers[i - 1];
    const currentTier = tiers[i];
    if (
      amount < (nextTier?.threshold || Infinity) &&
      amount >= currentTier.threshold
    ) {
      tier = currentTier;
      break;
    }
  }
  if (!tier) {
    return amount.toString();
  } // Fallback (shouldn't happen given above checks)

  // Calculate the scaled value
  const scaled = amount / tier.threshold;

  // If we're close to the next tier (>= 99.95% of the way there),
  // show the full number in the current tier
  const isCloseToNextTier = scaled >= 999.95;
  if (isCloseToNextTier) {
    return `${Math.floor(scaled)}\u00A0${tier.suffix}`;
  }

  // Otherwise, show one decimal place (but remove trailing .0)
  const space = '\u00A0';
  const formatted = scaled.toFixed(1).replace('.0', '');
  return `${formatted}${space}${tier.suffix}`;
};
