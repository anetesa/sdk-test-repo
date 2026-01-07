#!/bin/bash

echo "🚀 Setting up iOS development environment..."

# Check if CocoaPods is installed
if ! command -v pod &> /dev/null; then
    echo "❌ CocoaPods is not installed. Please install it first:"
    echo "   sudo gem install cocoapods"
    exit 1
fi

# Check CocoaPods version
POD_VERSION=$(pod --version)
echo "📱 Current CocoaPods version: $POD_VERSION"

# Navigate to iOS directory
cd ios

# Install pods
echo "📦 Installing pods..."
pod install

echo "✅ iOS setup completed successfully!"
echo "💡 You can now open Arise.xcworkspace in Xcode" 