// INFO
//
// The script takes one argument: "generateReportFile".
// If the argument is not given, the script does not generate report file.

import Foundation

let generateReportFileArgumentName = "generateReportFile"

// MARK: Log

var reportLog: [String] = []

func log(_ message: String, type: LogType = .debug) {
    print(message)
    if type == .report {
        reportLog.append(message)
    }
}

enum LogType {
    case report
    case debug
}

// MARK: TranslationsVerificator

class TranslationsVerificator {

    let localizableFileName = "Localizable.strings"
    let sourcesDirectory = "."
    let referenceLanguageCode = "en"
    let reportFilePath = "TranslationsVerificationReport"

    let fileHelper = FileHelper()
    let localizableStringsFileParser = LocalizableStringsFileParser()

    func verifyTranslations(shouldGenerateReportFile: Bool = false) {
        var results: [(VerificationResult, Module)] = []
        log("---")
        log("📖 📖 📖 Starting verification for missing translations... 📖 📖 📖\n")
        Module.allSupportedForLocalization.forEach {
            log("📦 📦 Module: \($0.rawValue) 📦 📦\n", type: .report)
            let result = verify(module: $0)
            results.append((result, $0))
            log("\n", type: .report)
        }

        if results.map({ $0.0 }).contains(.failure) {
            let failedModulesList = results.filter { $0.0 == .failure }
            log("\n\n ❌ Verification failed for modules: \(failedModulesList.map{ "'\($0.1.rawValue)'" }.joined(separator: ", "))", type: .report)

            if shouldGenerateReportFile {
                let logString = reportLog.joined(separator: "\n")
                fileHelper.writeToFile(string: logString, path: reportFilePath, encoding: .utf8)
            }
            exit(1)
        }
    }
}

private extension TranslationsVerificator {

    func localizableFilesPaths() -> [FileHelper.FileURL] {
        fileHelper.filePaths(in: sourcesDirectory, forFile: localizableFileName)
    }

    func filterPaths(for modules: [Module], from paths: [FileHelper.FileURL]) -> [FileHelper.FileURL] {
        paths
            .map { fileUrl in
                let firstComponent: () -> String? = {
                    if let url = URL(string: fileUrl.relative), let firstPathComponent = url.pathComponents.first {
                        return firstPathComponent
                    } else {
                        return nil
                    }
                }
                return (fileUrl, firstComponent())
            }
            .filter { (fileUrl, module) in module != nil }
            .filter { (fileUrl, module) in modules.map{$0.rawValue}.contains(module) }.map { $0.0 }
    }

    func verify(module: Module) -> VerificationResult {
        var result = VerificationResult.success

        let files = localizableFiles(for: module)

        guard let reference = files.first(where: { $0.languageCode == referenceLanguageCode }) else {
            log("❌ Reference file for module '\(module.rawValue)' does not exist. Expected language code: '\(referenceLanguageCode)'", type: .report)
            return .failure
        }
        let toBeVerified = files.filter { !["en", "Base"].contains($0.languageCode) }

        toBeVerified.forEach { file in
            let keysForMissingTranslations = Set(reference.elements.map { $0.key }).subtracting(Set(file.elements.map { $0.key }))

            if !keysForMissingTranslations.isEmpty {
                log("❌ Missing translations found in `\(module.rawValue)` module for language code '\(file.languageCode)'. List of missing keys:", type: .report)
                var dumpString = String()
                dump(keysForMissingTranslations, to: &dumpString)
                log(dumpString, type: .report)
                result = .failure
            } else {
                log("✅ No missing translations found in `\(module.rawValue)` module for language code '\(file.languageCode)' 👏 \n")
            }
        }

        if result == .success {
            log("✅ All good in '\(module.rawValue)' module 👏", type: .report)
        }
        return result
    }

    func localizableFiles(for module: Module) -> [LocalizableFile] {
        let paths = filterPaths(for: [module], from: localizableFilesPaths())
        var files: [LocalizableFile] = []
        paths.forEach { path in
            guard
                let url = URL(string: path.absolute),
                let lproj = url.pathComponents.first(where: { $0.hasSuffix(".lproj") }),
                let languageCode = lproj.components(separatedBy: ".").first,
                let file = fileHelper.readFile(path: path.absolute)
            else {
                return
            }

            let elements = localizableStringsFileParser.parse(fileContents: file)

            files.append(LocalizableFile(languageCode: languageCode, elements: elements))
        }
        return files
    }
}

private extension TranslationsVerificator {

    enum VerificationResult {
        case success
        case failure
    }
}

// MARK: Models

enum Module: String {
    case mimiSDK = "MimiSDK"
    case mimiAuthKit = "MimiAuthKit"
    case mimiTestKit = "MimiTestKit"
    case examples = "Examples"

    static var allSupportedForLocalization: [Module] {
        [
            .mimiSDK,
            .mimiAuthKit,
            .mimiTestKit
        ]
    }
}

struct LocalizableElement {
    let key: String
    let value: String
}

struct LocalizableFile {
    let languageCode: String
    let elements: [LocalizableElement]
}

// MARK: FileHelper

class FileHelper {

    typealias FileURL = (relative: String, absolute: String)

    func filePaths(in directory: String, forFile name: String) -> [FileURL] {

        let manager = FileManager.default
        var files = [FileURL]()
        manager.enumerator(atPath: directory)?.forEach {
            guard
                let string = $0 as? String,
                let url = URL(string: string),
                url.lastPathComponent == name
            else { return }

            files.append((url.absoluteString, directory + "/" + url.absoluteString))
        }

        return files
    }

    func readFile(path: String) -> String? {
        try? String(contentsOfFile: path)
    }

    func writeToFile(string: String, path: String, encoding: String.Encoding) {

        do {
            try string.write(
                toFile: path,
                atomically: true,
                encoding: encoding
            )
        } catch {
            if (error as NSError).code == 4 { // directory does not exist
                do {
                    let url = URL(fileURLWithPath: path).deletingLastPathComponent()
                    try FileManager.default.createDirectory(
                        atPath: url.absoluteString.replacingOccurrences(of: "file://", with: ""),
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                    writeToFile(string: string, path: path, encoding: encoding)
                } catch {
                    log("\(error)")
                    log("Could not write to file: \(path)\n\(string)")
                }
            } else {
                log("Could not write to file: \(path)\n\(string)")
            }
        }
    }
}


// MARK: LocalizableStringsFileParser

class LocalizableStringsFileParser {

    let regex = "\"(.*)\"[ ]*=[ ]*\"(.*)\";"

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
            log("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
