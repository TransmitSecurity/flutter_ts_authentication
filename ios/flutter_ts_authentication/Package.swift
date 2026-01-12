// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_ts_authentication",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "flutter-ts-authentication", targets: ["flutter_ts_authentication"])
    ],
    dependencies: [
        .package(url: "https://github.com/TransmitSecurity/authentication-ios-sdk", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "flutter_ts_authentication",
            dependencies: [
                .product(name: "TSAuthenticationSDK", package: "authentication-ios-sdk")
            ],
            resources: [

            ]
        )
    ]
)
