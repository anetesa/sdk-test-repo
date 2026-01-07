#!/bin/bash

# Script to run tests in CI environment
# This script provides better logging and progress tracking for CI

set -e

echo "🧪 Running tests in CI environment..."
echo ""

# Set up paths
# Script is in ios-sdk/libs/, so go up to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROJECT_PATH="$PROJECT_ROOT/ios-sdk/src/AriseMobileSdk.xcodeproj"
SCHEME="AriseMobileSdk"

# Allow overriding DerivedData path for local testing
# In CI: uses DerivedData-Tests
# Locally: can use DerivedData-Tests-Local via DERIVED_DATA_OVERRIDE env var
DERIVED_DATA="${DERIVED_DATA_OVERRIDE:-$PROJECT_ROOT/DerivedData-Tests}"

# Change to project root for relative paths
cd "$PROJECT_ROOT"

# Clean derived data (but keep cached dependencies if available)
echo "🧹 Preparing test environment..."

# Check if precompiled SourcePackages exist in repository
REPO_SOURCE_PACKAGES="$PROJECT_ROOT/ios-sdk/libs/SourcePackages"
if [ -d "$REPO_SOURCE_PACKAGES" ]; then
  echo "📦 Found precompiled SourcePackages in repository, using them..."
  # Copy precompiled SourcePackages to DerivedData
  mkdir -p "$DERIVED_DATA"
  if [ ! -d "$DERIVED_DATA/SourcePackages" ] || [ "$REPO_SOURCE_PACKAGES" -nt "$DERIVED_DATA/SourcePackages" ]; then
    echo "📦 Copying precompiled SourcePackages to DerivedData..."
    rm -rf "$DERIVED_DATA/SourcePackages"
    cp -R "$REPO_SOURCE_PACKAGES" "$DERIVED_DATA/SourcePackages"
  fi
fi

if [ -d "$DERIVED_DATA" ]; then
  echo "📦 Found existing DerivedData, keeping cached dependencies..."
  # Only clean test-specific artifacts, keep SourcePackages and compiled modules
  rm -rf "$DERIVED_DATA/Build/Products/Debug-iphonesimulator/AriseMobileSdkTests.xctest" 2>/dev/null || true
  rm -rf "$DERIVED_DATA/Build/Intermediates.noindex/AriseMobileSdk.build" 2>/dev/null || true
  # Keep SourcePackages for faster dependency resolution
  # Keep ModuleCache if it exists (can speed up compilation)
  # Only clean module cache if it's causing issues
  if [ -d "$DERIVED_DATA/ModuleCache.noindex" ] && [ "$(find "$DERIVED_DATA/ModuleCache.noindex" -type f | wc -l)" -gt 10000 ]; then
    echo "🧹 Cleaning large module cache to prevent compilation hangs..."
    rm -rf "$DERIVED_DATA/ModuleCache.noindex" 2>/dev/null || true
  fi
  # Keep SwiftExplicitPrecompiledModules if they exist (can speed up compilation)
else
  mkdir -p "$DERIVED_DATA"
fi

# Clean old test results bundle
# Note: xcresult is a directory, not a file
if [ -d "$PROJECT_ROOT/test-results.xcresult" ] || [ -f "$PROJECT_ROOT/test-results.xcresult" ]; then
  echo "🧹 Cleaning old test results bundle..."
  rm -rf "$PROJECT_ROOT/test-results.xcresult"
fi

# Find available simulator using xcodebuild to get compatible destinations
echo "📱 Finding compatible simulator..."
echo "Getting compatible destinations from xcodebuild..."

# First, show all available destinations for debugging
echo "Available destinations:"
xcodebuild -project "$PROJECT_PATH" -scheme "$SCHEME" -showdestinations 2>&1 | grep -E "(platform:|name:)" || true
echo ""

# Get destinations that xcodebuild can actually use, filter for iPhone iOS Simulator only (not Mac Catalyst)
# Don't use -destination flag with -showdestinations, it filters results incorrectly
# Use 2>&1 to capture both stdout and stderr, then filter
echo "🔍 Searching for iPhone simulators in destinations..."
DESTINATIONS=$(xcodebuild -project "$PROJECT_PATH" -scheme "$SCHEME" -showdestinations 2>&1 | grep "platform:iOS Simulator" | grep "name:iPhone" || true)

if [ -n "$DESTINATIONS" ]; then
  DESTINATION_COUNT=$(echo "$DESTINATIONS" | wc -l | xargs)
  echo "✅ Found $DESTINATION_COUNT iPhone simulator destination(s)"
else
  echo "⚠️  No iPhone simulators found in xcodebuild destinations"
fi

if [ -z "$DESTINATIONS" ]; then
  echo "⚠️  No specific iPhone simulator found in destinations"
  echo "Attempting to list available simulators using xcrun simctl..."
  
  # First, check for booted simulators (these are most likely to work)
  BOOTED_SIMULATORS=$(xcrun simctl list devices 2>/dev/null | grep "iPhone" | grep "Booted" || true)
  
  if [ -n "$BOOTED_SIMULATORS" ]; then
    echo "✅ Found booted iPhone simulators:"
    echo "$BOOTED_SIMULATORS"
    echo ""
    # Extract first booted simulator ID
    BOOTED_SIMULATOR_ID=$(echo "$BOOTED_SIMULATORS" | head -1 | grep -oE '[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}' | head -1)
    if [ -n "$BOOTED_SIMULATOR_ID" ]; then
      echo "📱 Using booted simulator: $BOOTED_SIMULATOR_ID"
      DESTINATION="platform=iOS Simulator,id=$BOOTED_SIMULATOR_ID"
    else
      echo "⚠️  Could not extract booted simulator ID, trying available simulators..."
      AVAILABLE_SIMULATORS=$(xcrun simctl list devices available 2>/dev/null | grep "iPhone" || true)
      if [ -n "$AVAILABLE_SIMULATORS" ]; then
        echo "Available iPhone simulators:"
        echo "$AVAILABLE_SIMULATORS"
        echo ""
        echo "Using generic iOS Simulator destination - xcodebuild will select one automatically"
        DESTINATION="platform=iOS Simulator,name=iPhone"
      else
        echo "Trying generic destination as fallback..."
        DESTINATION="platform=iOS Simulator,name=iPhone"
      fi
    fi
  else
    # Try to list available simulators
    AVAILABLE_SIMULATORS=$(xcrun simctl list devices available 2>/dev/null | grep "iPhone" || true)
    
    if [ -n "$AVAILABLE_SIMULATORS" ]; then
      echo "Available iPhone simulators:"
      echo "$AVAILABLE_SIMULATORS"
      echo ""
      echo "⚠️  Simulators exist but not showing in xcodebuild destinations"
      echo "Using generic iOS Simulator destination - xcodebuild will select one automatically"
      DESTINATION="platform=iOS Simulator,name=iPhone"
    else
      echo "❌ No iPhone simulators found at all"
      echo "This might be a CI environment issue - simulators may need to be booted first"
      echo "Trying generic destination as fallback..."
      DESTINATION="platform=iOS Simulator,name=iPhone"
    fi
  fi
else
  echo "✅ Found iPhone simulators in destinations"
  echo "Destinations (showing first 5):"
  echo "$DESTINATIONS" | head -5
  echo ""
  
  # Extract first iPhone simulator ID (prefer newer OS versions)
  # Format: { platform:iOS Simulator, arch:arm64, id:XXXXX, OS:XX.X, name:iPhone XX }
  # Try to extract ID directly using regex
  SIMULATOR_UDID=$(echo "$DESTINATIONS" | grep -oE 'id:[A-F0-9-]+' | head -1 | cut -d: -f2 || true)
  
  # If that didn't work, try a different approach - get the first line and extract from it
  if [ -z "$SIMULATOR_UDID" ]; then
    FIRST_LINE=$(echo "$DESTINATIONS" | head -1 || true)
    if [ -n "$FIRST_LINE" ]; then
      SIMULATOR_UDID=$(echo "$FIRST_LINE" | grep -oE 'id:[A-F0-9-]+' | cut -d: -f2 | head -1 || true)
    fi
  fi
  
  # Extract name and OS for logging
  if [ -n "$SIMULATOR_UDID" ]; then
    SIMULATOR_LINE=$(echo "$DESTINATIONS" | grep "$SIMULATOR_UDID" | head -1 || true)
    if [ -n "$SIMULATOR_LINE" ]; then
      SIMULATOR_NAME=$(echo "$SIMULATOR_LINE" | grep -oE 'name:[^,}]+' | cut -d: -f2 | xargs || echo "Unknown")
      SIMULATOR_OS=$(echo "$SIMULATOR_LINE" | grep -oE 'OS:[0-9.]+' | cut -d: -f2 || echo "Unknown")
    else
      SIMULATOR_NAME="Unknown"
      SIMULATOR_OS="Unknown"
    fi
  fi
  
  if [ -z "$SIMULATOR_UDID" ]; then
    echo "⚠️  Could not extract simulator ID from destinations"
    echo "Destinations found:"
    echo "$DESTINATIONS" | head -3
    echo ""
    echo "Using generic destination as fallback..."
    DESTINATION="platform=iOS Simulator,name=iPhone"
  else
    echo "📱 Selected simulator: $SIMULATOR_NAME (OS: $SIMULATOR_OS, ID: $SIMULATOR_UDID)"
    
    # Check if simulator is booted, if not, boot it
    set +e  # Temporarily disable exit on error for simulator state check
    SIMULATOR_STATE=$(xcrun simctl list devices 2>/dev/null | grep "$SIMULATOR_UDID" | grep -oE "(Booted|Shutdown)" || echo "Unknown")
    set -e  # Re-enable exit on error
    
    if [ "$SIMULATOR_STATE" != "Booted" ]; then
      echo "🚀 Booting simulator $SIMULATOR_UDID..."
      set +e  # Temporarily disable exit on error for boot command
      xcrun simctl boot "$SIMULATOR_UDID" 2>&1
      BOOT_EXIT_CODE=$?
      set -e  # Re-enable exit on error
      
      if [ $BOOT_EXIT_CODE -ne 0 ]; then
        # If boot fails, check if it's already booted (race condition)
        sleep 2
        set +e
        SIMULATOR_STATE=$(xcrun simctl list devices 2>/dev/null | grep "$SIMULATOR_UDID" | grep -oE "(Booted|Shutdown)" || echo "Unknown")
        set -e
        if [ "$SIMULATOR_STATE" != "Booted" ]; then
          echo "⚠️  Failed to boot simulator, but continuing - xcodebuild may boot it automatically"
        else
          echo "✅ Simulator is now booted"
        fi
      else
        echo "✅ Simulator booted successfully"
      fi
    else
      echo "✅ Simulator is already booted"
    fi
    
    DESTINATION="platform=iOS Simulator,id=$SIMULATOR_UDID"
  fi
fi

# Ensure DESTINATION is set (safety check)
if [ -z "$DESTINATION" ]; then
  echo "❌ Error: DESTINATION is not set!"
  echo "Falling back to generic iOS Simulator destination..."
  DESTINATION="platform=iOS Simulator,name=iPhone"
fi

# Show final destination being used
echo "📍 Final destination: $DESTINATION"
echo ""

# Resolve package dependencies first to cache them
echo ""
echo "📦 Resolving Swift Package dependencies..."
echo "ℹ️  This will cache dependencies and speed up test compilation"
xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "$DESTINATION" \
  -derivedDataPath "$DERIVED_DATA" \
  -resolvePackageDependencies \
  2>&1 | tee /tmp/test_resolve.log || true

echo ""
echo "✅ Package dependencies resolved"
echo ""

# Run tests with progress logging
echo ""
echo "🧪 Running tests..."
echo "ℹ️  This may take a while - compiling Swift Package dependencies..."
echo "ℹ️  If it seems stuck, it's likely just compiling (swift-crypto, swift-openapi-runtime, etc.)"
echo "ℹ️  Progress will be shown below - look for 'Compiling', 'Linking', or 'Building' messages"
echo "ℹ️  Large modules like CCryptoBoringSSL can take 10-30 minutes to link"
echo ""

# Run xcodebuild test with output to both file and stdout
# Use tee to capture output while still showing it in real-time
# This allows GitHub Actions to show progress and prevents timeout issues
# Use -jobs 1 to avoid deadlocks with large Swift Package dependencies
# Sequential compilation prevents hangs on modules like swift-collections
# Use -onlyUsePackageVersionsFromResolvedFile to avoid re-resolving dependencies
# Run tests sequentially to avoid issues with integration tests
# Integration tests may have shared state or initialization issues with parallel execution
xcodebuild test \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "$DESTINATION" \
  -derivedDataPath "$DERIVED_DATA" \
  -enableCodeCoverage YES \
  -resultBundlePath "$PROJECT_ROOT/test-results.xcresult" \
  -jobs 1 \
  -onlyUsePackageVersionsFromResolvedFile \
  -parallel-testing-enabled NO \
  -maximum-concurrent-test-device-destinations 1 \
  -maximum-concurrent-test-simulator-destinations 1 \
  -showBuildTimingSummary \
  2>&1 | tee /tmp/test_output.log

TEST_EXIT_CODE=${PIPESTATUS[0]}

echo ""
if [ $TEST_EXIT_CODE -eq 0 ]; then
  echo "✅ All tests passed!"
  echo ""
  echo "📊 Test summary:"
  # Try to extract test summary from output
  grep -E "(Test Suite|Test Case|passed|failed)" /tmp/test_output.log | tail -20 || true
else
  echo "❌ Tests failed with exit code: $TEST_EXIT_CODE"
  echo ""
  echo "Last 100 lines of test output:"
  tail -100 /tmp/test_output.log || true
  echo ""
  echo "Build timing summary:"
  grep -A 20 "Build Timing Summary" /tmp/test_output.log || true
  exit $TEST_EXIT_CODE
fi

echo ""
echo "✅ Tests completed successfully!"
echo "Results saved to: $PROJECT_ROOT/test-results.xcresult"

