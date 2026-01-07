#!/bin/bash

# Build script for CI/CD
# This script explicitly builds frameworks and creates XCFramework

set -e

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

print_status "🚀 Building ${FRAMEWORK_NAME} framework for CI/CD..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECT_PATH="${PROJECT_ROOT}/src/${PROJECT_NAME}.xcodeproj"
OUTPUT_DIR="${SCRIPT_DIR}"
BUILD_DIR="${OUTPUT_DIR}/Build"

# Clean output directory
rm -rf ${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework
mkdir -p ${BUILD_DIR}

DEVICE_DERIVED_DATA="${BUILD_DIR}/DerivedData-Device"
SIMULATOR_DERIVED_DATA="${BUILD_DIR}/DerivedData-Simulator"

print_status "Project path: $PROJECT_PATH"
print_status "Output directory: $OUTPUT_DIR"

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
    
    # Important: Do NOT create Modules directory - we don't want Swift interface files
    # This prevents Swift compiler from trying to import CloudCommerce as a module
    
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
    
    # Create minimal binary stub - compile a minimal Objective-C framework
    # This creates a valid framework binary that can be linked against
    TEMP_STUB="/tmp/CloudCommerce_stub.m"
    cat > "$TEMP_STUB" <<'EOFSTUB'
#import <Foundation/Foundation.h>

// Minimal stub to satisfy linker
void CloudCommerceStubInit(void) __attribute__((constructor));
void CloudCommerceStubInit(void) {
    // Empty constructor
}
EOFSTUB
    
    # Get SDK path
    SDK_PATH=$(xcrun --show-sdk-path --sdk iphoneos 2>/dev/null || echo "")
    if [ -z "$SDK_PATH" ]; then
        SDK_PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk"
    fi
    
    # Compile for device (arm64)
    if command -v clang >/dev/null 2>&1 && [ -d "$SDK_PATH" ]; then
        clang -arch arm64 \
            -isysroot "$SDK_PATH" \
            -dynamiclib \
            -install_name "@rpath/CloudCommerce.framework/CloudCommerce" \
            -compatibility_version 1.0.0 -current_version 1.0.0 \
            -framework Foundation \
            -fobjc-arc \
            -o "${CLOUDCOMMERCE_FRAMEWORK}/ios-arm64/CloudCommerce.framework/CloudCommerce" \
            "$TEMP_STUB" 2>/dev/null || \
        print_warning "Failed to compile device stub with clang"
    fi
    
    # Get Simulator SDK path
    SIM_SDK_PATH=$(xcrun --show-sdk-path --sdk iphonesimulator 2>/dev/null || echo "")
    if [ -z "$SIM_SDK_PATH" ]; then
        SIM_SDK_PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk"
    fi
    
    # Compile for simulator (arm64 + x86_64)
    if command -v clang >/dev/null 2>&1 && [ -d "$SIM_SDK_PATH" ]; then
        # Try to compile universal binary (arm64 + x86_64)
        clang -arch arm64 -arch x86_64 \
            -isysroot "$SIM_SDK_PATH" \
            -dynamiclib \
            -install_name "@rpath/CloudCommerce.framework/CloudCommerce" \
            -compatibility_version 1.0.0 -current_version 1.0.0 \
            -framework Foundation \
            -fobjc-arc \
            -o "${CLOUDCOMMERCE_FRAMEWORK}/ios-arm64_x86_64-simulator/CloudCommerce.framework/CloudCommerce" \
            "$TEMP_STUB" 2>/dev/null || \
        print_warning "Failed to compile simulator stub with clang"
    fi
    
    # Verify binaries were created, if not, log warning but continue
    if [ ! -f "${CLOUDCOMMERCE_FRAMEWORK}/ios-arm64/CloudCommerce.framework/CloudCommerce" ] || \
       [ ! -s "${CLOUDCOMMERCE_FRAMEWORK}/ios-arm64/CloudCommerce.framework/CloudCommerce" ]; then
        print_warning "CloudCommerce device binary missing or empty - linking may fail"
    fi
    
    if [ ! -f "${CLOUDCOMMERCE_FRAMEWORK}/ios-arm64_x86_64-simulator/CloudCommerce.framework/CloudCommerce" ] || \
       [ ! -s "${CLOUDCOMMERCE_FRAMEWORK}/ios-arm64_x86_64-simulator/CloudCommerce.framework/CloudCommerce" ]; then
        print_warning "CloudCommerce simulator binary missing or empty - linking may fail"
    fi
    
    # Cleanup temp file
    rm -f "$TEMP_STUB"
    
    print_status "Created CloudCommerce.xcframework stub"
fi

# Build for device
print_status "📱 Building for device (arm64)..."

# List available schemes and targets
print_status "Listing available schemes..."
xcodebuild -list -project "${PROJECT_PATH}" 2>&1 | head -20 || true

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

# Clean DerivedData (CloudCommerce will be copied during build if needed)
# We don't remove CloudCommerce artifacts here - let xcodebuild handle it naturally

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

# Verify CloudCommerce is available after resolving dependencies
if [ -d "$CLOUDCOMMERCE_FRAMEWORK" ]; then
    print_status "CloudCommerce.xcframework is available at: $CLOUDCOMMERCE_FRAMEWORK"
    # Check Swift version compatibility if possible
    if [ -f "${CLOUDCOMMERCE_FRAMEWORK}/ios-arm64/CloudCommerce.framework/Modules/CloudCommerce.swiftmodule/arm64-apple-ios.abi.json" ]; then
        print_status "CloudCommerce contains Swift module"
    fi
else
    print_warning "CloudCommerce.xcframework not found - stub will be used (may have Swift version compatibility issues)"
fi

# Two-stage build to avoid duplicate class warnings:
# Stage 1: Build with dependencies (static linkage) - needed for compilation
# Stage 2: Build with dynamic linkage - dependencies won't be included in framework
print_status "Building scheme: ${SCHEME_NAME} (Stage 1: with dependencies for compilation)..."

# Stage 1: Build with static linkage (dependencies included for compilation)
xcodebuild \
    -project "${PROJECT_PATH}" \
    -scheme "${SCHEME_NAME}" \
    -configuration Debug \
    -sdk iphoneos \
    -arch arm64 \
    -derivedDataPath "${DEVICE_DERIVED_DATA}" \
    build \
    2>&1 | tee "${BUILD_DIR}/device_build_stage1.log"

STAGE1_EXIT_CODE=${PIPESTATUS[0]}

if [ $STAGE1_EXIT_CODE -ne 0 ]; then
    print_error "Stage 1 build failed with exit code: $STAGE1_EXIT_CODE"
    tail -100 "${BUILD_DIR}/device_build_stage1.log" || true
    exit 1
fi

print_success "Stage 1 build completed. Dependencies are now in DerivedData."

# Stage 2: Manually relink the binary without dependencies
# Find the compiled framework and object files from stage 1
# Note: Framework name is FRAMEWORK_NAME (AriseMobile), not PROJECT_NAME (AriseMobileSdk)
STAGE1_FRAMEWORK="${DEVICE_DERIVED_DATA}/Build/Products/Debug-iphoneos/${FRAMEWORK_NAME}.framework"
if [ ! -d "$STAGE1_FRAMEWORK" ]; then
    STAGE1_FRAMEWORK=$(find "${DEVICE_DERIVED_DATA}" -name "${FRAMEWORK_NAME}.framework" -type d 2>/dev/null | head -1)
fi

if [ -z "$STAGE1_FRAMEWORK" ] || [ ! -d "$STAGE1_FRAMEWORK" ]; then
    print_error "Stage 1 framework not found for relinking"
    print_status "Searched for: ${FRAMEWORK_NAME}.framework in ${DEVICE_DERIVED_DATA}"
    print_status "Available frameworks:"
    find "${DEVICE_DERIVED_DATA}" -name "*.framework" -type d 2>/dev/null || true
    exit 1
fi

print_status "Stage 1 framework found: $STAGE1_FRAMEWORK"

# Find the binary from stage 1
STAGE1_BINARY="${STAGE1_FRAMEWORK}/${FRAMEWORK_NAME}"
if [ ! -f "$STAGE1_BINARY" ]; then
    # Try to find any binary in the framework
    STAGE1_BINARY=$(find "${STAGE1_FRAMEWORK}" -maxdepth 1 -type f -perm +111 ! -name "*.plist" ! -name "*.swiftmodule" ! -name "*.swiftdoc" ! -name "*.swiftinterface" | head -1)
fi

if [ -z "$STAGE1_BINARY" ] || [ ! -f "$STAGE1_BINARY" ]; then
    print_error "Stage 1 binary not found for relinking"
    exit 1
fi

print_status "Stage 1 binary found: $STAGE1_BINARY"

# Stage 2: Rebuild only the linking phase without dependencies
# Find object files directory
OBJ_DIR="${DEVICE_DERIVED_DATA}/Build/Intermediates.noindex/${PROJECT_NAME}.build/Debug-iphoneos/${PROJECT_NAME}.build/Objects-normal/arm64"
if [ ! -d "$OBJ_DIR" ]; then
    OBJ_DIR=$(find "${DEVICE_DERIVED_DATA}" -path "*/Objects-normal/arm64" -type d 2>/dev/null | head -1)
fi

if [ -z "$OBJ_DIR" ] || [ ! -d "$OBJ_DIR" ]; then
    print_warning "Object files directory not found, will rebuild from scratch without dependencies"
    OBJ_DIR=""
fi

print_status "Stage 2: Rebuilding linking phase without dependencies..."

# Create temporary xcconfig file to exclude dependencies from linking
TEMP_XCCONFIG="${BUILD_DIR}/no_deps_linkage.xcconfig"
cat > "${TEMP_XCCONFIG}" <<EOF
// Exclude Swift Package dependencies from linking
SWIFT_PACKAGE_DEPENDENCIES_LINKAGE = dynamic
// Remove package dependencies from linker flags
OTHER_LDFLAGS = \$(inherited)
// Don't automatically link Swift packages
SWIFT_PACKAGE_PRODUCTS = 
EOF

# Rebuild with dependencies excluded from linking
# Don't clean - keep object files, just relink
xcodebuild \
    -project "${PROJECT_PATH}" \
    -scheme "${SCHEME_NAME}" \
    -configuration Debug \
    -sdk iphoneos \
    -arch arm64 \
    -derivedDataPath "${DEVICE_DERIVED_DATA}" \
    -xcconfig "${TEMP_XCCONFIG}" \
    build \
    2>&1 | tee "${BUILD_DIR}/device_build.log"

# Clean up temporary xcconfig
rm -f "${TEMP_XCCONFIG}" 2>/dev/null || true

BUILD_EXIT_CODE=${PIPESTATUS[0]}

if [ $BUILD_EXIT_CODE -ne 0 ]; then
    print_error "Device build failed with exit code: $BUILD_EXIT_CODE"
    
    # Save full build log for debugging
    print_status "Full build log saved to: ${BUILD_DIR}/device_build.log"
    
    # Extract actual error messages (case insensitive, multiple patterns)
    print_status "=== Extracting compilation errors ==="
    ERRORS=$(grep -i -E "error:|failed|FAILED|swiftc.*error" "${BUILD_DIR}/device_build.log" 2>/dev/null | head -100 || true)
    if [ -n "$ERRORS" ]; then
        print_error "Compilation errors found:"
        echo "$ERRORS" | head -50
    else
        print_warning "No explicit error messages found, checking build output..."
    fi
    
    # Check for Swift compiler errors specifically
    print_status "=== Checking for Swift compilation errors ==="
    SWIFT_ERRORS=$(grep -i -B 2 -A 10 "error:" "${BUILD_DIR}/device_build.log" 2>/dev/null | grep -A 10 "SwiftCompile\|\.swift" | head -100 || true)
    if [ -n "$SWIFT_ERRORS" ]; then
        print_error "Swift compilation issues:"
        echo "$SWIFT_ERRORS" | head -80
    fi
    
    # Show context around BUILD FAILED
    print_status "=== Context around BUILD FAILED ==="
    grep -B 50 "BUILD FAILED" "${BUILD_DIR}/device_build.log" 2>/dev/null | tail -60 || true
    
    # Show last 150 lines for full context
    print_status "=== Last 150 lines of build log ==="
    tail -150 "${BUILD_DIR}/device_build.log" || true
    
    exit 1
fi

print_status "Build completed (exit code: $BUILD_EXIT_CODE). Searching for framework..."
print_status "Build log saved to: ${BUILD_DIR}/device_build.log"

# Check if build actually compiled something
print_status "Checking build log for compilation steps..."
HAS_COMPILE=$(grep -c "Compile Swift\|CompileC\|SwiftCompile\|Ld\|Link" "${BUILD_DIR}/device_build.log" 2>/dev/null || echo "0")
HAS_BUILD_SUCCEEDED=$(grep -c "BUILD SUCCEEDED" "${BUILD_DIR}/device_build.log" 2>/dev/null || echo "0")
HAS_BUILD_FAILED=$(grep -c "BUILD FAILED" "${BUILD_DIR}/device_build.log" 2>/dev/null || echo "0")
LOG_SIZE=$(wc -l < "${BUILD_DIR}/device_build.log" 2>/dev/null || echo "0")

if [ "$HAS_COMPILE" -gt 0 ]; then
    print_success "Build log contains $HAS_COMPILE compilation steps"
elif [ "$HAS_BUILD_SUCCEEDED" -gt 0 ]; then
    print_warning "Build succeeded but no compilation found - checking build log..."
    BUILD_LINES=$(grep -E "(Compile|Ld|Link|Archive|BUILD|Phase|Target)" "${BUILD_DIR}/device_build.log" | tail -20 || true)
    echo "$BUILD_LINES"
else
    print_warning "No compilation or success message found in build log"
    print_status "Full build log (last 50 lines):"
    tail -50 "${BUILD_DIR}/device_build.log" || true
fi

# Search for framework in DerivedData - check standard path first (as in working script)
# Note: Xcode creates framework with PRODUCT_NAME (FRAMEWORK_NAME), not PROJECT_NAME
print_status "Searching for framework in DerivedData..."
DEVICE_FRAMEWORK="${DEVICE_DERIVED_DATA}/Build/Products/Debug-iphoneos/${FRAMEWORK_NAME}.framework"
if [ ! -d "$DEVICE_FRAMEWORK" ]; then
    # Try alternative search if standard path doesn't exist
    DEVICE_FRAMEWORK=$(find "${DEVICE_DERIVED_DATA}" -name "${FRAMEWORK_NAME}.framework" -type d 2>/dev/null | head -1)
fi

if [ -z "$DEVICE_FRAMEWORK" ] || [ ! -d "$DEVICE_FRAMEWORK" ]; then
    print_error "Device framework not found"
    DD_STRUCTURE=$(find "${DEVICE_DERIVED_DATA}" -type d -maxdepth 4 2>/dev/null | head -30 || true)
    FRAMEWORK_FILES=$(find "${DEVICE_DERIVED_DATA}" -name "*.framework" -type d 2>/dev/null || true)
    BUILD_DIR_LIST=$(ls -la "${DEVICE_DERIVED_DATA}/" 2>/dev/null || true)
    print_status "Listing DerivedData structure:"
    echo "$DD_STRUCTURE"
    print_status "Searching all .framework files:"
    echo "$FRAMEWORK_FILES"
    print_status "Checking if Build directory exists:"
    echo "$BUILD_DIR_LIST"
    print_status "Checking build log for errors (last 100 lines):"
    tail -100 "${BUILD_DIR}/device_build.log" 2>/dev/null || true
    exit 1
fi

print_success "Device framework found: $DEVICE_FRAMEWORK"

# Verify that dependencies are not statically linked in the framework
# Check for common dependency symbols that should not be in the framework
print_status "Verifying dependencies are not statically linked..."
DEVICE_BINARY="${DEVICE_FRAMEWORK}/${XCFRAMEWORK_NAME}"
if [ -f "$DEVICE_BINARY" ]; then
    # Check for OpenAPIRuntime symbols (should not be in framework if dynamic linking worked)
    OPENAPI_SYMBOLS=$(nm "$DEVICE_BINARY" 2>/dev/null | grep -i "OpenAPIRuntime" | head -5 || true)
    if [ -n "$OPENAPI_SYMBOLS" ]; then
        print_warning "Found OpenAPIRuntime symbols in framework binary (may indicate static linking)"
        echo "$OPENAPI_SYMBOLS" | head -3
    else
        print_success "No OpenAPIRuntime symbols found in framework (dynamic linking appears to be working)"
    fi
    
    # Check for CryptoSwift symbols
    CRYPTO_SYMBOLS=$(nm "$DEVICE_BINARY" 2>/dev/null | grep -i "CryptoSwift" | head -5 || true)
    if [ -n "$CRYPTO_SYMBOLS" ]; then
        print_warning "Found CryptoSwift symbols in framework binary (may indicate static linking)"
        echo "$CRYPTO_SYMBOLS" | head -3
    else
        print_success "No CryptoSwift symbols found in framework (dynamic linking appears to be working)"
    fi
else
    print_warning "Cannot verify dependencies - framework binary not found at $DEVICE_BINARY"
fi

# Build for simulator
print_status "📱 Building for simulator (arm64)..."

# Clean DerivedData completely to remove any old artifacts and ensure fresh build
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

# Ensure no CloudCommerce artifacts remain in DerivedData
print_status "Removing any CloudCommerce artifacts from DerivedData..."
find "${SIMULATOR_DERIVED_DATA}" -name "*CloudCommerce*" -type d -exec rm -rf {} + 2>/dev/null || true
find "${SIMULATOR_DERIVED_DATA}" -name "*CloudCommerce*" -type f -delete 2>/dev/null || true

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

# Two-stage build for simulator (same approach as device)
print_status "Building scheme: ${SCHEME_NAME} (Stage 1: with dependencies for compilation)..."
print_status "Using generic iOS Simulator destination"

# Stage 1: Build with static linkage (dependencies included for compilation)
xcodebuild \
    -project "${PROJECT_PATH}" \
    -scheme "${SCHEME_NAME}" \
    -configuration Debug \
    -destination "generic/platform=iOS Simulator" \
    -sdk iphonesimulator \
    -derivedDataPath "${SIMULATOR_DERIVED_DATA}" \
    build \
    2>&1 | tee "${BUILD_DIR}/simulator_build_stage1.log"

STAGE1_SIM_EXIT_CODE=${PIPESTATUS[0]}

if [ $STAGE1_SIM_EXIT_CODE -ne 0 ]; then
    print_error "Simulator Stage 1 build failed with exit code: $STAGE1_SIM_EXIT_CODE"
    tail -100 "${BUILD_DIR}/simulator_build_stage1.log" || true
    exit 1
fi

print_success "Simulator Stage 1 build completed. Dependencies are now in DerivedData."

# Stage 2: Manually relink the binary without dependencies
# Find the compiled framework from stage 1
# Note: Framework name is FRAMEWORK_NAME (AriseMobile), not PROJECT_NAME (AriseMobileSdk)
STAGE1_SIM_FRAMEWORK="${SIMULATOR_DERIVED_DATA}/Build/Products/Debug-iphonesimulator/${FRAMEWORK_NAME}.framework"
if [ ! -d "$STAGE1_SIM_FRAMEWORK" ]; then
    STAGE1_SIM_FRAMEWORK=$(find "${SIMULATOR_DERIVED_DATA}" -name "${FRAMEWORK_NAME}.framework" -type d 2>/dev/null | head -1)
fi

if [ -z "$STAGE1_SIM_FRAMEWORK" ] || [ ! -d "$STAGE1_SIM_FRAMEWORK" ]; then
    print_error "Simulator Stage 1 framework not found for relinking"
    print_status "Searched for: ${FRAMEWORK_NAME}.framework in ${SIMULATOR_DERIVED_DATA}"
    print_status "Available frameworks:"
    find "${SIMULATOR_DERIVED_DATA}" -name "*.framework" -type d 2>/dev/null || true
    exit 1
fi

print_status "Simulator Stage 1 framework found: $STAGE1_SIM_FRAMEWORK"

# Stage 2: Rebuild with dependencies excluded from linking
print_status "Building scheme: ${SCHEME_NAME} (Stage 2: relinking without dependencies)..."

# Create temporary xcconfig file to exclude dependencies from linking
TEMP_XCCONFIG_SIM="${BUILD_DIR}/no_deps_linkage_sim.xcconfig"
cat > "${TEMP_XCCONFIG_SIM}" <<EOF
// Exclude Swift Package dependencies from linking
SWIFT_PACKAGE_DEPENDENCIES_LINKAGE = dynamic
// Remove package dependencies from linker flags
OTHER_LDFLAGS = \$(inherited)
// Don't automatically link Swift packages
SWIFT_PACKAGE_PRODUCTS = 
EOF

# Rebuild with dependencies excluded from linking
# Don't clean - keep object files, just relink
xcodebuild \
    -project "${PROJECT_PATH}" \
    -scheme "${SCHEME_NAME}" \
    -configuration Debug \
    -destination "generic/platform=iOS Simulator" \
    -sdk iphonesimulator \
    -derivedDataPath "${SIMULATOR_DERIVED_DATA}" \
    -xcconfig "${TEMP_XCCONFIG_SIM}" \
    build \
    2>&1 | tee "${BUILD_DIR}/simulator_build.log"

# Clean up temporary xcconfig
rm -f "${TEMP_XCCONFIG_SIM}" 2>/dev/null || true

BUILD_EXIT_CODE=${PIPESTATUS[0]}
if [ $BUILD_EXIT_CODE -ne 0 ]; then
    print_error "Simulator build failed with exit code: $BUILD_EXIT_CODE"
    print_status "Last 50 lines of build log:"
    tail -50 "${BUILD_DIR}/simulator_build.log" || true
    exit 1
fi

print_status "Build completed (exit code: $BUILD_EXIT_CODE). Searching for framework..."
print_status "Build log saved to: ${BUILD_DIR}/simulator_build.log"

# Search for framework in DerivedData - check standard path first
# Note: Xcode creates framework with PRODUCT_NAME (FRAMEWORK_NAME), not PROJECT_NAME
print_status "Searching for framework in DerivedData..."
SIMULATOR_FRAMEWORK="${SIMULATOR_DERIVED_DATA}/Build/Products/Debug-iphonesimulator/${FRAMEWORK_NAME}.framework"
if [ ! -d "$SIMULATOR_FRAMEWORK" ]; then
    # Try alternative search if standard path doesn't exist
    SIMULATOR_FRAMEWORK=$(find "${SIMULATOR_DERIVED_DATA}" -name "${FRAMEWORK_NAME}.framework" -type d 2>/dev/null | head -1)
fi

if [ -z "$SIMULATOR_FRAMEWORK" ] || [ ! -d "$SIMULATOR_FRAMEWORK" ]; then
    print_error "Simulator framework not found"
    print_status "Listing DerivedData structure:"
    find "${SIMULATOR_DERIVED_DATA}" -type d -maxdepth 4 2>/dev/null | head -30 || true
    print_status "Searching all .framework files:"
    find "${SIMULATOR_DERIVED_DATA}" -name "*.framework" -type d 2>/dev/null || true
    print_status "Checking if Build directory exists:"
    ls -la "${SIMULATOR_DERIVED_DATA}/" 2>/dev/null || true
    print_status "Checking build log for errors (last 100 lines):"
    tail -100 "${BUILD_DIR}/simulator_build.log" 2>/dev/null || true
    exit 1
fi

print_success "Simulator framework found: $SIMULATOR_FRAMEWORK"

# Rename frameworks to XCFRAMEWORK_NAME before creating XCFramework
# Note: xcodebuild -create-xcframework expects the binary inside the framework
# to have the same name as the framework folder (without .framework extension)
print_status "📦 Renaming frameworks to ${XCFRAMEWORK_NAME}..."

# Create temporary directories for renamed frameworks
TEMP_DEVICE_DIR="${BUILD_DIR}/device-framework"
TEMP_SIMULATOR_DIR="${BUILD_DIR}/simulator-framework"
TEMP_DEVICE_FRAMEWORK="${TEMP_DEVICE_DIR}/${XCFRAMEWORK_NAME}.framework"
TEMP_SIMULATOR_FRAMEWORK="${TEMP_SIMULATOR_DIR}/${XCFRAMEWORK_NAME}.framework"

# Clean and create temp directories
rm -rf "${TEMP_DEVICE_DIR}" "${TEMP_SIMULATOR_DIR}"
mkdir -p "${TEMP_DEVICE_DIR}" "${TEMP_SIMULATOR_DIR}"

# Copy and rename device framework
# First copy to a temporary location with original name
TEMP_DEVICE_FRAMEWORK_ORIG="${TEMP_DEVICE_DIR}/${PROJECT_NAME}.framework"
cp -R "${DEVICE_FRAMEWORK}" "${TEMP_DEVICE_FRAMEWORK_ORIG}"

# Rename the binary inside the framework to match framework name
# First, find the actual binary file (it should be named PROJECT_NAME, but check anyway)
DEVICE_BINARY=""
if [ -f "${TEMP_DEVICE_FRAMEWORK_ORIG}/${PROJECT_NAME}" ]; then
    DEVICE_BINARY="${TEMP_DEVICE_FRAMEWORK_ORIG}/${PROJECT_NAME}"
elif [ -f "${TEMP_DEVICE_FRAMEWORK_ORIG}/${XCFRAMEWORK_NAME}" ]; then
    # Already renamed, skip
    DEVICE_BINARY="${TEMP_DEVICE_FRAMEWORK_ORIG}/${XCFRAMEWORK_NAME}"
    print_status "Device binary already named ${XCFRAMEWORK_NAME}"
else
    # Try to find any executable binary in the framework
    DEVICE_BINARY=$(find "${TEMP_DEVICE_FRAMEWORK_ORIG}" -maxdepth 1 -type f -perm +111 ! -name "*.plist" ! -name "*.swiftmodule" ! -name "*.swiftdoc" ! -name "*.swiftinterface" ! -name "*.json" | head -1)
    if [ -z "$DEVICE_BINARY" ]; then
        print_error "No executable binary found in device framework ${TEMP_DEVICE_FRAMEWORK_ORIG}"
        ls -la "${TEMP_DEVICE_FRAMEWORK_ORIG}/" || true
        exit 1
    fi
    print_warning "Found device binary at unexpected location: $DEVICE_BINARY"
fi

# Rename the binary if needed
if [ -n "$DEVICE_BINARY" ] && [ "$(basename "$DEVICE_BINARY")" != "${XCFRAMEWORK_NAME}" ]; then
    mv "$DEVICE_BINARY" "${TEMP_DEVICE_FRAMEWORK_ORIG}/${XCFRAMEWORK_NAME}"
    print_success "Renamed device binary from $(basename "$DEVICE_BINARY") to ${XCFRAMEWORK_NAME}"
else
    print_status "Device binary already has correct name: ${XCFRAMEWORK_NAME}"
fi

# Verify the binary exists with the correct name
if [ ! -f "${TEMP_DEVICE_FRAMEWORK_ORIG}/${XCFRAMEWORK_NAME}" ]; then
    print_error "Device binary ${XCFRAMEWORK_NAME} not found after renaming in ${TEMP_DEVICE_FRAMEWORK_ORIG}"
    ls -la "${TEMP_DEVICE_FRAMEWORK_ORIG}/" || true
    exit 1
fi

# Fix install name in the binary to use the new framework name
print_status "🔧 Fixing install name in device binary..."
OLD_INSTALL_NAME="@rpath/${PROJECT_NAME}.framework/${PROJECT_NAME}"
NEW_INSTALL_NAME="@rpath/${XCFRAMEWORK_NAME}.framework/${XCFRAMEWORK_NAME}"
if install_name_tool -id "$NEW_INSTALL_NAME" "${TEMP_DEVICE_FRAMEWORK_ORIG}/${XCFRAMEWORK_NAME}" 2>/dev/null; then
    print_success "Updated device binary install name from ${OLD_INSTALL_NAME} to ${NEW_INSTALL_NAME}"
else
    print_warning "Failed to update device binary install name (may not be necessary)"
fi

# Also fix any references to the old framework name in dependencies
DEPENDENCIES=$(otool -L "${TEMP_DEVICE_FRAMEWORK_ORIG}/${XCFRAMEWORK_NAME}" 2>/dev/null | grep -E "@rpath/${PROJECT_NAME}\.framework" | awk '{print $1}' | tr -d ' ')
if [ -n "$DEPENDENCIES" ]; then
    for DEP in $DEPENDENCIES; do
        NEW_DEP=$(echo "$DEP" | sed "s|${PROJECT_NAME}|${XCFRAMEWORK_NAME}|g")
        if install_name_tool -change "$DEP" "$NEW_DEP" "${TEMP_DEVICE_FRAMEWORK_ORIG}/${XCFRAMEWORK_NAME}" 2>/dev/null; then
            print_success "Updated device binary dependency from ${DEP} to ${NEW_DEP}"
        fi
    done
fi

# Update Info.plist to reflect the new framework name
if [ -f "${TEMP_DEVICE_FRAMEWORK_ORIG}/Info.plist" ]; then
    # Check if CFBundleExecutable key exists
    CURRENT_EXECUTABLE=$(/usr/libexec/PlistBuddy -c "Print :CFBundleExecutable" "${TEMP_DEVICE_FRAMEWORK_ORIG}/Info.plist" 2>/dev/null || echo "")
    if [ -n "$CURRENT_EXECUTABLE" ]; then
        /usr/libexec/PlistBuddy -c "Set :CFBundleExecutable ${XCFRAMEWORK_NAME}" "${TEMP_DEVICE_FRAMEWORK_ORIG}/Info.plist" 2>/dev/null
        VERIFIED_EXECUTABLE=$(/usr/libexec/PlistBuddy -c "Print :CFBundleExecutable" "${TEMP_DEVICE_FRAMEWORK_ORIG}/Info.plist" 2>/dev/null || echo "")
        if [ "$VERIFIED_EXECUTABLE" = "${XCFRAMEWORK_NAME}" ]; then
            print_success "Updated device Info.plist CFBundleExecutable from ${CURRENT_EXECUTABLE} to ${XCFRAMEWORK_NAME}"
        else
            print_error "Failed to update device Info.plist CFBundleExecutable. Current: ${VERIFIED_EXECUTABLE}, Expected: ${XCFRAMEWORK_NAME}"
            exit 1
        fi
    else
        # Key doesn't exist, add it
        /usr/libexec/PlistBuddy -c "Add :CFBundleExecutable string ${XCFRAMEWORK_NAME}" "${TEMP_DEVICE_FRAMEWORK_ORIG}/Info.plist" 2>/dev/null
        print_status "Added device Info.plist CFBundleExecutable: ${XCFRAMEWORK_NAME}"
    fi
else
    print_warning "Device Info.plist not found at ${TEMP_DEVICE_FRAMEWORK_ORIG}/Info.plist"
fi

# Update module.modulemap if it exists
if [ -d "${TEMP_DEVICE_FRAMEWORK_ORIG}/Modules/${PROJECT_NAME}.swiftmodule" ]; then
    mv "${TEMP_DEVICE_FRAMEWORK_ORIG}/Modules/${PROJECT_NAME}.swiftmodule" "${TEMP_DEVICE_FRAMEWORK_ORIG}/Modules/${XCFRAMEWORK_NAME}.swiftmodule"
    print_status "Renamed device swiftmodule from ${PROJECT_NAME} to ${XCFRAMEWORK_NAME}"
fi

# Now rename the framework folder itself
mv "${TEMP_DEVICE_FRAMEWORK_ORIG}" "${TEMP_DEVICE_FRAMEWORK}"
print_status "Renamed device framework folder from ${PROJECT_NAME}.framework to ${XCFRAMEWORK_NAME}.framework"

# Verify the binary exists with correct name
if [ ! -f "${TEMP_DEVICE_FRAMEWORK}/${XCFRAMEWORK_NAME}" ]; then
    print_error "Device binary ${XCFRAMEWORK_NAME} not found after renaming in ${TEMP_DEVICE_FRAMEWORK}"
    ls -la "${TEMP_DEVICE_FRAMEWORK}/" || true
    exit 1
fi

# Verify Info.plist matches the binary name
DEVICE_PLIST_EXECUTABLE=$(/usr/libexec/PlistBuddy -c "Print :CFBundleExecutable" "${TEMP_DEVICE_FRAMEWORK}/Info.plist" 2>/dev/null || echo "")
if [ "$DEVICE_PLIST_EXECUTABLE" != "${XCFRAMEWORK_NAME}" ]; then
    print_error "Device Info.plist CFBundleExecutable mismatch: expected ${XCFRAMEWORK_NAME}, found ${DEVICE_PLIST_EXECUTABLE}"
    exit 1
fi
print_success "Device framework verified: binary=${XCFRAMEWORK_NAME}, Info.plist=${DEVICE_PLIST_EXECUTABLE}"

# Copy and rename simulator framework
# First copy to a temporary location with original name
TEMP_SIMULATOR_FRAMEWORK_ORIG="${TEMP_SIMULATOR_DIR}/${PROJECT_NAME}.framework"
cp -R "${SIMULATOR_FRAMEWORK}" "${TEMP_SIMULATOR_FRAMEWORK_ORIG}"

# Rename the binary inside the framework to match framework name
# First, find the actual binary file (it should be named PROJECT_NAME, but check anyway)
SIMULATOR_BINARY=""
if [ -f "${TEMP_SIMULATOR_FRAMEWORK_ORIG}/${PROJECT_NAME}" ]; then
    SIMULATOR_BINARY="${TEMP_SIMULATOR_FRAMEWORK_ORIG}/${PROJECT_NAME}"
elif [ -f "${TEMP_SIMULATOR_FRAMEWORK_ORIG}/${XCFRAMEWORK_NAME}" ]; then
    # Already renamed, skip
    SIMULATOR_BINARY="${TEMP_SIMULATOR_FRAMEWORK_ORIG}/${XCFRAMEWORK_NAME}"
    print_status "Simulator binary already named ${XCFRAMEWORK_NAME}"
else
    # Try to find any executable binary in the framework
    SIMULATOR_BINARY=$(find "${TEMP_SIMULATOR_FRAMEWORK_ORIG}" -maxdepth 1 -type f -perm +111 ! -name "*.plist" ! -name "*.swiftmodule" ! -name "*.swiftdoc" ! -name "*.swiftinterface" ! -name "*.json" | head -1)
    if [ -z "$SIMULATOR_BINARY" ]; then
        print_error "No executable binary found in simulator framework ${TEMP_SIMULATOR_FRAMEWORK_ORIG}"
        ls -la "${TEMP_SIMULATOR_FRAMEWORK_ORIG}/" || true
        exit 1
    fi
    print_warning "Found simulator binary at unexpected location: $SIMULATOR_BINARY"
fi

# Rename the binary if needed
if [ -n "$SIMULATOR_BINARY" ] && [ "$(basename "$SIMULATOR_BINARY")" != "${XCFRAMEWORK_NAME}" ]; then
    mv "$SIMULATOR_BINARY" "${TEMP_SIMULATOR_FRAMEWORK_ORIG}/${XCFRAMEWORK_NAME}"
    print_success "Renamed simulator binary from $(basename "$SIMULATOR_BINARY") to ${XCFRAMEWORK_NAME}"
else
    print_status "Simulator binary already has correct name: ${XCFRAMEWORK_NAME}"
fi

# Verify the binary exists with the correct name
if [ ! -f "${TEMP_SIMULATOR_FRAMEWORK_ORIG}/${XCFRAMEWORK_NAME}" ]; then
    print_error "Simulator binary ${XCFRAMEWORK_NAME} not found after renaming in ${TEMP_SIMULATOR_FRAMEWORK_ORIG}"
    ls -la "${TEMP_SIMULATOR_FRAMEWORK_ORIG}/" || true
    exit 1
fi

# Fix install name in the binary to use the new framework name
print_status "🔧 Fixing install name in simulator binary..."
OLD_INSTALL_NAME="@rpath/${PROJECT_NAME}.framework/${PROJECT_NAME}"
NEW_INSTALL_NAME="@rpath/${XCFRAMEWORK_NAME}.framework/${XCFRAMEWORK_NAME}"
if install_name_tool -id "$NEW_INSTALL_NAME" "${TEMP_SIMULATOR_FRAMEWORK_ORIG}/${XCFRAMEWORK_NAME}" 2>/dev/null; then
    print_success "Updated simulator binary install name from ${OLD_INSTALL_NAME} to ${NEW_INSTALL_NAME}"
else
    print_warning "Failed to update simulator binary install name (may not be necessary)"
fi

# Also fix any references to the old framework name in dependencies
DEPENDENCIES=$(otool -L "${TEMP_SIMULATOR_FRAMEWORK_ORIG}/${XCFRAMEWORK_NAME}" 2>/dev/null | grep -E "@rpath/${PROJECT_NAME}\.framework" | awk '{print $1}' | tr -d ' ')
if [ -n "$DEPENDENCIES" ]; then
    for DEP in $DEPENDENCIES; do
        NEW_DEP=$(echo "$DEP" | sed "s|${PROJECT_NAME}|${XCFRAMEWORK_NAME}|g")
        if install_name_tool -change "$DEP" "$NEW_DEP" "${TEMP_SIMULATOR_FRAMEWORK_ORIG}/${XCFRAMEWORK_NAME}" 2>/dev/null; then
            print_success "Updated simulator binary dependency from ${DEP} to ${NEW_DEP}"
        fi
    done
fi

# Update Info.plist to reflect the new framework name
if [ -f "${TEMP_SIMULATOR_FRAMEWORK_ORIG}/Info.plist" ]; then
    # Check if CFBundleExecutable key exists
    CURRENT_EXECUTABLE=$(/usr/libexec/PlistBuddy -c "Print :CFBundleExecutable" "${TEMP_SIMULATOR_FRAMEWORK_ORIG}/Info.plist" 2>/dev/null || echo "")
    if [ -n "$CURRENT_EXECUTABLE" ]; then
        /usr/libexec/PlistBuddy -c "Set :CFBundleExecutable ${XCFRAMEWORK_NAME}" "${TEMP_SIMULATOR_FRAMEWORK_ORIG}/Info.plist" 2>/dev/null
        VERIFIED_EXECUTABLE=$(/usr/libexec/PlistBuddy -c "Print :CFBundleExecutable" "${TEMP_SIMULATOR_FRAMEWORK_ORIG}/Info.plist" 2>/dev/null || echo "")
        if [ "$VERIFIED_EXECUTABLE" = "${XCFRAMEWORK_NAME}" ]; then
            print_success "Updated simulator Info.plist CFBundleExecutable from ${CURRENT_EXECUTABLE} to ${XCFRAMEWORK_NAME}"
        else
            print_error "Failed to update simulator Info.plist CFBundleExecutable. Current: ${VERIFIED_EXECUTABLE}, Expected: ${XCFRAMEWORK_NAME}"
            exit 1
        fi
    else
        # Key doesn't exist, add it
        /usr/libexec/PlistBuddy -c "Add :CFBundleExecutable string ${XCFRAMEWORK_NAME}" "${TEMP_SIMULATOR_FRAMEWORK_ORIG}/Info.plist" 2>/dev/null
        print_status "Added simulator Info.plist CFBundleExecutable: ${XCFRAMEWORK_NAME}"
    fi
else
    print_warning "Simulator Info.plist not found at ${TEMP_SIMULATOR_FRAMEWORK_ORIG}/Info.plist"
fi

# Update module.modulemap if it exists
if [ -d "${TEMP_SIMULATOR_FRAMEWORK_ORIG}/Modules/${PROJECT_NAME}.swiftmodule" ]; then
    mv "${TEMP_SIMULATOR_FRAMEWORK_ORIG}/Modules/${PROJECT_NAME}.swiftmodule" "${TEMP_SIMULATOR_FRAMEWORK_ORIG}/Modules/${XCFRAMEWORK_NAME}.swiftmodule"
    print_status "Renamed simulator swiftmodule from ${PROJECT_NAME} to ${XCFRAMEWORK_NAME}"
fi

# Now rename the framework folder itself
mv "${TEMP_SIMULATOR_FRAMEWORK_ORIG}" "${TEMP_SIMULATOR_FRAMEWORK}"
print_status "Renamed simulator framework folder from ${PROJECT_NAME}.framework to ${XCFRAMEWORK_NAME}.framework"

# Verify the binary exists with correct name
if [ ! -f "${TEMP_SIMULATOR_FRAMEWORK}/${XCFRAMEWORK_NAME}" ]; then
    print_error "Simulator binary ${XCFRAMEWORK_NAME} not found after renaming in ${TEMP_SIMULATOR_FRAMEWORK}"
    ls -la "${TEMP_SIMULATOR_FRAMEWORK}/" || true
    exit 1
fi

# Verify Info.plist matches the binary name
SIMULATOR_PLIST_EXECUTABLE=$(/usr/libexec/PlistBuddy -c "Print :CFBundleExecutable" "${TEMP_SIMULATOR_FRAMEWORK}/Info.plist" 2>/dev/null || echo "")
if [ "$SIMULATOR_PLIST_EXECUTABLE" != "${XCFRAMEWORK_NAME}" ]; then
    print_error "Simulator Info.plist CFBundleExecutable mismatch: expected ${XCFRAMEWORK_NAME}, found ${SIMULATOR_PLIST_EXECUTABLE}"
    exit 1
fi
print_success "Simulator framework verified: binary=${XCFRAMEWORK_NAME}, Info.plist=${SIMULATOR_PLIST_EXECUTABLE}"

# Create XCFramework
print_status "📦 Creating XCFramework..."

xcframework_path="${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework"
rm -rf "${xcframework_path}"

print_status "Creating XCFramework from:"
print_status "  Device: $TEMP_DEVICE_FRAMEWORK"
print_status "  Simulator: $TEMP_SIMULATOR_FRAMEWORK"
print_status "  Output: $xcframework_path"

xcodebuild -create-xcframework \
    -framework "${TEMP_DEVICE_FRAMEWORK}" \
    -framework "${TEMP_SIMULATOR_FRAMEWORK}" \
    -output "${xcframework_path}" 2>&1 | tee "${BUILD_DIR}/xcframework_create.log"

XCFRAMEWORK_EXIT_CODE=${PIPESTATUS[0]}

if [ $XCFRAMEWORK_EXIT_CODE -ne 0 ]; then
    print_error "Failed to create XCFramework (exit code: $XCFRAMEWORK_EXIT_CODE)"
    print_status "XCFramework creation log:"
    cat "${BUILD_DIR}/xcframework_create.log" || true
    exit 1
fi

if [ ! -d "${xcframework_path}" ]; then
    print_error "XCFramework directory not found after creation"
    exit 1
fi

print_success "XCFramework created: ${xcframework_path}"

# Update Info.plist in XCFramework to reflect correct framework name
print_status "🔧 Updating XCFramework Info.plist..."
XCFRAMEWORK_INFO_PLIST="${xcframework_path}/Info.plist"
if [ -f "${XCFRAMEWORK_INFO_PLIST}" ]; then
    # Update all LibraryPath entries to use XCFRAMEWORK_NAME
    /usr/libexec/PlistBuddy -c "Print :AvailableLibraries" "${XCFRAMEWORK_INFO_PLIST}" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        # Count number of libraries
        LIB_COUNT=$(/usr/libexec/PlistBuddy -c "Print :AvailableLibraries" "${XCFRAMEWORK_INFO_PLIST}" | grep -c "Dict" || echo "0")
        for ((i=0; i<$LIB_COUNT; i++)); do
            /usr/libexec/PlistBuddy -c "Set :AvailableLibraries:$i:LibraryPath ${XCFRAMEWORK_NAME}.framework" "${XCFRAMEWORK_INFO_PLIST}" 2>/dev/null || true
        done
        print_success "Updated XCFramework Info.plist LibraryPath to ${XCFRAMEWORK_NAME}.framework"
    fi
fi

# Verify module name in XCFramework
print_status "🔍 Verifying module name in XCFramework..."
MODULEMAP=$(find "${xcframework_path}" -name "module.modulemap" -type f | head -1)
if [ -n "$MODULEMAP" ] && [ -f "$MODULEMAP" ]; then
    MODULE_NAME=$(grep -E "^[[:space:]]*module[[:space:]]+[A-Za-z0-9_]+" "$MODULEMAP" | head -1 | sed -E 's/.*module[[:space:]]+([A-Za-z0-9_]+)[[:space:]]*\{.*/\1/' | xargs)
    echo "Detected module name in XCFramework: $MODULE_NAME"
    if [ "$MODULE_NAME" = "AriseMobile" ]; then
        print_success "✅ Module name is correct: AriseMobile"
    else
        print_warning "⚠️  Module name mismatch: expected 'AriseMobile', found '$MODULE_NAME'"
    fi
else
    print_warning "⚠️  Could not find module.modulemap to verify module name"
fi

# Verify XCFramework
print_status "🔍 Verifying XCFramework..."
if [ -d "${xcframework_path}" ]; then
    print_status "Framework contents:"
    ls -la "${xcframework_path}/"
    
    # Check architectures
    if [ -d "${xcframework_path}/ios-arm64/${XCFRAMEWORK_NAME}.framework" ]; then
        device_binary="${xcframework_path}/ios-arm64/${XCFRAMEWORK_NAME}.framework/${XCFRAMEWORK_NAME}"
        if [ -f "$device_binary" ]; then
            print_status "Device binary architectures:"
            lipo -info "$device_binary"
        fi
    fi
    
    # Check simulator framework (name can be ios-arm64-simulator or ios-arm64_x86_64-simulator)
    SIM_FRAMEWORK_DIR=$(find "${xcframework_path}" -path "*/simulator/${XCFRAMEWORK_NAME}.framework" -type d 2>/dev/null | head -1)
    if [ -n "$SIM_FRAMEWORK_DIR" ] && [ -d "$SIM_FRAMEWORK_DIR" ]; then
        sim_binary="${SIM_FRAMEWORK_DIR}/${XCFRAMEWORK_NAME}"
        if [ -f "$sim_binary" ]; then
            print_status "Simulator binary architectures:"
            lipo -info "$sim_binary"
        fi
    fi
    
    print_success "✅ XCFramework verification completed"
else
    print_error "XCFramework not found after creation"
    exit 1
fi

print_success "🎉 Build completed successfully!"
print_status "XCFramework location: ${xcframework_path}"
