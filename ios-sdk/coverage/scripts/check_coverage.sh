#!/bin/bash

# Script to check code coverage and display summary
# Usage: ./scripts/check_coverage.sh [minimum-coverage-percentage] [path-to-xcresult]
#   - First argument: minimum coverage percentage (default: 75)
#   - Second argument: path to .xcresult file (optional)
#   - If .xcresult path not provided, looks for coverage/test-results.xcresult
#   - If not found, searches for latest .xcresult in DerivedData

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
COVERAGE_DIR="${PROJECT_ROOT}/coverage"

# Parse arguments
MIN_COVERAGE=${1:-75}  # Default minimum coverage is 75%
XCRESULT_PATH="$2"     # Optional path to .xcresult file

# Function to find .xcresult file
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
    
    # Also check in coverage/coverage/ (alternative location)
    if [ -d "${COVERAGE_DIR}/coverage/test-results.xcresult" ]; then
        echo "${COVERAGE_DIR}/coverage/test-results.xcresult"
        return 0
    fi
    
    # Search for latest .xcresult in DerivedData
    PROJECT_PATH="${PROJECT_ROOT}/src/AriseMobileSdk.xcodeproj"
    PROJECT_NAME=$(basename "${PROJECT_PATH}" .xcodeproj)
    
    # Try default DerivedData location
    DERIVED_DATA="${HOME}/Library/Developer/Xcode/DerivedData"
    if [ -d "${DERIVED_DATA}" ]; then
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
RESULTS_DIR=$(find_xcresult "${XCRESULT_PATH}")

if [ -z "${RESULTS_DIR}" ] || [ ! -d "${RESULTS_DIR}" ]; then
    echo -e "${RED}❌ Test results (.xcresult) not found${NC}"
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo "  ./scripts/check_coverage.sh [min-coverage] [path-to-xcresult]"
    echo ""
    echo -e "${YELLOW}The script will look for:${NC}"
    echo "  1. Path provided as second argument"
    echo "  2. coverage/test-results.xcresult (from run_tests_with_coverage.sh)"
    echo "  3. Latest .xcresult in DerivedData (from Xcode Cmd+U)"
    echo ""
    echo -e "${YELLOW}To generate coverage data, run:${NC}"
    echo "  ./scripts/run_tests_with_coverage.sh"
    exit 1
fi

echo -e "${BLUE}📊 Using coverage data from: ${RESULTS_DIR}${NC}"
echo ""

# Get all coverage data - parse xccov output format: "percentage% (covered/total)    /path/to/file"
ALL_COVERAGE=$(xcrun xccov view --report "${RESULTS_DIR}" 2>/dev/null | grep "AriseMobileSdk/" || echo "")

if [ -z "$ALL_COVERAGE" ]; then
    echo -e "${RED}❌ Unable to read SDK coverage data${NC}"
    echo -e "${YELLOW}Try running tests with coverage first: ./scripts/run_tests_with_coverage.sh${NC}"
    exit 1
fi

# Filter to only include testable components (exclude Models, GeneratedSources, OpenAPI, Protocols-only files)
# Testable components: Services, Storages, Utils, Networking (middlewares only), Mappers, Core, main SDK files
TESTABLE_PATTERNS="AriseMobileSdk/(Services|Storages|Utils|Networking/Middlewares|Mappers|Core|AriseMobileSdk\.swift|AriseMobileTTP\.swift)"
EXCLUDE_PATTERNS="AriseMobileSdkTests|AriseTestAppForDebug|\.xctest|TestHelpers|Mocks|/Models/|GeneratedSources|OpenAPI|_backup|Protocol\.swift$"

# Get testable files only and parse coverage percentage
# Format: "percentage% (covered/total)    /path/to/file"
# Extract percentage (first number before %)
TESTABLE_COVERAGE=$(echo "$ALL_COVERAGE" | \
    grep -E "${TESTABLE_PATTERNS}" | \
    grep -vE "${EXCLUDE_PATTERNS}" | \
    awk '{
        # Extract percentage from format like "37.14% (13/35)    /path/to/file"
        if (match($0, /([0-9]+\.[0-9]+)%/)) {
            percentage = substr($0, RSTART, RLENGTH-1)
            printf "%.2f %s\n", percentage, $0
        }
    }' || echo "")

if [ -z "$TESTABLE_COVERAGE" ]; then
    echo -e "${RED}❌ No testable files found in coverage data${NC}"
    exit 1
fi

# Calculate overall coverage (first column is percentage)
COVERAGE_PERCENT=$(echo "$TESTABLE_COVERAGE" | \
    awk '{sum+=$1; count++} END {if (count>0) printf "%.2f", sum/count; else print "0.0"}')

# Group by category and calculate coverage per category
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Code Coverage Report - Testable Components Only${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""


# Helper function to display category coverage
display_category() {
    local category_name="$1"
    local category_icon="$2"
    local category_pattern="$3"
    local category_files=$(echo "$TESTABLE_COVERAGE" | grep "$category_pattern" || echo "")
    
    if [ -n "$category_files" ]; then
        local category_cov=$(echo "$category_files" | awk '{sum+=$1; count++} END {if (count>0) printf "%.2f", sum/count; else print "0.0"}')
        local category_count=$(echo "$category_files" | wc -l | tr -d ' ')
        echo -e "${BLUE}${category_icon} ${category_name} (${category_count} files):${NC} ${category_cov}%"
    echo "$category_files" | awk '{
        percentage = $1
        # Find the filename (last component of path)
        for (i = 2; i <= NF; i++) {
            if ($i ~ /\.swift$/) {
                n = split($i, parts, "/")
                filename = parts[n]
                printf "  %-60s %6.2f%%\n", filename, percentage
                break
            }
        }
    }'
        echo ""
    fi
}

# Services
display_category "Services" "📦" "AriseMobileSdk/Services/"

# Storages
display_category "Storages" "💾" "AriseMobileSdk/Storages/"

# Utils
display_category "Utils" "🛠️ " "AriseMobileSdk/Utils/"

# Networking (Middlewares only)
display_category "Networking" "🌐" "AriseMobileSdk/Networking/"

# Mappers
display_category "Mappers" "🔄" "AriseMobileSdk/Mappers/"

# Core
display_category "Core" "⚙️ " "AriseMobileSdk/Core/"

# Main SDK files
MAIN_FILES=$(echo "$TESTABLE_COVERAGE" | grep -E "AriseMobileSdk\.swift|AriseMobileTTP\.swift" || echo "")
if [ -n "$MAIN_FILES" ]; then
    MAIN_COV=$(echo "$MAIN_FILES" | awk '{sum+=$1; count++} END {if (count>0) printf "%.2f", sum/count; else print "0.0"}')
    MAIN_COUNT=$(echo "$MAIN_FILES" | wc -l | tr -d ' ')
    echo -e "${BLUE}📱 Main SDK Files (${MAIN_COUNT} files):${NC} ${MAIN_COV}%"
    echo "$MAIN_FILES" | awk '{
        percentage = $1
        for (i = 2; i <= NF; i++) {
            if ($i ~ /\.swift$/) {
                n = split($i, parts, "/")
                filename = parts[n]
                printf "  %-60s %6.2f%%\n", filename, percentage
                break
            }
        }
    }'
    echo ""
fi

# Summary
TOTAL_FILES=$(echo "$TESTABLE_COVERAGE" | wc -l | tr -d ' ')
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Summary${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "Total testable files: ${TOTAL_FILES}"
echo -e "Overall coverage: ${COVERAGE_PERCENT}%"
echo ""

# Files with low coverage (< 70%)
LOW_COVERAGE=$(echo "$TESTABLE_COVERAGE" | awk '$1 < 70 {print $0}' || echo "")
if [ -n "$LOW_COVERAGE" ]; then
    LOW_COUNT=$(echo "$LOW_COVERAGE" | wc -l | tr -d ' ')
    echo -e "${YELLOW}⚠️  Files with coverage < 70% (${LOW_COUNT} files):${NC}"
    echo "$LOW_COVERAGE" | awk '{
        percentage = $1
        for (i = 2; i <= NF; i++) {
            if ($i ~ /\.swift$/) {
                n = split($i, parts, "/")
                filename = parts[n]
                printf "  %-60s %6.2f%%\n", filename, percentage
                break
            }
        }
    }'
    echo ""
fi

# Check if coverage meets minimum requirement
COVERAGE_INT=$(echo "$COVERAGE_PERCENT" | cut -d. -f1)

if [ "$COVERAGE_INT" -ge "$MIN_COVERAGE" ]; then
    echo -e "${GREEN}✅ Overall Coverage: ${COVERAGE_PERCENT}% (meets minimum of ${MIN_COVERAGE}%)${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Overall Coverage: ${COVERAGE_PERCENT}% (below minimum of ${MIN_COVERAGE}%)${NC}"
    echo -e "${YELLOW}Consider adding more tests to improve coverage.${NC}"
    exit 0  # Don't fail, just warn
fi
