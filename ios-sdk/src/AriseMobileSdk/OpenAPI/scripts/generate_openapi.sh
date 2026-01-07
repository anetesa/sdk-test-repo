#!/bin/bash

# Script to automatically generate Swift OpenAPI client code
# This script handles the entire generation process from OpenAPI spec to Swift code

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# PROJECT_ROOT: from OpenAPI/scripts/ go up to ios-sdk root
# Script is in: ios-sdk/src/AriseMobileSdk/OpenAPI/scripts/
# Need to go: ../../../../ to reach ios-sdk/
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../../" && pwd)"

# Initialize default paths (will be overridden if custom file is provided)
OPENAPI_DIR="$PROJECT_ROOT/src/AriseMobileSdk/OpenAPI"
SPECS_DIR="$OPENAPI_DIR/specs"
GENERATED_DIR="$OPENAPI_DIR/generated"
GENERATED_SOURCES_DIR="$GENERATED_DIR/Sources/AriseApi"
NORMALIZE_SCRIPT="$OPENAPI_DIR/scripts/normalize_swagger_schemas.py"

# OpenAPI spec files
YAML_SPEC="$SPECS_DIR/arise-api.yaml"
JSON_SPEC="$SPECS_DIR/swagger.json"
USE_CUSTOM_FILE=false

# Check if a specific file is provided as argument (but not help flag)
if [ $# -ge 1 ] && [ "$1" != "-h" ] && [ "$1" != "--help" ] && [ -f "$1" ]; then
    # Use provided file and generate in the same directory as the spec file
    CUSTOM_SPEC_FILE="$1"
    CUSTOM_SPEC_FILE_ABS="$(cd "$(dirname "$CUSTOM_SPEC_FILE")" && pwd)/$(basename "$CUSTOM_SPEC_FILE")"
    CUSTOM_SPEC_DIR="$(dirname "$CUSTOM_SPEC_FILE_ABS")"
    
    # Determine spec type from extension
    if [[ "$CUSTOM_SPEC_FILE_ABS" == *.yaml ]] || [[ "$CUSTOM_SPEC_FILE_ABS" == *.yml ]]; then
        SPEC_TYPE="yaml"
    else
        SPEC_TYPE="json"
    fi
    
    # Generate in the same directory as the spec file
    GENERATED_DIR="$CUSTOM_SPEC_DIR/generated"
    GENERATED_SOURCES_DIR="$GENERATED_DIR/Sources/AriseApi"
    NORMALIZE_SCRIPT="$PROJECT_ROOT/src/AriseMobileSdk/OpenAPI/scripts/normalize_swagger_schemas.py"
    
    SPEC_FILE="$CUSTOM_SPEC_FILE_ABS"
    USE_CUSTOM_FILE=true
fi

# Configuration
PACKAGE_NAME="AriseApi"
SWIFT_VERSION="5.9"
MIN_IOS_VERSION="13.0"
MIN_MACOS_VERSION="10.15"

# Function to print colored messages
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_step() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📋 $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Step 1: Check prerequisites
check_prerequisites() {
    print_step "Checking prerequisites"
    
    # Check Swift
    if ! command_exists swift; then
        print_error "Swift is not installed. Please install Xcode Command Line Tools."
        exit 1
    fi
    SWIFT_VERSION_OUTPUT=$(swift --version | head -n1)
    print_info "Swift: $SWIFT_VERSION_OUTPUT"
    
    # Check Python (for normalization script)
    if ! command_exists python3; then
        print_error "Python 3 is not installed. Please install Python 3."
        exit 1
    fi
    PYTHON_VERSION=$(python3 --version)
    print_info "Python: $PYTHON_VERSION"
    
    # Check if specs directory exists (only for default mode)
    if [ "$USE_CUSTOM_FILE" = false ] && [ ! -d "$SPECS_DIR" ]; then
        print_error "Specs directory not found: $SPECS_DIR"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Step 2: Determine which spec file to use
determine_spec_file() {
    print_step "Determining OpenAPI specification file"
    
    if [ "$USE_CUSTOM_FILE" = true ]; then
        # Custom file already set
        if [ ! -f "$SPEC_FILE" ]; then
            print_error "Specified file not found: $SPEC_FILE"
            exit 1
        fi
        print_info "Using custom spec file: $SPEC_FILE"
        print_success "Using spec file: $SPEC_FILE (type: $SPEC_TYPE)"
        return
    fi
    
    # Default behavior: look for spec files in SPECS_DIR
    SPEC_FILE=""
    SPEC_TYPE=""
    
    if [ -f "$YAML_SPEC" ]; then
        SPEC_FILE="$YAML_SPEC"
        SPEC_TYPE="yaml"
        print_info "Found YAML spec: $YAML_SPEC"
    elif [ -f "$JSON_SPEC" ]; then
        SPEC_FILE="$JSON_SPEC"
        SPEC_TYPE="json"
        print_info "Found JSON spec: $JSON_SPEC"
        
        # Check if normalization is needed
        if grep -q '`' "$JSON_SPEC" || grep -q "Page\`1" "$JSON_SPEC"; then
            print_warning "JSON spec contains .NET generic types, normalization may be needed"
        fi
    else
        print_error "No OpenAPI specification found in $SPECS_DIR"
        print_error "Expected one of: arise-api.yaml or swagger.json"
        print_info "Or provide a custom file as argument: $0 <path/to/spec.yaml>"
        exit 1
    fi
    
    print_success "Using spec file: $SPEC_FILE (type: $SPEC_TYPE)"
}

# Step 3: Normalize JSON spec if needed
normalize_spec() {
    if [ "$SPEC_TYPE" != "json" ]; then
        print_info "Skipping normalization (not using JSON spec)"
        return
    fi
    
    print_step "Normalizing JSON specification"
    
    if [ ! -f "$NORMALIZE_SCRIPT" ]; then
        print_warning "Normalization script not found: $NORMALIZE_SCRIPT"
        print_warning "Skipping normalization. Generated code may have long class names."
        return
    fi
    
    # Check if normalization is needed
    if grep -q '`' "$SPEC_FILE" || grep -q "Page\`1" "$SPEC_FILE"; then
        print_info "Running normalization script..."
        if python3 "$NORMALIZE_SCRIPT" "$SPEC_FILE"; then
            print_success "Specification normalized successfully"
        else
            print_error "Normalization failed"
            exit 1
        fi
    else
        print_info "Specification doesn't need normalization"
    fi
}

# Step 4: Create directory structure
create_directory_structure() {
    print_step "Creating directory structure"
    
    # Create all necessary directories from scratch
    # mkdir -p creates parent directories automatically, but we'll be explicit for clarity
    print_info "Creating base directory: $GENERATED_DIR"
    mkdir -p "$GENERATED_DIR"
    
    print_info "Creating sources directory: $GENERATED_SOURCES_DIR"
    mkdir -p "$GENERATED_SOURCES_DIR"
    
    # Verify directories were created
    if [ ! -d "$GENERATED_DIR" ]; then
        print_error "Failed to create directory: $GENERATED_DIR"
        exit 1
    fi
    
    if [ ! -d "$GENERATED_SOURCES_DIR" ]; then
        print_error "Failed to create directory: $GENERATED_SOURCES_DIR"
        exit 1
    fi
    
    print_success "Directory structure created: $GENERATED_DIR"
    print_info "  - Base: $GENERATED_DIR"
    print_info "  - Sources: $GENERATED_SOURCES_DIR"
}

# Step 5: Create Package.swift
create_package_swift() {
    print_step "Creating Package.swift"
    
    # Ensure directory exists
    if [ ! -d "$GENERATED_DIR" ]; then
        print_error "Generated directory does not exist: $GENERATED_DIR"
        exit 1
    fi
    
    PACKAGE_FILE="$GENERATED_DIR/Package.swift"
    
    # Extract major and minor version numbers
    IOS_MAJOR=$(echo $MIN_IOS_VERSION | cut -d. -f1)
    MACOS_MAJOR=$(echo $MIN_MACOS_VERSION | cut -d. -f1)
    MACOS_MINOR=$(echo $MIN_MACOS_VERSION | cut -d. -f2)
    
    # iOS uses only major version (e.g., .v13)
    # macOS uses major_minor for versions < 11 (e.g., .v10_15) or major for >= 11 (e.g., .v11)
    if [ "$MACOS_MAJOR" -lt 11 ]; then
        MACOS_VERSION=".v${MACOS_MAJOR}_${MACOS_MINOR}"
    else
        MACOS_VERSION=".v${MACOS_MAJOR}"
    fi
    
    cat > "$PACKAGE_FILE" << EOF
// swift-tools-version: $SWIFT_VERSION
// Generated by generate_openapi.sh - DO NOT EDIT MANUALLY
import PackageDescription

let package = Package(
    name: "$PACKAGE_NAME",
    platforms: [
        .iOS(.v${IOS_MAJOR}),
        .macOS(${MACOS_VERSION})
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "$PACKAGE_NAME",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession")
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
            ]
        )
    ]
)
EOF

    print_success "Package.swift created: $PACKAGE_FILE"
}

# Step 6: Create or update generator config
create_generator_config() {
    print_step "Creating/updating generator configuration"
    
    # Ensure directory exists
    if [ ! -d "$GENERATED_SOURCES_DIR" ]; then
        print_error "Sources directory does not exist: $GENERATED_SOURCES_DIR"
        exit 1
    fi
    
    CONFIG_FILE="$GENERATED_SOURCES_DIR/openapi-generator-config.yaml"
    
    # Check if config file already exists
    if [ -f "$CONFIG_FILE" ]; then
        print_info "Config file exists, checking for namingStrategy..."
        
        # Check if namingStrategy is already present
        if grep -q "namingStrategy:" "$CONFIG_FILE"; then
            # Check if it's set to idiomatic
            if grep -q "namingStrategy:.*idiomatic" "$CONFIG_FILE"; then
                print_info "namingStrategy: idiomatic already present"
            else
                # Update existing namingStrategy to idiomatic
                print_info "Updating namingStrategy to idiomatic..."
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    # macOS
                    sed -i '' 's/namingStrategy:.*/namingStrategy: idiomatic/' "$CONFIG_FILE"
                else
                    # Linux
                    sed -i 's/namingStrategy:.*/namingStrategy: idiomatic/' "$CONFIG_FILE"
                fi
                print_success "Updated namingStrategy to idiomatic"
            fi
        else
            # Add namingStrategy: idiomatic to existing config
            print_info "Adding namingStrategy: idiomatic to existing config..."
            # Use a temporary file for safer editing
            TEMP_CONFIG=$(mktemp)
            ADDED=false
            
            # Read the file and add namingStrategy after accessModifier or at the end
            while IFS= read -r line || [ -n "$line" ]; do
                echo "$line" >> "$TEMP_CONFIG"
                # Add namingStrategy after accessModifier line
                if [[ "$line" =~ ^accessModifier: ]] && [ "$ADDED" = false ]; then
                    echo "namingStrategy: idiomatic" >> "$TEMP_CONFIG"
                    ADDED=true
                fi
            done < "$CONFIG_FILE"
            
            # If we didn't find accessModifier, add at the end
            if [ "$ADDED" = false ]; then
                echo "namingStrategy: idiomatic" >> "$TEMP_CONFIG"
            fi
            
            mv "$TEMP_CONFIG" "$CONFIG_FILE"
            print_success "Added namingStrategy: idiomatic to config"
        fi
    else
        # Create new config file with namingStrategy: idiomatic
        print_info "Creating new config file with namingStrategy: idiomatic..."
        cat > "$CONFIG_FILE" << EOF
# Configuration for Swift OpenAPI Generator
# Documentation: https://swiftpackageindex.com/apple/swift-openapi-generator/documentation

generate:
  - types
  - client
accessModifier: public
namingStrategy: idiomatic
EOF
        print_success "Generator config created: $CONFIG_FILE"
    fi
    
    print_info "Configuration includes: namingStrategy: idiomatic"
}

# Step 7: Copy spec file to generated directory
copy_spec_file() {
    print_step "Copying specification file"
    
    # Ensure directory exists
    if [ ! -d "$GENERATED_SOURCES_DIR" ]; then
        print_error "Sources directory does not exist: $GENERATED_SOURCES_DIR"
        exit 1
    fi
    
    if [ "$SPEC_TYPE" = "yaml" ]; then
        DEST_FILE="$GENERATED_SOURCES_DIR/openapi.yaml"
    else
        DEST_FILE="$GENERATED_SOURCES_DIR/openapi.json"
    fi
    
    if [ ! -f "$SPEC_FILE" ]; then
        print_error "Source specification file not found: $SPEC_FILE"
        exit 1
    fi
    
    cp "$SPEC_FILE" "$DEST_FILE"
    print_success "Specification copied to: $DEST_FILE"
}

# Step 8: Generate Swift code
generate_swift_code() {
    print_step "Generating Swift OpenAPI code"
    
    # Ensure directory exists
    if [ ! -d "$GENERATED_DIR" ]; then
        print_error "Generated directory does not exist: $GENERATED_DIR"
        exit 1
    fi
    
    # Save current directory to return later
    ORIGINAL_DIR=$(pwd)
    
    cd "$GENERATED_DIR" || {
        print_error "Failed to change to directory: $GENERATED_DIR"
        exit 1
    }
    
    # Create a placeholder Swift file if it doesn't exist
    # This is required for the target to be valid
    PLACEHOLDER_FILE="$GENERATED_SOURCES_DIR/${PACKAGE_NAME}.swift"
    if [ ! -f "$PLACEHOLDER_FILE" ]; then
        echo "// Placeholder file for OpenAPI code generation" > "$PLACEHOLDER_FILE"
        print_info "Created placeholder Swift file"
    fi
    
    print_info "Running Swift OpenAPI Generator plugin..."
    print_info "This may take a few minutes..."
    
    # First, try to resolve dependencies
    print_info "Resolving package dependencies..."
    if ! swift package resolve >/dev/null 2>&1; then
        print_warning "Package resolution had warnings, continuing..."
    fi
    
    # Generate code using the plugin
    GENERATION_OUTPUT=$(swift package plugin --allow-writing-to-package-directory generate-code-from-openapi 2>&1)
    GENERATION_EXIT_CODE=$?
    
    # Check if generation succeeded
    if echo "$GENERATION_OUTPUT" | grep -q "successfully completed"; then
        print_success "Code generation completed successfully"
        
        # Verify generated files exist
        if [ -d "$GENERATED_SOURCES_DIR/GeneratedSources" ]; then
            GENERATED_TYPES="$GENERATED_SOURCES_DIR/GeneratedSources/Types.swift"
            GENERATED_CLIENT="$GENERATED_SOURCES_DIR/GeneratedSources/Client.swift"
            
            if [ -f "$GENERATED_TYPES" ] && [ -f "$GENERATED_CLIENT" ]; then
                print_success "Generated files verified: Types.swift and Client.swift"
            else
                print_info "GeneratedSources directory created, files may be generated on first build"
            fi
        fi
    elif [ $GENERATION_EXIT_CODE -eq 0 ]; then
        # Exit code is 0 but no success message - might still have worked
        if [ -d "$GENERATED_SOURCES_DIR/GeneratedSources" ]; then
            print_success "Code generation completed (files found in GeneratedSources)"
        else
            print_warning "Code generation completed but GeneratedSources not found"
            print_info "Files may be generated during Xcode build (this is normal for SPM plugins)"
        fi
    else
        print_error "Code generation failed"
        echo "$GENERATION_OUTPUT" | grep -E "(error|Error)" | head -5
        print_info "Troubleshooting:"
        print_info "1. Make sure swift-openapi-generator is installed"
        print_info "2. Check that the spec file is valid OpenAPI 3.0"
        print_info "3. Verify internet connection (dependencies need to be downloaded)"
        exit 1
    fi
    
    # Return to original directory
    cd "$ORIGINAL_DIR" || {
        print_warning "Failed to return to original directory, continuing..."
    }
}

# Step 9: Verify generation
verify_generation() {
    print_step "Verifying generated code"
    
    GENERATED_TYPES="$GENERATED_SOURCES_DIR/GeneratedSources/Types.swift"
    GENERATED_CLIENT="$GENERATED_SOURCES_DIR/GeneratedSources/Client.swift"
    
    if [ -f "$GENERATED_TYPES" ]; then
        print_success "Types.swift found: $GENERATED_TYPES"
        TYPE_COUNT=$(grep -c "^public struct\|^public enum\|^public class" "$GENERATED_TYPES" || echo "0")
        print_info "Found $TYPE_COUNT type definitions"
    else
        print_warning "Types.swift not found (may be generated in DerivedData during Xcode build)"
    fi
    
    if [ -f "$GENERATED_CLIENT" ]; then
        print_success "Client.swift found: $GENERATED_CLIENT"
        OPERATION_COUNT=$(grep -c "^public func" "$GENERATED_CLIENT" || echo "0")
        print_info "Found $OPERATION_COUNT API operations"
    else
        print_warning "Client.swift not found (may be generated in DerivedData during Xcode build)"
    fi
    
    # Check if GeneratedSources directory exists
    if [ -d "$GENERATED_SOURCES_DIR/GeneratedSources" ]; then
        print_success "GeneratedSources directory exists"
    else
        print_info "GeneratedSources will be created during Xcode build"
        print_info "This is normal - Swift OpenAPI Generator creates files in DerivedData"
    fi
}

# Step 10: Fix method names and other issues in generated Client.swift
fix_method_names() {
    print_step "Fixing method names and HTTPBody issues"
    
    SOURCE_CLIENT="$GENERATED_SOURCES_DIR/GeneratedSources/Client.swift"
    FIX_SCRIPT="$OPENAPI_DIR/scripts/fix_method_names.py"
    
    if [ ! -f "$SOURCE_CLIENT" ]; then
        print_warning "Client.swift not found, skipping method name fix"
        return
    fi
    
    if [ ! -f "$FIX_SCRIPT" ]; then
        print_warning "Fix script not found: $FIX_SCRIPT"
        return
    fi
    
    print_info "Running method name fix script..."
    if python3 "$FIX_SCRIPT" "$SOURCE_CLIENT"; then
        print_success "Method names fixed successfully"
    else
        print_warning "Method name fix had issues, continuing anyway"
    fi
}

# Step 11: Copy generated files to Networking/GeneratedSources
copy_generated_files() {
    # Only copy to Networking/GeneratedSources if using default paths
    if [ "$USE_CUSTOM_FILE" = true ]; then
        print_info "Skipping copy to Networking/GeneratedSources (using custom file)"
        print_info "Generated files are in: $GENERATED_SOURCES_DIR/GeneratedSources"
        return
    fi
    
    print_step "Copying generated files to Networking/GeneratedSources"
    
    SOURCE_TYPES="$GENERATED_SOURCES_DIR/GeneratedSources/Types.swift"
    SOURCE_CLIENT="$GENERATED_SOURCES_DIR/GeneratedSources/Client.swift"
    DEST_DIR="$PROJECT_ROOT/src/AriseMobileSdk/Networking/GeneratedSources"
    
    if [ ! -f "$SOURCE_TYPES" ] || [ ! -f "$SOURCE_CLIENT" ]; then
        print_warning "Generated files not found, skipping copy"
        print_info "Files may be generated during Xcode build"
        return
    fi
    
    # Create destination directory if it doesn't exist
    mkdir -p "$DEST_DIR"
    
    # Copy files
    if cp "$SOURCE_TYPES" "$DEST_DIR/Types.swift" && cp "$SOURCE_CLIENT" "$DEST_DIR/Client.swift"; then
        print_success "Copied Types.swift and Client.swift to $DEST_DIR"
        print_info "Files are ready to use in the project"
    else
        print_error "Failed to copy generated files"
        exit 1
    fi
}

# Step 11: Summary
print_summary() {
    print_step "Generation Summary"
    
    echo ""
    print_info "Generated package: $PACKAGE_NAME"
    print_info "Location: $GENERATED_DIR"
    print_info "Specification: $SPEC_FILE"
    echo ""
    
    print_success "Swift OpenAPI code generation completed!"
    echo ""
    
    if [ "$USE_CUSTOM_FILE" = true ]; then
        print_info "Generated files are in: $GENERATED_DIR"
        print_info "You can use this package as a local Swift Package dependency"
    else
        print_info "Next steps:"
        echo "  1. Open Xcode project: $PROJECT_ROOT/src/AriseMobileSdk.xcodeproj"
        echo "  2. Add Local Swift Package:"
        echo "     File → Add Package Dependencies... → Add Local..."
        echo "     Select: $GENERATED_DIR"
        echo "  3. Add AriseApi product to AriseMobileSdk target"
        echo "  4. Build the project (Cmd+B)"
        echo ""
    fi
    
    print_info "Note: Generated files may be in DerivedData during Xcode build"
    print_info "This is normal behavior for Swift Package Manager plugins"
}

# Main execution
main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║   Swift OpenAPI Code Generator for Arise Mobile SDK      ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Show usage if help requested
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "Usage: $0 [path/to/openapi-spec.yaml|json]"
        echo ""
        echo "Options:"
        echo "  <file>     Path to OpenAPI specification file (YAML or JSON)"
        echo "             If provided, generates code in the same directory as the spec file"
        echo "  -h, --help Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0                                    # Use default spec from src/AriseMobileSdk/OpenAPI/specs/"
        echo "  $0 /path/to/custom-api.yaml          # Use custom file, generate in /path/to/generated/"
        echo "  $0 ../api-specs/swagger.json          # Use relative path, generate in ../api-specs/generated/"
        echo ""
        exit 0
    fi
    
    check_prerequisites
    determine_spec_file
    normalize_spec
    create_directory_structure
    create_package_swift
    create_generator_config
    copy_spec_file
    generate_swift_code
    verify_generation
    fix_method_names
    copy_generated_files
    print_summary
    
    echo ""
    print_success "All done! ✨"
    echo ""
}

# Run main function with all script arguments
main "$@"

