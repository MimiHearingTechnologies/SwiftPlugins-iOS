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

//    func test_verifyTranslationsEmptyModulesError() {
//        do {
//            try LocalizationExecutable.verifyTranslations(modules: [])
//        } catch {
//            XCTAssertEqual(error as! TranslationsVerificator.VerificationError, TranslationsVerificator.VerificationError.noModulesProvided)
//            return
//        }
//
//        XCTFail("Expected `VerificationError.noModulesProvided` error`")
//    }

    func test() {
        do {
            _ = try TranslationsVerificator(with: [])
        } catch {
            print(error)
            XCTAssertEqual(error as! TranslationsVerificator.VerificationError, TranslationsVerificator.VerificationError.noModulesProvided)
        }
    }
    
}
