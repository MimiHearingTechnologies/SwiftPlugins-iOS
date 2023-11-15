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

List of modules can be also provided through `swiftgen` config file, at the top of the file in the following format:

`#MODULES: Module_A, Module_B, Module_C`

The following flags are optional:

- Verify only (only runs verify translations step): `--verify-only true`, default value is `false`
- Generate report (generates a report for verify translations step if set to true): `--generate-report true`, default value is `false`
- SwiftGen config file path: `--swiftgen-config custom/path/swiftgen.yml`, defaults to target root directory
- Phrase config file path: `--phrase-config custom/path/.phrase.yml`, defaults to target root directory
- Verification source: `--verification-source custom/source`, defaults to target root directory

To run the command right click the target and select `LocalizationCommand` in Xcode.

Example of a full command: 

`--verify-only true --verification-source custom/source --generate-report true --swiftgen-config custom/path/swiftgen.yml --phrase-config custom/path/.phrase.yml ModuleA ModuleB ModuleC`

