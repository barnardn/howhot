// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension Target.Dependency {
    // internal
    static var geoLookup: Self { "GeoLookup" }
    static var ipAddressLookup: Self { "IPAddressLookup" }
    static var apiNetworking: Self { "APINetworking" }

    // external
    static var swiftArgumentParger: Self {
        .product(name: "ArgumentParser", package: "swift-argument-parser")
    }
}

let package = Package(
    name: "howhot",
    platforms: [.macOS(.v26)],
    products: [
        .executable(name: "howhot", targets: ["howhot"]),
        .library(name: "IPAddressLookup", targets: ["IPAddressLookup"]),
        .library(name: "GeoLookup", targets: ["GeoLookup"]),
        .library(name: "APINetworking", targets: ["APINetworking"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "IPAddressLookup", dependencies: []),
        .target(name: "APINetworking", dependencies: []),
        .target(name: "GeoLookup", dependencies: [.apiNetworking]),
        .executableTarget(
            name: "howhot",
            dependencies: [
                .swiftArgumentParger,
                .ipAddressLookup,
                .geoLookup,
            ]
        ),
    ]
)
