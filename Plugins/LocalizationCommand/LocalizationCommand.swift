//
//  LocalizationCommandPlugin.swift
//
//
//  Created by Kosta Nedeljkovic on 24/11/2023.
//

import Foundation
import PackagePlugin

struct LocalizationCommand: CommandPlugin {
    func performCommand(context: PluginContext, arguments externalArgs: [String]) async throws {
        let exec = try context.tool(named: "LocalizationExecutable")

        do {
            try exec.run(arguments: externalArgs, environment: nil)
        } catch let error {
            Diagnostics.remark(error.localizedDescription)
        }
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

@main
extension LocalizationCommand: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments externalArgs: [String]) throws {
        let exec = try context.tool(named: "LocalizationExecutable")

        do {
            try exec.run(arguments: externalArgs, environment: nil)
        } catch let error {
            Diagnostics.remark(error.localizedDescription)
        }
    }
}

#endif

private extension PluginContext.Tool {
    func run(arguments: [String], environment: [String: String]?) throws {
        let pipe = Pipe()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path.string)
        process.arguments = arguments
        process.environment = environment
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        if process.terminationReason == .exit && process.terminationStatus == 0 {
            return
        }

        let data = try pipe.fileHandleForReading.readToEnd()
        let stderr = data.flatMap { String(data: $0, encoding: .utf8) }

        if let stderr {
            Diagnostics.error(stderr)
        } else {
            let problem = "\(process.terminationReason.rawValue):\(process.terminationStatus)"
            Diagnostics.error(problem)
        }
    }
}
