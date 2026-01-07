#!/bin/bash

# Script to prepare precompiled Swift Package dependencies for CI
# This allows CI to skip compilation of heavy dependencies like swift-crypto
#
# Usage:
#   1. Run this script locally after updating dependencies
#   2. Commit the generated SourcePackages to repository
#   3. CI will use precompiled dependencies instead of compiling them

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROJECT_PATH="$PROJECT_ROOT/ios-sdk/src/AriseMobileSdk.xcodeproj"
SCHEME="AriseMobileSdk"
DERIVED_DATA="$PROJECT_ROOT/ios-sdk/libs/BinaryDependencies"

echo "📦 Preparing precompiled Swift Package dependencies..."
echo ""

# Create directory for binary dependencies
mkdir -p "$DERIVED_DATA"

# Change to project root
cd "$PROJECT_ROOT"

# Resolve and build all dependencies
echo "🔨 Resolving and building dependencies..."
xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination "generic/platform=iOS Simulator" \
  -derivedDataPath "$DERIVED_DATA" \
  -resolvePackageDependencies \
  2>&1 | tee "$DERIVED_DATA/resolve.log" || true

echo ""
echo "✅ Dependencies resolved"
echo ""

# Build dependencies (this will compile all Swift packages)
echo "🔨 Building dependencies (this may take 10-30 minutes)..."
xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination "generic/platform=iOS Simulator" \
  -derivedDataPath "$DERIVED_DATA" \
  -build-for-testing \
  2>&1 | tee "$DERIVED_DATA/build.log" || true

echo ""
echo "✅ Dependencies built"
echo ""

# Copy SourcePackages to repository
SOURCE_PACKAGES="$DERIVED_DATA/SourcePackages"
REPO_SOURCE_PACKAGES="$PROJECT_ROOT/ios-sdk/libs/SourcePackages"

if [ -d "$SOURCE_PACKAGES" ]; then
  echo "📦 Copying SourcePackages to repository..."
  rm -rf "$REPO_SOURCE_PACKAGES"
  cp -R "$SOURCE_PACKAGES" "$REPO_SOURCE_PACKAGES"
  
  # Calculate size
  SIZE=$(du -sh "$REPO_SOURCE_PACKAGES" | cut -f1)
  echo "✅ SourcePackages copied to repository (size: $SIZE)"
  echo ""
  echo "📝 Next steps:"
  echo "   1. Review the changes: git status"
  echo "   2. Add to git: git add ios-sdk/libs/SourcePackages"
  echo "   3. Commit: git commit -m 'Add precompiled Swift Package dependencies'"
  echo ""
  echo "⚠️  Note: This will increase repository size. Consider using Git LFS for large files."
else
  echo "❌ SourcePackages not found at $SOURCE_PACKAGES"
  exit 1
fi

