//
//  LocalizationConfigParserTests.swift
//
//
//  Created by Kosta Nedeljkovic on 15/11/2023.
//

import XCTest
@testable import LocalizationExecutable

final class LocalizationConfigParserTests: XCTestCase {

    func test_parse_emptyTextConfig() {
        let sut = LocalizationConfigParser(text: "")

        let expected = defaultParsed
        let result = try? sut.parse()

        XCTAssertEqual(result, expected)
    }

    func test_parse_validTextConfig() {
        let text = """
            phrase: .phrase.yml
            swiftgen: SwiftGen/swiftgen-localization.yml
            modules: A, B, C
            verification-source: ./verification/path
            verify-only: false
            generate-report: true
        """
        let sut = LocalizationConfigParser(text: text)
        let expected = LocalizationConfigParser.ConfigArguments(modules: ["A", "B", "C"],
                                                                phrase: ".phrase.yml",
                                                                swiftgen: "SwiftGen/swiftgen-localization.yml",
                                                                verificationSource: "./verification/path",
                                                                generateReport: true,
                                                                verifyOnly: false)

        let result = try? sut.parse()

        XCTAssertEqual(result, expected)
    }

    func test_parse_missingColonTextThrowsError() {
        let text = """
            phrase .phrase.yml
            swiftgen: SwiftGen/swiftgen-localization.yml
            """
        let sut = LocalizationConfigParser(text: text)

        do {
            let _ = try sut.parse()
            XCTFail()
        } catch {
            XCTAssertEqual(error as! LocalizationConfigParser.ParsingError, LocalizationConfigParser.ParsingError.invalidFormat(line: "phrase .phrase.yml"))
        }
    }

    func test_parse_invalidBooleanTextThrowsError() {
        let text = """
            verify-only: tru
            swiftgen: SwiftGen/swiftgen-localization.yml
            """
        let sut = LocalizationConfigParser(text: text)

        do {
            let _ = try sut.parse()
            XCTFail("Expected `ParsingError.boolFormat`")
        } catch {
            XCTAssertEqual(error as! LocalizationConfigParser.ParsingError, LocalizationConfigParser.ParsingError.invalidBoolFormat(line: "verify-only: tru"))
        }
    }

    // MARK: - Helpers

    private var defaultParsed: LocalizationConfigParser.ConfigArguments {
        LocalizationConfigParser.ConfigArguments(modules: [],
                                                 phrase: ".phrase.yml",
                                                 swiftgen: "swiftgen.yml",
                                                 verificationSource: ".",
                                                 generateReport: false,
                                                 verifyOnly: false)
    }

}
