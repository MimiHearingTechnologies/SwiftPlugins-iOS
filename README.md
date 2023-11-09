# Swift Package plugins

This project contains a swift package with all the Swift package plugins to be used in the iOS SDK & any other projects. 

## List of plugins:

### LocalizationCommand

A command plugin which is run manually and performs the following operations on the selected target:

1. Pulls translations from Phrase
2. Generates `Localization.swift` containing type safe translations
3. Verifies the translations

Prerequisites:

- Install [Phrase CLI](https://support.phrase.com/hc/en-us/articles/5784093863964-CLI-Installation-Strings-) using Homebrew
- Install [ SwiftGen](https://github.com/SwiftGen/SwiftGen#installation) using Homebrew

Following flags & arguments need to be provided:

- List of modules for verifying translations, provided at the end: `ModuleA ModuleB moduleC`

The following flags are optional:

- Generate report (generates a report for verify translations step if set to true): `--generate-report true`
- SwiftGen config file path: `--swiftgen-config custom/path/swiftgen.yml`, defaults to target root directory
- Phrase config file path: `--phrase-config custom/path/.phrase.yml`, defaults to target root directory
- Verification source: `--verification-source custom/source`, defaults to target root directory

To run the command right click the target and select `LocalizationCommand` in Xcode.

Example of a full command: 

`--swiftgen-config custom/path/swiftgen.yml --phrase-config custom/path/.phrase.yml ModuleA ModuleB ModuleC`

