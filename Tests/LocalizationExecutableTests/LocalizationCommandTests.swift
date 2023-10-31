//
//  ExecutableCommandTests.swift
//
//
//  Created by Kosta Nedeljkovic on 26/10/2023.
//

import XCTest
@testable import ArgumentParser
@testable import LocalizationExecutable


final class LocalizationCommandTests: XCTestCase {

    func test_phraseCommandInitWithConfig() throws {
        let phraseCommand = LocalizationExecutable.LocalizationCommand.pullPhrase(config: "configPath")

        XCTAssertEqual(phraseCommand.cmdPath, "/opt/homebrew/bin/phrase")
        XCTAssertEqual(phraseCommand.args, "pull --config configPath")
    }

    func test_phraseCommandInitWithEmptyConfig() throws {
        let phraseCommand = LocalizationExecutable.LocalizationCommand.pullPhrase(config: "")

        XCTAssertEqual(phraseCommand.cmdPath, "/opt/homebrew/bin/phrase")
        XCTAssertEqual(phraseCommand.args, "pull")
    }

    func test_localizationCommandInitWithConfig() throws {
        let localizationCommand = LocalizationExecutable.LocalizationCommand.generateLocalization(config: "configPath")

        XCTAssertEqual(localizationCommand.cmdPath, "/opt/homebrew/bin/swiftgen")
        XCTAssertEqual(localizationCommand.args, "config run --verbose --config configPath")
    }

    func test_localizationCommandInitWithEmptyConfig() throws {
        let localizationCommand = LocalizationExecutable.LocalizationCommand.generateLocalization(config: "")

        XCTAssertEqual(localizationCommand.cmdPath, "/opt/homebrew/bin/swiftgen")
        XCTAssertEqual(localizationCommand.args, "config run --verbose")
    }
}
