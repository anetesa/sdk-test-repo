#!/bin/bash

# Script to generate detailed code coverage report with file-by-file breakdown
# Usage: ./scripts/generate_detailed_coverage.sh [path-to-xcresult]
#   - If path is provided, uses that .xcresult file
#   - Otherwise, looks for coverage/test-results.xcresult
#   - If not found, searches for latest .xcresult in DerivedData

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
COVERAGE_DIR="${PROJECT_ROOT}/coverage"
REPORT_FILE="${COVERAGE_DIR}/detailed_coverage_report.md"

# Function to find .xcresult file (same as generate_coverage_report.sh)
find_xcresult() {
    # If path provided as argument, use it
    if [ -n "$1" ] && [ -d "$1" ]; then
        echo "$1"
        return 0
    fi
    
    # Check for coverage/test-results.xcresult (from run_tests_with_coverage.sh)
    if [ -d "${COVERAGE_DIR}/test-results.xcresult" ]; then
        echo "${COVERAGE_DIR}/test-results.xcresult"
        return 0
    fi
    
    # Search for latest .xcresult in DerivedData
    PROJECT_PATH="${PROJECT_ROOT}/src/AriseMobileSdk.xcodeproj"
    PROJECT_NAME=$(basename "${PROJECT_PATH}" .xcodeproj)
    
    # Try default DerivedData location
    DERIVED_DATA="${HOME}/Library/Developer/Xcode/DerivedData"
    if [ -d "${DERIVED_DATA}" ]; then
        # Find all .xcresult files in DerivedData for this project
        LATEST_XCRESULT=$(find "${DERIVED_DATA}" -name "*.xcresult" -type d -path "*/${PROJECT_NAME}*" -exec stat -f "%m %N" {} \; 2>/dev/null | \
            sort -rn | head -1 | cut -d' ' -f2-)
        
        if [ -n "${LATEST_XCRESULT}" ] && [ -d "${LATEST_XCRESULT}" ]; then
            echo "${LATEST_XCRESULT}"
            return 0
        fi
    fi
    
    # Try project-specific DerivedData
    PROJECT_DERIVED_DATA="${PROJECT_ROOT}/src/build"
    if [ -d "${PROJECT_DERIVED_DATA}" ]; then
        LATEST_XCRESULT=$(find "${PROJECT_DERIVED_DATA}" -name "*.xcresult" -type d -exec stat -f "%m %N" {} \; 2>/dev/null | \
            sort -rn | head -1 | cut -d' ' -f2-)
        
        if [ -n "${LATEST_XCRESULT}" ] && [ -d "${LATEST_XCRESULT}" ]; then
            echo "${LATEST_XCRESULT}"
            return 0
        fi
    fi
    
    return 1
}

# Find .xcresult file
RESULTS_DIR=$(find_xcresult "$1")

if [ -z "${RESULTS_DIR}" ] || [ ! -d "${RESULTS_DIR}" ]; then
    echo -e "${RED}❌ Test results (.xcresult) not found${NC}"
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo "  ./scripts/generate_detailed_coverage.sh [path-to-xcresult]"
    echo ""
    echo -e "${YELLOW}The script will look for:${NC}"
    echo "  1. Path provided as argument"
    echo "  2. coverage/test-results.xcresult (from run_tests_with_coverage.sh)"
    echo "  3. Latest .xcresult in DerivedData (from Xcode Cmd+U)"
    echo ""
    echo -e "${YELLOW}To generate coverage data, run:${NC}"
    echo "  ./scripts/run_tests_with_coverage.sh"
    echo ""
    echo -e "${YELLOW}Or run tests in Xcode (Cmd+U) and provide the .xcresult path:${NC}"
    echo "  ./scripts/generate_detailed_coverage.sh ~/Library/Developer/Xcode/DerivedData/.../Logs/Test/*.xcresult"
    exit 1
fi

echo -e "${GREEN}📊 Using coverage data from: ${RESULTS_DIR}${NC}"

echo -e "${GREEN}📊 Generating detailed SDK code coverage report...${NC}"

# Filter to only include SDK source files (exclude tests, test app, models, and generated code)
# Include only: Services, Storages, Utils, Networking (except GeneratedSources), Mappers, Core
# Exclude: Models, AriseMobileSdkTests, AriseTestAppForDebug, GeneratedSources, OpenAPI
INCLUDE_PATTERNS="AriseMobileSdk/(Services|Storages|Utils|Networking|Mappers|Core|AriseMobileSdk\.swift|AriseMobileTTP\.swift)"
EXCLUDE_PATTERNS="AriseMobileSdkTests|AriseTestAppForDebug|\.xctest|TestHelpers|Mocks|/Models/|GeneratedSources|OpenAPI/generated|_backup"

# Get overall SDK coverage
SDK_COVERAGE=$(xcrun xccov view --report --files-for-target AriseMobileSdk "${RESULTS_DIR}" 2>/dev/null | \
    grep -E "${INCLUDE_PATTERNS}" | \
    grep -vE "${EXCLUDE_PATTERNS}" | \
    awk '{sum+=$1; count++} END {if (count>0) printf "%.2f%%", sum/count; else print "0.0%"}' || echo "0.0%")

# Get target coverage
TARGET_COVERAGE=$(xcrun xccov view --report --only-targets "${RESULTS_DIR}" 2>/dev/null || echo "Unable to generate target coverage")

# Get file-by-file coverage (SDK only)
FILE_COVERAGE=$(xcrun xccov view --report --files-for-target AriseMobileSdk "${RESULTS_DIR}" 2>/dev/null | \
    grep -E "${INCLUDE_PATTERNS}" | \
    grep -vE "${EXCLUDE_PATTERNS}" || echo "Unable to generate file coverage")

# Create detailed markdown report
cat > "${REPORT_FILE}" << EOF
# Detailed Code Coverage Report (SDK Only)

Generated: $(date)

**Note:** This report shows coverage only for SDK source code, excluding:
- Test files and test applications
- Model files (data structures)
- Generated code (OpenAPI, GeneratedSources)
- Backup files

**Included directories:**
- Services/
- Storages/
- Utils/
- Networking/ (excluding GeneratedSources/)
- Mappers/
- Core/
- Main SDK files (AriseMobileSdk.swift, AriseMobileTTP.swift)

## Overall SDK Coverage

**${SDK_COVERAGE}**

## Coverage by Target

\`\`\`
${TARGET_COVERAGE}
\`\`\`

## File-by-File Coverage

\`\`\`
${FILE_COVERAGE}
\`\`\`

## Coverage Categories

### Well Covered (>80%)
Files with high test coverage.

### Needs Improvement (50-80%)
Files that need additional test coverage.

### Poor Coverage (<50%)
Files with low test coverage that should be prioritized.

## Recommendations

1. Focus on files with <50% coverage first
2. Add edge case tests for critical components
3. Ensure all public API methods are tested
4. Add integration tests for complex workflows

## How to View Coverage in Xcode

1. Open \`src/AriseMobileSdk.xcodeproj\`
2. Product > Show Test Report (Cmd+9)
3. Select the test run
4. Click the "Coverage" tab
5. Browse files to see line-by-line coverage

## Coverage Data Location

Coverage data source: \`${RESULTS_DIR}\`

**Note:** This script automatically finds the latest coverage data from:
1. Path provided as argument (if specified)
2. \`coverage/test-results.xcresult\` (from \`run_tests_with_coverage.sh\`)
3. Latest \`.xcresult\` in DerivedData (from Xcode Cmd+U)

EOF

echo -e "${GREEN}✅ Detailed coverage report generated: ${REPORT_FILE}${NC}"
echo ""
echo -e "${BLUE}Coverage Summary:${NC}"
echo "$TARGET_COVERAGE" | head -10


