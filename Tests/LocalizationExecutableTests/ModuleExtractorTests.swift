//
//  ModuleExtractorTests.swift
//  
//
//  Created by Kosta Nedeljkovic on 15/11/2023.
//

import XCTest
@testable import LocalizationExecutable

final class ModuleExtractorTests: XCTestCase {

    func test_extract_returnsEmptyArrayForEmptyText() {
        let sut = LocalizationExecutable.ModuleExtractor(text: "")

        XCTAssertEqual(sut.extractModules(), [])
    }

    func test_extract_returnsEmptyArrayForTextInWrongOrder() {
        let text = """
            Should be on top

            #MODULES:A,B,C
        """

        let sut = LocalizationExecutable.ModuleExtractor(text: text)

        XCTAssertEqual(sut.extractModules(), [])
    }

    func test_extract_returnsModulesForCorrectText() {
        let text = """
            #MODULES: A, B, C
        """

        let sut = LocalizationExecutable.ModuleExtractor(text: text)

        XCTAssertEqual(sut.extractModules(), ["A", "B", "C"])
    }

    func test_extract_returnsModulesForTextWithoutSpaces() {
        let text = """
            #MODULES:A,B,C
        """

        let sut = LocalizationExecutable.ModuleExtractor(text: text)

        XCTAssertEqual(sut.extractModules(), ["A", "B", "C"])
    }

}
