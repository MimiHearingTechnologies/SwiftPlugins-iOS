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

        if modules.isEmpty {
            self.modules = extractModules()
        }

        guard !verifyOnly else {
            verifyTranslations(logger: logger)
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

        verifyTranslations(logger: logger)
    }

    private func separatorLog(_ logger: Logger, text: String) {
        logger.log("""
            -------------------------------------
            \(text)
            """)
    }

    private func verifyTranslations(logger: Logger) {
        do {
            separatorLog(logger, text: "Starting to verify translations.")
            let verificator = try TranslationsVerificator(with: modules, sourceDir: verificationSource)
            verificator.verifyTranslations(shouldGenerateReportFile: generateReport)
        } catch {
            logger.log(error.localizedDescription)
        }
    }


    private func extractModules() -> [String] {
        guard
            let swiftgenData = FileManager.default.contents(atPath: swiftgenConfig),
            let text = String(data: swiftgenData, encoding: .utf8) else {
            return []
        }

        let extractor = ModuleExtractor(text: text)
        return extractor.extractModules()
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

// MARK: - ModuleExtractor

extension LocalizationExecutable {

    /// Extractor used to extract modules from swiftgen config
    /// The following format is expected as first line of the text: #MODULES: module_A module_B module_C
    struct ModuleExtractor {

        var text: String

        func extractModules() -> [String] {
            guard
                let modules = text.replacingOccurrences(of: " ", with: "").components(separatedBy: CharacterSet.newlines).first,
                modules.contains("#MODULES:") else {
                return []
            }

            let split = modules.components(separatedBy: "#MODULES:")
            guard split.count > 1 else { return [] }

            return split[1].components(separatedBy: ",")
        }
    }
}
