# Changelog
All notable changes to this project will be documented in this file.
SwiftPlugins adheres to [Semantic Versioning](http://semver.org/).

## 2.0.0
Released on 2023-11-21

**This release restructures the `LocalizationCommand` command line arguments. Instead of using multiple arguments, a config argument is now supported, which contains all the necessary parameters for the command.**

### Added
- `config` command line argument in `LocalizationExecutable`

### Removed
The following command line arguments have been removed in `LocalizationExecutable`:

- `phraseConfig`
- `swiftgenConfig`
- `modules`
- `verificationSource`
- `verifyOnly`
- `generateReport`

---

## 1.1.0
Released on 2023-11-14

**This release adds support for additional command line arguments that enable us to run the verification step only.**

### Added
- `verifyOnly` command line argument in `LocalizationExecutable`
- `verificationSource` command line argument in `LocalizationExecutable`
- `generateReport` command line argument in `LocalizationExecutable`

---

## 1.0.0
Released on 2023-11-14

**First release of the SwiftPlugins package, containing LocalizationCommand plugin, which performs the following operations:**

- Pulls translations from Phrase using a provided phrase config
- Generates type safe translations using Swiftgen tool
- Verifies translations for provided modules 

### Added
- `LocalizationCommand` plugin