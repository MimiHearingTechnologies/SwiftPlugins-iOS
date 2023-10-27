//
//  File.swift
//
//
//  Created by Kosta Nedeljkovic on 27/10/2023.
//

import Foundation
import OSLog

public enum ExecutionError: LocalizedError, Equatable {
    case executableNotFound
    case commandNotFound
    case runFailed(description: String)

    public var errorDescription: String {
        switch self {
        case .executableNotFound:
            return "Executable not found."
        case .commandNotFound:
            return "Command not found."
        case let .runFailed(description):
            return "Run failed: \(description)"
        }
    }
}

public struct ShellCommand {
    var commandPath: String
    var arguments: String

    var fullPath: String {
        return "\(commandPath) \(arguments)"
    }

    public init(commandPath: String, arguments: String) {
        self.commandPath = commandPath
        self.arguments = arguments
    }
}

public class ShellExecutor {

    private let fileManager = FileManager.default

    var executablePath: String

    // MARK: - Initializers

    public init(executablePath: String? = nil) {
        self.executablePath = executablePath ?? "/bin/zsh"
    }

    @discardableResult
    public func execute(_ command: ShellCommand) throws -> String {
        // This check is needed bacause Process is only available on macOS
#if os(macOS)
        guard fileManager.fileExists(atPath: executablePath) else {
            throw ExecutionError.executableNotFound
        }

        guard fileManager.fileExists(atPath: command.commandPath) else {
            throw ExecutionError.commandNotFound
        }

        let process = Process()
        let pipe = Pipe()

        process.standardOutput = pipe
        process.standardError = pipe

        process.arguments = ["-c", command.fullPath]

        process.executableURL = URL(fileURLWithPath: executablePath)
        process.standardInput = nil

        var environment = ProcessInfo.processInfo.environment
        environment["PROJECT_DIR"] = process.currentDirectoryPath
        process.environment = environment

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            throw ExecutionError.runFailed(description: error.localizedDescription)
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!

        return output
#else
        return "Not supported. Executable only on macOS."
#endif
    }
}


