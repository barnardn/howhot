// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension Target.Dependency {
    // internal
    static var apiNetworking: Self { "APINetworking" }
    static var configuration: Self { "Configuration" }
    static var common: Self { "Common" }
    static var ipAddressLookup: Self { "IPAddressLookup" }
    static var geoLookup: Self { "GeoLookup" }
    static var openWeatherMap: Self { "OpenWeatherMap" }

    // external
    static var swiftArgumentParger: Self {
        .product(name: "ArgumentParser", package: "swift-argument-parser")
    }

    static var swiftConfiguration: Self {
        .product(name: "Configuration", package: "swift-configuration")
    }
}

let package = Package(
    name: "howhot",
    platforms: [.macOS(.v26)],
    products: [
        .executable(name: "howhot", targets: ["howhot"]),
        .library(name: "Common", targets: ["Common"]),
        .library(name: "IPAddressLookup", targets: ["IPAddressLookup"]),
        .library(name: "GeoLookup", targets: ["GeoLookup"]),
        .library(name: "APINetworking", targets: ["APINetworking"]),
        .library(name: "OpenWeatherMap", targets: ["OpenWeatherMap"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(
            url: "https://github.com/apple/swift-configuration",
            from: "1.0.0",
            traits: [.defaults, "YAML"]
        ),
        // Only added explicitly as a workaround for https://github.com/apple/swift-configuration/issues/89
        .package(url: "https://github.com/jpsim/Yams", "5.4.0"..<"7.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "APINetworking", dependencies: []),
        .target(name: "Common", dependencies: [.swiftConfiguration]),
        .target(name: "GeoLookup", dependencies: [.apiNetworking, .common]),
        .target(name: "IPAddressLookup", dependencies: []),
        .target(name: "OpenWeatherMap", dependencies: [.common]),
        .executableTarget(
            name: "howhot",
            dependencies: [
                .swiftArgumentParger,
                .ipAddressLookup,
                .geoLookup,
                .openWeatherMap,
                .swiftConfiguration,
            ]
        ),
    ]
)
