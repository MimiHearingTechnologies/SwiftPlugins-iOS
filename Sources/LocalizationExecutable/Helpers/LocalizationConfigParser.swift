//
//  File.swift
//  
//
//  Created by Kosta Nedeljkovic on 15/11/2023.
//

import Foundation

enum ParsingError: Error, CustomStringConvertible {
    case wrongFormat(line: String)

    var description: String {
        switch self {
        case .wrongFormat:
            return ""
        }
    }
}

struct LocalizationConfigParser {

    enum Parameter: String {
        case phrase, swiftgen, modules
    }

    var text: String

    func parse() throws -> ConfigParameters {
        var modules: [String] = []
        var phrase: String = ""
        var swiftgen: String = ""

        let lines = text.replacingOccurrences(of: " ", with: "").components(separatedBy: CharacterSet.newlines)
        do {
            for line in lines {
                if line.contains(Parameter.modules.rawValue) {
                    modules = try parseModules(from: line)
                    continue
                }
                if line.contains(Parameter.phrase.rawValue) {
                    phrase = try parsePath(from: line, separator: Parameter.phrase.rawValue)
                    continue
                }
                if line.contains(Parameter.swiftgen.rawValue) {
                    swiftgen = try parsePath(from: line, separator: Parameter.swiftgen.rawValue)
                    continue
                }
            }
        } catch {
            throw error
        }

        let config = ConfigParameters(modules: modules, phrase: phrase, swiftgen: swiftgen)
        return config
    }

    private func parsePath(from text: String, separator: String) throws -> String {
        let split = text.components(separatedBy: "\(separator):")

        guard split.count > 1 else {
            throw ParsingError.wrongFormat(line: text)
        }

        return split[1]
    }

    private func parseModules(from text: String) throws -> [String] {
        let split = text.components(separatedBy: "modules:")
        guard split.count > 1 else { return [] }

        return split[1].components(separatedBy: ",")
    }
}

struct ConfigParameters {
    var modules: [String]
    var phrase: String
    var swiftgen: String
}
