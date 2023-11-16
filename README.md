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

In order to run the command, a config path parameter needs to be provided, which supports the following arguments:

- SwiftGen config file path - defaults to `./swiftgen.yml`
- Phrase config file path - defaults to `./.phrase.yml`
- List of modules to verify translations for
- Verification source - source directory where the modules are located, defaults to target root directory
- Verify only - when set to true runs verify translations step only, default value is `false`
- Generate report - generates a report for verify translations step if set to true, default value is `false`

The config follows the following format:

```
phrase: custom/path/.phrase.yml. 
swiftgen: custom/path/swiftgen.yml
modules: ModuleA, ModuleB, ModuleC
verification-source: custom/path
verify-only: false
generate-report: true
```



To run the command right click the target and select `LocalizationCommand` in Xcode.

Example of the command: 

`--config custom/path/config.yml`

