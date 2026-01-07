# AriseMobileSdk

iOS SDK for Arise Mobile Payment Platform

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/YOUR_ORG/arise-mobile-sdk-distribution.git", from: "1.0.0")
]
```

Or add it via Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select the version range

## Usage

```swift
import AriseMobileSdkIos

// Initialize the SDK
let sdk = try AriseMobileSdk(environment: .uat)
```

## License

Copyright © Arise. All rights reserved.
