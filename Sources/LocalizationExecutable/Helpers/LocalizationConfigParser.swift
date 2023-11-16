//
//  LocalizationConfigParser.swift
//  
//
//  Created by Kosta Nedeljkovic on 15/11/2023.
//

import Foundation

struct LocalizationConfigParser {

    enum Parameter: String, CaseIterable {
        case phrase, swiftgen, modules, verificationSource, generateReport, verifyOnly

        var name: String {
            switch self {
            case .phrase, .swiftgen, .modules:
                return self.rawValue
            case .verificationSource:
                return "verification-source"
            case .verifyOnly:
                return "verify-only"
            case .generateReport:
                return "generate-report"
            }
        }
    }

    var text: String

    func parse() throws -> ConfigArguments {
        var config = ConfigArguments()

        let lines = text.components(separatedBy: CharacterSet.newlines)

        for line in lines {
            for parameter in Parameter.allCases {
                if line.contains(parameter.name) {
                    try parseParameter(parameter, from: line, into: &config)
                }
            }
        }

        return config
    }

    private func parseParameter(_ parameter: Parameter, from line: String, into config: inout ConfigArguments) throws {
        let key = parameter.name
        let split = line.replacingOccurrences(of: " ", with: "").components(separatedBy: "\(key):")

        guard split.count > 1 else {
            throw ParsingError.invalidFormat(line: line)
        }

        switch parameter {
        case .modules:
            config.modules = try parseModules(from: split[1])
        case .phrase:
            config.phrase = split[1]
        case .swiftgen:
            config.swiftgen = split[1]
        case .verificationSource:
            config.verificationSource = split[1]
        case .generateReport:
            config.generateReport = try parseBool(from: split[1], line: line)
        case .verifyOnly:
            config.verifyOnly = try parseBool(from: split[1], line: line)
        }
    }

    private func parseBool(from text: String, line: String) throws -> Bool {
        guard let value = Bool(text) else {
            throw ParsingError.invalidBoolFormat(line: line)
        }
        return value
    }

    private func parseModules(from text: String) throws -> [String] {
        return text.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
}

// MARK: - ConfigParameters

extension LocalizationConfigParser {

    struct ConfigArguments: Equatable {
        var modules: [String] = []
        var phrase: String = ""
        var swiftgen: String = ""
        var verificationSource: String = "."
        var generateReport = false
        var verifyOnly = false
    }
}

// MARK: - ParsingError

extension LocalizationConfigParser {

    enum ParsingError: Error, CustomStringConvertible, Equatable {
        case invalidFormat(line: String)
        case invalidBoolFormat(line: String)

        var description: String {
            switch self {
            case let .invalidFormat(line):
                return "Invalid format for line: \(line)"
            case let .invalidBoolFormat(line):
                return "Invalid format for boolean on line: \(line)"
            }
        }
    }
}
