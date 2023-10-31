//
//  LocalizationExecutableTests.swift
//  
//
//  Created by Kosta Nedeljkovic on 27/10/2023.
//

import XCTest
@testable import LocalizationExecutable
@testable import Execution

final class LocalizationExecutableTests: XCTestCase {

    func test_verifyTranslationsEmptyModulesError() {
        do {
            _ = try TranslationsVerificator(with: [])
            XCTFail("Expected `VerificationError.noModulesProvided` error`")
        } catch {
            XCTAssertEqual(error as! TranslationsVerificator.VerificationError, TranslationsVerificator.VerificationError.noModulesProvided)
        }
    }
    
}
