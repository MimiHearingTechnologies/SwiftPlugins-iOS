import Foundation
import OSLog
import ArgumentParser

protocol ExecutableCommand {

    var type: Executor.Command { get set }

    var configPath: String? { get set }

    var command: String { get }
}

@main
struct LocalizationExecutable: ParsableCommand {

    // MARK: - Parsed Command line arguments

    @Option(help: "Target module")
    var target: String?

    @Option(help: "Phrase config path")
    var phraseConfig: String

    @Option(help: "SwiftGen config path")
    var swiftgenConfig: String

    // Modules used for verifying translations
    @Argument(parsing: .captureForPassthrough) public var modules: [String]

    mutating func run() throws {

        let executor = Executor()

        print("Starting to pull files from Phrase...")
        print(Executor.executeShell(.pullPhrase(config: phraseConfig)))

        if !modules.isEmpty {
            print("Starting to verify translations")
            Executor.verifyTranslations(modules: modules)
        }

        print("Starting to generate Localization.swift")
        print(Executor.executeShell(.generateLocalization(config: swiftgenConfig)))
    }
}

// MARK: - Executor

class Executor {

    // the path where homebrew is installed by default
    static let defaultHomebrewPath = "/opt/homebrew/bin/"

    enum Command {
        case pullPhrase(config: String), generateLocalization(config: String)

        var cmd: String {
            switch self {
            case let .pullPhrase(config):
                return Executor.defaultHomebrewPath + "phrase pull --config \(config)"
            case let .generateLocalization(config):
                return Executor.defaultHomebrewPath + "swiftgen config run --verbose --config \(config)"
            }
        }
    }

    class func verifyTranslations(modules: [String]) {
        let verificator = TranslationsVerificator(with: modules)

        let shouldGenerateReportFile = CommandLine.arguments.contains(generateReportFileArgumentName)
        verificator.verifyTranslations(shouldGenerateReportFile: shouldGenerateReportFile)
    }

    class func executeShell(_ command: Command) -> String {
        // This check is needed bacause Process is only available on macOS
#if os(macOS)
        let process = Process()
        let pipe = Pipe()

        process.standardOutput = pipe
        process.standardError = pipe

        process.arguments = ["-c", command.cmd]

        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.standardInput = nil

        var environment = ProcessInfo.processInfo.environment
        environment["PROJECT_DIR"] = process.currentDirectoryPath
        process.environment = environment

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            print("Failed to run the process: \(error)")
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!

        return output
#else
        return "Not supported. Executable only on macOS."
#endif
    }
}
