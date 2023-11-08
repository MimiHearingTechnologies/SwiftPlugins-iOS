// INFO
//
// The script takes one argument: "generateReportFile".
// If the argument is not given, the script does not generate report file.

import Foundation

class TranslationsVerificator {

    private let localizableFileName = "Localizable.strings"
    private let sourceDir: String
    private let referenceLanguageCode = "en"
    private let reportFilePath = "TranslationsVerificationReport"
    private let fileHelper = FileHelper()
    private let localizableStringsFileParser = LocalizableStringsFileParser()
    private let logger = Logger()
    
    private let modules: [String]
    
    enum VerificationError: Error, CustomStringConvertible {
        case noModulesProvided

        var description: String {
            switch self {
            case .noModulesProvided:
                return "❌ No modules provided, verifying translations failed."
            }
        }
    }

    init(with modules: [String], sourceDir: String) throws {
        guard !modules.isEmpty else {
            throw TranslationsVerificator.VerificationError.noModulesProvided
        }
        self.modules = modules
        self.sourceDir = sourceDir
    }

    func verifyTranslations(shouldGenerateReportFile: Bool = false) {
        var results: [(VerificationResult, String)] = []
        logger.log("---")
        logger.log("📖 📖 📖 Starting verification for missing translations... 📖 📖 📖\n")
        modules.forEach {
            logger.log("📦 📦 Module: \($0) 📦 📦\n", type: .report)
            let result = verify(module: $0)
            results.append((result, $0))
            logger.log("\n", type: .report)
        }

        if results.map({ $0.0 }).contains(.failure) {
            let failedModulesList = results.filter { $0.0 == .failure }
            logger.log("\n\n ❌ Verification failed for modules: \(failedModulesList.map{ "'\($0.1)'" }.joined(separator: ", "))", type: .report)

            if shouldGenerateReportFile {
                let log = logger.generateReport()
                fileHelper.writeToFile(string: log, path: reportFilePath, encoding: .utf8)
            }
            exit(1)
        }
    }
}

private extension TranslationsVerificator {

    func localizableFilesPaths() -> [FileHelper.FileURL] {
        fileHelper.filePaths(in: sourceDir, forFile: localizableFileName)
    }

    func filterPaths(for modules: [String], from paths: [FileHelper.FileURL]) -> [FileHelper.FileURL] {
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
            .filter { (fileUrl, module) in modules.map{$0}.contains(module) }.map { $0.0 }
    }

    func verify(module: String) -> VerificationResult {
        var result = VerificationResult.success

        let files = localizableFiles(for: module)

        guard let reference = files.first(where: { $0.languageCode == referenceLanguageCode }) else {
            logger.log("❌ Reference file for module '\(module)' does not exist. Expected language code: '\(referenceLanguageCode)'", type: .report)
            return .failure
        }
        let toBeVerified = files.filter { !["en", "Base"].contains($0.languageCode) }

        toBeVerified.forEach { file in
            let keysForMissingTranslations = Set(reference.elements.map { $0.key }).subtracting(Set(file.elements.map { $0.key }))

            if !keysForMissingTranslations.isEmpty {
                logger.log("❌ Missing translations found in `\(module)` module for language code '\(file.languageCode)'. List of missing keys:", type: .report)
                var dumpString = String()
                dump(keysForMissingTranslations, to: &dumpString)
                logger.log(dumpString, type: .report)
                result = .failure
            } else {
                logger.log("✅ No missing translations found in `\(module)` module for language code '\(file.languageCode)' 👏 \n")
            }
        }

        if result == .success {
            logger.log("✅ All good in '\(module)' module 👏", type: .report)
        }
        return result
    }

    func localizableFiles(for module: String) -> [LocalizableFile] {
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
