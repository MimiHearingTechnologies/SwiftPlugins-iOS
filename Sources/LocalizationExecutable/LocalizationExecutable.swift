import Foundation
import ArgumentParser
import Execution

@main
struct LocalizationExecutable: ParsableCommand {

    // MARK: - Parsed Command line arguments

    @Option(help: "Target module")
    var target: String?

    @Option(help: "If set to true, only verify translations step is completed")
    var verifyOnly: Bool = false

    @Option(help: "If set to true, verify translations step generates `TranslationsVerificationReport`")
    var generateReport: Bool = false

    @Option(help: "Source directory for verification step")
    var verificationSource: String = "."

    @Option(help: "Phrase config path")
    var phraseConfig: String = "./.phrase.yml"

    @Option(help: "SwiftGen config path")
    var swiftgenConfig: String = "./SwiftGen/swiftgen-localization.yml"

    // Modules used for verifying translations
    @Argument(parsing: .remaining) public var modules: [String] = []

    mutating func run() throws {
        let executor = ShellExecutor()
        let logger = Logger()

        guard !verifyOnly else {
            do {
                try verifyTranslations(logger: logger)
            } catch {
                throw error
            }
            return
        }

        do {
            separatorLog(logger, text: "Starting to pull files from Phrase...")
            let phraseCommand = LocalizationCommand.pullPhrase(config: phraseConfig )
            let shellCommand = ShellCommand(commandPath: phraseCommand.cmdPath, arguments: phraseCommand.args)
            logger.log(try executor.execute(shellCommand))
        } catch {
            logger.log(error.localizedDescription)
            throw error
        }

        do {
            separatorLog(logger,text: "Starting to generate Localization.swift")
            let localizationCommand = LocalizationCommand.generateLocalization(config: swiftgenConfig)
            let shellCommand = ShellCommand(commandPath: localizationCommand.cmdPath, arguments: localizationCommand.args)
            logger.log(try executor.execute(shellCommand))
        } catch {
            logger.log(error.localizedDescription)
            throw error
        }

        do {
            try verifyTranslations(logger: logger)
        } catch {
            throw error
        }
    }

    private func separatorLog(_ logger: Logger, text: String) {
        logger.log("""
            -------------------------------------
            \(text)
            """)
    }

    private func verifyTranslations(logger: Logger) throws {
        do {
            separatorLog(logger, text: "Starting to verify translations.")
            let verificator = try TranslationsVerificator(with: modules, sourceDir: verificationSource)
            verificator.verifyTranslations(shouldGenerateReportFile: generateReport)
        } catch {
            logger.log(error.localizedDescription)
            throw error
        }
    }
}

// MARK: - LocalizationCommand

extension LocalizationExecutable {

    enum LocalizationCommand {
        case pullPhrase(config: String), generateLocalization(config: String)

        static let brewPath = "/opt/homebrew/bin/"

        var cmdPath: String {
            switch self {
            case .pullPhrase:
                return "\(Self.brewPath)phrase"
            case .generateLocalization:
                return "\(Self.brewPath)swiftgen"
            }
        }

        var args: String {
            switch self {
            case let .pullPhrase(config):
                return "pull" + configArg(for: config)
            case let .generateLocalization(config):
                return "config run --verbose" + configArg(for: config)
            }
        }

        private func configArg(for config: String) -> String {
            return config.isEmpty ? "" : " --config \(config)"
        }
    }

}
