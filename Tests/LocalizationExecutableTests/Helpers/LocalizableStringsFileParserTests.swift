//
//  LocalizableStringsFileParserTests.swift
//  
//
//  Created by Salar on 10/30/23.
//

import XCTest
@testable import LocalizationExecutable

final class LocalizableStringsFileParserTests: XCTestCase {
    private let invalidContent = "invalid key value"
    private let validContent = "\"key\"=\"value\";"

    func test_parse_returnsEmptyOnInvalidContent() {
        let sut = LocalizableStringsFileParser()
        
        let result = sut.parse(fileContents: invalidContent)
        
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_parse_returnsElementsOnValidContent() {
        let sut = LocalizableStringsFileParser()
        
        let result = sut.parse(fileContents: validContent)
        
        XCTAssertEqual(result, [LocalizableElement(key: "key", value: "value")])
    }
}
                       
extension LocalizableElement: Equatable {
    public static func == (lhs: LocalizableElement, rhs: LocalizableElement) -> Bool {
        lhs.key == rhs.key && lhs.value == rhs.value
    }
}
