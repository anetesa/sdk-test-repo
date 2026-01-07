#!/bin/bash

# Script to test CI workflow commands locally
# This mimics what happens in GitHub Actions

set -e

echo "🧪 Running tests locally (simulating CI)..."
echo ""

# Set up paths (adjust if needed)
# Script is in ios-sdk/libs/, so go up to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROJECT_PATH="$PROJECT_ROOT/ios-sdk/src/AriseMobileSdk.xcodeproj"
SCHEME="AriseMobileSdk"
DERIVED_DATA="$PROJECT_ROOT/DerivedData-Tests-Local"

# Clean derived data and old test results
echo "🧹 Cleaning derived data and old test results..."
rm -rf "$DERIVED_DATA"
rm -rf "$PROJECT_ROOT/test-results-local.xcresult"
mkdir -p "$DERIVED_DATA"

# Find available simulator using xcodebuild to get compatible destinations
echo "📱 Finding available simulator..."
echo "Getting compatible destinations from xcodebuild..."

# First, show all available destinations for debugging
echo "Available destinations:"
xcodebuild -project "$PROJECT_PATH" -scheme "$SCHEME" -showdestinations 2>/dev/null | grep -E "(platform:|name:)" || true
echo ""

# Get destinations that xcodebuild can actually use, filter for iPhone iOS Simulator only (not Mac Catalyst)
# xcodebuild will automatically select a compatible simulator based on deployment target (17.6)
DESTINATIONS=$(xcodebuild -project "$PROJECT_PATH" -scheme "$SCHEME" -showdestinations -destination "generic/platform=iOS Simulator" 2>/dev/null | grep "platform:iOS Simulator" | grep "name:iPhone" | head -1)

if [ -z "$DESTINATIONS" ]; then
  echo "⚠️  No specific iPhone simulator found, using generic iOS Simulator destination"
  # Use generic destination - xcodebuild will select a compatible simulator
  DESTINATION="platform=iOS Simulator,name=iPhone"
else
  # Extract simulator ID from destination string
  # Format: { platform:iOS Simulator, arch:arm64, id:XXXXX, OS:XX.X, name:iPhone XX }
  SIMULATOR_UDID=$(echo "$DESTINATIONS" | grep -oE 'id:[A-F0-9-]+' | cut -d: -f2 | head -1)
  SIMULATOR_NAME=$(echo "$DESTINATIONS" | grep -oE 'name:[^}]+' | cut -d: -f2 | xargs)
  
  if [ -z "$SIMULATOR_UDID" ]; then
    echo "⚠️  Could not extract simulator ID, using generic destination"
    DESTINATION="platform=iOS Simulator,name=iPhone"
  else
    echo "📱 Using simulator: $SIMULATOR_NAME ($SIMULATOR_UDID)"
    DESTINATION="platform=iOS Simulator,id=$SIMULATOR_UDID"
  fi
fi

# Run tests
echo ""
echo "🧪 Running tests..."
echo "This may take a while - compiling dependencies..."
echo ""

cd "$PROJECT_ROOT"

xcodebuild test \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "$DESTINATION" \
  -derivedDataPath "$DERIVED_DATA" \
  -enableCodeCoverage YES \
  -resultBundlePath "$PROJECT_ROOT/test-results-local.xcresult" \
  -jobs 1 \
  -maximum-concurrent-test-device-destinations 1 \
  -maximum-concurrent-test-simulator-destinations 1

echo ""
echo "✅ Tests completed!"
echo "Results saved to: $PROJECT_ROOT/test-results-local.xcresult"

