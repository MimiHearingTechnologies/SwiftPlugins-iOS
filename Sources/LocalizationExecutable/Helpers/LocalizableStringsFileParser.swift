//
//  LocalizableStringsFileParser.swift
//  
//
//  Created by Salar on 10/30/23.
//

import Foundation

class LocalizableStringsFileParser {

    private let regex = "\"(.*)\"[ ]*=[ ]*\"(.*)\";"
    private let logger = Logger()

    func parse(fileContents: String) -> [LocalizableElement] {

        let matchingStrings = matches(for: regex, in: fileContents)

        let elements: [LocalizableElement] = matchingStrings
            .map {
                let firstElement = $0.propertyListFromStringsFileFormat().first
                let key = firstElement?.key ?? ""
                let value = firstElement?.value ?? ""

                return LocalizableElement(key: key, value: value)
            }

        return elements
    }

    private func matches(for regex: String, in text: String) -> [String] {

        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map { String(text[Range($0.range, in: text)!]) }
        } catch let error {
            logger.log("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
