import Foundation

@main
class LocalizationExecutable {

  static func main() {

      print("Starting to pull files from Phrase...")
      Executor.executeShell(.pullPhrase)

      print("Starting to verify translations")
      Executor.verifyTranslations()

      print("Starting to generate type safe Localization.swift")
      Executor.executeShell(.generateLocalization)
  }
}

class Executor {

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

        var config: String {
            switch self {
            case .pullPhrase:
                return ".phrase.yml"
            case .generateLocalization:
                return "SwiftGen/swiftgen-localization.yml"
            }
        }
    }

    class func verifyTranslations() {
        let verificator = TranslationsVerificator()

        let shouldGenerateReportFile = CommandLine.arguments.contains(generateReportFileArgumentName)
        verificator.verifyTranslations(shouldGenerateReportFile: shouldGenerateReportFile)
    }

    class func executeShell(_ command: Command) {
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

        let configPath = "\(process.currentDirectoryPath)/../\(command.config)"
        process.arguments = ["-c", "\(command.cmd) --config \(configPath)"]

        process.launchPath = "/bin/zsh"
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
#endif
        return "Not supported. Executable only on macOS."
    }
}
