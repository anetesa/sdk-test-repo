// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AriseMobileSdkIos",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "AriseMobileSdkIos",
            targets: ["AriseMobileSdkIos"]
        ),
    ],
    dependencies: [
        // AriseMobileSdk.framework requires these dependencies
        .package(url: "https://github.com/apple/swift-openapi-runtime.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-http-types.git", from: "1.0.0"),
        // CloudCommerce.framework requires these dependencies
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.8.0"),
        .package(url: "https://github.com/apple/swift-asn1.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-certificates.git", from: "1.0.0"),
    ],
    targets: [
        // Binary target name MUST match the module name inside the framework
        // The framework's module is "AriseMobile" (from PRODUCT_MODULE_NAME)
        // In CI/CD, XCFRAMEWORK_NAME="AriseMobile", so the xcframework is named "AriseMobile.xcframework"
        // with "AriseMobile.framework" inside. The binary target name must match the module name.
        .binaryTarget(
            name: "AriseMobile",
            path: "./libs/AriseMobile.xcframework"
        ),
        .binaryTarget(
            name: "CloudCommerce",
            path: "./libs/CloudCommerce.xcframework"
        ),
        .target(
            name: "AriseMobileSdkIos",
            dependencies: [
                "AriseMobile",     // Binary target with module name "AriseMobile"
                "CloudCommerce",   // Binary target with module name "CloudCommerce"
                // AriseMobile requires these dependencies
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
                .product(name: "HTTPTypes", package: "swift-http-types"),
                // CloudCommerce requires these dependencies
                .product(name: "CryptoSwift", package: "CryptoSwift"),
                .product(name: "SwiftASN1", package: "swift-asn1"),
                .product(name: "X509", package: "swift-certificates"),
            ],
            path: "Sources/AriseMobileSdkIos"
        ),
    ]
)
