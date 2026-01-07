#!/bin/bash

# Script to run tests with code coverage enabled
# Usage: ./scripts/run_tests_with_coverage.sh [test-suite-name]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
PROJECT_PATH="${PROJECT_ROOT}/src/AriseMobileSdk.xcodeproj"
SCHEME="AriseMobileSdk"
DESTINATION="platform=iOS Simulator,name=iPhone 17"
COVERAGE_DIR="${PROJECT_ROOT}/coverage"
RESULTS_DIR="${COVERAGE_DIR}/test-results.xcresult"

# Create coverage directory if it doesn't exist
mkdir -p "${COVERAGE_DIR}"

# Remove old test results if they exist
if [ -d "${RESULTS_DIR}" ]; then
    echo -e "${YELLOW}Removing old test results...${NC}"
    rm -rf "${RESULTS_DIR}"
fi

echo -e "${GREEN}🧪 Running tests with code coverage...${NC}"

# Build arguments
BUILD_ARGS=(
    -project "${PROJECT_PATH}"
    -scheme "${SCHEME}"
    -destination "${DESTINATION}"
    -enableCodeCoverage YES
    -derivedDataPath "${PROJECT_ROOT}/src/build"
)

# Add test filter if provided
if [ -n "$1" ]; then
    BUILD_ARGS+=(-only-testing:"AriseMobileSdkTests/$1")
    echo -e "${YELLOW}Running specific test suite: $1${NC}"
fi

# Run tests
echo -e "${GREEN}Running tests...${NC}"
xcodebuild test \
    "${BUILD_ARGS[@]}" \
    -resultBundlePath "${RESULTS_DIR}" \
    2>&1 | tee "${COVERAGE_DIR}/test-output.log"

# Check if tests passed
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo -e "${GREEN}✅ Tests completed successfully!${NC}"
    echo -e "${GREEN}Coverage data saved to: ${RESULTS_DIR}${NC}"
    echo ""
    echo -e "${YELLOW}To view coverage in Xcode:${NC}"
    echo "1. Open ${PROJECT_PATH}"
    echo "2. Product > Show Test Report"
    echo "3. Select the test run and click 'Coverage' tab"
    echo ""
    echo -e "${YELLOW}To generate coverage report, run:${NC}"
    echo "./scripts/generate_coverage_report.sh"
else
    echo -e "${RED}❌ Tests failed. Check ${COVERAGE_DIR}/test-output.log for details.${NC}"
    exit 1
fi

