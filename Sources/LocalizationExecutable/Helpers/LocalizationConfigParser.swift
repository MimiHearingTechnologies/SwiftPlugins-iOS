//
//  LocalizationConfigParser.swift
//  
//
//  Created by Kosta Nedeljkovic on 15/11/2023.
//

import Foundation

struct LocalizationConfigParser {

    enum Parameter: String {
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
        var modules: [String] = []
        var phrase: String = ""
        var swiftgen: String = ""
        var verificationSource: String = "."
        var generateReport = false
        var verifyOnly = false

        // TODO: - Improve code by using regex
        let lines = text.components(separatedBy: CharacterSet.newlines)
        do {
            for line in lines {
                if line.contains(Parameter.modules.name) {
                    modules = try parseModules(from: line)
                    continue
                }
                if line.contains(Parameter.phrase.name) {
                    phrase = try parsePath(from: line, separator: Parameter.phrase.name)
                    continue
                }
                if line.contains(Parameter.swiftgen.name) {
                    swiftgen = try parsePath(from: line, separator: Parameter.swiftgen.name)
                    continue
                }
                if line.contains(Parameter.verificationSource.name) {
                    verificationSource = try parsePath(from: line, separator: Parameter.verificationSource.name)
                    continue
                }
                if line.contains(Parameter.generateReport.name) {
                    generateReport = try parseBool(from: line, separator: Parameter.generateReport.name)
                    continue
                }
                if line.contains(Parameter.verifyOnly.name) {
                    verifyOnly = try parseBool(from: line, separator: Parameter.verifyOnly.name)
                    continue
                }
            }
        } catch {
            throw error
        }

        let config = ConfigArguments(modules: modules,
                                     phrase: phrase,
                                     swiftgen: swiftgen,
                                     verificationSource: verificationSource,
                                     generateReport: generateReport,
                                     verifyOnly: verifyOnly)
        return config
    }

    private func parsePath(from text: String, separator: String) throws -> String {
        let split = text.replacingOccurrences(of: " ", with: "").components(separatedBy: "\(separator):")

        guard split.count > 1 else {
            throw ParsingError.invalidFormat(line: text)
        }

        return split[1]
    }

    func parseBool(from text: String, separator: String) throws -> Bool {
        let split = text.replacingOccurrences(of: " ", with: "").components(separatedBy: "\(separator):")

        guard split.count > 1 else {
            throw ParsingError.invalidFormat(line: text)
        }

        guard let value = Bool(split[1]) else {
            throw ParsingError.boolFormat(line: text)
        }
        return value
    }

    private func parseModules(from text: String) throws -> [String] {
        let split = text.replacingOccurrences(of: " ", with: "").components(separatedBy: "modules:")
        guard split.count > 1 else { return [] }

        return split[1].components(separatedBy: ",")
    }
}

// MARK: - ConfigParameters

extension LocalizationConfigParser {

    struct ConfigArguments: Equatable {
        var modules: [String]
        var phrase: String
        var swiftgen: String
        var verificationSource: String
        var generateReport: Bool
        var verifyOnly: Bool
    }
}

// MARK: - ParsingError

extension LocalizationConfigParser {

    enum ParsingError: Error, CustomStringConvertible, Equatable {
        case invalidFormat(line: String)
        case boolFormat(line: String)

        var description: String {
            switch self {
            case let .invalidFormat(line):
                return "Invalid format for line: \(line)"
            case let .boolFormat(line):
                return "Wrong format for boolean on line: \(line)"
            }
        }
    }
}
