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
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(
            url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git",
            .upToNextMajor(from: "12.0.0")
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
        )
    ]
)
