#!/bin/bash

# Build script for creating XCFramework from Xcode build products
# This script uses already built frameworks from Xcode DerivedData
# Useful for local development when you've already built the project in Xcode

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

print_status "🚀 Creating ${FRAMEWORK_NAME} XCFramework from Xcode build products..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECT_PATH="${PROJECT_ROOT}/src/${PROJECT_NAME}.xcodeproj"
OUTPUT_DIR="${SCRIPT_DIR}"

# Clean output directory
rm -rf ${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework
mkdir -p ${OUTPUT_DIR}

print_status "Project path: $PROJECT_PATH"
print_status "Output directory: $OUTPUT_DIR"

# Function to find Xcode DerivedData path
find_derived_data() {
    local scheme_name="$1"
    local sdk="$2"
    local config="${3:-Debug}"
    
    # Try to find DerivedData using xcodebuild
    local derived_data_path
    derived_data_path=$(xcodebuild -showBuildSettings \
        -project "${PROJECT_PATH}" \
        -scheme "${scheme_name}" \
        -configuration "${config}" \
        -sdk "${sdk}" 2>/dev/null | \
        grep -E "^\s*BUILD_DIR\s*=" | \
        head -1 | \
        sed -E 's/.*BUILD_DIR\s*=\s*(.+)/\1/' | \
        xargs)
    
    if [ -n "$derived_data_path" ]; then
        # Extract DerivedData path from BUILD_DIR
        # BUILD_DIR is usually: DerivedData/ProjectName-XXXXX/Build/Products
        derived_data_path=$(echo "$derived_data_path" | sed -E 's|/Build/Products.*||')
        echo "$derived_data_path"
        return 0
    fi
    
    # Fallback: search in default DerivedData location
    local default_dd="$HOME/Library/Developer/Xcode/DerivedData"
    if [ -d "$default_dd" ]; then
        # Find project-specific DerivedData folder
        local project_dd=$(find "$default_dd" -maxdepth 1 -type d -name "${PROJECT_NAME}-*" 2>/dev/null | head -1)
        if [ -n "$project_dd" ] && [ -d "$project_dd" ]; then
            echo "$project_dd"
            return 0
        fi
    fi
    
    return 1
}

# Function to find framework in DerivedData
find_framework() {
    local derived_data="$1"
    local sdk="$2"
    local config="${3:-Debug}"
    
    # Standard path
    local framework_path="${derived_data}/Build/Products/${config}-${sdk}/${PROJECT_NAME}.framework"
    
    if [ -d "$framework_path" ]; then
        echo "$framework_path"
        return 0
    fi
    
    # Alternative paths to search
    local search_paths=(
        "${derived_data}/Build/Products/${config}-${sdk}/${PROJECT_NAME}.framework"
        "${derived_data}/Build/Products/${PROJECT_NAME}.framework"
        "${derived_data}/Build/Products/${config}/${PROJECT_NAME}.framework"
    )
    
    for path in "${search_paths[@]}"; do
        if [ -d "$path" ]; then
            echo "$path"
            return 0
        fi
    done
    
    # Last resort: search recursively
    local found=$(find "$derived_data" -name "${PROJECT_NAME}.framework" -type d 2>/dev/null | grep -E "${sdk}|${config}" | head -1)
    if [ -n "$found" ] && [ -d "$found" ]; then
        echo "$found"
        return 0
    fi
    
    return 1
}

# Find device framework
print_status "🔍 Searching for device framework in Xcode DerivedData..."

DEVICE_DERIVED_DATA=$(find_derived_data "${SCHEME_NAME}" "iphoneos" "Debug")
if [ -z "$DEVICE_DERIVED_DATA" ] || [ ! -d "$DEVICE_DERIVED_DATA" ]; then
    print_warning "Could not find device DerivedData using xcodebuild, trying default location..."
    DEVICE_DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData"
    if [ ! -d "$DEVICE_DERIVED_DATA" ]; then
        print_error "Xcode DerivedData directory not found at: $DEVICE_DERIVED_DATA"
        print_error "Please build the project in Xcode first (Product → Build for iOS Device)"
        exit 1
    fi
fi

print_status "Device DerivedData: $DEVICE_DERIVED_DATA"

DEVICE_FRAMEWORK=$(find_framework "$DEVICE_DERIVED_DATA" "iphoneos" "Debug")
if [ -z "$DEVICE_FRAMEWORK" ] || [ ! -d "$DEVICE_FRAMEWORK" ]; then
    print_error "Device framework not found!"
    print_error "Please build the project in Xcode first:"
    print_error "  1. Open ${PROJECT_PATH} in Xcode"
    print_error "  2. Select 'Any iOS Device' or a physical device"
    print_error "  3. Product → Build (⌘B)"
    exit 1
fi

print_success "Device framework found: $DEVICE_FRAMEWORK"

# Find simulator framework
print_status "🔍 Searching for simulator framework in Xcode DerivedData..."

SIMULATOR_DERIVED_DATA=$(find_derived_data "${SCHEME_NAME}" "iphonesimulator" "Debug")
if [ -z "$SIMULATOR_DERIVED_DATA" ] || [ ! -d "$SIMULATOR_DERIVED_DATA" ]; then
    # Use same DerivedData as device if simulator not found separately
    SIMULATOR_DERIVED_DATA="$DEVICE_DERIVED_DATA"
    print_status "Using same DerivedData for simulator: $SIMULATOR_DERIVED_DATA"
fi

SIMULATOR_FRAMEWORK=$(find_framework "$SIMULATOR_DERIVED_DATA" "iphonesimulator" "Debug")
if [ -z "$SIMULATOR_FRAMEWORK" ] || [ ! -d "$SIMULATOR_FRAMEWORK" ]; then
    print_warning "Simulator framework not found!"
    print_warning "Please build the project in Xcode for simulator:"
    print_warning "  1. Open ${PROJECT_PATH} in Xcode"
    print_warning "  2. Select any iOS Simulator"
    print_warning "  3. Product → Build (⌘B)"
    print_warning ""
    print_warning "Continuing with device-only XCFramework..."
    SIMULATOR_FRAMEWORK=""
fi

if [ -n "$SIMULATOR_FRAMEWORK" ] && [ -d "$SIMULATOR_FRAMEWORK" ]; then
    print_success "Simulator framework found: $SIMULATOR_FRAMEWORK"
fi

# Create XCFramework structure
print_status "📦 Creating XCFramework structure..."

# Determine platform identifiers
DEVICE_PLATFORM="ios-arm64"
SIMULATOR_PLATFORM="ios-arm64_x86_64-simulator"

# Check architectures in simulator framework
if [ -n "$SIMULATOR_FRAMEWORK" ] && [ -d "$SIMULATOR_FRAMEWORK" ]; then
    SIMULATOR_BINARY="${SIMULATOR_FRAMEWORK}/${PROJECT_NAME}"
    if [ -f "$SIMULATOR_BINARY" ]; then
        ARCHS=$(lipo -info "$SIMULATOR_BINARY" 2>/dev/null | sed -E 's/.*: (.*)$/\1/' || echo "")
        if echo "$ARCHS" | grep -q "x86_64"; then
            SIMULATOR_PLATFORM="ios-arm64_x86_64-simulator"
        else
            SIMULATOR_PLATFORM="ios-arm64-simulator"
        fi
    fi
fi

# Create directories
mkdir -p "${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework/${DEVICE_PLATFORM}/${FRAMEWORK_NAME}.framework"

if [ -n "$SIMULATOR_FRAMEWORK" ] && [ -d "$SIMULATOR_FRAMEWORK" ]; then
    mkdir -p "${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework/${SIMULATOR_PLATFORM}/${FRAMEWORK_NAME}.framework"
fi

# Copy device framework
print_status "📋 Copying device framework..."
cp -R "${DEVICE_FRAMEWORK}"/* "${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework/${DEVICE_PLATFORM}/${FRAMEWORK_NAME}.framework/"

# Rename binary if needed
DEVICE_BINARY="${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework/${DEVICE_PLATFORM}/${FRAMEWORK_NAME}.framework/${PROJECT_NAME}"
if [ -f "$DEVICE_BINARY" ]; then
    if [ "$(basename "$DEVICE_BINARY")" != "${FRAMEWORK_NAME}" ]; then
        mv "$DEVICE_BINARY" "${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework/${DEVICE_PLATFORM}/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"
        print_status "Renamed device binary to ${FRAMEWORK_NAME}"
    fi
fi

# Update Info.plist if it exists
DEVICE_INFO_PLIST="${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework/${DEVICE_PLATFORM}/${FRAMEWORK_NAME}.framework/Info.plist"
if [ -f "$DEVICE_INFO_PLIST" ]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleExecutable ${FRAMEWORK_NAME}" "$DEVICE_INFO_PLIST" 2>/dev/null || true
    print_status "Updated device Info.plist"
fi

# Rename swiftmodule if it exists
DEVICE_SWIFTMODULE="${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework/${DEVICE_PLATFORM}/${FRAMEWORK_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule"
if [ -d "$DEVICE_SWIFTMODULE" ]; then
    mv "$DEVICE_SWIFTMODULE" "${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework/${DEVICE_PLATFORM}/${FRAMEWORK_NAME}.framework/Modules/${FRAMEWORK_NAME}.swiftmodule"
    print_status "Renamed device swiftmodule"
fi

print_success "Device framework copied successfully"

# Copy simulator framework if available
if [ -n "$SIMULATOR_FRAMEWORK" ] && [ -d "$SIMULATOR_FRAMEWORK" ]; then
    print_status "📋 Copying simulator framework..."
    cp -R "${SIMULATOR_FRAMEWORK}"/* "${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework/${SIMULATOR_PLATFORM}/${FRAMEWORK_NAME}.framework/"
    
    # Rename binary if needed
    SIMULATOR_BINARY="${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework/${SIMULATOR_PLATFORM}/${FRAMEWORK_NAME}.framework/${PROJECT_NAME}"
    if [ -f "$SIMULATOR_BINARY" ]; then
        if [ "$(basename "$SIMULATOR_BINARY")" != "${FRAMEWORK_NAME}" ]; then
            mv "$SIMULATOR_BINARY" "${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework/${SIMULATOR_PLATFORM}/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"
            print_status "Renamed simulator binary to ${FRAMEWORK_NAME}"
        fi
    fi
    
    # Update Info.plist if it exists
    SIMULATOR_INFO_PLIST="${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework/${SIMULATOR_PLATFORM}/${FRAMEWORK_NAME}.framework/Info.plist"
    if [ -f "$SIMULATOR_INFO_PLIST" ]; then
        /usr/libexec/PlistBuddy -c "Set :CFBundleExecutable ${FRAMEWORK_NAME}" "$SIMULATOR_INFO_PLIST" 2>/dev/null || true
        print_status "Updated simulator Info.plist"
    fi
    
    # Rename swiftmodule if it exists
    SIMULATOR_SWIFTMODULE="${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework/${SIMULATOR_PLATFORM}/${FRAMEWORK_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule"
    if [ -d "$SIMULATOR_SWIFTMODULE" ]; then
        mv "$SIMULATOR_SWIFTMODULE" "${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework/${SIMULATOR_PLATFORM}/${FRAMEWORK_NAME}.framework/Modules/${FRAMEWORK_NAME}.swiftmodule"
        print_status "Renamed simulator swiftmodule"
    fi
    
    print_success "Simulator framework copied successfully"
fi

# Create Info.plist for XCFramework
print_status "📝 Creating XCFramework Info.plist..."

XCFRAMEWORK_INFO_PLIST="${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework/Info.plist"

cat > "$XCFRAMEWORK_INFO_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>AvailableLibraries</key>
    <array>
        <dict>
            <key>LibraryIdentifier</key>
            <string>${DEVICE_PLATFORM}</string>
            <key>LibraryPath</key>
            <string>${FRAMEWORK_NAME}.framework</string>
            <key>SupportedArchitectures</key>
            <array>
                <string>arm64</string>
            </array>
            <key>SupportedPlatform</key>
            <string>ios</string>
        </dict>
EOF

if [ -n "$SIMULATOR_FRAMEWORK" ] && [ -d "$SIMULATOR_FRAMEWORK" ]; then
    cat >> "$XCFRAMEWORK_INFO_PLIST" <<EOF
        <dict>
            <key>LibraryIdentifier</key>
            <string>${SIMULATOR_PLATFORM}</string>
            <key>LibraryPath</key>
            <string>${FRAMEWORK_NAME}.framework</string>
            <key>SupportedArchitectures</key>
            <array>
EOF
    # Add architectures based on simulator binary
    if [ -f "${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework/${SIMULATOR_PLATFORM}/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" ]; then
        ARCHS=$(lipo -info "${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework/${SIMULATOR_PLATFORM}/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" 2>/dev/null | sed -E 's/.*: (.*)$/\1/' || echo "arm64")
        for arch in $ARCHS; do
            echo "                <string>$arch</string>" >> "$XCFRAMEWORK_INFO_PLIST"
        done
    else
        echo "                <string>arm64</string>" >> "$XCFRAMEWORK_INFO_PLIST"
    fi
    cat >> "$XCFRAMEWORK_INFO_PLIST" <<EOF
            </array>
            <key>SupportedPlatform</key>
            <string>ios</string>
            <key>SupportedPlatformVariant</key>
            <string>simulator</string>
        </dict>
EOF
fi

cat >> "$XCFRAMEWORK_INFO_PLIST" <<EOF
    </array>
    <key>CFBundlePackageType</key>
    <string>XFWK</string>
    <key>XCFrameworkFormatVersion</key>
    <string>1.0</string>
</dict>
</plist>
EOF

print_success "XCFramework Info.plist created"

# Verify the framework
print_status "✅ Verifying XCFramework..."

if [ -d "${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework" ]; then
    print_success "XCFramework created successfully!"
    print_status "Framework location: ${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework"
    
    # Show framework contents
    print_status "📋 Framework contents:"
    ls -la "${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework/"
    
    # Show architectures
    print_status "🏗️ Supported architectures:"
    if [ -f "${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework/${DEVICE_PLATFORM}/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" ]; then
        print_status "Device (${DEVICE_PLATFORM}):"
        lipo -info "${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework/${DEVICE_PLATFORM}/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" || true
    fi
    
    if [ -n "$SIMULATOR_FRAMEWORK" ] && [ -d "$SIMULATOR_FRAMEWORK" ]; then
        if [ -f "${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework/${SIMULATOR_PLATFORM}/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" ]; then
            print_status "Simulator (${SIMULATOR_PLATFORM}):"
            lipo -info "${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework/${SIMULATOR_PLATFORM}/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" || true
        fi
    fi
    
    print_success "🎉 XCFramework created successfully from Xcode build products!"
    print_status "📍 Location: ${OUTPUT_DIR}/${XCFRAMEWORK_NAME}.xcframework"
else
    print_error "❌ Failed to create XCFramework"
    exit 1
fi

