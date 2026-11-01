// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdsEngine",
    platforms: [.iOS(.v18)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AdsEngine",
            targets: ["AdsEngine"]
        ),
        // Opt-in: links the mediation adapters, so consumers of `AdsEngine`
        // alone do not pull in the extra ad networks.
        .library(
            name: "AdsEngineMediation",
            targets: ["AdsEngineMediation"]
        ),
        // Opt-in: reports ad events to RevenueCat through its AdMob adapter.
        .library(
            name: "AdsEngineRevenueCat",
            targets: ["AdsEngineRevenueCat"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(
            url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git",
            .upToNextMajor(from: "13.0.0")
        ),
        .package(
            url: "https://github.com/googleads/googleads-mobile-ios-mediation-liftoffmonetize.git",
            exact: "7.7.800"
        ),
        .package(
            url: "https://github.com/googleads/googleads-mobile-ios-mediation-unity.git",
            exact: "4.21.000"
        ),
        // Each adapter release pins `purchases-ios-spm` to its own version, so
        // a range lets the consumer's RevenueCat version pick the adapter.
        .package(
            url: "https://github.com/RevenueCat/purchases-ios-admob.git",
            .upToNextMajor(from: "5.100.0")
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        // ponytail: pinned to Swift 5 semantics. tools-version 6.0 is here for
        // `.iOS(.v18)`, not for a concurrency migration — drop this to adopt Swift 6.
        .target(
            name: "AdsEngine",
            dependencies: [
                .product(
                    name: "GoogleMobileAds",
                    package: "swift-package-manager-google-mobile-ads"
                ),
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "AdsEngineMediation",
            dependencies: [
                "AdsEngine",
                .product(
                    name: "LiftoffMonetizeAdapterTarget",
                    package: "googleads-mobile-ios-mediation-liftoffmonetize"
                ),
                .product(
                    name: "UnityAdapterTarget",
                    package: "googleads-mobile-ios-mediation-unity"
                ),
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "AdsEngineRevenueCat",
            dependencies: [
                "AdsEngine",
                .product(
                    name: "RevenueCatAdMob",
                    package: "purchases-ios-admob"
                ),
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "AdsEngineTests",
            dependencies: [
                "AdsEngine",
                .product(
                    name: "GoogleMobileAds",
                    package: "swift-package-manager-google-mobile-ads"
                ),
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        )
    ]
)
