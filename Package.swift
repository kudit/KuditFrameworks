// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KuditFrameworks",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
		// need to include .visionOS(.v1)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "KuditFrameworks",
            targets: ["KuditFrameworks"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/GetStream/effects-library", "1.0.0"..<"2.0.0"),
        .package(url: "https://github.com/devicekit/DeviceKit.git", "5.1.0"..<"6.0.0")
        .package(url: "https://github.com/johnsundell/ink.git", "0.6.0"..<"1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "KuditFrameworks",
            dependencies: [
                .product(name: "EffectsLibrary", package: "effects-library"),
                .product(name: "DeviceKit", package: "devicekit")
                .product(name: "Ink", package: "ink")
            ],
            path: "Sources",
            resources: [
            ]
        ),
        .testTarget(
            name: "KuditFrameworksTests",
            dependencies: ["KuditFrameworks"]),
    ]
)
