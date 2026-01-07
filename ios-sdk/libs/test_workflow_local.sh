#!/bin/bash

# Script to run the complete CI workflow locally
# This mimics all steps from .github/workflows/ios-sdk-tests.yml

set -e

echo "🚀 Running complete CI workflow locally..."
echo "This will execute all steps from ios-sdk-tests.yml workflow"
echo ""

# Set up paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_step() {
    echo -e "${BLUE}▶ $1${NC}"
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

# Step 1: Checkout (already done, we're in the repo)
print_step "Step 1: Checkout source repository"
print_success "Already in repository: $PROJECT_ROOT"
echo ""

# Step 2: Setup Xcode (verify version)
print_step "Step 2: Verify Swift and Xcode versions"
echo "Xcode version:"
xcodebuild -version
echo ""
echo "Swift version:"
swift --version
echo ""
echo "Full Swift version details:"
xcrun swift --version
echo ""

# Step 3: Cache (simulate - check if cache exists, but we'll use local paths)
print_step "Step 3: Checking for cached dependencies"
DERIVED_DATA="$PROJECT_ROOT/DerivedData-Tests-Local"
CACHE_PATHS=(
    "$DERIVED_DATA"
    "$HOME/Library/Developer/Xcode/DerivedData"
    "$HOME/Library/Caches/org.swift.swiftpm"
    "$DERIVED_DATA/SourcePackages"
)

CACHE_FOUND=false
for path in "${CACHE_PATHS[@]}"; do
    if [ -d "$path" ] && [ "$(ls -A "$path" 2>/dev/null)" ]; then
        SIZE=$(du -sh "$path" 2>/dev/null | cut -f1)
        print_success "Found cache: $path (size: $SIZE)"
        CACHE_FOUND=true
    fi
done

if [ "$CACHE_FOUND" = false ]; then
    print_warning "No cache found - first run will be slower"
fi
echo ""

# Step 4: Run Tests
print_step "Step 4: Run Tests"
echo "This is the main test execution step..."
echo ""

# Make test script executable
chmod +x ios-sdk/libs/test_ci.sh

# Override DerivedData path for local testing
export DERIVED_DATA_OVERRIDE="$DERIVED_DATA"

print_warning "Running test_ci.sh (this may take 30-60 minutes for first run)..."
print_warning "Using local DerivedData: $DERIVED_DATA"
echo ""

# Run tests using CI script with local paths
./ios-sdk/libs/test_ci.sh || {
    print_error "Tests failed"
    exit 1
}
echo ""

# Step 5: Upload Test Results (simulate - just show where they are)
print_step "Step 5: Test Results"
if [ -d "./test-results.xcresult" ]; then
    SIZE=$(du -sh "./test-results.xcresult" 2>/dev/null | cut -f1)
    print_success "Test results found: ./test-results.xcresult (size: $SIZE)"
    echo "  To view: xcresulttool get --path ./test-results.xcresult --format json"
else
    print_warning "Test results not found at ./test-results.xcresult"
fi

if [ -f "/tmp/test_output.log" ]; then
    SIZE=$(du -sh "/tmp/test_output.log" 2>/dev/null | cut -f1)
    print_success "Test output log found: /tmp/test_output.log (size: $SIZE)"
else
    print_warning "Test output log not found at /tmp/test_output.log"
fi
echo ""

# Step 6: Generate Test Coverage Report
print_step "Step 6: Generate Test Coverage Report"
if [ -d "./test-results.xcresult" ]; then
    echo "📊 Generating test coverage report using project scripts..."
    
    # Make scripts executable
    chmod +x ios-sdk/coverage/scripts/*.sh 2>/dev/null || true
    
    # Generate coverage report using project script
    if [ -f "ios-sdk/coverage/scripts/generate_coverage_report.sh" ]; then
        echo "✅ Using generate_coverage_report.sh..."
        cd ios-sdk/coverage/scripts
        bash generate_coverage_report.sh "../../../test-results.xcresult" || {
            echo "⚠️  generate_coverage_report.sh failed, trying detailed report..."
            bash generate_detailed_coverage.sh "../../../test-results.xcresult" || {
                echo "⚠️  Detailed report also failed, using fallback"
            }
        }
        cd ../../..
    elif [ -f "ios-sdk/coverage/scripts/generate_detailed_coverage.sh" ]; then
        echo "✅ Using generate_detailed_coverage.sh..."
        cd ios-sdk/coverage/scripts
        bash generate_detailed_coverage.sh "../../../test-results.xcresult" || echo "⚠️  Detailed report generation failed"
        cd ../../..
    else
        echo "⚠️  Coverage report scripts not found, using fallback..."
    fi
    
    # Also run check_coverage.sh for summary
    if [ -f "ios-sdk/coverage/scripts/check_coverage.sh" ]; then
        echo ""
        echo "📋 Running coverage check..."
        cd ios-sdk/coverage/scripts
        bash check_coverage.sh 75 "../../../test-results.xcresult" || echo "⚠️  Coverage check failed"
        cd ../../..
    fi
    
    # Display generated reports if they exist
    if [ -f "ios-sdk/coverage/coverage_report.md" ]; then
        echo ""
        echo "✅ Coverage report generated: ios-sdk/coverage/coverage_report.md"
        echo "📄 Report preview (first 50 lines):"
        head -50 ios-sdk/coverage/coverage_report.md || true
    fi
    
    if [ -f "ios-sdk/coverage/detailed_coverage_report.md" ]; then
        echo ""
        echo "✅ Detailed coverage report generated: ios-sdk/coverage/detailed_coverage_report.md"
    fi
else
    print_warning "Test results bundle not found at ./test-results.xcresult"
fi
echo ""

# Step 7: Upload Coverage Reports (simulate - just show where they are)
print_step "Step 7: Coverage Reports"
COVERAGE_FILES=(
    "ios-sdk/coverage/coverage_report.md"
    "ios-sdk/coverage/detailed_coverage_report.md"
)

COVERAGE_FOUND=false
for file in "${COVERAGE_FILES[@]}"; do
    if [ -f "$file" ]; then
        SIZE=$(du -sh "$file" 2>/dev/null | cut -f1)
        print_success "Coverage report found: $file (size: $SIZE)"
        COVERAGE_FOUND=true
    fi
done

if [ "$COVERAGE_FOUND" = false ]; then
    print_warning "No coverage reports generated"
fi
echo ""

# Summary
print_step "Workflow Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_success "All workflow steps completed locally!"
echo ""
echo "📊 Results:"
echo "  • Test results: ./test-results.xcresult"
echo "  • Test logs: /tmp/test_output.log"
echo "  • Coverage reports: ios-sdk/coverage/"
echo ""
echo "💡 Tips:"
echo "  • To view test results: open ./test-results.xcresult"
echo "  • To view coverage: cat ios-sdk/coverage/coverage_report.md"
echo "  • To clean and rerun: rm -rf DerivedData-Tests-Local test-results.xcresult"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

