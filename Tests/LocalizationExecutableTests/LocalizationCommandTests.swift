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

        XCTAssertEqual(phraseCommand.cmd, "/opt/homebrew/bin/phrase pull --config configPath")
    }

    func test_phraseCommandInitWithEmptyConfig() throws {
        let phraseCommand = LocalizationExecutable.LocalizationCommand.pullPhrase(config: "")

        XCTAssertEqual(phraseCommand.cmd, "/opt/homebrew/bin/phrase pull")
    }

    func test_localizationCommandInitWithConfig() throws {
        let localizationCommand = LocalizationExecutable.LocalizationCommand.generateLocalization(config: "configPath")

        XCTAssertEqual(localizationCommand.cmd, "/opt/homebrew/bin/swiftgen config run --verbose --config configPath")
    }

    func test_localizationCommandInitWithEmptyConfig() throws {
        let localizationCommand = LocalizationExecutable.LocalizationCommand.generateLocalization(config: "")

        XCTAssertEqual(localizationCommand.cmd, "/opt/homebrew/bin/swiftgen config run --verbose")
    }

}
