#!/bin/bash

# Script to generate sentry.properties from environment variables

set -e

echo "🔧 Generating Sentry configuration from .env variables..."

# Get the project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Generate Sentry configuration
echo "🔧 Generating Sentry configuration..."
cd "$PROJECT_ROOT"
ruby scripts/generate-sentry-config.rb --verbose

echo ""
echo "✅ Sentry configuration generated!"
echo "📁 Location: ios/sentry.properties"
echo ""
echo "💡 To update, just run this script again after changing your .env files" 
