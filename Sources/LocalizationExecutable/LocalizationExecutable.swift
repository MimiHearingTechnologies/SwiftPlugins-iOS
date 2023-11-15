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

    @Option(help: "Localization command config")
    var config: String = "./localization-config.yml"

    mutating func run() throws {
        let executor = ShellExecutor()
        let logger = Logger()

        guard let config = readConfig(logger) else {
            return
        }

        guard !verifyOnly else {
            verifyTranslations(logger: logger, modules: config.modules)
            return
        }

        do {
            separatorLog(logger, text: "Starting to pull files from Phrase...")
            let phraseCommand = LocalizationCommand.pullPhrase(config: config.phrase)
            let shellCommand = ShellCommand(commandPath: phraseCommand.cmdPath, arguments: phraseCommand.args)
            logger.log(try executor.execute(shellCommand))
        } catch {
            logger.log(error.localizedDescription)
            throw error
        }

        do {
            separatorLog(logger,text: "Starting to generate Localization.swift")
            let localizationCommand = LocalizationCommand.generateLocalization(config: config.swiftgen)
            let shellCommand = ShellCommand(commandPath: localizationCommand.cmdPath, arguments: localizationCommand.args)
            logger.log(try executor.execute(shellCommand))
        } catch {
            logger.log(error.localizedDescription)
            throw error
        }

        verifyTranslations(logger: logger, modules: config.modules)
    }

    private func separatorLog(_ logger: Logger, text: String) {
        logger.log("""
            -------------------------------------
            \(text)
            """)
    }

    private func verifyTranslations(logger: Logger, modules: [String]) {
        do {
            separatorLog(logger, text: "Starting to verify translations.")
            let verificator = try TranslationsVerificator(with: modules, sourceDir: verificationSource)
            verificator.verifyTranslations(shouldGenerateReportFile: generateReport)
        } catch {
            logger.log(error.localizedDescription)
        }
    }


    private func readConfig(_ logger: Logger) -> ConfigParameters? {
        guard
            let swiftgenData = FileManager.default.contents(atPath: config),
            let text = String(data: swiftgenData, encoding: .utf8) else {
            return nil
        }

        let parser = LocalizationConfigParser(text: text)

        do {
            let config = try parser.parse()
            return config
        } catch {
            logger.log(error.localizedDescription)
            return nil
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
