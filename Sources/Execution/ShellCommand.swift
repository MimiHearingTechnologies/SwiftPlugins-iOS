//
//  ShellCommand.swift
//
//
//  Created by Salar on 10/30/23.
//

import Foundation

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
