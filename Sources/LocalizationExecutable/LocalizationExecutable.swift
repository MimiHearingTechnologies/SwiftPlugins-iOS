import Foundation
import OSLog
import ArgumentParser
import Execution

enum VerificationError: LocalizedError {
    case noModulesProvided

    var errorDescription: String {
        switch self {
        case .noModulesProvided:
            return "❌ No modules provided, verifying translations failed."
        }
    }
}

@main
struct LocalizationExecutable: ParsableCommand {

    // MARK: - Parsed Command line arguments

    @Option(help: "Target module")
    var target: String?

    @Option(help: "Phrase config path")
    var phraseConfig: String = "../.phrase.yml"

    @Option(help: "SwiftGen config path")
    var swiftgenConfig: String = "../SwiftGen/swiftgen-localization.yml"

    // Modules used for verifying translations
    @Argument(parsing: .remaining) public var modules: [String] = []

    mutating func run() throws {
        let executor = ShellExecutor()

        do {
            print("Starting to pull files from Phrase...")
            let phraseCommand = LocalizationCommand.pullPhrase(config: phraseConfig )
            print(try executor.execute(phraseCommand.cmd))
        } catch let error as ExecutionError {
            print(error.errorDescription)
        }

        do {
            print("Starting to verify translations...")
            try Self.verifyTranslations(modules: modules)
        } catch let error as VerificationError {
            print(error.errorDescription)
        }

        do {
            print("Starting to generate Localization.swift")
            let localizationCommand = LocalizationCommand.generateLocalization(config: swiftgenConfig)
            print(try executor.execute(localizationCommand.cmd))
        } catch let error as ExecutionError {
            print(error.errorDescription)
        }


    }
}

// MARK: - Verify translations

extension LocalizationExecutable {

    static func verifyTranslations(modules: [String]) throws {
        guard !modules.isEmpty else {
            throw VerificationError.noModulesProvided
        }
        let verificator = TranslationsVerificator(with: modules)

        let shouldGenerateReportFile = CommandLine.arguments.contains(generateReportFileArgumentName)
        verificator.verifyTranslations(shouldGenerateReportFile: shouldGenerateReportFile)
    }
}

// MARK: - LocalizationCommand

extension LocalizationExecutable {

    enum LocalizationCommand {
        case pullPhrase(config: String), generateLocalization(config: String)

        static let brewPath = "/opt/homebrew/bin/"

        var cmd: String {
            switch self {
            case let .pullPhrase(config):
                return "\(Self.brewPath)phrase pull" + configArg(for: config)
            case let .generateLocalization(config):
                return "\(Self.brewPath)swiftgen config run --verbose" + configArg(for: config)
            }
        }

        func configArg(for config: String) -> String {
            return config.isEmpty ? "" : " --config \(config)"
        }
    }


}
