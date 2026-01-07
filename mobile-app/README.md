# Arise React Native App

A React Native application for contactless payment processing using Mastercard's CloudCommerce SDK and Apple's Tap to Pay on iPhone technology.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Mobile App Developer Workflow](#mobile-app-developer-workflow)
- [CloudCommerce SDK Integration](#cloudcommerce-sdk-integration)
- [Troubleshooting](#troubleshooting)
- [Technology Stack](#technology-stack)
- [Learn More](#learn-more)

## 🚀 Overview

This is a React Native project bootstrapped using [`@react-native-community/cli`](https://github.com/react-native-community/cli) that enables merchants to process contactless payments through their iPhones using Mastercard's CloudCommerce SDK.

## ⚙️ Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** >= 20.17 (latest recommended)
- **Yarn** 3.6.4
- **CocoaPods** 1.16.2
- **Xcode** 16.4+ (for iOS development)
- **Ruby** 3.2.2
- **Apple Silicon Mac** (required for iOS development)
- **Environment files** (request from your team):
  - `.env.uat`
  - `.env.development`
  - `.env.production`

> **Note**: Make sure you have completed the [React Native Environment Setup](https://reactnative.dev/docs/environment-setup) instructions before proceeding.

## 🏃‍♂️ Quick Start

### 1. Setup CloudCommerce Framework

The CloudCommerce framework (100MB+) is not included in the repository due to size constraints. You must:

1. **Request the framework** from your team if you don't have access
2. Create a `Framework` folder inside the `/ios` directory
3. Place the `CloudCommerce.xcframework` file inside the Framework folder

### 2. Install Dependencies

```bash
# Install JavaScript dependencies
yarn

# Install iOS dependencies
cd ios
pod install
cd ..
```

### 3. Build and Run

#### Step 1: Build in Xcode

1. Open Xcode and open `Arise.xcworkspace`. this file is inside `/ios` folder.
2. Select a simulator (iPhone 15 with iOS 18.5 recommended)
3. Build the app using the Play button in Xcode
4. You'll see an error asking you to have Metro Bundler running.

#### Step 2: Start Metro Bundler

```bash
# Development environment
yarn ios

# UAT environment
yarn ios-uat
```

Press `R` in the Metro bundler to reload the app.

### Environment Configuration

The app supports multiple environments. Ensure you have the correct environment files:

- `.env.development` - Local development
- `.env.uat` - User Acceptance Testing
- `.env.production` - Production environment

### Xcode Schema Configuration

Our project uses **three Xcode schemas** that automatically configure the environment when you build the app:

#### How It Works

1. **Select a Schema**: Choose from Development, UAT, or Production in Xcode
2. **Pre-Build Script**: Before building, the schema runs a script that:
   - Generates a `.env` file with the correct `APP_ENV` (development/uat/production)
   - Configures Sentry with environment-specific keys
3. **Two Ruby Scripts**: The process uses:
   - `scripts/process-env.rb` - Merges environment variables from `.env.*` files
   - `scripts/setup-sentry.sh` - Configures Sentry for the selected environment

#### Available Schemas

| Schema          | Environment   | Use Case                      |
| --------------- | ------------- | ----------------------------- |
| **Development** | `development` | Local development and testing |
| **UAT**         | `uat`         | User Acceptance Testing       |
| **Production**  | `production`  | Production builds             |

When you select a schema and build, the app automatically uses the correct environment variables and Sentry configuration for that environment.

## 👨‍💻 Mobile App Developer Workflow

### Code Review Process

Ideally, create a pull request and ask a teammate to review your code. In exceptional cases where you need to push urgently, review it yourself and merge — but still create the pull request so there's a record. That way, your teammates can review it later and leave comments.

### Design Implementation

Use the Toggle Element Inspector feature to check pixel sizes, colors, margins, and paddings. Compare each of these values one by one against the Figma design.

### Pull Request Requirements

The pull request should include at least some screenshots of the app working.

### Pre-Push Testing

Before pushing your code, make sure it hasn't broken any other screens or views in the app.

### Edge Case Testing

Test edge cases in your feature: log in and out multiple times, try to crash the part you worked on, and do your best to catch any issues before QA does. Once that's done, you can upload to TestFlight.

### TestFlight Validation

Test everything again in TestFlight. If you find a bug, decide whether to push a fix or do a rollback. Any fix must still meet the standards from steps 2, 3, and 4.

### Task Management

Only after testing in TestFlight, move your task to Done and your ticket to IN QA. Until then, it should remain In Progress.

## 💳 CloudCommerce SDK Integration

This project includes Mastercard's CloudCommerce SDK for Tap-to-Pay functionality. The configuration is already set up, but here's a reference for the setup process.

### Architecture & Data Flow

For a deep dive into how the Tap to Pay implementation works, including state management, event handling, and the interaction between React Native and the native iOS SDK, please refer to the architecture documentation:

👉 **[Tap to Pay Architecture Guide](TAP_TO_PAY_ARCHITECTURE.md)**

For the official and up-to-date Mastercard documentation, see:

- [Cloud Commerce iOS SDK Docs](https://developer.mastercard.com/cloud-commerce-ios-sdk/documentation/)

### iOS Configuration

#### 1. Framework Integration

1. Open `Arise.xcworkspace` from the `/ios` folder in Xcode
2. Drag `CloudCommerce.xcframework` to "Frameworks, Libraries, and Embedded Content"
3. Set the framework to **"Embed & Sign"**

#### 2. Info.plist Configuration

Add these keys to your `Info.plist`:

```xml
<key>PRODUCT_TEAM_IDENTIFIER</key>
<string>69WQLJ9K8N</string>
<key>Privacy - Location When In Use Usage Description</key>
<string>Your location is required to process payments securely.</string>
```

#### 3. Required Capabilities

In Xcode's "Signing & Capabilities" tab, add:

- ✅ App Attest
- ✅ Near Field Communication Tag Reading
- ✅ Tap to Pay on iPhone

### Sandbox Testing

For testing the payment integration:

1. **Create Sandbox Apple IDs** - [Apple's Guide](https://developer.apple.com/documentation/xcode/creating-sandbox-apple-ids)
2. **Add Test Cards** - [Apple Pay Sandbox Testing](https://developer.apple.com/apple-pay/sandbox-testing/)

### App Responsibilities

Your application handles:

- **Transaction UI**: Amount entry, result display, error messages
- **Merchant Authentication**: Login and session management
- **Device Attestation**: Environment integrity verification
  - [DeviceCheck Documentation](https://developer.apple.com/documentation/devicecheck)
  - [Fraud Mitigation Guide](https://developer.apple.com/documentation/devicecheck/fraud_mitigation_with_the_devicecheck_framework)

> **Important**: The `countryCode` must match your physical location. Verify Tap to Pay availability with your administrator.

## 🛠️ Troubleshooting

### Common Issues

#### Podfile.lock Changes

If `Podfile.lock` changes after `pod install`, it's usually due to:

- Different CocoaPods versions between team members
- Different Ruby versions
- Different Xcode versions

**Solution**: Use the exact versions specified in the project configuration.

#### Metro Bundler Issues

- Ensure Metro is running before building in Xcode
- Press `R` to reload if the app shows a loading screen
- Check that environment files are properly configured

### Additional Resources

- [React Native Troubleshooting](https://reactnative.dev/docs/troubleshooting)
- [Integration Guide](https://reactnative.dev/docs/integration-with-existing-apps)

### Troubleshooting Tap To Pay Development

- The error ATT023 gets fixed by turning the phone off and back on again.

## 🧪 Testing

### Running Tests

The project uses Jest for unit testing with React Native Testing Library for component testing.

#### Run All Tests

```bash
# Run all tests
yarn test

# Run tests in watch mode
yarn test --watch

# Run tests with coverage
yarn test --coverage
```

#### Run Specific Tests

```bash
# Run tests for a specific file
yarn test ArisePasswordInput.test.tsx

# Run tests matching a pattern
yarn test --testNamePattern="password visibility"

# Run tests in a specific directory
yarn test src/components/baseComponents/__tests__/
```

#### Test Configuration

The project includes the following test configuration:

- **Jest Setup**: `jest-setup.js` - Configures React Native Reanimated for testing
- **SVG Mocking**: `__mocks__/svgMock.js` - Handles SVG imports in tests
- **Jest Config**: `jest.config.js` - Main Jest configuration with module mapping

#### Writing Tests

When writing tests for components that use SVGs:

1. **SVG Imports**: SVGs are automatically mocked via `jest.config.js`
2. **Component Testing**: Use React Native Testing Library for component tests
3. **Async Operations**: Wrap state changes in `act()` to avoid warnings
4. **Style Testing**: Use the `flattenStyle` utility for complex style assertions

Example test structure:

```typescript
import {render, fireEvent, act} from '@testing-library/react-native';
import ArisePasswordInput from '../ArisePasswordInput';

describe('ArisePasswordInput', () => {
  it('should toggle password visibility', async () => {
    const {getByTestId} = render(<ArisePasswordInput />);

    await act(async () => {
      fireEvent.press(getByTestId('showPassword'));
    });

    // Test assertions here
  });
});
```

#### Troubleshooting Tests

**Common Issues:**

- **SVG Import Errors**: Ensure `jest.config.js` has proper SVG mocking
- **React State Warnings**: Wrap state changes in `act()`
- **Style Comparison Failures**: Use `flattenStyle` utility for complex styles
- **Navigation Errors**: Mock navigation objects in component tests

**Debugging Tips:**

```bash
# Run tests with verbose output
yarn test --verbose

# Run a single test with debugging
yarn test --testNamePattern="specific test name" --verbose

# Check test coverage for specific files
yarn test --coverage --collectCoverageFrom="src/components/**/*.tsx"
```

## 🔍 Network Debugging with Atlantis

For network traffic inspection during development, this project uses [Atlantis](https://github.com/ProxymanApp/atlantis) with [Proxyman](https://proxyman.io).

### Features

- ✅ Automatic HTTP/HTTPS traffic capture
- ✅ No proxy or certificate configuration needed
- ✅ Works only in DEBUG mode (safe for production)
- ✅ Zero overhead in Release builds

### Quick Start

1. Install [Proxyman](https://proxyman.io) on your Mac
2. Ensure Mac and device are on the same WiFi network
3. Run the app in development mode:
   ```bash
   npx react-native run-ios
   ```
4. Network requests will appear automatically in Proxyman

## 🏗️ Technology Stack

| Component                        | Version                 | Notes                |
| -------------------------------- | ----------------------- | -------------------- |
| **iOS SDK**                      | 18.0+                   | Minimum iOS version  |
| **Swift**                        | 5                       | Programming language |
| **CryptoSwift**                  | `1.8.2` to `< 2.0.0`    | Cryptography library |
| **Swift Certificates**           | `>= 1.4.0` to `< 2.0.0` | Certificate handling |
| **Swift ASN1**                   | `>= 1.2.0` to `< 2.0.0` | ASN.1 encoding       |
| **ProximityReader.framework**    | Bundled                 | iOS system framework |
| **Jest**                         | Latest                  | Testing framework    |
| **React Native Testing Library** | Latest                  | Component testing    |

**Deliverable**: `iXGuarded` iOS framework (`.xcframework`) supporting both Simulator and Device builds.

## 📚 Learn More

### React Native Resources

- [React Native Website](https://reactnative.dev) - Official documentation
- [Getting Started](https://reactnative.dev/docs/environment-setup) - Environment setup guide
- [Learn the Basics](https://reactnative.dev/docs/getting-started) - React Native fundamentals
- [Blog](https://reactnative.dev/blog) - Latest updates and news
- [GitHub Repository](https://github.com/facebook/react-native) - Source code

### Payment Processing

- [Apple Tap to Pay](https://developer.apple.com/apple-pay/tap-to-pay-on-iphone/)
- [Mastercard CloudCommerce](https://developer.mastercard.com/cloud-commerce/)
- [DeviceCheck Framework](https://developer.apple.com/documentation/devicecheck)

---

**Need Help?** Contact your development team for environment files and CloudCommerce framework access.
