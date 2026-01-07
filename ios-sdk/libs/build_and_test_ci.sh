#!/bin/bash

# Combined build and test script for CI/CD
# Usage: ./build_and_test_ci.sh [build|test|both]
#   build - Only build the framework
#   test  - Only run tests
#   both  - Build framework and run tests (default)

set -e

# Default mode
MODE="${1:-both}"

# Project name (name of Xcode project file)
PROJECT_NAME="AriseMobileSdk"
# Scheme name (name of the scheme in Xcode, not the target name)
SCHEME_NAME="AriseMobileSdk"

# Framework output name (name of .xcframework and .framework files)
XCFRAMEWORK_NAME="AriseMobile"
FRAMEWORK_NAME="${XCFRAMEWORK_NAME}"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}💡 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Set up paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECT_PATH="${PROJECT_ROOT}/src/${PROJECT_NAME}.xcodeproj"
OUTPUT_DIR="${SCRIPT_DIR}"
BUILD_DIR="${OUTPUT_DIR}/Build"

# Allow overriding DerivedData path for local testing
DERIVED_DATA="${DERIVED_DATA_OVERRIDE:-$PROJECT_ROOT/DerivedData-Tests}"

# Change to project root for relative paths
cd "$PROJECT_ROOT"

print_status "🚀 Starting CI script in mode: $MODE"
print_status "Project path: $PROJECT_PATH"
print_status "Output directory: $OUTPUT_DIR"

# ============================================================================
# BUILD SECTION
# ============================================================================

build_framework() {
    print_status "🔨 Building ${FRAMEWORK_NAME} framework..."
    
    DEVICE_DERIVED_DATA="${BUILD_DIR}/DerivedData-Device"
    SIMULATOR_DERIVED_DATA="${BUILD_DIR}/DerivedData-Simulator"
    
    # Clean output directory
    rm -rf ${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework
    mkdir -p ${BUILD_DIR}
    
    # Check if CloudCommerce.xcframework exists
    CLOUDCOMMERCE_FRAMEWORK="${OUTPUT_DIR}/CloudCommerce.xcframework"
    if [ -d "$CLOUDCOMMERCE_FRAMEWORK" ]; then
        print_success "CloudCommerce.xcframework found at: $CLOUDCOMMERCE_FRAMEWORK"
    else
        print_warning "CloudCommerce.xcframework not found at: $CLOUDCOMMERCE_FRAMEWORK"
        print_warning "Creating minimal stub for CI build (this may cause Swift version compatibility issues)..."
        
        # Clean any existing CloudCommerce artifacts from DerivedData that might cause conflicts
        find "${DEVICE_DERIVED_DATA}" -name "*CloudCommerce*" -type d -exec rm -rf {} + 2>/dev/null || true
        find "${DEVICE_DERIVED_DATA}" -name "*CloudCommerce*" -type f -delete 2>/dev/null || true
        print_status "Cleaned existing CloudCommerce artifacts from DerivedData"
        mkdir -p "${CLOUDCOMMERCE_FRAMEWORK}/ios-arm64/CloudCommerce.framework"
        mkdir -p "${CLOUDCOMMERCE_FRAMEWORK}/ios-arm64/CloudCommerce.framework/Headers"
        mkdir -p "${CLOUDCOMMERCE_FRAMEWORK}/ios-arm64_x86_64-simulator/CloudCommerce.framework"
        mkdir -p "${CLOUDCOMMERCE_FRAMEWORK}/ios-arm64_x86_64-simulator/CloudCommerce.framework/Headers"
        
        # Create minimal Info.plist for XCFramework
        cat > "${CLOUDCOMMERCE_FRAMEWORK}/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>AvailableLibraries</key>
    <array>
        <dict>
            <key>LibraryIdentifier</key>
            <string>ios-arm64</string>
            <key>LibraryPath</key>
            <string>CloudCommerce.framework</string>
            <key>SupportedArchitectures</key>
            <array>
                <string>arm64</string>
            </array>
            <key>SupportedPlatform</key>
            <string>ios</string>
        </dict>
        <dict>
            <key>LibraryIdentifier</key>
            <string>ios-arm64_x86_64-simulator</string>
            <key>LibraryPath</key>
            <string>CloudCommerce.framework</string>
            <key>SupportedArchitectures</key>
            <array>
                <string>arm64</string>
                <string>x86_64</string>
            </array>
            <key>SupportedPlatform</key>
            <string>ios</string>
            <key>SupportedPlatformVariant</key>
            <string>simulator</string>
        </dict>
    </array>
    <key>CFBundlePackageType</key>
    <string>XFWK</string>
    <key>XCFrameworkFormatVersion</key>
    <string>1.0</string>
</dict>
</plist>
EOF

        # Create minimal framework Info.plist for device
        cat > "${CLOUDCOMMERCE_FRAMEWORK}/ios-arm64/CloudCommerce.framework/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>CloudCommerce</string>
    <key>CFBundleIdentifier</key>
    <string>com.arise.CloudCommerce</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>CloudCommerce</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>MinimumOSVersion</key>
    <string>15.0</string>
</dict>
</plist>
EOF

        # Create minimal framework Info.plist for simulator
        cp "${CLOUDCOMMERCE_FRAMEWORK}/ios-arm64/CloudCommerce.framework/Info.plist" "${CLOUDCOMMERCE_FRAMEWORK}/ios-arm64_x86_64-simulator/CloudCommerce.framework/Info.plist"
        
        print_status "Created CloudCommerce.xcframework stub"
    fi
    
    # Build for device
    print_status "📱 Building for device (arm64)..."
    
    # Clean DerivedData completely to remove any old artifacts and ensure fresh build
    print_status "Cleaning DerivedData completely..."
    rm -rf "${DEVICE_DERIVED_DATA}" 2>/dev/null || true
    mkdir -p "${DEVICE_DERIVED_DATA}"
    
    # First clean
    print_status "Cleaning build..."
    xcodebuild clean \
        -project "${PROJECT_PATH}" \
        -scheme "${SCHEME_NAME}" \
        -configuration Debug \
        -sdk iphoneos \
        -derivedDataPath "${DEVICE_DERIVED_DATA}" \
        2>&1 | tee "${BUILD_DIR}/device_clean.log" || true
    
    # Resolve package dependencies separately first
    print_status "Resolving package dependencies..."
    xcodebuild \
        -project "${PROJECT_PATH}" \
        -scheme "${SCHEME_NAME}" \
        -configuration Debug \
        -sdk iphoneos \
        -derivedDataPath "${DEVICE_DERIVED_DATA}" \
        -resolvePackageDependencies \
        2>&1 | tee "${BUILD_DIR}/device_resolve.log" || true
    
    # Build for device
    print_status "Building scheme: ${SCHEME_NAME}..."
    xcodebuild \
        -project "${PROJECT_PATH}" \
        -scheme "${SCHEME_NAME}" \
        -configuration Debug \
        -sdk iphoneos \
        -arch arm64 \
        -derivedDataPath "${DEVICE_DERIVED_DATA}" \
        build \
        2>&1 | tee "${BUILD_DIR}/device_build.log"
    
    BUILD_EXIT_CODE=${PIPESTATUS[0]}
    
    if [ $BUILD_EXIT_CODE -ne 0 ]; then
        print_error "Device build failed with exit code: $BUILD_EXIT_CODE"
        tail -100 "${BUILD_DIR}/device_build.log" || true
        exit 1
    fi
    
    # Search for framework in DerivedData
    print_status "Searching for framework in DerivedData..."
    DEVICE_FRAMEWORK="${DEVICE_DERIVED_DATA}/Build/Products/Debug-iphoneos/${FRAMEWORK_NAME}.framework"
    if [ ! -d "$DEVICE_FRAMEWORK" ]; then
        DEVICE_FRAMEWORK=$(find "${DEVICE_DERIVED_DATA}" -name "${FRAMEWORK_NAME}.framework" -type d 2>/dev/null | head -1)
    fi
    
    if [ -z "$DEVICE_FRAMEWORK" ] || [ ! -d "$DEVICE_FRAMEWORK" ]; then
        print_error "Device framework not found"
        exit 1
    fi
    
    print_success "Device framework found: $DEVICE_FRAMEWORK"
    
    # Build for simulator
    print_status "📱 Building for simulator (arm64)..."
    
    # Clean DerivedData completely
    print_status "Cleaning DerivedData completely..."
    rm -rf "${SIMULATOR_DERIVED_DATA}" 2>/dev/null || true
    mkdir -p "${SIMULATOR_DERIVED_DATA}"
    
    # First clean
    print_status "Cleaning build..."
    xcodebuild clean \
        -project "${PROJECT_PATH}" \
        -scheme "${SCHEME_NAME}" \
        -configuration Debug \
        -sdk iphonesimulator \
        -derivedDataPath "${SIMULATOR_DERIVED_DATA}" \
        2>&1 | tee "${BUILD_DIR}/simulator_clean.log" || true
    
    # Resolve package dependencies separately first
    print_status "Resolving package dependencies..."
    xcodebuild \
        -project "${PROJECT_PATH}" \
        -scheme "${SCHEME_NAME}" \
        -configuration Debug \
        -sdk iphonesimulator \
        -derivedDataPath "${SIMULATOR_DERIVED_DATA}" \
        -resolvePackageDependencies \
        2>&1 | tee "${BUILD_DIR}/simulator_resolve.log" || true
    
    # Build for simulator
    print_status "Building scheme: ${SCHEME_NAME} for simulator..."
    xcodebuild \
        -project "${PROJECT_PATH}" \
        -scheme "${SCHEME_NAME}" \
        -configuration Debug \
        -destination "generic/platform=iOS Simulator" \
        -sdk iphonesimulator \
        -derivedDataPath "${SIMULATOR_DERIVED_DATA}" \
        build \
        2>&1 | tee "${BUILD_DIR}/simulator_build.log"
    
    BUILD_EXIT_CODE=${PIPESTATUS[0]}
    if [ $BUILD_EXIT_CODE -ne 0 ]; then
        print_error "Simulator build failed with exit code: $BUILD_EXIT_CODE"
        tail -50 "${BUILD_DIR}/simulator_build.log" || true
        exit 1
    fi
    
    # Search for framework in DerivedData
    print_status "Searching for framework in DerivedData..."
    SIMULATOR_FRAMEWORK="${SIMULATOR_DERIVED_DATA}/Build/Products/Debug-iphonesimulator/${FRAMEWORK_NAME}.framework"
    if [ ! -d "$SIMULATOR_FRAMEWORK" ]; then
        SIMULATOR_FRAMEWORK=$(find "${SIMULATOR_DERIVED_DATA}" -name "${FRAMEWORK_NAME}.framework" -type d 2>/dev/null | head -1)
    fi
    
    if [ -z "$SIMULATOR_FRAMEWORK" ] || [ ! -d "$SIMULATOR_FRAMEWORK" ]; then
        print_error "Simulator framework not found"
        exit 1
    fi
    
    print_success "Simulator framework found: $SIMULATOR_FRAMEWORK"
    
    # Create XCFramework
    print_status "📦 Creating XCFramework..."
    
    xcframework_path="${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework"
    rm -rf "${xcframework_path}"
    
    print_status "Creating XCFramework from:"
    print_status "  Device: $DEVICE_FRAMEWORK"
    print_status "  Simulator: $SIMULATOR_FRAMEWORK"
    print_status "  Output: $xcframework_path"
    
    xcodebuild -create-xcframework \
        -framework "${DEVICE_FRAMEWORK}" \
        -framework "${SIMULATOR_FRAMEWORK}" \
        -output "${xcframework_path}" 2>&1 | tee "${BUILD_DIR}/xcframework_create.log"
    
    XCFRAMEWORK_EXIT_CODE=${PIPESTATUS[0]}
    
    if [ $XCFRAMEWORK_EXIT_CODE -ne 0 ]; then
        print_error "Failed to create XCFramework (exit code: $XCFRAMEWORK_EXIT_CODE)"
        cat "${BUILD_DIR}/xcframework_create.log" || true
        exit 1
    fi
    
    if [ ! -d "${xcframework_path}" ]; then
        print_error "XCFramework directory not found after creation"
        exit 1
    fi
    
    print_success "XCFramework created: ${xcframework_path}"
    print_success "🎉 Build completed successfully!"
}

# ============================================================================
# TEST SECTION
# ============================================================================

run_tests() {
    print_status "🧪 Running tests in CI environment..."
    echo ""
    
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
    xcodebuild -project "$PROJECT_PATH" -scheme "$SCHEME_NAME" -showdestinations 2>&1 | grep -E "(platform:|name:)" || true
    echo ""
    
    # Get destinations that xcodebuild can actually use, filter for iPhone iOS Simulator only (not Mac Catalyst)
    # Don't use -destination flag with -showdestinations, it filters results incorrectly
    # Use 2>&1 to capture both stdout and stderr, then filter
    echo "🔍 Searching for iPhone simulators in destinations..."
    DESTINATIONS=$(xcodebuild -project "$PROJECT_PATH" -scheme "$SCHEME_NAME" -showdestinations 2>&1 | grep "platform:iOS Simulator" | grep "name:iPhone" || true)
    
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
        -scheme "$SCHEME_NAME" \
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
    xcodebuild test \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME_NAME" \
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
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

case "$MODE" in
    build)
        build_framework
        ;;
    test)
        run_tests
        ;;
    both)
        build_framework
        run_tests
        ;;
    *)
        print_error "Invalid mode: $MODE"
        print_status "Usage: $0 [build|test|both]"
        exit 1
        ;;
esac

print_success "🎉 CI script completed successfully in mode: $MODE"

