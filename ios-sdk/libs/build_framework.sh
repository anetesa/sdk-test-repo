#!/bin/bash

# --- Configuration ---
FRAMEWORK_NAME="AriseMobileSdk"
TARGET_NAME="${FRAMEWORK_NAME}"
SCHEME_NAME="${FRAMEWORK_NAME}"

# --- Colors for output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Helper functions ---
print_status() {
    echo -e "${BLUE}💡 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

ask_yes_no() {
    local prompt="$1"
    local default="${2:-y}"
    local answer
    
    # Check if running in interactive terminal
    if [ ! -t 0 ]; then
        # Not interactive, use default
        print_status "$prompt (non-interactive, using default: $default)"
        if [ "$default" = "y" ]; then
            return 0
        else
            return 1
        fi
    fi
    
    while true; do
        if [ "$default" = "y" ]; then
            echo -e "${BLUE}💡 $prompt (Y/n): ${NC}" >&2
        else
            echo -e "${BLUE}💡 $prompt (y/N): ${NC}" >&2
        fi
        read -r answer
        answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
        
        if [ -z "$answer" ]; then
            answer="$default"
        fi
        
        case "$answer" in
            y|yes)
                return 0
                ;;
            n|no)
                return 1
                ;;
            *)
                echo -e "${RED}❌ Please answer 'y' or 'n'${NC}" >&2
                ;;
        esac
    done
}

# --- Main script ---
print_status "🚀 Building ${FRAMEWORK_NAME} framework..."

# Determine script location and set paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECT_PATH="${PROJECT_ROOT}/src/${FRAMEWORK_NAME}.xcodeproj"
OUTPUT_DIR="${SCRIPT_DIR}"

# Check if running from the correct directory structure
if [ ! -d "${PROJECT_ROOT}/src" ]; then
    print_error "Please run this script from the libs directory or ensure src/ directory exists in parent"
    exit 1
fi

# Ensure output directory exists
mkdir -p ${OUTPUT_DIR}

# Remove old XCFramework
print_status "Removing old XCFramework..."
rm -rf ${OUTPUT_DIR}/AriseMobileSdk.xcframework

# Build for device
print_status "📱 Building for device (arm64)..."
xcodebuild \
    -project ${PROJECT_PATH} \
    -target ${TARGET_NAME} \
    -configuration Debug \
    -sdk iphoneos \
    -arch arm64 \
    -resolvePackageDependencies \
    build

if [ $? -eq 0 ]; then
    print_success "Device build completed successfully"
else
    print_error "Device build failed"
    exit 1
fi

# Build for simulator
print_status "📱 Building for simulator (arm64)..."
# Try to find an available simulator
SIMULATOR_NAME=$(xcrun simctl list devices available | grep "iPhone" | head -1 | sed 's/.*(\([^)]*\)).*/\1/')
if [ -z "$SIMULATOR_NAME" ]; then
    SIMULATOR_NAME="iPhone 15 Pro"
fi
print_status "Using simulator: $SIMULATOR_NAME"

xcodebuild \
    -project ${PROJECT_PATH} \
    -scheme ${SCHEME_NAME} \
    -configuration Debug \
    -destination "platform=iOS Simulator,name=$SIMULATOR_NAME" \
    -resolvePackageDependencies \
    build

if [ $? -eq 0 ]; then
    print_success "Simulator build completed successfully"
else
    print_error "Simulator build failed"
    exit 1
fi

# Find the latest DerivedData path for AriseMobileSdk (not TestApp)
DERIVED_DATA_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "*AriseMobileSdk*" -type d | grep -v TestApp | head -1)
print_status "Using DerivedData path: $DERIVED_DATA_PATH"

# Create XCFramework using xcodebuild -create-xcframework
print_status "📦 Creating XCFramework using xcodebuild -create-xcframework..."

# Extract frameworks and dSYMs from DerivedData
DEVICE_FRAMEWORK="$DERIVED_DATA_PATH/Build/Products/Debug-iphoneos/AriseMobileSdk.framework"
DEVICE_DSYM="$DERIVED_DATA_PATH/Build/Products/Debug-iphoneos/AriseMobileSdk.framework.dSYM"
SIMULATOR_FRAMEWORK="$DERIVED_DATA_PATH/Build/Products/Debug-iphonesimulator/AriseMobileSdk.framework"
SIMULATOR_DSYM="$DERIVED_DATA_PATH/Build/Products/Debug-iphonesimulator/AriseMobileSdk.framework.dSYM"

if [ -d "$DEVICE_FRAMEWORK" ]; then
    print_success "Device framework found at: $DEVICE_FRAMEWORK"
    
    if [ -d "$SIMULATOR_FRAMEWORK" ]; then
        print_success "Simulator framework found at: $SIMULATOR_FRAMEWORK"
        print_status "Creating universal XCFramework manually..."
        
        # Create XCFramework structure manually
        mkdir -p ${OUTPUT_DIR}/AriseMobileSdk.xcframework/ios-arm64/AriseMobileSdk.framework
        mkdir -p ${OUTPUT_DIR}/AriseMobileSdk.xcframework/ios-arm64-simulator/AriseMobileSdk.framework
        
        # Copy device framework
        cp -R "$DEVICE_FRAMEWORK"/* ${OUTPUT_DIR}/AriseMobileSdk.xcframework/ios-arm64/AriseMobileSdk.framework/
        print_success "Device framework copied successfully"
        
        # Remove any nested frameworks (CloudCommerce should not be embedded)
        if [ -d "${OUTPUT_DIR}/AriseMobileSdk.xcframework/ios-arm64/AriseMobileSdk.framework/Frameworks" ]; then
            print_status "Removing nested Frameworks directory from device framework..."
            rm -rf "${OUTPUT_DIR}/AriseMobileSdk.xcframework/ios-arm64/AriseMobileSdk.framework/Frameworks"
        fi
        
        # Copy simulator framework
        cp -R "$SIMULATOR_FRAMEWORK"/* ${OUTPUT_DIR}/AriseMobileSdk.xcframework/ios-arm64-simulator/AriseMobileSdk.framework/
        print_success "Simulator framework copied successfully"
        
        # Remove any nested frameworks (CloudCommerce should not be embedded)
        if [ -d "${OUTPUT_DIR}/AriseMobileSdk.xcframework/ios-arm64-simulator/AriseMobileSdk.framework/Frameworks" ]; then
            print_status "Removing nested Frameworks directory from simulator framework..."
            rm -rf "${OUTPUT_DIR}/AriseMobileSdk.xcframework/ios-arm64-simulator/AriseMobileSdk.framework/Frameworks"
        fi
        
        # Ask user if they want to include dSYM files
        echo ""
        print_status "📦 dSYM files detected. Do you want to include them in the XCFramework?"
        if ask_yes_no "Include dSYM files?" "y"; then
            # Copy device dSYM if it exists
            if [ -d "$DEVICE_DSYM" ]; then
                cp -R "$DEVICE_DSYM" ${OUTPUT_DIR}/AriseMobileSdk.xcframework/ios-arm64/
                print_success "Device dSYM copied successfully"
            else
                print_status "⚠️  Device dSYM not found (this is expected if DEBUG_INFORMATION_FORMAT is not set to dwarf-with-dsym)"
            fi
            
            # Copy simulator dSYM if it exists
            if [ -d "$SIMULATOR_DSYM" ]; then
                cp -R "$SIMULATOR_DSYM" ${OUTPUT_DIR}/AriseMobileSdk.xcframework/ios-arm64-simulator/
                print_success "Simulator dSYM copied successfully"
            else
                print_status "⚠️  Simulator dSYM not found (this is expected if DEBUG_INFORMATION_FORMAT is not set to dwarf-with-dsym)"
            fi
        else
            print_status "⏭️  Skipping dSYM files (not included in XCFramework)"
        fi
        
        # Create Info.plist
        cat > ${OUTPUT_DIR}/AriseMobileSdk.xcframework/Info.plist << 'EOF'
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
            <string>AriseMobileSdk.framework</string>
            <key>SupportedArchitectures</key>
            <array>
                <string>arm64</string>
            </array>
            <key>SupportedPlatform</key>
            <string>ios</string>
        </dict>
        <dict>
            <key>LibraryIdentifier</key>
            <string>ios-arm64-simulator</string>
            <key>LibraryPath</key>
            <string>AriseMobileSdk.framework</string>
            <key>SupportedArchitectures</key>
            <array>
                <string>arm64</string>
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
        print_success "Info.plist created successfully"
        
    else
        print_warning "Simulator framework not found, creating device-only XCFramework..."
        
        # Create XCFramework structure manually
        mkdir -p ${OUTPUT_DIR}/AriseMobileSdk.xcframework/ios-arm64/AriseMobileSdk.framework
        
        # Copy device framework
        cp -R "$DEVICE_FRAMEWORK"/* ${OUTPUT_DIR}/AriseMobileSdk.xcframework/ios-arm64/AriseMobileSdk.framework/
        print_success "Device framework copied successfully"
        
        # Remove any nested frameworks (CloudCommerce should not be embedded)
        if [ -d "${OUTPUT_DIR}/AriseMobileSdk.xcframework/ios-arm64/AriseMobileSdk.framework/Frameworks" ]; then
            print_status "Removing nested Frameworks directory from device framework..."
            rm -rf "${OUTPUT_DIR}/AriseMobileSdk.xcframework/ios-arm64/AriseMobileSdk.framework/Frameworks"
        fi
        
        # Ask user if they want to include dSYM files
        echo ""
        print_status "📦 dSYM files detected. Do you want to include them in the XCFramework?"
        if ask_yes_no "Include dSYM files?" "y"; then
            # Copy device dSYM if it exists
            if [ -d "$DEVICE_DSYM" ]; then
                cp -R "$DEVICE_DSYM" ${OUTPUT_DIR}/AriseMobileSdk.xcframework/ios-arm64/
                print_success "Device dSYM copied successfully"
            else
                print_status "⚠️  Device dSYM not found (this is expected if DEBUG_INFORMATION_FORMAT is not set to dwarf-with-dsym)"
            fi
        else
            print_status "⏭️  Skipping dSYM files (not included in XCFramework)"
        fi
        
        # Create Info.plist
        cat > ${OUTPUT_DIR}/AriseMobileSdk.xcframework/Info.plist << 'EOF'
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
            <string>AriseMobileSdk.framework</string>
            <key>SupportedArchitectures</key>
            <array>
                <string>arm64</string>
            </array>
            <key>SupportedPlatform</key>
            <string>ios</string>
        </dict>
    </array>
    <key>CFBundlePackageType</key>
    <string>XFWK</string>
    <key>XCFrameworkFormatVersion</key>
    <string>1.0</string>
</dict>
</plist>
EOF
        print_success "Info.plist created successfully"
    fi
    
    print_success "XCFramework created successfully"
else
    print_error "Device framework not found at: $DEVICE_FRAMEWORK"
    exit 1
fi

# Verify the framework
print_status "✅ Verifying framework..."
if [ -d "${OUTPUT_DIR}/AriseMobileSdk.xcframework" ]; then
    print_success "XCFramework created successfully!"
    print_status "Framework location: ${OUTPUT_DIR}/AriseMobileSdk.xcframework"
    
    # Show framework contents
    print_status "📋 Framework contents:"
    ls -la ${OUTPUT_DIR}/AriseMobileSdk.xcframework/
    
    # Verify no nested frameworks
    print_status "🔍 Checking for nested frameworks..."
    if find ${OUTPUT_DIR}/AriseMobileSdk.xcframework -type d -name "Frameworks" | grep -q .; then
        print_error "⚠️  WARNING: Found nested Frameworks directory! This should not be present."
        find ${OUTPUT_DIR}/AriseMobileSdk.xcframework -type d -name "Frameworks"
    else
        print_success "✅ No nested Frameworks found (correct)"
    fi
    
    # Verify dSYM files
    print_status "🔍 Checking for dSYM files..."
    DSYM_COUNT=$(find ${OUTPUT_DIR}/AriseMobileSdk.xcframework -name "*.dSYM" -type d | wc -l | tr -d ' ')
    if [ "$DSYM_COUNT" -gt 0 ]; then
        print_success "✅ Found $DSYM_COUNT dSYM file(s)"
        find ${OUTPUT_DIR}/AriseMobileSdk.xcframework -name "*.dSYM" -type d
    else
        print_status "⚠️  No dSYM files found in XCFramework"
    fi
    
    # Show architectures for each platform
    print_status "🏗️ Supported architectures:"
    find ${OUTPUT_DIR}/AriseMobileSdk.xcframework -name "*.framework" -exec echo "Framework: {}" \; -exec lipo -info {}/AriseMobileSdk \;
    
    print_status "📊 Framework summary:"
    print_status "   - Device (iOS): arm64"
    print_status "   - Simulator: arm64 (Apple Silicon only)"
    print_status "   - Note: x86_64 not supported in iOS 26.0+"
    
else
    print_error "❌ Failed to create XCFramework"
    exit 1
fi

print_success "🎉 Universal XCFramework build completed successfully!"
print_status "Universal framework supports:"
print_status "  • iOS devices (arm64)"
print_status "  • iOS Simulator on Apple Silicon (arm64)"
print_status "  • Combined device and simulator builds into single XCFramework"
print_status "📍 Location: ${OUTPUT_DIR}/AriseMobileSdk.xcframework"