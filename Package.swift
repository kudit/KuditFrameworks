// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "KuditFrameworks",
    platforms: [
        .iOS("15.2"),
        .macOS("12.0"), // minimum for foregroundStyle (Touchbook running Monterey), also minimum for MotionEffects
        .tvOS("17.0"), // Menu is only available after tvOS 17 (and we don't have any apps we're supporting for earlier tvOS)
        .watchOS("8.0"),
        .visionOS("1.0"), // unavailable in Swift Playgrounds
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "KuditFrameworks Library", // has to be named different from the iOSApplication or Swift Playgrounds won't open correctly
            targets: ["KuditFrameworks"]
        ),
        .iOSApplication(
            name: "KuditFrameworks", // needs to match package name to open properly in Swift Playgrounds
            targets: ["KuditFrameworksTestAppModule"],
            teamIdentifier: "3QPV894C33",
            displayVersion: "4.3.1",
            bundleVersion: "1",
            appIcon: .asset("AppIcon"),
            accentColor: .presetColor(.red),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            capabilities: [
                .outgoingNetworkConnections()
            ],
            appCategory: .developerTools
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
//        .package(url: "https://github.com/GetStream/effects-library", "1.0.0"..<"2.0.0"),
        .package(url: "https://github.com/kudit/MotionEffects", "1.0.0"..<"2.0.0"),
        .package(url: "https://github.com/johnsundell/ink.git", "0.6.0"..<"1.0.0"),
        .package(url: "https://github.com/kudit/Device", "2.1.4"..<"3.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "KuditFrameworks",
            dependencies: [
                .product(name: "MotionEffects Library", package: "motioneffects"),
                // Should this be moved to the executable dependency?
                .product(name: "Device Library", package: "device"), // apparently needs to be lowercase.  Also note this is "Device Library" not "Device"
                .product(name: "Ink", package: "ink"),
            ],
            path: "Sources"
            // If resources need to be included, include here
//            resources: [.process("Resources")]
        ),
        .executableTarget(
            name: "KuditFrameworksTestAppModule",
            dependencies: [
                "KuditFrameworks",
            ],
            path: "Development",
//            exclude: ["Tests", "Sources"],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        ),
        .testTarget(
            name: "KuditFrameworkTests",
            dependencies: [
                "KuditFrameworks"
            ],
            path: "Tests"
        ),
    ]
)
