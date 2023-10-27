//
//  LocalizationExecutableTests.swift
//  
//
//  Created by Kosta Nedeljkovic on 27/10/2023.
//

import XCTest
@testable import LocalizationExecutable
@testable import Execution

#if os(macOS)
final class LocalizationExecutableTests: XCTestCase {

    func test_verifyTranslationsEmptyModulesError() {
        do {
            try LocalizationExecutable.verifyTranslations(modules: [])
        } catch {
            XCTAssertEqual(error as! VerificationError, VerificationError.noModulesProvided)
            return
        }

        XCTFail("Expected `VerificationError.noModulesProvided` error`")
    }

}
#endif
