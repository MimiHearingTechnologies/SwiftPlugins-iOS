//
//  ShellCommandTests.swift
//  
//
//  Created by Salar on 10/30/23.
//

import XCTest
@testable import Execution

final class ShellCommandTests: XCTestCase {

    func test_parameters() {
        let sut = ShellCommand(commandPath: "path", arguments: "args")
        
        XCTAssertEqual(sut.commandPath, "path")
        XCTAssertEqual(sut.arguments, "args")
        XCTAssertEqual(sut.fullPath, "path args")
    }
}
