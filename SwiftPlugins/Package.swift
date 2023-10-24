// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftPlugins",
    products: [
        .plugin(
            name: "LocalizationCommandPlugin",
            targets: ["LocalizationCommandPlugin"]),
    ],
    targets: [
        .plugin(
            name: "LocalizationCommandPlugin",
            capability: .command(intent: .custom(
                verb: "LocalizationCommandPlugin",
                description: "Pull translations, verifies them & generate Localization.swift using SwiftGen"
            ))
        ),
    ]
)
