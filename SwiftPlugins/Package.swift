// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftPlugins",
    products: [
        .executable(name: "LocalizationExecutable", targets: ["LocalizationExecutable"]),
        .plugin(name: "LocalizationCommand", targets: ["LocalizationCommand"]),
    ],
    targets: [
        .executableTarget(
            name: "LocalizationExecutable"
        ),
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
