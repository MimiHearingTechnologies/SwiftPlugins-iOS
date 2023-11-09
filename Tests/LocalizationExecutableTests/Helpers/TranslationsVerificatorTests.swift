//
//  TranslationsVerificatorTests.swift
//  
//
//  Created by Salar on 10/30/23.
//

import XCTest
@testable import LocalizationExecutable

final class TranslationsVerificatorTests: XCTestCase {

    func test_init_throwsErrorOnEmptyModules() {
        do {
            _ = try TranslationsVerificator(with: [])
            XCTFail("Expected `VerificationError.noModulesProvided` error, but we succeeded instead.")
        } catch {
            XCTAssertEqual(error as! TranslationsVerificator.VerificationError, TranslationsVerificator.VerificationError.noModulesProvided)
        }
    }

    func test_init_throwsErrorOnNonexistentSourceDir() {
        let nonExistentPath = UUID().uuidString

        do {
            _ = try TranslationsVerificator(with: ["TestModule"], sourceDir: nonExistentPath)
            XCTFail("Expected `VerificationError.sourceDirNotFound` error, but we succeeded instead.")
        } catch {
            XCTAssertEqual(error as! TranslationsVerificator.VerificationError, TranslationsVerificator.VerificationError.sourceDirNotFound(path: nonExistentPath))
        }
    }

}
