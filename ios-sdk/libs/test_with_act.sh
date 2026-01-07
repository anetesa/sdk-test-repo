#!/bin/bash

# Script to test GitHub Actions workflow locally using 'act'
# Install act: brew install act (on macOS) or see https://github.com/nektos/act

set -e

echo "🚀 Testing GitHub Actions workflow with 'act'..."
echo ""

# Check if act is installed
if ! command -v act &> /dev/null; then
    echo "❌ 'act' is not installed"
    echo ""
    echo "📦 Install it:"
    echo "  macOS: brew install act"
    echo "  Linux: See https://github.com/nektos/act#installation"
    echo "  Windows: See https://github.com/nektos/act#installation"
    echo ""
    echo "💡 Alternative: Use ./test_workflow_local.sh for manual workflow testing"
    exit 1
fi

echo "✅ 'act' is installed"
echo ""

# Run the test workflow
echo "🧪 Running ios-sdk-tests workflow..."
echo ""

# Act command to run the test workflow
# -W: workflow file
# -j: job name
# --container-architecture: use linux/amd64 for compatibility
act \
  -W .github/workflows/ios-sdk-tests.yml \
  -j test \
  --container-architecture linux/amd64 \
  --verbose

echo ""
echo "✅ Workflow test completed!"

