import Foundation
import OSLog
import ArgumentParser

@main
struct LocalizationExecutable: ParsableCommand {

    @Option(help: "Target module")
    var target: String?

    @Option(help: "Path to the Phrase config")
    var phraseConfig: String

    @Option(help: "Path to the SwiftGen config")
    var swiftgenConfig: String

    mutating func run() throws {

        let executor = Executor(phraseConfig: phraseConfig, swiftgenConfig: swiftgenConfig)

        print("Starting to pull files from Phrase...")
        executor.executeShell(.pullPhrase)

        print("Starting to verify translations")
        Executor.verifyTranslations()

        print("Starting to generate Localization.swift")
        executor.executeShell(.generateLocalization)
    }
}

class Executor {

    var phraseConfig: String
    var swiftgenConfig: String

    // the path where homebrew is installed by default
    static let defaultHomebrewPath = "/opt/homebrew/bin/"

    enum Command {
        case pullPhrase, generateLocalization

        var cmd: String {
            switch self {
            case .pullPhrase:
                return Executor.defaultHomebrewPath + "phrase pull"
            case .generateLocalization:
                return Executor.defaultHomebrewPath + "swiftgen config run --verbose"
            }
        }

        // relative path
        var configPath: String {
            switch self {
            case .pullPhrase:
                return ".phrase.yml"
            case .generateLocalization:
                return "SwiftGen/swiftgen-localization.yml"
            }
        }
    }

    init(phraseConfig: String, swiftgenConfig: String) {
        self.phraseConfig = phraseConfig
        self.swiftgenConfig = swiftgenConfig
    }

    class func verifyTranslations() {
        let verificator = TranslationsVerificator()

        let shouldGenerateReportFile = CommandLine.arguments.contains(generateReportFileArgumentName)
        verificator.verifyTranslations(shouldGenerateReportFile: shouldGenerateReportFile)
    }

    func executeShell(_ command: Command) {
        print(Self.shell(command))
    }

    @discardableResult
    private class func shell(_ command: Command) -> String {
// This check is needed bacause Process is only available on macOS
#if os(macOS)
        let process = Process()
        let pipe = Pipe()

        process.standardOutput = pipe
        process.standardError = pipe

        let configPath = "\(process.currentDirectoryPath)/../\(command.configPath)"
        process.arguments = ["-c", "\(command.cmd) --config \(configPath)"]

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
