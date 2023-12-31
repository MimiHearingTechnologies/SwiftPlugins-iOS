// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftPlugins",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
    ],
    products: [
        .executable(name: "LocalizationExecutable", targets: ["LocalizationExecutable"]),
        .plugin(name: "LocalizationCommand", targets: ["LocalizationCommand"]),
    ],
    dependencies: [
            // other dependencies
            .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "LocalizationExecutable",
            dependencies: [
                .target(name: "Execution"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(name: "Execution"),
        .testTarget(name: "LocalizationExecutableTests", dependencies: ["LocalizationExecutable"]),
        .testTarget(name: "ExecutionTests", dependencies: ["Execution"]),
        .plugin(
            name: "LocalizationCommand",
            capability: .command(
                intent: .custom(
                    verb: "LocalizationCommand",
                    description: "Pulls translations from Phrase, verifies them & generates Localization.swift using SwiftGen"
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "This command generates source code"),
                    .allowNetworkConnections(
                        scope: .all(),
                        reason: "Network connection is needed to pull the translation from Phrase."
                    )
                ]
            ),
            dependencies: ["LocalizationExecutable"]
        )
    ]
)
