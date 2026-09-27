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
        // Pinned `exact` deliberately: the plugin chooses this version on behalf of every
        // integrator, so an integrator cannot select a different TSAuthenticationSDK version
        // without forking the plugin. Accepted trade-off — a loose constraint could resolve to an
        // untested version across a platform-channel boundary we cannot validate at build time.
        // 1.2.2 vs 1.2.1: no public API change (identical `.swiftinterface`); 1.2.2 only corrects
        // the SDK's own declared platform floor. Core floor is `from: "1.1.5"` at both versions.
        .package(url: "https://github.com/TransmitSecurity/authentication-ios-sdk", exact: "1.2.2")
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
