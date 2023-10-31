# Swift Package plugins

This project contains a swift package with all the Swift package plugins to be used in the iOS SDK & any other projects. 

## List of plugins:

### LocalizationCommand

A command plugin which is run manually and performs the following operations on the selected target:

1. Pulls translations from Phrase
2. Generates `Localization.swift` containing type safe translations
3. Verifies the translations

The command is run by right clicking the target and selecting `LocalizationCommand` in XCode.

Following flags & arguments need to be provided:

- SwiftGen config file path: `--swiftgen-config ../SwiftGen/swiftgen-localization.yml`
- Phrase config file path: `--phrase-config ../.phrase.yml`
- List of modules for verifying translations, provided at the end: `ModuleA ModuleB moduleC`

Example of a full command: 

`--swiftgen-config ../SwiftGen/swiftgen-localization.yml --phrase-config ../.phrase.yml MimiSDK MimiTestKit MimiAuthKit`

